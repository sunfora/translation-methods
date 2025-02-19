#lang racket
(require "lex.rkt")

(struct     node  (children) #:transparent)
(struct E   node  ()         #:transparent)
(struct Un  node  ()         #:transparent)
(struct Op1 node  ()         #:transparent)
(struct Op2 node  ()         #:transparent)
(struct Op3 node  ()         #:transparent)
(struct Pr  node  ()         #:transparent)
(struct E1  node  ()         #:transparent)
(struct C1  node  ()         #:transparent)
(struct E2  node  ()         #:transparent)
(struct C2  node  ()         #:transparent)
(struct E3  node  ()         #:transparent)
(struct C3  node  ()         #:transparent)

(define (parser in)
  
  (define lex (lexer in))
  (define cur (lex))
  (define (take) 
    (let [(old cur)]
      (set! cur (lex))
      old))

  (define (report expected got)
    (error 'parse-error "at: ~s, expected ~s, but got ~s"
           (token-pos cur)
           expected
           got))

  (define (expect cond?)
    (if (cond? cur)
      (take)
      (report (object-name cond?) cur)))

  (define (un)
    (match cur
      [(operation _ _ 0) (Un (take))]
      [_ (report "unary operation" cur)]))
  (define (op1)
    (match cur
      [(operation _ _ 1) (Op1 (take))]
      [_ (report "operator with prec 1" cur)]))
  (define (op2)
    (match cur
      [(operation _ _ 2) (Op2 (take))]
      [_ (report "operator with prec 2" cur)]))
  (define (op3)
    (match cur
      [(operation _ _ 3) (Op3 (take))]
      [_ (report "operator with prec 3" cur)]))
  (define (pr)
    (match cur
      [(operation _ _ 0) (Pr (list (un) (pr)))]
      [(open-paren _ _) (Pr (list (take) (e) (expect close-paren?)))]
      [(variable _ _) (Pr (take))]
      [_ (report "expression" cur)]))
  (define (e1)
    (E1 (list (pr) (c1))))
  (define (c1)
    (match cur
      [(operation _ _ 1) (C1 (list (op1) (e1)))]
      [_ (C1 null)]))
  (define (e2)
    (E2 (list (e1) (c2))))
  (define (c2)
    (match cur
      [(operation _ _ 2) (C2 (list (op2) (e2)))]
      [_ (C2 null)]))
  (define (e3)
    (E3 (list (e2) (c3))))
  (define (c3)
    (match cur
      [(operation _ _ 3) (C3 (list (op3) (e3)))]
      [_ (C3 null)]))
  (define (e)
    (E (e3)))
  (let [(result (e))]
    (expect end-of-input?)
    result))

(provide (all-defined-out))
