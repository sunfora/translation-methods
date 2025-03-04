#lang racket

(require "types.rkt")
(require racket/generator)
(require racket/stxparam)

; NOTE: не забудь чекнуть что оно не расходится
;       наверное можно как-то сделать умнее но пока так
(define operations '(#\- #\* #\+ #\/))
(define (make-operation pos text)
  (define (classify text)
    (case text
      {["-"] (op-sub pos text)}
      {["*"] (op-mul  pos text)}
      {["+"] (op-add pos text)}
      {["/"] (op-div  pos text)}
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

(define (make-number pos text) 
  (number pos text (string->number text)))

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
  (define (num? x) (and (char? x) (or (char-numeric? x)
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
      {[num? cur]
        (yield 
          (make-number pos 
            (loop ([varcur cur    #:then (read-char in)]
                   [varpos pos    #:then (+ 1 varpos)]
                   [buffer '()    #:then (cons varcur buffer)])
              {[num? varcur] advance}
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

(provide lexer)
