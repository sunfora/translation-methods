#lang racket
(require racket/generator)
(require racket/stxparam)

(struct token (pos text) 
  #:transparent)

(struct end-of-input token () 
  #:transparent)

(struct operation token (priority) 
  #:transparent)
; NOTE: не забудь чекнуть что оно не расходится
;       наверное можно как-то сделать умнее но пока так
(define operations '(#\! #\* #\+ #\& #\^ #\|))
(define (make-operation pos text)
  (define (classify text)
    (case text
      {["!"] 0}
      {["*"] 1}
      {["+"] 2}
      {["&"] 3}
      {["^"] 4}
      {["|"] 5}
      {else (error 'make "unsupported operation type: ~s" text)}))
  (operation pos text (classify text)))

(struct variable token ()
  #:transparent)

(struct paren token ()
  #:transparent)
; NOTE: не забудь чекнуть что оно не расходится
;       наверное можно как-то сделать умнее но пока так
(define parens '(#\( #\)))
(define (make-paren pos text) 
  (case text
    {["("] (open-paren pos text)}
    {[")"] (close-paren pos text)}
    {else (error 'make "weird paren type: ~s" text)}))

(struct open-paren paren ()
  #:transparent)
(struct close-paren paren ()
  #:transparent)

(struct violation token ()
  #:transparent)

(define-syntax-parameter advance (syntax-rules ()))
(define-syntax-parameter retry (syntax-rules ()))

(define-syntax-rule (loop ((id expr #:then next) ...) body ...)
  (let loop [(id expr) ...]
    (syntax-parameterize
      ([advance (syntax-id-rules () [_ (loop next ...)])]
       [retry   (syntax-id-rules () [_ (loop id ...)])])
      (cond body ...))))
      
(define (var? x) (and (char? x) (or (char-alphabetic? x)
                                    (eq? x #\-)
                                    (eq? x #\_)
                                    )))
(define (dvar? x) (and (char? x) (or (var? x)
                                     (char-numeric? x))))

(define (lexer in)
  (define (op? x) (member x operations))
  (define (par? x) (member x parens))
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
              {[dvar? varcur] advance}
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

(provide (all-defined-out))
