#lang racket
(require "../pgen.rkt")
(require "types.rkt")
(require "lexer.rkt")

(define parse (make-parser {
  [lexer lexer]
  [grammar #:start-with parse-result
     [(Un  -) [(op-sub )]]
     [(Op1 /) [(op-div )]]
     [(Op2 *) [(op-mul )]]
     [(Op3 +) [(op-add)]]
     [(Op4 -) [(op-sub)]]

     [(Pr (a v)) [(Un .a) (Pr .v)]]
     [(Pr v) [(open-paren) (E .v) (close-paren)]]
     [(Pr v) [(number .p .t .v)]]
    
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
     [(parse-result v) [(E .v) (end-of-input)]]
    ]
}))

(provide parse)
