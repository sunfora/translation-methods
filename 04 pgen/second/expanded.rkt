#lang racket
(require "../pgen.rkt" "types.rkt" "parser.rkt" racket/pretty)

(define expanded (parser-expand #'(make-parser {
  [lexer lexer]
  [grammar #:start-with parse-result
     [(Un  $1* -) [(op-sub )]]
     [(Op1 $1* /) [(op-div )]]
     [(Op2 $1* *) [(op-mul )]]
     [(Op3 $1* +) [(op-add)]]
     [(Op4 $1* -) [(op-sub)]]
     [(Op5 $1* (λ (a b) 
                 (define name 
                   (let destruct ([cur a])
                     (cond
                       [(assignment? cur)
                        (destruct (assignment-var cur))]
                       [(variable? cur)
                        (token-text cur)]
                       [else (not-a-variable cur)])))
                 (displayln (format "~a = ~a" name b))
                 (dict-set! ctx name b)
                 b)) 
        [(op-assign)]]
     
     [(Pr (merge op tokens) (action value)) 
      [(Un .op .action) (Pr .tokens .value)]]
     [(Pr (if (list? tokens)
            (merge $1* tokens $3*)
            tokens)
          value) 
      [(open-paren) (E .tokens .value) (close-paren)]]
     [(Pr $1* v) 
      [(number _ _ .v)]]
     [(Pr $1* (ref name)) [(variable _ .name)]]
    
     [(E1 (merge t rest) v) 
      [(Pr .t .a) (C1 .rest .v a)]]
     [(C1 (merge top t rest) r .a) 
      [(Op1 .top .op) (Pr .t .b) (C1 .rest .r (op a b))]]
     [(C1 '()                r .r) []]

     [(E2 (merge t rest) v) 
      [(E1 .t .a) (C2 .rest .v a)]]
     [(C2 (merge top t rest) r .a) 
      [(Op2 .top .op) (E1 .t .b) (C2 .rest .r (op a b))]]
     [(C2 '()                 r .r) []]

     [(E3 (merge t rest) v) 
      [(E2 .t .a) (C3 .rest .v a)]]
     [(C3 (merge top t rest) r .a) 
      [(Op3 .top .op) (E2 .t .b) (C3 .rest .r (op a b))]]
     [(C3 '()                r .r) []]

     [(E4 (merge t rest) v) 
      [(E3 .t .a) (C4 .rest .v a)]]
     [(C4 (merge top t rest) r .a) 
      [(Op4 .top .op) (E3 .t .b) (C4 .rest .r (op a b))]]
     [(C4 '()                r .r) []]

     [(E5 r v) [(E4 .t .a) (C5 .r .v a t)]]
     [(C5 (assignment tokens $$-value*) 
          (op tokens value) 
          _ 
          .tokens) 
      [(Op5 _ .op) (E5 _ .value)]]
     [(C5 tokens r .r .tokens) []]

     [(E tokens v) [(E5 .tokens .v)]]
     [(parse-result v) [(E _ .v) (end-of-input)]]
    ]
})))

(provide parse)
(with-output-to-file "expanded-program.rkt"
  (λ () (pretty-print expanded))
  #:exists 'replace)
