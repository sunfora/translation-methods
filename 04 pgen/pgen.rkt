#lang racket
(require (for-syntax racket/syntax))
(require (for-syntax racket/struct-info))
(require (for-syntax racket/list))
(require (for-syntax racket/dict))
(require (for-syntax racket/set))
(require (for-syntax racket/match))
(require (for-syntax racket/sequence))
(require (for-syntax racket/bool))
(require (for-syntax syntax/stx))
(require racket/match)
(require racket/provide-syntax)

(begin-for-syntax
  (define (get-pred stx)
    (list-ref 
      (extract-struct-info (syntax-local-value stx))
      2))
  (define (get-fields stx)
    (define (flds stx)
      (struct-field-info-list 
              (syntax-local-value stx)))
    (let loop ([cur stx]
               [fields '()])
      (if (eq? #t cur)
        (reverse fields)
        (loop (get-super cur) (append fields (flds cur))))))
  (define (get-setters stx)
    (reverse
      (list-ref  
        (extract-struct-info (syntax-local-value stx))
        4)))
  (define (get-getters stx)
    (reverse
      (list-ref  
        (extract-struct-info (syntax-local-value stx))
        3)))
  (define (get-super stx)
    (list-ref
      (extract-struct-info (syntax-local-value stx))
      5))

  (define (symbol-ref x i)
    (string-ref (symbol->string x) 0))

  (define (is-dotted? stx)
    (and (identifier? stx)
         (eq? (symbol-ref (syntax->datum stx) 0) #\.))))

(define-for-syntax (bind-as expr)
  (with-syntax ([expr expr])
    (λ (stx)
        (syntax-case stx ()
          [(xid terms ...) #'(expr terms ...)]
          [xid (identifier? #'xid) #'expr]))))

(define-syntax (construct-with stx)
  (syntax-case stx ()
    [(_ st-name value)
     #`(st-name #,@(for/list ([i (get-fields #'st-name)])
                     #'value))]))

(define-for-syntax (grab-from-form pred?)
  (λ (stx)
    (syntax-case stx ()
      [(name exprs ...)
       (for/list ([expr  (syntax-e  #'(exprs ...))]
                  [field (get-fields     #'name)]
                  [get   (get-getters    #'name)]
                  [set   (get-setters    #'name)]
                  #:when (pred? expr))
         (list #'name field get set expr))])))

(define-for-syntax (grab-with-ctors pred?)
  (λ (stx ctors)
    (with-syntax ([(forms ...) stx])
       (append* (map (λ ($ forms) (map (λ (x) (cons $ x)) forms))
                   (syntax-e ctors)
                   (map (grab-from-form pred?)
                        (syntax-e #'(forms ...))))))))

(define-syntax (with-syntax-lets stx)
  (define (undot dotted)
    (let* ([datum    (syntax->datum dotted)]
           [str      (symbol->string datum)]
           [undot    (substring str 1)])
      (format-id dotted "~a" undot)))
  (define (force-dotted place name field get set expr)
    (with-syntax* ([id (undot expr)]
                   [get get]
                   [place place])
      #'[id (bind-as #'(force (get place)))]))
  (define (gen-lambdas stx ctors)
      (map (λ (j) (apply force-dotted j)) 
           ((grab-with-ctors is-dotted?) stx ctors)))
  (define (gen-starred stx ctors)
    (define (star place)
      (λ (field)
        (format-id place "~a-~a*" place field)))

    (with-syntax* ([(ctor ...) ctors]
                   [((form-name _ ...) ...) stx]
                   [(part ...) #'((form-name ctor) ...)])
      (flatten
        (for/list ([j (syntax-e #'(part ...))])
          (with-syntax* ([(form-name place) j])
              (define fields  (get-fields  #'form-name))
              (define getters (get-getters #'form-name))
              (define starred (map (star #'place) fields))
              (list
                (with-syntax* ([(get ...) getters]
                               [starred-place (format-id #'place "~a*" #'place)])
                  #'[starred-place (bind-as (syntax (form-name (force (get place)) ...)))])
                (for/list ([id starred]
                           [get getters])
                  (with-syntax* ([id id] [get get])
                    #'[id (bind-as #'(force (get place)))]))))))))
  (syntax-case stx ()
    [(_ [head [form ...]] 
        [head-ctor [form-ctor ...]] 
        body ...)
     (begin
       (with-syntax* ([forms #'(head form ...)]
                      [ctors #'(head-ctor form-ctor ...)]
                      [(dotted ...) (gen-lambdas #'forms #'ctors)]
                      [(starred ...) (gen-starred #'forms #'ctors)])
         #'(let-syntax (dotted  ...
                        starred ...)
               body ...)))]))

(define-syntax (with-delayed stx)
  (define (not-dotted? x) (not (is-dotted? x)))
  (define (delayed-set place name field get set expr)
    #`(#,set #,place (delay #,expr)))
  (define (gen-sets stx ctors)
    (datum->syntax 
      stx 
      (map (λ (j) (apply delayed-set j)) 
           ((grab-with-ctors not-dotted?) stx ctors))))
  (syntax-case stx ()
    [(_ [head [form ...]] 
        [head-ctor [form-ctor ...]] 
        body ...)
     (with-syntax* ([forms #'(head form ...)]
                    [ctors #'(head-ctor form-ctor ...)]
                    [sets (gen-sets #'forms #'ctors)])
       #'(begin 
             (~@ . sets)
             body ...))]))

(define-syntax-rule (with-constructors [head [(st-name _ ...) ...]] 
                                       [head-ctor [form-ctor ...]] 
                                       body ...)
  (let* ([form-ctor (construct-with st-name '())] ...)
    body ...))


(define-syntax-rule (surround-body rule ctors body ...)
  (with-constructors rule ctors
    (with-syntax-lets rule ctors 
       (with-delayed  rule ctors
                      body ...))))

(define-syntax-rule (syntax-displayln form)
  (displayln (expand-once #'form)))
(define-syntax-rule (for-syntax-displayln form ...)
  (let-syntax ([x (λ (stx)
                    (displayln form) ...
                    #'(void))])
    x))


(define-for-syntax (make-resolver donate)
  (λ (qv)
    (define stx (datum->syntax donate qv donate))
    (let loop ([cur stx]
               [next (get-super stx)])
      (if (eq? next #t)
        (syntax->datum cur)
        (loop next (get-super next))))))

(define-for-syntax (grammar->rules grammar)
  (map append
    (syntax->datum
     (syntax-case grammar ()                                      
       [([(sth _ ... ) [(stf _ ...) ...]] ...)
        #'([sth [stf ...]] ...)]))
    (map list (syntax-e grammar))))

(define-for-syntax (compute-first kind rules)
  (define changed? #f)
  (define FIRST (make-hash))
  (define (ref! nterm)
    (dict-ref! FIRST nterm (mutable-set)))
  (define (upd! nterm v)
    (define n-set (ref! nterm))
    (for ([m v])
      (when (not (set-member? n-set m))
        (set! changed? #t)
        (set-add! n-set m))))

  (define (first list-of-symbols)
    (let/ec return
      (when (empty? list-of-symbols)
        (return (set 'ε)))
      (match-let ([(list a rest ...) list-of-symbols])
        (define set-a
            (case (kind a)
              [(token) (set a)]
              [(nterm) (ref! a)]
              [else (raise-syntax-error 
                      #f 
                      "unexpected kind")]))
        (if (set-member? set-a 'ε)
          (set-union (first rest) set-a)
          set-a))))

  (let compute []
    (set! changed? #f)
    (for ([rule rules])
      (match-let ([(list A a) rule])
        (upd! A (first a))))
    (when changed?
      (compute)))
  (for ([(k v) FIRST])
    (dict-set! FIRST k (for/set ([i v]) i)))
  first)

(define-for-syntax (compute-follow start first kind rules)
  (define changed? #f)
  (define FOLLOW (make-hash))
  (define (ref! nterm)
    (dict-ref! FOLLOW nterm (mutable-set)))
  (define (upd! nterm v)
    (define n-set (ref! nterm))
    (for ([m v]
          #:unless (eq? m 'ε))
      (when (not (set-member? n-set m))
        (set! changed? #t)
        (set-add! n-set m))))

  (define follow ref!)

  (define (nterm? B)
    (eq? (kind B) 'nterm))

  (upd! start (set '$))
  (let compute []
    (set! changed? #f)
    (for ([rule rules])
      (match-let ([(list A α) rule])
        (for ([(B γ) (with-tail α)]
              #:when (nterm? B))
          
          (let* ([first-γ   (first γ)]
                 [has-ε?    (set-member? first-γ 'ε)])
            (upd! B first-γ)
            (when has-ε?
              (upd! B (follow A)))))))
    (when changed?
      (compute)))
  (for ([(k v) FOLLOW])
    (dict-set! FOLLOW k (for/set ([i v]) i)))
  follow)


(define-for-syntax (with-tail lst)
  (make-do-sequence
   (lambda ()
     (initiate-sequence
      #:pos->element (lambda (s) (values (car s) (cdr s)))
      #:next-pos cdr
      #:init-pos lst
      #:continue-with-pos? pair?))))

(define-syntax (make-parser stx)
  (syntax-case stx ()
    [(_ {
        [lexer lexer-name/body]
        [grammar #:start-with start
           grammar-rule ... ]
       })
     (begin 
       (unless (eq? (syntax->datum #'grammar) 'grammar)
         (raise-syntax-error #f "expected literal `grammar`" #'grammar))
       (unless (eq? (syntax->datum #'lexer) 'lexer)
         (raise-syntax-error #f "expected literal `lexer`"   #'lexer))

       (let* ([donate #'grammar]
              [resolver (make-resolver donate)]
              [rules*   (grammar->rules  #'(grammar-rule ...))]
              [rules    (map (λ (x) (list (car x)
                                          (cadr x)))
                             rules*)]
              [first    (compute-first   resolver rules)]
              [follow   (compute-follow  (syntax->datum #'start) 
                                         first resolver rules)]
              [grouped  (group-by car rules*)])

         (define (check A α β)
           (and (set-empty? (set-intersect (first α) (first β)))
                (or (not (set-member? (first α) 'ε))
                    (set-empty? (set-intersect (follow A) (first β))))))
         (define ll1? 
           (for/and ([group grouped])
             (for*/and ([rule-1 group]
                        [rule-2 group]
                        #:when (not (eq? rule-1 rule-2)))
               (check (car rule-1) 
                      (cadr rule-1) 
                      (cadr rule-2)))))
         (unless ll1?
           (raise-syntax-error #f "not a LL(1) grammar"))

         (define tokens
           (for/fold ([tokens (set)])
                     ([rule rules])
            (set-union 
              (for/set ([thing (cadr rule)]
                        #:when (eq? (resolver thing) 'token))
                thing)
              tokens)))

         (define defined (make-hash))

         (for ([token tokens])
           (with-syntax* ([stoken  (datum->syntax donate token)]
                          [expect-token (format-id donate "expect-~a" #'stoken)]
                          [place-token (format-id donate "$$")]
                          [token? (get-pred #'stoken)]
                          [(set-token-field! ...) (get-setters #'stoken)]
                          [(token-field! ...) (get-getters #'stoken)])
             (dict-set! defined 
                token 
                (cons #'expect-token 
                      #'(define (expect-token place-token)
                           (unless (token? cur)
                             (report place-token cur))
                           (set-token-field! place-token (token-field! cur)) 
                           ...
                           (take))))))


        (define (make-cases group parse-nterm place-nterm)
          (define (generate-body prod stx-rule)
            (define (get part)
              (if (dict-has-key? defined part)
                (car (dict-ref defined part))
                (format-id donate "parse-~a" part)))
            (with-syntax 
              ([the-rule stx-rule]
               [parse-nterm parse-nterm]
               [place-nterm place-nterm]
               [funcs (map get prod)]
               [places (for/list ([x prod] 
                                  [i (in-naturals)]) 
                         (format-id stx-rule "$~a" (+ 1 i)))])
                #'(body-from-rule the-rule
                                  [place-nterm places]
                                  [parse-nterm funcs])))

          (define has-else? #f)

          (define (case-cond prod)
            (define result (set->list (set-remove (first prod) 'ε)))
            (if (empty? result)
              (begin
                (set! has-else? #t)
                'else)
              result))

          (define without-error 
            (for/list ([rule group])
              (match-let ([(list name prod as-stx) rule])
                (with-syntax 
                  ([body (generate-body prod as-stx)]
                   [fst  (case-cond prod)])
                  #'[fst body]))))

          (if has-else?
            without-error
            (with-syntax ([parse-nterm parse-nterm]
                          [place-nterm place-nterm]
                          [(cases ...) without-error])
              #'(cases 
                  ...
                  [else (report place-nterm cur)]))))

        (for ([group grouped])
          (let ([nterm (car (car group))]
                [has-else? #f])
            (with-syntax*
              ([parse-nterm (format-id donate "parse-~a" nterm)]
               [place-nterm (format-id donate "$$")]
               [(cases ...) (make-cases group #'parse-nterm #'place-nterm)])
              (dict-set! defined 
                nterm
                (cons #'parse-nterm
                      #'(define (parse-nterm place-nterm)
                          (case (object-name cur)
                            cases ...)
                          ))))))

         (with-syntax* ([(define-thing ...) (for/list ([(k v) defined]) (cdr v))]
                        [parse-start (car (dict-ref defined (syntax->datum #'start)))]
                        [.... '...])
             #'(λ (in) 
                 (define lex (lexer-name/body in))
                 (define cur (lex))
                 (define (report expected got)
                     (error 'parse-error "expected ~s, but got ~s"
                            expected
                            got))
                (define (take) 
                    (let [(old cur)]
                      (set! cur (lex))
                      old))

                 define-thing ...

                 (define (as-values result)
                   (define fres (force result))
                   (struct-as-values start fres))

                 (as-values
                   (parse-start (construct-with start '())))))))]))



(define-syntax (struct-as-values stx)
  (syntax-case stx ()
    [(_ name object)
     (with-syntax ([(get ...) (get-getters #'name)])
       #'(values (force (get object)) ...))]))

(define-syntax-rule (body-from-rule
                      [head       (form       ...)]
                      [$$         ($i         ...)]
                      [parse-head (parse-form ...)])
  (surround-body [head       (form       ...)] 
                 [$$         ($i         ...)]
    (parse-form $i) ...
    (delay $$)))


(require macro-debugger/expand)
(define all-macro (list 'body-from-rule 
                        'make-parser
                        'surround-body
                        'with-constructors
                        'with-syntax-lets
                        'with-delayed
                        'construct-with
                        'struct-as-values
                        ))

(define (parser-expand stx)
  (syntax->datum (expand/show-predicate stx (λ (x) (memq (syntax-e x) all-macro)))))

(provide make-parser parser-expand)
(provide (for-syntax bind-as))
