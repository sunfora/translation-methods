#lang racket
(require (for-syntax racket/syntax))
(require (for-syntax racket/struct-info))
(require (for-syntax racket/list))
(require (for-syntax racket/dict))
(require (for-syntax racket/set))
(require (for-syntax racket/match))
(require (for-syntax racket/sequence))
(require (for-syntax racket/bool))
(require racket/match)
;(expr v) [(expr .a) (fold a .v)]
; (fold .a v) -> (expr .e) (fold (+ a e) .v)
; (fold .a a)

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
        (loop (get-super cur) (append (flds cur) fields)))))
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

(define-for-syntax (generate-special-parser-symbols llmap)
  (define n (length llmap))
  (for/list ([j llmap]
             [i (range 0 n)])
    (for/list ([form j])
      (cons 
        (format-id (car form) "$~a" (if (zero? i) "$" i))
        form))))

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
    (let ([id (undot expr)])
        #`[#,id (λ (stx)
                  (syntax-case stx ()
                    [#,id (identifier? (syntax #,id)) 
                     (syntax (force (#,get #,place)))]))]))
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
                (with-syntax ([(get ...) getters]
                              [starred-place (format-id #'place "~a*" #'place)])
                  #'[starred-place 
                      (λ (stx)
                        (syntax-case stx ()
                          [id (identifier? (syntax starred-place))
                              (syntax (form-name (force (get place)) ...))]))])
                (for/list ([id starred]
                           [get getters])
                  (with-syntax ([id id] [get get])
                    #'[id (λ (stx)
                            (syntax-case stx ()
                              [id (identifier? (syntax id))
                                  (syntax (force (get place)))]))]))))))))
  (syntax-case stx ()
    [(_ [head [form ...]] 
        [head-ctor [form-ctor ...]] 
        body ...)
     (with-syntax* ([forms #'(head form ...)]
                    [ctors #'(head-ctor form-ctor ...)]
                    [(dotted ...) (gen-lambdas #'forms #'ctors)]
                    [(starred ...) (gen-starred #'forms #'ctors)])
       #'(let-syntax (dotted  ...
                      starred ...)
             body ...))]))

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


(define-for-syntax (make-resolver grammar)
  (λ (qv)
    (syntax->datum (get-super (datum->syntax grammar qv)))))

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
  (syntax-case stx (tokens nterms grammar lexer)
    [(_ {
        [lexer lexer-name/body]
        [grammar #:start-with start
           grammar-rule ...]
       })
     (let* ([resolver (make-resolver   #'(grammar-rule ...))]
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
         (with-syntax* ([stoken  (datum->syntax stx token)]
                        [expect-token (format-id stx "expect-~a" #'stoken)]
                        [place-token (format-id stx "$$")]
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
              (format-id stx "parse-~a" part)))
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
            ([parse-nterm (format-id stx "parse-~a" nterm)]
             [place-nterm (format-id stx "$$")]
             [(cases ...) (make-cases group #'parse-nterm #'place-nterm)])
            (dict-set! defined 
              nterm
              (cons #'parse-nterm
                    #'(define (parse-nterm place-nterm)
                        (case (object-name cur)
                          cases ...)
                        ))))))

       (with-syntax* ([(define-thing ...) (for/list ([(k v) defined]) (cdr v))]
                      [parse-start (car (dict-ref defined (syntax->datum #'start)))])
           #'(λ (in) 
               (define lex (lexer-name/body in))
               (define cur (lex))
               (define (report expected got)
                   (error 'parse-error "at: ~s, expected ~s, but got ~s"
                          (token-pos cur)
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
                 (parse-start (construct-with start '()))))))]))

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

(require racket/generator)
(require racket/stxparam)

(struct nterm ()             #:transparent #:mutable)
(struct E   nterm (children) #:transparent #:mutable)
(struct Un  nterm (children) #:transparent #:mutable)
(struct Op1 nterm (children) #:transparent #:mutable)
(struct Op2 nterm (children) #:transparent #:mutable)
(struct Op3 nterm (children) #:transparent #:mutable)
(struct Op4 nterm (children) #:transparent #:mutable)
(struct Op5 nterm (children) #:transparent #:mutable)
(struct Pr  nterm (children) #:transparent #:mutable)
(struct E1  nterm (children) #:transparent #:mutable)
(struct C1  nterm (children) #:transparent #:mutable)
(struct E2  nterm (children) #:transparent #:mutable)
(struct C2  nterm (children) #:transparent #:mutable)
(struct E3  nterm (children) #:transparent #:mutable)
(struct C3  nterm (children) #:transparent #:mutable)
(struct E4  nterm (children) #:transparent #:mutable)
(struct C4  nterm (children) #:transparent #:mutable)
(struct E5  nterm (children) #:transparent #:mutable)
(struct C5  nterm (children) #:transparent #:mutable)

(struct token (pos text)      #:transparent #:mutable)
(struct end-of-input token () #:transparent #:mutable)
(struct op-neg       token () #:transparent #:mutable)
(struct op-mul       token () #:transparent #:mutable)
(struct op-plus      token () #:transparent #:mutable)
(struct op-and       token () #:transparent #:mutable)
(struct op-xor       token () #:transparent #:mutable)
(struct op-or        token () #:transparent #:mutable)
(struct variable     token () #:transparent #:mutable)
(struct open-paren   token () #:transparent #:mutable)
(struct close-paren  token () #:transparent #:mutable)
(struct violation    token () #:transparent #:mutable)

(require (for-syntax macro-debugger/expand))
(require macro-debugger/expand)
(syntax->datum
  (expand-only #'(make-parser {
                    [lexer lexer]
                    [grammar #:start-with E
                       [(Un  $1) [(op-neg )]]
                       [(Op1 $1) [(op-mul )]]
                       [(Op2 $1) [(op-plus)]]
                       [(Op3 $1) [(op-and )]]
                       [(Op4 $1) [(op-xor )]]
                       [(Op5 $1) [(op-or  )]]

                       [(Pr (list $1 $2)) [(Un) (Pr)]]
                       [(Pr (list $1 $2 $3)) [(open-paren) (E) (close-paren)]]
                       [(Pr $1) [(variable)]]
                      
                       [(E1 (list $1 $2)) [(Pr) (C1)]]
                       [(C1 (list $1 $2)) [(Op1) (E1)]]
                       [(C1 '()) []]

                       [(E2 (list $1 $2)) [(E1) (C2)]]
                       [(C2 (list $1 $2)) [(Op2) (E2)]]
                       [(C2 '()) []]

                       [(E3 (list $1 $2)) [(E2) (C3)]]
                       [(C3 (list $1 $2)) [(Op3) (E3)]]
                       [(C3 '()) []]

                       [(E4 (list $1 $2)) [(E3) (C4)]]
                       [(C4 (list $1 $2)) [(Op4) (E4)]]
                       [(C4 '()) []]

                       [(E5 (list $1 $2)) [(E4) (C5)]]
                       [(C5 (list $1 $2)) [(Op5) (E5)]]
                       [(C5 '()) []]

                       [(E $1*) [(E5)]]
                      ]
                  })
      (list #'body-from-rule 
            #'make-parser
            #'surround-body
            #'with-constructors
            #'with-syntax-lets
            #'with-delayed
            #'construct-with
            #'struct-as-values
            )))


; NOTE: не забудь чекнуть что оно не расходится
;       наверное можно как-то сделать умнее но пока так
(define operations '(#\! #\* #\+ #\& #\^ #\|))
(define (make-operation pos text)
  (define (classify text)
    (case text
      {["!"] (op-neg  pos text)}
      {["*"] (op-mul  pos text)}
      {["+"] (op-plus pos text)}
      {["&"] (op-and  pos text)}
      {["^"] (op-xor  pos text)}
      {["|"] (op-or   pos text)}
      {else (error 'make "unsupported operation type: ~s" text)}))
  (classify text))

; NOTE: не забудь чекнуть что оно не расходится
;       наверное можно как-то сделать умнее но пока так
(define parens '(#\( #\)))
(define (make-paren pos text) 
  (case text
    {["("] (open-paren pos text)}
    {[")"] (close-paren pos text)}
    {else (error 'make "weird paren type: ~s" text)}))


(define-syntax-parameter advance (syntax-rules ()))
(define-syntax-parameter retry (syntax-rules ()))

(define-syntax-rule (loop ((id expr #:then next) ...) body ...)
  (let loop [(id expr) ...]
    (syntax-parameterize
      ([advance (syntax-id-rules () [_ (loop next ...)])]
       [retry   (syntax-id-rules () [_ (loop id ...)])])
      (cond body ...))))
      
(define (lexer in)
  (define (op? x) (member x operations))
  (define (par? x) (member x parens))
  (define (var? x) (and (char? x) (or (char-alphabetic? x)
                                      (eq? x #\-)
                                      (eq? x #\_)
                                      )))
  (define skip? char-whitespace?)
  ; NOTE: короче вроде генераторы самый 
  ;       наитупейший варик тут сделать стримы
  ;
  ;       можно потом если чо сделать in-producer
  ;       и получить sequence
  ;
  ;       мы конечно мучаться не будем и этим нагло 
  ;       воспользуемся
  (generator ()
    (loop ([cur (read-char in) #:then (read-char in)]
           [pos 0              #:then (+ 1 pos)])
      {[eof-object? cur] 
        (end-of-input pos "")}
      {[skip? cur] 
        advance}
      {[op? cur]
        (yield (make-operation pos (string cur)))
        advance}
      {[var? cur]
        (yield 
          (variable pos 
            (loop ([varcur cur    #:then (read-char in)]
                   [varpos pos    #:then (+ 1 varpos)]
                   [buffer '()    #:then (cons varcur buffer)])
              {[var? varcur] advance}
              {else (begin
                      (set! pos varpos)
                      (set! cur varcur)
                      (list->string (reverse buffer)))})))
          retry}
      {[par? cur]
        (yield (make-paren pos (string cur)))
        advance}
      {else 
        (begin 
          (yield (violation pos (string cur)))
          advance)})))


(struct parse-result nterm (value) #:mutable #:transparent)

(define parse (make-parser {
  [lexer lexer]
  [grammar #:start-with parse-result
     [(Un  $1*) [(op-neg )]]
     [(Op1 $1*) [(op-mul )]]
     [(Op2 $1*) [(op-plus)]]
     [(Op3 $1*) [(op-and )]]
     [(Op4 $1*) [(op-xor )]]
     [(Op5 $1*) [(op-or  )]]

     [(Pr (list $1* $2*)) [(Un) (Pr)]]
     [(Pr (list $1* $2* $3*)) [(open-paren) (E) (close-paren)]]
     [(Pr $1*) [(variable)]]
    
     [(E1 (list $1* $2*)) [(Pr) (C1)]]
     [(C1 (list $1* $2*)) [(Op1) (E1)]]
     [(C1 '()) []]

     [(E2 (list $1* $2*)) [(E1) (C2)]]
     [(C2 (list $1* $2*)) [(Op2) (E2)]]
     [(C2 '()) []]

     [(E3 (list $1* $2*)) [(E2) (C3)]]
     [(C3 (list $1* $2*)) [(Op3) (E3)]]
     [(C3 '()) []]

     [(E4 (list $1* $2*)) [(E3) (C4)]]
     [(C4 (list $1* $2*)) [(Op4) (E4)]]
     [(C4 '()) []]

     [(E5 (list $1* $2*)) [(E4) (C5)]]
     [(C5 (list $1* $2*)) [(Op5) (E5)]]
     [(C5 '()) []]
     
     [(E $1*) [(E5)]]
     [(parse-result $1*) [(E) (end-of-input)]]
    ]
}))

(call-with-input-string "a + !b" parse)
