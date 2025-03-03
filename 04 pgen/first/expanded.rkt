#lang racket
(require "../pgen.rkt" "types.rkt" "parser.rkt" racket/pretty)
(define expanded 
  (parser-expand #'(make-parser {
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
  })))
(with-output-to-file "expanded-program.rkt"
  (λ () (pretty-display expanded))
  #:exists 'replace)
