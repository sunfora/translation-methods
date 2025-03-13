#lang racket
(require "../pgen.rkt")
(require "types.rkt")
(require "lexer.rkt")


(define (uop* f)
  (λ (z)
    (define z-int (map first z))
    (define z-flt (map second z))
    (define z-dif (map third z))

    (define c-int 
      (format/list "~a~a" (list (object-name f)) z-int))

    (define c-flt
      (format/list "~a~a" (list (object-name f)) z-flt))
    (define c-dif
      (format/list "(~a~a)" (list "@") z-dif))
    (define c
      (map list c-int c-flt c-dif))

    (define x (round (f (last z-int))))
    (define y (f (last z-flt)))

    (define c-last
      (list (list x y (- x y))))
    (append c c-last)))

(define (bop* f)
  (λ (a b)
    (define a-int (map first a))
    (define a-flt (map second a))
    (define a-dif (map third a))

    (define b-int (map first b))
    (define b-flt (map second b))
    (define b-dif (map third b))

    (define c-int 
      (format/list "~a ~a ~a"
                   a-int
                   (list (object-name f))
                   b-int))
    (define c-flt
      (format/list "~a ~a ~a"
                   a-flt
                   (list (object-name f))
                   b-flt))
    (define c-dif
      (format/list "(~a ~a ~a)"
                   a-dif
                   (list "⊗")
                   b-dif))

    (define c-but (map list c-int c-flt c-dif))
    
    (define x (round (f (last a-int) (last b-int))))
    (define y (f (last a-flt) (last b-flt)))

    (define c-last 
      (list (list x y (- x y))))
    (append c-but c-last)))

(define (format/list pattern . lists)
  (define traversed '())
  (define rest (map car lists))
  (set! lists (map cdr lists))
  (set! lists (cons (cons (car rest)
                          (car lists))
                    (cdr lists)))
  (flatten 
    (for/list ([list lists])
      (let ([h (car rest)])
        (set! rest (cdr rest))
        (set! traversed (cons h traversed)))
      (for/list ([elem list])
        (set! traversed (cons elem (cdr traversed)))
        (apply format pattern (append (reverse traversed) rest))))))

(define (just-parens x)
  (define x-int (map first x))
  (define x-flt (map second x))
  (define x-dif (map third x))
  (define c-int (format/list "(~a)" x-int))
  (define c-flt (format/list "(~a)" x-flt))
  (define c-dif (format/list "(~a)" x-dif))
  (define c (map list c-int c-flt c-dif))
  (append c (list (last x))))

(define parse (make-parser {
  [lexer lexer]
  [grammar #:start-with parse-result
     [(Un  (uop* -)) [(op-sub )]]
     [(Op1 (bop* /)) [(op-div )]]
     [(Op2 (bop* *)) [(op-mul )]]
     [(Op3 (bop* +)) [(op-add)]]
     [(Op4 (bop* -)) [(op-sub)]]

     [(Pr (a v)) [(Un .a) (Pr .v)]]
     [(Pr (just-parens v))
        [(open-paren) (E .v) (close-paren)]]
     [(Pr (list (list
                  (inexact->exact (round v))
                  (exact->inexact v)
                  (- (inexact->exact (round v))
                    (exact->inexact v) ))))
      [(number .p .t .v)]]
    
     [(E1 v) [(Pr .a) (C1 .v a)]]
     [(C1 r .a) [(Op1 .op) (Pr .b) (C1 .r (op a b))]]
     [(C1 r .r) []]

     [(E2 v) [(E1 .a) (C2 .v a)]]
     [(C2 r .a) [(Op2 .op) (E1 .b) (C2 .r (op a b))]]
     [(C2 r .r) []]

     [(E3 v) [(E2 .a) (C3 .v a)]]
     [(C3 r .a) [(Op3 .op) (E2 .b) (C3 .r (op a b))]]
     [(C3 r .r) []]

     [(E4 v) [(E3 .a) (C4 .v a)]]
     [(C4 r .a) [(Op4 .op) (E3 .b) (C4 .r (op a b))]]
     [(C4 r .r) []]

     [(E v) [(E4 .v)]]
     [(parse-result (for ([x v])
                      (displayln (format "  (int): ~a" (first x)))
                      (displayln (format "(float): ~a" (second x)))
                      (displayln (format "> ~a" (third x)))
                      (displayln "--"))) 
      [(E .v) (end-of-input)]]
    ]
}))

(provide parse)
