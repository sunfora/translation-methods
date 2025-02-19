#lang racket
(require racket/generator)

(struct token (pos text) 
  #:transparent)

(struct end-of-input token () 
  #:transparent)

(struct operation token (priority) 
  #:transparent)
; NOTE: не забудь чекнуть что оно не расходится
;       наверное можно как-то сделать умнее но пока так
(define operations '(#\! #\& #\^ #\|))
(define (make-operation pos text)
  (define (classify text)
    (case text
      {["!"] 0}
      {["&"] 1}
      {["^"] 2}
      {["|"] 3}
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

(define (lexer in)
  (define (op? x) (member x operations))
  (define (par? x) (member x parens))
  (define var? char-alphabetic?)
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
    (let loop ([cur (read-char in)] 
               [pos 0])
      (define (advance)
        (loop (read-char in) (+ 1 pos)))
      (cond
        {[eof-object? cur] 
          (end-of-input pos "")}
        {[skip? cur] 
          (advance)}
        {[op? cur]
          (yield (make-operation pos (string cur)))
          (advance)}
        {[var? cur]
          (yield (variable pos (string cur)))
          (advance)}
        {[par? cur]
          (yield (make-paren pos (string cur)))
          (advance)}
        {else 
          (begin 
            (yield (violation pos (string cur)))
            (advance))}))))

(provide (all-defined-out))
