#lang racket
(require "../pgen.rkt")
(require "types.rkt")
(require "lexer.rkt")


(define (uop* f)
  (λ (z)
    (let* ([a (car z)]
           [b (cdr z)]
           [a* (f a)] 
           [b* (f b)])
      (displayln (format "operation: (~a ~a)\nint: ~a\nreal: ~a\ndiff: ~a" 
                         (object-name f) z 
                         a* b* (- a* b*)))
      (newline)
      (cons  a* b*))))

(define (bop* f)
  (λ (za zc)
   (let* ([a (car za)]
          [b (cdr za)]
          [c (car zc)]
          [d (cdr zc)]
          [a* (round (f a c))] 
          [b* (f b d)])
      (displayln (format "operation: (~a ~a ~a)\nint: ~a \nreal: ~a\ndiff: ~a" 
                       (object-name f)  za zc  
                       a* b* (- a* b*)))
      (newline)
      (cons a* b*))))

(define parse (make-parser {
  [lexer lexer]
  [grammar #:start-with parse-result
     [(Un  (uop* -)) [(op-sub )]]
     [(Op1 (bop* /)) [(op-div )]]
     [(Op2 (bop* *)) [(op-mul )]]
     [(Op3 (bop* +)) [(op-add)]]
     [(Op4 (bop* -)) [(op-sub)]]

     [(Pr (a v)) [(Un .a) (Pr .v)]]
     [(Pr v) [(open-paren) (E .v) (close-paren)]]
     [(Pr (cons (inexact->exact (round v)) (exact->inexact v))) [(number .p .t .v)]]
    
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
     [(parse-result (list v)) [(E .v) (end-of-input)]]
    ]
}))

(provide parse)
