'(λ (in)
   (define lex (lexer in))
   (define cur (lex))
   (define (report expected got)
     (error 'parse-error "expected ~s, but got ~s" expected got))
   (define (take) (let ((old cur)) (set! cur (lex)) old))
   (define (parse-C1 $$)
     (case (object-name cur)
       ((op-div)
        (let* (($1 (Op1 '())) ($2 (Pr '() '())) ($3 (C1 '() '() '())))
          (let-syntax ((a (bind-as #'(force (fold-accumulator $$))))
                       (op (bind-as #'(force (operator-action $1))))
                       (b (bind-as #'(force (node-value $2))))
                       (r (bind-as #'(force (node-value $3))))
                       (has? (bind-as #'(force (node-place $3))))
                       ($$*
                        (bind-as
                         #'(C1
                            (force (node-value $$))
                            (force (node-place $$))
                            (force (fold-accumulator $$)))))
                       ($$-accumulator* (bind-as #'(force (node-value $$))))
                       ($$-value* (bind-as #'(force (node-place $$))))
                       ($$-place* (bind-as #'(force (fold-accumulator $$))))
                       ($1* (bind-as #'(Op1 (force (operator-action $1)))))
                       ($1-action* (bind-as #'(force (operator-action $1))))
                       ($2*
                        (bind-as
                         #'(Pr
                            (force (node-value $2))
                            (force (node-place $2)))))
                       ($2-value* (bind-as #'(force (node-value $2))))
                       ($2-place* (bind-as #'(force (node-place $2))))
                       ($3*
                        (bind-as
                         #'(C1
                            (force (node-value $3))
                            (force (node-place $3))
                            (force (fold-accumulator $3)))))
                       ($3-accumulator* (bind-as #'(force (node-value $3))))
                       ($3-value* (bind-as #'(force (node-place $3))))
                       ($3-place* (bind-as #'(force (fold-accumulator $3)))))
            (begin
              (set-node-value! $$ (delay r))
              (set-node-place! $$ (delay #t))
              (set-fold-accumulator! $3 (delay (op a b)))
              (parse-Op1 $1)
              (parse-Pr $2)
              (parse-C1 $3)
              (delay $$)))))
       (else
        (let* ()
          (let-syntax ((r (bind-as #'(force (fold-accumulator $$))))
                       ($$*
                        (bind-as
                         #'(C1
                            (force (node-value $$))
                            (force (node-place $$))
                            (force (fold-accumulator $$)))))
                       ($$-accumulator* (bind-as #'(force (node-value $$))))
                       ($$-value* (bind-as #'(force (node-place $$))))
                       ($$-place* (bind-as #'(force (fold-accumulator $$)))))
            (begin
              (set-node-value! $$ (delay r))
              (set-node-place! $$ (delay #f))
              (delay $$)))))))
   (define (parse-Un $$)
     (case (object-name cur)
       ((op-sub)
        (let* (($1 (op-sub '() '())))
          (let-syntax (($$* (bind-as #'(Un (force (operator-action $$)))))
                       ($$-action* (bind-as #'(force (operator-action $$))))
                       ($1*
                        (bind-as
                         #'(op-sub
                            (force (token-pos $1))
                            (force (token-text $1)))))
                       ($1-pos* (bind-as #'(force (token-pos $1))))
                       ($1-text* (bind-as #'(force (token-text $1)))))
            (begin
              (set-operator-action! $$ (delay -))
              (expect-op-sub $1)
              (delay $$)))))
       (else (report $$ cur))))
   (define (parse-C4 $$)
     (case (object-name cur)
       ((op-sub)
        (let* (($1 (Op4 '())) ($2 (E3 '() '())) ($3 (C4 '() '() '())))
          (let-syntax ((a (bind-as #'(force (fold-accumulator $$))))
                       (op (bind-as #'(force (operator-action $1))))
                       (b (bind-as #'(force (node-value $2))))
                       (r (bind-as #'(force (node-value $3))))
                       (has? (bind-as #'(force (node-place $3))))
                       ($$*
                        (bind-as
                         #'(C4
                            (force (node-value $$))
                            (force (node-place $$))
                            (force (fold-accumulator $$)))))
                       ($$-accumulator* (bind-as #'(force (node-value $$))))
                       ($$-value* (bind-as #'(force (node-place $$))))
                       ($$-place* (bind-as #'(force (fold-accumulator $$))))
                       ($1* (bind-as #'(Op4 (force (operator-action $1)))))
                       ($1-action* (bind-as #'(force (operator-action $1))))
                       ($2*
                        (bind-as
                         #'(E3
                            (force (node-value $2))
                            (force (node-place $2)))))
                       ($2-value* (bind-as #'(force (node-value $2))))
                       ($2-place* (bind-as #'(force (node-place $2))))
                       ($3*
                        (bind-as
                         #'(C4
                            (force (node-value $3))
                            (force (node-place $3))
                            (force (fold-accumulator $3)))))
                       ($3-accumulator* (bind-as #'(force (node-value $3))))
                       ($3-value* (bind-as #'(force (node-place $3))))
                       ($3-place* (bind-as #'(force (fold-accumulator $3)))))
            (begin
              (set-node-value! $$ (delay r))
              (set-node-place! $$ (delay #t))
              (set-fold-accumulator! $3 (delay (op a b)))
              (parse-Op4 $1)
              (parse-E3 $2)
              (parse-C4 $3)
              (delay $$)))))
       (else
        (let* ()
          (let-syntax ((r (bind-as #'(force (fold-accumulator $$))))
                       ($$*
                        (bind-as
                         #'(C4
                            (force (node-value $$))
                            (force (node-place $$))
                            (force (fold-accumulator $$)))))
                       ($$-accumulator* (bind-as #'(force (node-value $$))))
                       ($$-value* (bind-as #'(force (node-place $$))))
                       ($$-place* (bind-as #'(force (fold-accumulator $$)))))
            (begin
              (set-node-value! $$ (delay r))
              (set-node-place! $$ (delay #f))
              (delay $$)))))))
   (define (parse-Op5 $$)
     (case (object-name cur)
       ((op-assign)
        (let* (($1 (op-assign '() '())))
          (let-syntax (($$* (bind-as #'(Op5 (force (operator-action $$)))))
                       ($$-action* (bind-as #'(force (operator-action $$))))
                       ($1*
                        (bind-as
                         #'(op-assign
                            (force (token-pos $1))
                            (force (token-text $1)))))
                       ($1-pos* (bind-as #'(force (token-pos $1))))
                       ($1-text* (bind-as #'(force (token-text $1)))))
            (begin
              (set-operator-action!
               $$
               (delay
                (λ (a b)
                  (displayln (format "~a = ~a" a b))
                  (dict-set! ctx a b)
                  b)))
              (expect-op-assign $1)
              (delay $$)))))
       (else (report $$ cur))))
   (define (parse-Pr $$)
     (case (object-name cur)
       ((op-sub)
        (let* (($1 (Un '())) ($2 (Pr '() '())))
          (let-syntax ((a (bind-as #'(force (operator-action $1))))
                       (v (bind-as #'(force (node-value $2))))
                       ($$*
                        (bind-as
                         #'(Pr
                            (force (node-value $$))
                            (force (node-place $$)))))
                       ($$-value* (bind-as #'(force (node-value $$))))
                       ($$-place* (bind-as #'(force (node-place $$))))
                       ($1* (bind-as #'(Un (force (operator-action $1)))))
                       ($1-action* (bind-as #'(force (operator-action $1))))
                       ($2*
                        (bind-as
                         #'(Pr
                            (force (node-value $2))
                            (force (node-place $2)))))
                       ($2-value* (bind-as #'(force (node-value $2))))
                       ($2-place* (bind-as #'(force (node-place $2)))))
            (begin
              (set-node-value! $$ (delay (a v)))
              (set-node-place! $$ (delay (not-a-variable)))
              (parse-Un $1)
              (parse-Pr $2)
              (delay $$)))))
       ((open-paren)
        (let* (($1 (open-paren '() '()))
               ($2 (E '() '()))
               ($3 (close-paren '() '())))
          (let-syntax ((v (bind-as #'(force (node-value $2))))
                       (place (bind-as #'(force (node-place $2))))
                       ($$*
                        (bind-as
                         #'(Pr
                            (force (node-value $$))
                            (force (node-place $$)))))
                       ($$-value* (bind-as #'(force (node-value $$))))
                       ($$-place* (bind-as #'(force (node-place $$))))
                       ($1*
                        (bind-as
                         #'(open-paren
                            (force (token-pos $1))
                            (force (token-text $1)))))
                       ($1-pos* (bind-as #'(force (token-pos $1))))
                       ($1-text* (bind-as #'(force (token-text $1))))
                       ($2*
                        (bind-as
                         #'(E
                            (force (node-value $2))
                            (force (node-place $2)))))
                       ($2-value* (bind-as #'(force (node-value $2))))
                       ($2-place* (bind-as #'(force (node-place $2))))
                       ($3*
                        (bind-as
                         #'(close-paren
                            (force (token-pos $3))
                            (force (token-text $3)))))
                       ($3-pos* (bind-as #'(force (token-pos $3))))
                       ($3-text* (bind-as #'(force (token-text $3)))))
            (begin
              (set-node-value! $$ (delay v))
              (set-node-place! $$ (delay place))
              (expect-open-paren $1)
              (parse-E $2)
              (expect-close-paren $3)
              (delay $$)))))
       ((number)
        (let* (($1 (number '() '() '())))
          (let-syntax ((p (bind-as #'(force (token-pos $1))))
                       (t (bind-as #'(force (token-text $1))))
                       (v (bind-as #'(force (number-value $1))))
                       ($$*
                        (bind-as
                         #'(Pr
                            (force (node-value $$))
                            (force (node-place $$)))))
                       ($$-value* (bind-as #'(force (node-value $$))))
                       ($$-place* (bind-as #'(force (node-place $$))))
                       ($1*
                        (bind-as
                         #'(number
                            (force (token-pos $1))
                            (force (token-text $1))
                            (force (number-value $1)))))
                       ($1-value* (bind-as #'(force (token-pos $1))))
                       ($1-pos* (bind-as #'(force (token-text $1))))
                       ($1-text* (bind-as #'(force (number-value $1)))))
            (begin
              (set-node-value! $$ (delay v))
              (set-node-place! $$ (delay (not-a-variable)))
              (expect-number $1)
              (delay $$)))))
       ((variable)
        (let* (($1 (variable '() '())))
          (let-syntax ((p (bind-as #'(force (token-pos $1))))
                       (name (bind-as #'(force (token-text $1))))
                       ($$*
                        (bind-as
                         #'(Pr
                            (force (node-value $$))
                            (force (node-place $$)))))
                       ($$-value* (bind-as #'(force (node-value $$))))
                       ($$-place* (bind-as #'(force (node-place $$))))
                       ($1*
                        (bind-as
                         #'(variable
                            (force (token-pos $1))
                            (force (token-text $1)))))
                       ($1-pos* (bind-as #'(force (token-pos $1))))
                       ($1-text* (bind-as #'(force (token-text $1)))))
            (begin
              (set-node-value! $$ (delay (ref name)))
              (set-node-place! $$ (delay name))
              (expect-variable $1)
              (delay $$)))))
       (else (report $$ cur))))
   (define (parse-E3 $$)
     (case (object-name cur)
       ((variable op-sub number open-paren)
        (let* (($1 (E2 '() '())) ($2 (C3 '() '() '())))
          (let-syntax ((a (bind-as #'(force (node-value $1))))
                       (p (bind-as #'(force (node-place $1))))
                       (v (bind-as #'(force (node-value $2))))
                       (has? (bind-as #'(force (node-place $2))))
                       ($$*
                        (bind-as
                         #'(E3
                            (force (node-value $$))
                            (force (node-place $$)))))
                       ($$-value* (bind-as #'(force (node-value $$))))
                       ($$-place* (bind-as #'(force (node-place $$))))
                       ($1*
                        (bind-as
                         #'(E2
                            (force (node-value $1))
                            (force (node-place $1)))))
                       ($1-value* (bind-as #'(force (node-value $1))))
                       ($1-place* (bind-as #'(force (node-place $1))))
                       ($2*
                        (bind-as
                         #'(C3
                            (force (node-value $2))
                            (force (node-place $2))
                            (force (fold-accumulator $2)))))
                       ($2-accumulator* (bind-as #'(force (node-value $2))))
                       ($2-value* (bind-as #'(force (node-place $2))))
                       ($2-place* (bind-as #'(force (fold-accumulator $2)))))
            (begin
              (set-node-value! $$ (delay v))
              (set-node-place! $$ (delay (if has? (not-a-variable) p)))
              (set-fold-accumulator! $2 (delay a))
              (parse-E2 $1)
              (parse-C3 $2)
              (delay $$)))))
       (else (report $$ cur))))
   (define (expect-close-paren $$)
     (unless (close-paren? cur) (report $$ cur))
     (set-token-pos! $$ (token-pos cur))
     (set-token-text! $$ (token-text cur))
     (take))
   (define (expect-op-add $$)
     (unless (op-add? cur) (report $$ cur))
     (set-token-pos! $$ (token-pos cur))
     (set-token-text! $$ (token-text cur))
     (take))
   (define (expect-op-sub $$)
     (unless (op-sub? cur) (report $$ cur))
     (set-token-pos! $$ (token-pos cur))
     (set-token-text! $$ (token-text cur))
     (take))
   (define (parse-E5 $$)
     (case (object-name cur)
       ((variable op-sub number open-paren)
        (let* (($1 (E4 '() '())) ($2 (C5 '() '() '())))
          (let-syntax ((a (bind-as #'(force (node-value $1))))
                       (p (bind-as #'(force (node-place $1))))
                       (v (bind-as #'(force (node-value $2))))
                       ($$*
                        (bind-as
                         #'(E5
                            (force (node-value $$))
                            (force (node-place $$)))))
                       ($$-value* (bind-as #'(force (node-value $$))))
                       ($$-place* (bind-as #'(force (node-place $$))))
                       ($1*
                        (bind-as
                         #'(E4
                            (force (node-value $1))
                            (force (node-place $1)))))
                       ($1-value* (bind-as #'(force (node-value $1))))
                       ($1-place* (bind-as #'(force (node-place $1))))
                       ($2*
                        (bind-as
                         #'(C5
                            (force (node-value $2))
                            (force (node-place $2))
                            (force (fold-accumulator $2)))))
                       ($2-accumulator* (bind-as #'(force (node-value $2))))
                       ($2-value* (bind-as #'(force (node-place $2))))
                       ($2-place* (bind-as #'(force (fold-accumulator $2)))))
            (begin
              (set-node-value! $$ (delay v))
              (set-node-place! $$ (delay p))
              (set-node-place! $2 (delay p))
              (set-fold-accumulator! $2 (delay a))
              (parse-E4 $1)
              (parse-C5 $2)
              (delay $$)))))
       (else (report $$ cur))))
   (define (parse-Op2 $$)
     (case (object-name cur)
       ((op-mul)
        (let* (($1 (op-mul '() '())))
          (let-syntax (($$* (bind-as #'(Op2 (force (operator-action $$)))))
                       ($$-action* (bind-as #'(force (operator-action $$))))
                       ($1*
                        (bind-as
                         #'(op-mul
                            (force (token-pos $1))
                            (force (token-text $1)))))
                       ($1-pos* (bind-as #'(force (token-pos $1))))
                       ($1-text* (bind-as #'(force (token-text $1)))))
            (begin
              (set-operator-action! $$ (delay *))
              (expect-op-mul $1)
              (delay $$)))))
       (else (report $$ cur))))
   (define (parse-C2 $$)
     (case (object-name cur)
       ((op-mul)
        (let* (($1 (Op2 '())) ($2 (E1 '() '())) ($3 (C2 '() '() '())))
          (let-syntax ((a (bind-as #'(force (fold-accumulator $$))))
                       (op (bind-as #'(force (operator-action $1))))
                       (b (bind-as #'(force (node-value $2))))
                       (r (bind-as #'(force (node-value $3))))
                       (has? (bind-as #'(force (node-place $3))))
                       ($$*
                        (bind-as
                         #'(C2
                            (force (node-value $$))
                            (force (node-place $$))
                            (force (fold-accumulator $$)))))
                       ($$-accumulator* (bind-as #'(force (node-value $$))))
                       ($$-value* (bind-as #'(force (node-place $$))))
                       ($$-place* (bind-as #'(force (fold-accumulator $$))))
                       ($1* (bind-as #'(Op2 (force (operator-action $1)))))
                       ($1-action* (bind-as #'(force (operator-action $1))))
                       ($2*
                        (bind-as
                         #'(E1
                            (force (node-value $2))
                            (force (node-place $2)))))
                       ($2-value* (bind-as #'(force (node-value $2))))
                       ($2-place* (bind-as #'(force (node-place $2))))
                       ($3*
                        (bind-as
                         #'(C2
                            (force (node-value $3))
                            (force (node-place $3))
                            (force (fold-accumulator $3)))))
                       ($3-accumulator* (bind-as #'(force (node-value $3))))
                       ($3-value* (bind-as #'(force (node-place $3))))
                       ($3-place* (bind-as #'(force (fold-accumulator $3)))))
            (begin
              (set-node-value! $$ (delay r))
              (set-node-place! $$ (delay #t))
              (set-fold-accumulator! $3 (delay (op a b)))
              (parse-Op2 $1)
              (parse-E1 $2)
              (parse-C2 $3)
              (delay $$)))))
       (else
        (let* ()
          (let-syntax ((r (bind-as #'(force (fold-accumulator $$))))
                       ($$*
                        (bind-as
                         #'(C2
                            (force (node-value $$))
                            (force (node-place $$))
                            (force (fold-accumulator $$)))))
                       ($$-accumulator* (bind-as #'(force (node-value $$))))
                       ($$-value* (bind-as #'(force (node-place $$))))
                       ($$-place* (bind-as #'(force (fold-accumulator $$)))))
            (begin
              (set-node-value! $$ (delay r))
              (set-node-place! $$ (delay #f))
              (delay $$)))))))
   (define (parse-E1 $$)
     (case (object-name cur)
       ((variable op-sub number open-paren)
        (let* (($1 (Pr '() '())) ($2 (C1 '() '() '())))
          (let-syntax ((a (bind-as #'(force (node-value $1))))
                       (p (bind-as #'(force (node-place $1))))
                       (v (bind-as #'(force (node-value $2))))
                       (has? (bind-as #'(force (node-place $2))))
                       ($$*
                        (bind-as
                         #'(E1
                            (force (node-value $$))
                            (force (node-place $$)))))
                       ($$-value* (bind-as #'(force (node-value $$))))
                       ($$-place* (bind-as #'(force (node-place $$))))
                       ($1*
                        (bind-as
                         #'(Pr
                            (force (node-value $1))
                            (force (node-place $1)))))
                       ($1-value* (bind-as #'(force (node-value $1))))
                       ($1-place* (bind-as #'(force (node-place $1))))
                       ($2*
                        (bind-as
                         #'(C1
                            (force (node-value $2))
                            (force (node-place $2))
                            (force (fold-accumulator $2)))))
                       ($2-accumulator* (bind-as #'(force (node-value $2))))
                       ($2-value* (bind-as #'(force (node-place $2))))
                       ($2-place* (bind-as #'(force (fold-accumulator $2)))))
            (begin
              (set-node-value! $$ (delay v))
              (set-node-place! $$ (delay (if has? (not-a-variable) p)))
              (set-fold-accumulator! $2 (delay a))
              (parse-Pr $1)
              (parse-C1 $2)
              (delay $$)))))
       (else (report $$ cur))))
   (define (parse-Op1 $$)
     (case (object-name cur)
       ((op-div)
        (let* (($1 (op-div '() '())))
          (let-syntax (($$* (bind-as #'(Op1 (force (operator-action $$)))))
                       ($$-action* (bind-as #'(force (operator-action $$))))
                       ($1*
                        (bind-as
                         #'(op-div
                            (force (token-pos $1))
                            (force (token-text $1)))))
                       ($1-pos* (bind-as #'(force (token-pos $1))))
                       ($1-text* (bind-as #'(force (token-text $1)))))
            (begin
              (set-operator-action! $$ (delay /))
              (expect-op-div $1)
              (delay $$)))))
       (else (report $$ cur))))
   (define (expect-op-assign $$)
     (unless (op-assign? cur) (report $$ cur))
     (set-token-pos! $$ (token-pos cur))
     (set-token-text! $$ (token-text cur))
     (take))
   (define (expect-open-paren $$)
     (unless (open-paren? cur) (report $$ cur))
     (set-token-pos! $$ (token-pos cur))
     (set-token-text! $$ (token-text cur))
     (take))
   (define (expect-variable $$)
     (unless (variable? cur) (report $$ cur))
     (set-token-pos! $$ (token-pos cur))
     (set-token-text! $$ (token-text cur))
     (take))
   (define (parse-Op4 $$)
     (case (object-name cur)
       ((op-sub)
        (let* (($1 (op-sub '() '())))
          (let-syntax (($$* (bind-as #'(Op4 (force (operator-action $$)))))
                       ($$-action* (bind-as #'(force (operator-action $$))))
                       ($1*
                        (bind-as
                         #'(op-sub
                            (force (token-pos $1))
                            (force (token-text $1)))))
                       ($1-pos* (bind-as #'(force (token-pos $1))))
                       ($1-text* (bind-as #'(force (token-text $1)))))
            (begin
              (set-operator-action! $$ (delay -))
              (expect-op-sub $1)
              (delay $$)))))
       (else (report $$ cur))))
   (define (parse-E $$)
     (case (object-name cur)
       ((variable op-sub number open-paren)
        (let* (($1 (E5 '() '())))
          (let-syntax ((v (bind-as #'(force (node-value $1))))
                       (p (bind-as #'(force (node-place $1))))
                       ($$*
                        (bind-as
                         #'(E
                            (force (node-value $$))
                            (force (node-place $$)))))
                       ($$-value* (bind-as #'(force (node-value $$))))
                       ($$-place* (bind-as #'(force (node-place $$))))
                       ($1*
                        (bind-as
                         #'(E5
                            (force (node-value $1))
                            (force (node-place $1)))))
                       ($1-value* (bind-as #'(force (node-value $1))))
                       ($1-place* (bind-as #'(force (node-place $1)))))
            (begin
              (set-node-value! $$ (delay v))
              (set-node-place! $$ (delay p))
              (parse-E5 $1)
              (delay $$)))))
       (else (report $$ cur))))
   (define (expect-op-div $$)
     (unless (op-div? cur) (report $$ cur))
     (set-token-pos! $$ (token-pos cur))
     (set-token-text! $$ (token-text cur))
     (take))
   (define (parse-C5 $$)
     (case (object-name cur)
       ((op-assign)
        (let* (($1 (Op5 '())) ($2 (E5 '() '())))
          (let-syntax ((place (bind-as #'(force (node-place $$))))
                       (op (bind-as #'(force (operator-action $1))))
                       (v (bind-as #'(force (node-value $2))))
                       ($$*
                        (bind-as
                         #'(C5
                            (force (node-value $$))
                            (force (node-place $$))
                            (force (fold-accumulator $$)))))
                       ($$-accumulator* (bind-as #'(force (node-value $$))))
                       ($$-value* (bind-as #'(force (node-place $$))))
                       ($$-place* (bind-as #'(force (fold-accumulator $$))))
                       ($1* (bind-as #'(Op5 (force (operator-action $1)))))
                       ($1-action* (bind-as #'(force (operator-action $1))))
                       ($2*
                        (bind-as
                         #'(E5
                            (force (node-value $2))
                            (force (node-place $2)))))
                       ($2-value* (bind-as #'(force (node-value $2))))
                       ($2-place* (bind-as #'(force (node-place $2)))))
            (begin
              (set-node-value! $$ (delay (op place v)))
              (parse-Op5 $1)
              (parse-E5 $2)
              (delay $$)))))
       (else
        (let* ()
          (let-syntax ((place (bind-as #'(force (node-place $$))))
                       (r (bind-as #'(force (fold-accumulator $$))))
                       ($$*
                        (bind-as
                         #'(C5
                            (force (node-value $$))
                            (force (node-place $$))
                            (force (fold-accumulator $$)))))
                       ($$-accumulator* (bind-as #'(force (node-value $$))))
                       ($$-value* (bind-as #'(force (node-place $$))))
                       ($$-place* (bind-as #'(force (fold-accumulator $$)))))
            (begin (set-node-value! $$ (delay r)) (delay $$)))))))
   (define (expect-number $$)
     (unless (number? cur) (report $$ cur))
     (set-token-pos! $$ (token-pos cur))
     (set-token-text! $$ (token-text cur))
     (set-number-value! $$ (number-value cur))
     (take))
   (define (parse-C3 $$)
     (case (object-name cur)
       ((op-add)
        (let* (($1 (Op3 '())) ($2 (E2 '() '())) ($3 (C3 '() '() '())))
          (let-syntax ((a (bind-as #'(force (fold-accumulator $$))))
                       (op (bind-as #'(force (operator-action $1))))
                       (b (bind-as #'(force (node-value $2))))
                       (r (bind-as #'(force (node-value $3))))
                       (has? (bind-as #'(force (node-place $3))))
                       ($$*
                        (bind-as
                         #'(C3
                            (force (node-value $$))
                            (force (node-place $$))
                            (force (fold-accumulator $$)))))
                       ($$-accumulator* (bind-as #'(force (node-value $$))))
                       ($$-value* (bind-as #'(force (node-place $$))))
                       ($$-place* (bind-as #'(force (fold-accumulator $$))))
                       ($1* (bind-as #'(Op3 (force (operator-action $1)))))
                       ($1-action* (bind-as #'(force (operator-action $1))))
                       ($2*
                        (bind-as
                         #'(E2
                            (force (node-value $2))
                            (force (node-place $2)))))
                       ($2-value* (bind-as #'(force (node-value $2))))
                       ($2-place* (bind-as #'(force (node-place $2))))
                       ($3*
                        (bind-as
                         #'(C3
                            (force (node-value $3))
                            (force (node-place $3))
                            (force (fold-accumulator $3)))))
                       ($3-accumulator* (bind-as #'(force (node-value $3))))
                       ($3-value* (bind-as #'(force (node-place $3))))
                       ($3-place* (bind-as #'(force (fold-accumulator $3)))))
            (begin
              (set-node-value! $$ (delay r))
              (set-node-place! $$ (delay #t))
              (set-fold-accumulator! $3 (delay (op a b)))
              (parse-Op3 $1)
              (parse-E2 $2)
              (parse-C3 $3)
              (delay $$)))))
       (else
        (let* ()
          (let-syntax ((r (bind-as #'(force (fold-accumulator $$))))
                       ($$*
                        (bind-as
                         #'(C3
                            (force (node-value $$))
                            (force (node-place $$))
                            (force (fold-accumulator $$)))))
                       ($$-accumulator* (bind-as #'(force (node-value $$))))
                       ($$-value* (bind-as #'(force (node-place $$))))
                       ($$-place* (bind-as #'(force (fold-accumulator $$)))))
            (begin
              (set-node-value! $$ (delay r))
              (set-node-place! $$ (delay #f))
              (delay $$)))))))
   (define (expect-end-of-input $$)
     (unless (end-of-input? cur) (report $$ cur))
     (set-token-pos! $$ (token-pos cur))
     (set-token-text! $$ (token-text cur))
     (take))
   (define (parse-parse-result $$)
     (case (object-name cur)
       ((variable op-sub number open-paren)
        (let* (($1 (E '() '())) ($2 (end-of-input '() '())))
          (let-syntax ((v (bind-as #'(force (node-value $1))))
                       ($$*
                        (bind-as
                         #'(parse-result (force (parse-result-value $$)))))
                       ($$-value* (bind-as #'(force (parse-result-value $$))))
                       ($1*
                        (bind-as
                         #'(E
                            (force (node-value $1))
                            (force (node-place $1)))))
                       ($1-value* (bind-as #'(force (node-value $1))))
                       ($1-place* (bind-as #'(force (node-place $1))))
                       ($2*
                        (bind-as
                         #'(end-of-input
                            (force (token-pos $2))
                            (force (token-text $2)))))
                       ($2-pos* (bind-as #'(force (token-pos $2))))
                       ($2-text* (bind-as #'(force (token-text $2)))))
            (begin
              (set-parse-result-value! $$ (delay v))
              (parse-E $1)
              (expect-end-of-input $2)
              (delay $$)))))
       (else (report $$ cur))))
   (define (parse-E4 $$)
     (case (object-name cur)
       ((variable op-sub number open-paren)
        (let* (($1 (E3 '() '())) ($2 (C4 '() '() '())))
          (let-syntax ((a (bind-as #'(force (node-value $1))))
                       (p (bind-as #'(force (node-place $1))))
                       (v (bind-as #'(force (node-value $2))))
                       (has? (bind-as #'(force (node-place $2))))
                       ($$*
                        (bind-as
                         #'(E4
                            (force (node-value $$))
                            (force (node-place $$)))))
                       ($$-value* (bind-as #'(force (node-value $$))))
                       ($$-place* (bind-as #'(force (node-place $$))))
                       ($1*
                        (bind-as
                         #'(E3
                            (force (node-value $1))
                            (force (node-place $1)))))
                       ($1-value* (bind-as #'(force (node-value $1))))
                       ($1-place* (bind-as #'(force (node-place $1))))
                       ($2*
                        (bind-as
                         #'(C4
                            (force (node-value $2))
                            (force (node-place $2))
                            (force (fold-accumulator $2)))))
                       ($2-accumulator* (bind-as #'(force (node-value $2))))
                       ($2-value* (bind-as #'(force (node-place $2))))
                       ($2-place* (bind-as #'(force (fold-accumulator $2)))))
            (begin
              (set-node-value! $$ (delay v))
              (set-node-place! $$ (delay (if has? (not-a-variable) p)))
              (set-fold-accumulator! $2 (delay a))
              (parse-E3 $1)
              (parse-C4 $2)
              (delay $$)))))
       (else (report $$ cur))))
   (define (parse-E2 $$)
     (case (object-name cur)
       ((variable op-sub number open-paren)
        (let* (($1 (E1 '() '())) ($2 (C2 '() '() '())))
          (let-syntax ((a (bind-as #'(force (node-value $1))))
                       (p (bind-as #'(force (node-place $1))))
                       (v (bind-as #'(force (node-value $2))))
                       (has? (bind-as #'(force (node-place $2))))
                       ($$*
                        (bind-as
                         #'(E2
                            (force (node-value $$))
                            (force (node-place $$)))))
                       ($$-value* (bind-as #'(force (node-value $$))))
                       ($$-place* (bind-as #'(force (node-place $$))))
                       ($1*
                        (bind-as
                         #'(E1
                            (force (node-value $1))
                            (force (node-place $1)))))
                       ($1-value* (bind-as #'(force (node-value $1))))
                       ($1-place* (bind-as #'(force (node-place $1))))
                       ($2*
                        (bind-as
                         #'(C2
                            (force (node-value $2))
                            (force (node-place $2))
                            (force (fold-accumulator $2)))))
                       ($2-accumulator* (bind-as #'(force (node-value $2))))
                       ($2-value* (bind-as #'(force (node-place $2))))
                       ($2-place* (bind-as #'(force (fold-accumulator $2)))))
            (begin
              (set-node-value! $$ (delay v))
              (set-node-place! $$ (delay (if has? (not-a-variable) p)))
              (set-fold-accumulator! $2 (delay a))
              (parse-E1 $1)
              (parse-C2 $2)
              (delay $$)))))
       (else (report $$ cur))))
   (define (parse-Op3 $$)
     (case (object-name cur)
       ((op-add)
        (let* (($1 (op-add '() '())))
          (let-syntax (($$* (bind-as #'(Op3 (force (operator-action $$)))))
                       ($$-action* (bind-as #'(force (operator-action $$))))
                       ($1*
                        (bind-as
                         #'(op-add
                            (force (token-pos $1))
                            (force (token-text $1)))))
                       ($1-pos* (bind-as #'(force (token-pos $1))))
                       ($1-text* (bind-as #'(force (token-text $1)))))
            (begin
              (set-operator-action! $$ (delay +))
              (expect-op-add $1)
              (delay $$)))))
       (else (report $$ cur))))
   (define (expect-op-mul $$)
     (unless (op-mul? cur) (report $$ cur))
     (set-token-pos! $$ (token-pos cur))
     (set-token-text! $$ (token-text cur))
     (take))
   (define (as-values result)
     (define fres (force result))
     (values (force (parse-result-value fres))))
   (as-values (parse-parse-result (parse-result '()))))
