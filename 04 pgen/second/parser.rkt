#lang racket
(require "../pgen.rkt")
(require "types.rkt")
(require "lexer.rkt")
(require racket/dict)
(define ctx (make-hash))

(define (not-a-variable)
  (error 'calc
         "illegal asignment, not a variable"))

(define (ref name)
  (if (dict-has-key? ctx name)
    (dict-ref ctx name)
    (report-undefined name)))

(define (report-undefined name)
  (error 'calc
         (format "variable ~a referenced before assignment" name)))

(define parse (make-parser {
  [lexer lexer]
  [grammar #:start-with parse-result
     [(Un  -) [(op-sub )]]
     [(Op1 /) [(op-div )]]
     [(Op2 *) [(op-mul )]]
     [(Op3 +) [(op-add)]]
     [(Op4 -) [(op-sub)]]
     [(Op5 (λ (a b) 
             (displayln (format "~a = ~a" a b))
             (dict-set! ctx a b)
             b)) 
        [(op-assign)]]
     
     [(Pr (a v) (not-a-variable)) 
      [(Un .a) (Pr .v)]]
     [(Pr v place) 
      [(open-paren) (E .v .place) (close-paren)]]
     [(Pr v (not-a-variable)) 
      [(number .p .t .v)]]
     [(Pr (ref name) name) [(variable .p .name)]]
    
     [(E1 v (if has? (not-a-variable) p)) 
      [(Pr .a .p) (C1 .v .has? a)]]
     [(C1 r #t .a) [(Op1 .op) (Pr .b) (C1 .r .has? (op a b))]]
     [(C1 r #f .r) []]

     [(E2 v (if has? (not-a-variable) p)) 
      [(E1 .a .p) (C2 .v .has? a)]]
     [(C2 r #t .a) [(Op2 .op) (E1 .b) (C2 .r .has? (op a b))]]
     [(C2 r #f .r) []]

     [(E3 v (if has? (not-a-variable) p)) 
      [(E2 .a .p) (C3 .v .has? a)]]
     [(C3 r #t .a) [(Op3 .op) (E2 .b) (C3 .r .has? (op a b))]]
     [(C3 r #f .r) []]

     [(E4 v (if has? (not-a-variable) p)) 
      [(E3 .a .p) (C4 .v .has? a)]]
     [(C4 r #t .a) [(Op4 .op) (E3 .b) (C4 .r .has? (op a b))]]
     [(C4 r #f .r) []]

     [(E5 v p) [(E4 .a .p) (C5 .v p a)]]
     [(C5 (op place v) .place) [(Op5 .op) (E5 .v)]]
     [(C5 r .place .r) []]

     [(E v p) [(E5 .v .p)]]
     [(parse-result v) [(E .v) (end-of-input)]]
    ]
}))

(provide (all-defined-out))
