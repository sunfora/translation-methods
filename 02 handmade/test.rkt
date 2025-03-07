#lang racket
(require "lex.rkt")
(require "parser.rkt")
(require "visual.rkt")

(define-syntax-rule (test-case txt rules ...)
  (begin 
    (displayln (format "[~a]" txt))
    rules ...))

(define-syntax-rule (with-values f body ...)
  (call-with-values (λ () body ...) f))

(define (test)
  (define failed? #f)
  (define passed 0)
  (define failed 0)

  (define (fail cs because) 
     (display "[FAILED] ")
     (println cs)
     (set! failed? #t)
     (set! failed (+ 1 failed))

     (displayln "+")
     (displayln because)
     (displayln "+"))
  (define (pass cs)
      (display "[  OK  ] ")
      (println cs)
      (set! passed (+ 1 passed)))

  (define (expect cs value)
    (display (format "\tcheck? "))
    (with-handlers ([exn:fail? (λ (v) 
                                 (fail cs (format "unexpected error ~a" v)))])
      (define t (parse-string cs))
      (if (equal? t value)
        (pass cs)
        (fail cs (format "expected\n~a\nbut got\n~a" 
                      (pretty-format value) (pretty-format t))))))
  (define (experr cs)
    (display (format "\terror? "))
    (define-values (value errored?)
      (with-handlers ([exn:fail? (lambda (v) (values '() #t))])
        (values (parse-string cs) #f)))
    (if errored?
      (pass cs)
      (fail cs (format "expected error but got\n~a" (pretty-format value)))))


  (define (choose fuel)
    (list-ref fuel (random 0 (length fuel))))

  (define (random-from-ranges-combined ranges)
    (define (cntr rng)
      (- (second rng) (first rng) -1))
    (define cnt (for/fold ([ln 0])
                            ([rng ranges])
                  (+ ln (cntr rng))))
    (λ ()
      (define i (random 0 cnt))
      (for/fold ([t i]
                 [p i]
                 [s 0]
                  #:result (integer->char (+ s p)))
                ([rng ranges]
                 #:break (< t 0))
          (values (- t (cntr rng)) t (first rng)))))

  (define (random-from-range ranges)
    (λ ()
      (define rng (choose ranges))
      (define a (first rng))
      (define b (+ (second rng) 1))
      (integer->char (random a b))))

  (define (unicode-ranges pred?)
    (define start #f)  
    (define prev #f) 
    (define result '())
    (define (upd) (set! result (cons (list start prev) result)))
    (for ([cp (in-range 0 #x110000)])
      (define-values (valid-unicode? c) 
        (with-handlers  ([exn:fail? (lambda (v) (values #f '()))])
                  (values #t (integer->char cp))))
      (if (and valid-unicode? (pred? c))
          (begin
            (when (not start)
              (set! start cp))  
            (set! prev cp))
          (when start
            (upd)
            (set! start #f))))
    (when start
      (upd))
    (reverse result))

  (define adequate-whitespace? (λ (x) (or (eq? x #\space)
                                          (eq? x #\newline)
                                          (eq? x #\return))))
  (define r>just-space? 
    (random-from-range (unicode-ranges 
                         (λ (x) (eq? x #\space)))))  
  (define r>adequate-whitespace? 
    (random-from-range (unicode-ranges adequate-whitespace?)))
  (define r>whitespace? 
    (random-from-range (unicode-ranges char-whitespace?)))
  (define r>space? r>just-space?)

  (define r>adequate-var? 
     (random-from-range '((45 45)                      
                          (65 90)
                          (95 95)                      
                          (97 122)                     
                          (97 122)                     
                          (97 122))))                          
  (define r>adequate-num? (random-from-range '((48 57))))
  (define (r>adequate-dvar?)
    ((choose (list r>adequate-var? 
                   r>adequate-var? 
                   r>adequate-var? 
                   r>adequate-var? 
                   r>adequate-num?))))

  (define r>var? (random-from-range (unicode-ranges var?)))
  (define r>dvar? (random-from-range (unicode-ranges dvar?)))

  
  (define (vr pos text)
    (enclose-Pr (variable pos text)))

  (define (enclose-Pr expr)
    (enclose-E1 (Pr expr)))

  (define (enclose-E1 expr)
    (enclose-E2 (E1 (list expr (C1 '())))))
  (define (enclose-E2 expr)
    (enclose-E3 (E2 (list expr (C2 '())))))
  (define (enclose-E3 expr)
    (enclose-E4 (E3 (list expr (C3 '())))))
  (define (enclose-E4 expr)
    (enclose-E5 (E4 (list expr (C4 '())))))
  (define (enclose-E5 expr)
    (enclose-E (E5 (list expr (C5 '())))))
  (define (enclose-E expr)
    (E expr))

  (define (enclose expr)
    (cond 
      [(E5? expr) (enclose-E expr)]
      [(E4? expr) (enclose-E5 expr)]
      [(E3? expr) (enclose-E4 expr)]
      [(E2? expr) (enclose-E3 expr)]
      [(E1? expr) (enclose-E2 expr)]
      [(Pr? expr) (enclose-E1 expr)]
      [else       (enclose-Pr expr)]))
  
  (define (make-Pr a [b '()] [c '()])
    (let/ec return
      (when (open-paren? a)
        (return (Pr (list a (enclose b) c))))
      (when (null? b)
        (return (Pr a)))
      (unless (Un? a)
        (return (make-Pr (Un a) b)))
      (unless (Pr? b)
        (return (make-Pr a (Pr b))))
      (Pr (list a b))))

  (define (make-E1 a [op '()] [b '()])
    (let/ec return
      (unless (Pr? a)
        (return (make-E1 (Pr a) op b)))
      (when (null? op)
        (return (E1 (list a (C1 b)))))
      (unless (Op1? op)
        (return (make-E1 a (Op1 op) b)))
      (unless (E1? b)
        (return (make-E1 a op (make-E1 b))))
      (E1 (list a (C1 (list op b))))))

  (define (make-E2 a [op '()] [b '()])
    (let/ec return
      (unless (E1? a)
        (return (make-E2 (make-E1 a) op b)))
      (when (null? op)
        (return (E2 (list a (C2 b)))))
      (unless (Op2? op)
        (return (make-E2 a (Op2 op) b)))
      (unless (E2? b)
        (return (make-E2 a op (make-E2 b))))
      (E2 (list a (C2 (list op b))))))

  (define (make-E3 a [op '()] [b '()])
    (let/ec return
      (unless (E2? a)
        (return (make-E3 (make-E2 a) op b)))
      (when (null? op)
        (return (E3 (list a (C3 b)))))
      (unless (Op3? op)
        (return (make-E3 a (Op3 op) b)))
      (unless (E3? b)
        (return (make-E3 a op (make-E3 b))))
      (E3 (list a (C3 (list op b))))))


  (define (make-E4 a [op '()] [b '()])
    (let/ec return
      (unless (E3? a)
        (return (make-E4 (make-E3 a) op b)))
      (when (null? op)
        (return (E4 (list a (C4 b)))))
      (unless (Op4? op)
        (return (make-E4 a (Op4 op) b)))
      (unless (E4? b)
        (return (make-E4 a op (make-E4 b))))
      (E4 (list a (C4 (list op b))))))

  (define (make-E5 a [op '()] [b '()])
    (let/ec return
      (unless (E4? a)
        (return (make-E5 (make-E4 a) op b)))
      (when (null? op)
        (return (E5 (list a (C5 b)))))
      (unless (Op5? op)
        (return (make-E5 a (Op5 op) b)))
      (unless (E5? b)
        (return (make-E5 a op (make-E5 b))))
      (E5 (list a (C5 (list op b))))))

  (define stop-nesting-after (make-parameter 100))

  (define space-min (make-parameter 0))
  (define space-max (make-parameter 10))
  (define space-r>white (make-parameter r>space?))

  (define (r>space pos)
    (define times (random (space-min) (space-max)))
    (define str 
      (apply string 
             (for/list ([i (range 0 times)]) 
               ((space-r>white)) )))
    (values (+ times pos) str '() identity 'error))
  
  (define variable-parts-min (make-parameter 1))
  (define variable-parts-max (make-parameter 5))

  (define variable-length-max    (make-parameter 10))
  (define variable-length-min    (make-parameter 1))
  (define variable-char-r>first  (make-parameter r>adequate-var?))
  (define variable-char-r>rest   (make-parameter r>adequate-dvar?))


  (define (r>variable pos)
    (define surrounder enclose-Pr)

    (define times (random (variable-length-min)
                          (variable-length-max)))
    (define str (apply string (cons ((variable-char-r>first))
                                    (for/list ([i (range 0 (- times 1))])
                                      ((variable-char-r>rest))))))
    (values (+ pos times) str (variable pos str) surrounder 'expect))

  (define (spaced f)
    (λ (pos)
      (let*-values ([(sp1 str1 e1 s1 k1) (r>space pos)]
                    [(sp2 str2 e2 s2 k2) (f sp1)]
                    [(sp3 str3 e3 s3 k3) (r>space sp2)])
        (values sp3 
                (string-append str1 str2 str3)
                e2
                s2
                k2)))) 

  (define (r>Un pos)
    (values (+ 1 pos) "!" (Un (make-operation pos "!")) identity 'error))
  (define (r>Op1 pos)
    (values (+ 1 pos) "*" (Op1 (make-operation pos "*")) identity 'error))
  (define (r>Op2 pos)
    (values (+ 1 pos) "+" (Op2 (make-operation pos "+")) identity 'error))
  (define (r>Op3 pos)
    (values (+ 1 pos) "&" (Op3 (make-operation pos "&")) identity 'error))
  (define (r>Op4 pos)
    (values (+ 1 pos) "^" (Op4 (make-operation pos "^")) identity 'error))
  (define (r>Op5 pos)
    (values (+ 1 pos) "|" (Op5 (make-operation pos "|")) identity 'error))

  (define (r>Pr/variable pos)
    (let*-values ([(sp2 str2 e2 s2 k2) (r>variable pos)])
      (values sp2 str2 (Pr e2) enclose-E1 k2)))

  (define (r>Pr/Un-Pr pos)
    (let*-values ([(sp1 str1 e1 s1 k1) (r>Un pos)]
                  [(sp2 str2 e2 s2 k2) (r>space sp1)]
                  [(sp3 str3 e3 s3 k3) (r>Pr sp2)])
      (values sp3 (string-append str1 str2 str3) (Pr (list e1 e3)) s3 k3)))

  (define (r>Pr/E pos)
    (let*-values ([(sp1 str1 e1 s1 k1) ((spaced r>E) (+ pos 1))])
      (values (+ sp1 1) 
              (string-append "(" str1 ")")
              (Pr (list (open-paren pos "(") 
                        e1
                        (close-paren sp1 ")")))
              enclose-E1
              k1)))

  (define (r>C1/Op1-E1 pos)
    (let*-values ([(sp1 str1 e1 s1 k1) ((spaced r>Op1) pos)]
                  [(sp2 str2 e2 s2 k2) (r>E1 sp1)])
      (values sp2 (string-append str1 str2)
              (C1 (list e1 e2))
              identity
              'error)))
  (define (r>C1/ε pos)
    (values pos "" (C1 '()) identity 'error))
  (define (r>C1 pos)
    (if  (< (stop-nesting-after) pos)
      (r>C1/ε pos)
      ((choose (list r>C1/Op1-E1 r>C1/ε)) pos)))
  (define (r>E1 pos)
    (let*-values ([(sp1 str1 e1 s1 k1) (r>Pr pos)]
                  [(sp2 str2 e2 s2 k2) (r>C1 sp1)])
      (values sp2 (string-append str1 str2)
              (E1 (list e1 e2))
              enclose
              k1)))


  (define (r>C2/Op2-E2 pos)
    (let*-values ([(sp1 str1 e1 s1 k1) ((spaced r>Op2) pos)]
                  [(sp2 str2 e2 s2 k2) (r>E2 sp1)])
      (values sp2 (string-append str1 str2)
              (C2 (list e1 e2))
              identity
              'error)))
  (define (r>C2/ε pos)
    (values pos "" (C2 '()) identity 'error))
  (define (r>C2 pos)
    (if  (< (stop-nesting-after) pos)
      (r>C2/ε pos)
      ((choose (list r>C2/Op2-E2 r>C2/ε)) pos)))
  (define (r>E2 pos)
    (let*-values ([(sp1 str1 e1 s1 k1) (r>E1 pos)]
                  [(sp2 str2 e2 s2 k2) (r>C2 sp1)])
      (values sp2 (string-append str1 str2)
              (E2 (list e1 e2))
              enclose
              k1)))


  (define (r>C3/Op3-E3 pos)
    (let*-values ([(sp1 str1 e1 s1 k1) ((spaced r>Op3) pos)]
                  [(sp2 str2 e2 s2 k2) (r>E3 sp1)])
      (values sp2 (string-append str1 str2)
              (C3 (list e1 e2))
              identity
              'error)))
  (define (r>C3/ε pos)
    (values pos "" (C3 '()) identity 'error))
  (define (r>C3 pos)
    (if  (< (stop-nesting-after) pos)
      (r>C3/ε pos)
      ((choose (list r>C3/Op3-E3 r>C3/ε)) pos)))
  (define (r>E3 pos)
    (let*-values ([(sp1 str1 e1 s1 k1) (r>E2 pos)]
                  [(sp2 str2 e2 s2 k2) (r>C3 sp1)])
      (values sp2 (string-append str1 str2)
              (E3 (list e1 e2))
              enclose
              k1)))


  (define (r>C4/Op4-E4 pos)
    (let*-values ([(sp1 str1 e1 s1 k1) ((spaced r>Op4) pos)]
                  [(sp2 str2 e2 s2 k2) (r>E4 sp1)])
      (values sp2 (string-append str1 str2)
              (C4 (list e1 e2))
              identity
              'error)))
  (define (r>C4/ε pos)
    (values pos "" (C4 '()) identity 'error))
  (define (r>C4 pos)
    (if  (< (stop-nesting-after) pos)
      (r>C4/ε pos)
      ((choose (list r>C4/Op4-E4 r>C4/ε)) pos)))
  (define (r>E4 pos)
    (let*-values ([(sp1 str1 e1 s1 k1) (r>E3 pos)]
                  [(sp2 str2 e2 s2 k2) (r>C4 sp1)])
      (values sp2 (string-append str1 str2)
              (E4 (list e1 e2))
              enclose
              k1)))


  (define (r>C5/Op5-E5 pos)
    (let*-values ([(sp1 str1 e1 s1 k1) ((spaced r>Op5) pos)]
                  [(sp2 str2 e2 s2 k2) (r>E5 sp1)])
      (values sp2 (string-append str1 str2)
              (C5 (list e1 e2))
              identity
              'error)))
  (define (r>C5/ε pos)
    (values pos "" (C5 '()) identity 'error))
  (define (r>C5 pos)
    (if  (< (stop-nesting-after) pos)
      (r>C5/ε pos)
      ((choose (list r>C5/Op5-E5 r>C5/ε)) pos)))
  (define (r>E5 pos)
    (let*-values ([(sp1 str1 e1 s1 k1) (r>E4 pos)]
                  [(sp2 str2 e2 s2 k2) (r>C5 sp1)])
      (values sp2 (string-append str1 str2)
              (E5 (list e1 e2))
              enclose
              k1)))

  (define (r>E pos)
    (let*-values ([(sp1 str1 e1 s1 k1) (r>E5 pos)])
      (values sp1
              str1
              (s1 e1)
              identity
              k1)))

  (define (r>Pr pos)
    (if (< (stop-nesting-after) pos)
      (r>Pr/variable pos)
      ((choose (list r>Pr/variable r>Pr/Un-Pr r>Pr/E)) pos)))



  (define (random-test f)
    (define pos 0)
    (let-values ([(pos str expected surrounder kind) (f 0)])
      (if (eq? kind 'error)
        (experr str)
        (expect str (surrounder expected)))))

  (test-case "пустое выражение"
    (experr "")
    (experr " " )
    (experr "   ")
    )
  (test-case "рандомные пустые"
    (for ([i (range 1 10)])
      (random-test r>space)))
  (test-case "переменные"
    (expect "a" (vr 0 "a"))
    (expect "b   " (vr 0 "b"))
    (expect "   c   " (vr 3 "c")))
  (test-case "длинные переменные"
      (expect "some-var" (vr 0 "some-var"))
      (expect "lol_var   " (vr 0 "lol_var"))
      (expect "_" (vr 0 "_"))
      (expect "   abracadabra   " (vr 3 "abracadabra"))
      (expect "som124e-var" (vr 0 "som124e-var"))
      (expect "var1" (vr 0 "var1"))
      (expect "var2" (vr 0 "var2")))
  (test-case "невалидные переменные"
      (experr "some-v$c43j89ar")
      (experr "@some-vc43j89ar")
      (experr "some-vc43j89ar@"))
  (test-case "рандомные переменные"
    (for ([i (range 1 10)])
      (random-test r>variable)))
  (test-case "рандомные переменные + пробелы"
    (for ([i (range 1 10)])
      (random-test (spaced r>variable))))
  (test-case "рандомные переменные + whitespace"
    (parameterize ([space-r>white r>whitespace?]
                   [space-max 5]
                   [variable-length-max 4])
      (for ([i (range 1 10)])
        (random-test (spaced r>variable)))))
  (test-case "простые унарные операции"
    (expect 
      "! a" 
      (enclose 
        (make-Pr (make-operation 0 "!")
                 (variable 2 "a"))))
    (expect 
      "!a" 
      (enclose 
        (make-Pr (make-operation 0 "!") 
                 (variable 1 "a"))))
    (expect 
      " !a" 
      (enclose 
        (make-Pr (make-operation 1 "!") 
                 (variable 2 "a"))))
    (expect 
      "!a " 
      (enclose 
        (make-Pr (make-operation 0 "!") 
                 (variable 1 "a")))))
  (test-case "сложные унарные"
    (expect 
      "!!a" 
      (enclose 
        (make-Pr (make-operation 0 "!") 
                 (make-Pr (make-operation 1 "!") 
                          (variable 2 "a")))))
    (expect 
      "!(!a)" 
      (enclose 
        (make-Pr 
          (make-operation 0 "!")
          (make-Pr
              (open-paren 1 "(")
              (make-Pr 
                  (make-operation 2 "!")
                  (variable 3 "a"))
              (close-paren 4 ")")))))

    (experr "!@a")
    (expect 
      "! !!a" 
      (enclose 
        (make-Pr (make-operation 0 "!") 
                 (make-Pr (make-operation 2 "!")
                          (make-Pr (make-operation 3 "!")
                                   (variable 4 "a")))))))


  (test-case "приоритет 1 : ассоциативность правая"
    (expect 
      "a * b" 
      (enclose
        (make-E1 (variable 0 "a")
                 (make-operation 2 "*")
                 (variable 4 "b"))))
    (expect 
      "a * b * c" 
      (enclose
        (make-E1 (variable 0 "a")
                 (make-operation 2 "*")
                 (make-E1 
                   (variable 4 "b") 
                   (make-operation 6 "*")
                   (variable 8 "c")))))
    (expect 
      "(a * b) * c" 
      (enclose
        (make-E1 
          (make-Pr 
            (open-paren 0 "(")
            (make-E1 (variable 1 "a")
                     (make-operation 3 "*")
                     (variable 5 "b"))
            (close-paren 6 ")"))
          (make-operation 8 "*")
          (variable 10 "c"))))
    (expect 
      "a * ! b * c" 
      (enclose
        (make-E1 (variable 0 "a")
                 (make-operation 2 "*")
                 (make-E1 
                   (make-Pr (make-operation 4 "!")
                            (variable 6 "b"))
                   (make-operation 8 "*")
                   (variable 10 "c"))))))
  (test-case "приоритет 1 : пропущенный операнд"
    (experr "a * b * ")
    (experr "a * * b"))

  (test-case "приоритет 2 : ассоциативность правая"
    (expect 
      "a + b" 
      (enclose
        (make-E2 (variable 0 "a")
                 (make-operation 2 "+")
                 (variable 4 "b"))))
    (expect 
      "a + b + c"
      (enclose 
        (make-E2 (variable 0 "a")
                 (make-operation 2 "+")
                 (make-E2 
                   (variable 4 "b")
                   (make-operation 6 "+")
                   (variable 8 "c")))))

    (expect 
      "(a + b) + c"
      (enclose 
        (make-E2 (make-Pr
                   (open-paren 0 "(")
                   (make-E2
                     (variable 1 "a")
                     (make-operation 3 "+")
                     (variable 5 "b"))
                   (close-paren 6 ")"))
                 (make-operation 8 "+")
                 (variable 10 "c"))))
    (expect 
      "a + b * c"
      (enclose 
        (make-E2 (variable 0 "a")
                 (make-operation 2 "+")
                 (make-E1 
                   (variable 4 "b")
                   (make-operation 6 "*")
                   (variable 8 "c")))))
    (expect 
      "a * b + c"
      (enclose 
        (make-E2 (make-E1 
                   (variable 0 "a")
                   (make-operation 2 "*")
                   (variable 4 "b"))
                 (make-operation 6 "+")
                 (variable 8 "c"))))
    (expect 
      "a * (b + c)" 
      (enclose 
        (make-E1
          (variable 0 "a")
          (make-operation 2 "*")
          (make-Pr (open-paren 4 "(")
                   (make-E2 
                     (variable 5 "b")
                     (make-operation 7 "+")
                     (variable 9 "c"))
                   (close-paren 10 ")")))))
    (expect 
      "a + ! b + c" 
      (enclose
        (make-E2 (variable 0 "a")
                 (make-operation 2 "+")
                 (make-E2 
                   (make-Pr (make-operation 4 "!")
                            (variable 6 "b"))
                   (make-operation 8 "+")
                   (variable 10 "c"))))))
  (test-case "приоритет 2 : пропущенный операнд"
    (experr "a + b * ")
    (experr "a + + b")
    (experr "a + c + !")
    (experr "a * b + "))


  (test-case "приоритет 3 : ассоциативность правая"
    (expect 
      "a & b" 
      (enclose
        (make-E3 (variable 0 "a")
                 (make-operation 2 "&")
                 (variable 4 "b"))))
    (expect 
      "a & b & c"
      (enclose 
        (make-E3 (variable 0 "a")
                 (make-operation 2 "&")
                 (make-E3 
                   (variable 4 "b")
                   (make-operation 6 "&")
                   (variable 8 "c")))))

    (expect 
      "(a & b) & c"
      (enclose 
        (make-E3 (make-Pr
                   (open-paren 0 "(")
                   (make-E3
                     (variable 1 "a")
                     (make-operation 3 "&")
                     (variable 5 "b"))
                   (close-paren 6 ")"))
                 (make-operation 8 "&")
                 (variable 10 "c"))))
    (expect 
      "a & b + c"
      (enclose 
        (make-E3 (variable 0 "a")
                 (make-operation 2 "&")
                 (make-E2 
                   (variable 4 "b")
                   (make-operation 6 "+")
                   (variable 8 "c")))))
    (expect 
      "a + b & c"
      (enclose 
        (make-E3 (make-E2 
                   (variable 0 "a")
                   (make-operation 2 "+")
                   (variable 4 "b"))
                 (make-operation 6 "&")
                 (variable 8 "c"))))
    (expect 
      "a + (b & c)" 
      (enclose 
        (make-E2
          (variable 0 "a")
          (make-operation 2 "+")
          (make-Pr (open-paren 4 "(")
                   (make-E3 
                     (variable 5 "b")
                     (make-operation 7 "&")
                     (variable 9 "c"))
                   (close-paren 10 ")")))))
    (expect 
      "a & ! b & c" 
      (enclose
        (make-E3 (variable 0 "a")
                 (make-operation 2 "&")
                 (make-E3 
                   (make-Pr (make-operation 4 "!")
                            (variable 6 "b"))
                   (make-operation 8 "&")
                   (variable 10 "c")))))

    (expect 
      "a & ! b + d & c" 
      (enclose
        (make-E3 (variable 0 "a")
                 (make-operation 2 "&")
                 (make-E3 
                   (make-E2 
                     (make-Pr (make-operation 4 "!")
                              (variable 6 "b"))
                     (make-operation 8 "+")
                     (variable 10 "d"))
                   (make-operation 12 "&")
                   (variable 14 "c")))))

    (expect 
      "a & ! b + d * e & c" 
      (enclose
        (make-E3 (variable 0 "a")
                 (make-operation 2 "&")
                 (make-E3 
                   (make-E2 
                     (make-Pr (make-operation 4 "!")
                              (variable 6 "b"))
                     (make-operation 8 "+")
                     (make-E1 (variable 10 "d")
                              (make-operation 12 "*")
                              (variable 14 "e")))
                   (make-operation 16 "&")
                   (variable 18 "c"))))))
  (test-case "приоритет 3 : пропущенный операнд"
    (experr "a + b & c * ")
    (experr "a + d + & b")
    (experr "a&e + c + !")
    (experr "a * x  & b & "))


  (test-case "приоритет 4 : ассоциативность правая"
    (expect 
      "a ^ b" 
      (enclose
        (make-E4 (variable 0 "a")
                 (make-operation 2 "^")
                 (variable 4 "b"))))
    (expect 
      "a ^ b ^ c"
      (enclose 
        (make-E4 (variable 0 "a")
                 (make-operation 2 "^")
                 (make-E4 
                   (variable 4 "b")
                   (make-operation 6 "^")
                   (variable 8 "c")))))

    (expect 
      "(a ^ b) ^ c"
      (enclose 
        (make-E4 (make-Pr
                   (open-paren 0 "(")
                   (make-E4
                     (variable 1 "a")
                     (make-operation 3 "^")
                     (variable 5 "b"))
                   (close-paren 6 ")"))
                 (make-operation 8 "^")
                 (variable 10 "c"))))
    (expect 
      "a ^ b & c"
      (enclose 
        (make-E4 (variable 0 "a")
                 (make-operation 2 "^")
                 (make-E3 
                   (variable 4 "b")
                   (make-operation 6 "&")
                   (variable 8 "c")))))
    (expect 
      "a & b ^ c"
      (enclose 
        (make-E4 (make-E3 
                   (variable 0 "a")
                   (make-operation 2 "&")
                   (variable 4 "b"))
                 (make-operation 6 "^")
                 (variable 8 "c"))))
    (expect 
      "a & (b ^ c)" 
      (enclose 
        (make-E3
          (variable 0 "a")
          (make-operation 2 "&")
          (make-Pr (open-paren 4 "(")
                   (make-E4 
                     (variable 5 "b")
                     (make-operation 7 "^")
                     (variable 9 "c"))
                   (close-paren 10 ")")))))
    (expect 
      "a ^ ! b ^ c" 
      (enclose
        (make-E4 (variable 0 "a")
                 (make-operation 2 "^")
                 (make-E4 
                   (make-Pr (make-operation 4 "!")
                            (variable 6 "b"))
                   (make-operation 8 "^")
                   (variable 10 "c")))))

    (expect 
      "a ^ ! b + d ^ c" 
      (enclose
        (make-E4 (variable 0 "a")
                 (make-operation 2 "^")
                 (make-E4 
                   (make-E2 
                     (make-Pr (make-operation 4 "!")
                              (variable 6 "b"))
                     (make-operation 8 "+")
                     (variable 10 "d"))
                   (make-operation 12 "^")
                   (variable 14 "c")))))

    (expect 
      "a ^ ! b + c * d ^ e" 
      (enclose
        (make-E4 (variable 0 "a")
                 (make-operation 2 "^")
                 (make-E4 
                   (make-E2 
                     (make-Pr (make-operation 4 "!")
                              (variable 6 "b"))
                     (make-operation 8 "+")
                     (make-E1 (variable 10 "c")
                              (make-operation 12 "*")
                              (variable 14 "d")))
                   (make-operation 16 "^")
                   (variable 18 "e")))))
    (expect 
      "a ^ ! b + c * d & e ^ f" 
      (enclose
        (make-E4 (variable 0 "a")
                 (make-operation 2 "^")
                 (make-E4 
                   (make-E3
                     (make-E2 
                       (make-Pr (make-operation 4 "!")
                                (variable 6 "b"))
                       (make-operation 8 "+")
                       (make-E1 (variable 10 "c")
                                (make-operation 12 "*")
                                (variable 14 "d")))
                     (make-operation 16 "&")
                     (variable 18 "e"))
                   (make-operation 20 "^")
                   (variable 22 "f"))))))
  (test-case "приоритет 4 : пропущенный операнд"
    (experr "a + ^ e ^ lol b & c * ")
    (experr "a + d + & b ^")
    (experr "a&e + c + !xyz^")
    (experr "x ^ !!!!!!!!!!!x ^"))


  (test-case "приоритет 5 : ассоциативность правая"
    (expect 
      "a | b" 
      (enclose
        (make-E5 (variable 0 "a")
                 (make-operation 2 "|")
                 (variable 4 "b"))))
    (expect 
      "a | b | c"
      (enclose 
        (make-E5 (variable 0 "a")
                 (make-operation 2 "|")
                 (make-E5 
                   (variable 4 "b")
                   (make-operation 6 "|")
                   (variable 8 "c")))))

    (expect 
      "(a | b) | c"
      (enclose 
        (make-E5 (make-Pr
                   (open-paren 0 "(")
                   (make-E5
                     (variable 1 "a")
                     (make-operation 3 "|")
                     (variable 5 "b"))
                   (close-paren 6 ")"))
                 (make-operation 8 "|")
                 (variable 10 "c"))))
    (expect 
      "a | b ^ c"
      (enclose 
        (make-E5 (variable 0 "a")
                 (make-operation 2 "|")
                 (make-E4 
                   (variable 4 "b")
                   (make-operation 6 "^")
                   (variable 8 "c")))))
    (expect 
      "a ^ b | c"
      (enclose 
        (make-E5 (make-E4 
                   (variable 0 "a")
                   (make-operation 2 "^")
                   (variable 4 "b"))
                 (make-operation 6 "|")
                 (variable 8 "c"))))
    (expect 
      "a ^ (b | c)" 
      (enclose 
        (make-E4
          (variable 0 "a")
          (make-operation 2 "^")
          (make-Pr (open-paren 4 "(")
                   (make-E5 
                     (variable 5 "b")
                     (make-operation 7 "|")
                     (variable 9 "c"))
                   (close-paren 10 ")")))))
    (expect 
      "a | ! b | c" 
      (enclose
        (make-E5 (variable 0 "a")
                 (make-operation 2 "|")
                 (make-E5 
                   (make-Pr (make-operation 4 "!")
                            (variable 6 "b"))
                   (make-operation 8 "|")
                   (variable 10 "c")))))

    (expect 
      "a | ! b + d | c" 
      (enclose
        (make-E5 (variable 0 "a")
                 (make-operation 2 "|")
                 (make-E5 
                   (make-E2 
                     (make-Pr (make-operation 4 "!")
                              (variable 6 "b"))
                     (make-operation 8 "+")
                     (variable 10 "d"))
                   (make-operation 12 "|")
                   (variable 14 "c")))))

    (expect 
      "a | ! b + c * d | e" 
      (enclose
        (make-E5 (variable 0 "a")
                 (make-operation 2 "|")
                 (make-E5 
                   (make-E2 
                     (make-Pr (make-operation 4 "!")
                              (variable 6 "b"))
                     (make-operation 8 "+")
                     (make-E1 (variable 10 "c")
                              (make-operation 12 "*")
                              (variable 14 "d")))
                   (make-operation 16 "|")
                   (variable 18 "e")))))
    (expect 
      "a | ! b + c * d & e | f" 
      (enclose
        (make-E5 (variable 0 "a")
                 (make-operation 2 "|")
                 (make-E5 
                   (make-E3
                     (make-E2 
                       (make-Pr (make-operation 4 "!")
                                (variable 6 "b"))
                       (make-operation 8 "+")
                       (make-E1 (variable 10 "c")
                                (make-operation 12 "*")
                                (variable 14 "d")))
                     (make-operation 16 "&")
                     (variable 18 "e"))
                   (make-operation 20 "|")
                   (variable 22 "f")))))
    (expect 
      "a | ! b + c * d & e ^ f | g" 
      (enclose
        (make-E5 (variable 0 "a")
                 (make-operation 2 "|")
                 (make-E5 
                   (make-E4
                     (make-E3
                       (make-E2 
                         (make-Pr (make-operation 4 "!")
                                  (variable 6 "b"))
                         (make-operation 8 "+")
                         (make-E1 (variable 10 "c")
                                  (make-operation 12 "*")
                                  (variable 14 "d")))
                       (make-operation 16 "&")
                       (variable 18 "e"))
                     (make-operation 20 "^")
                     (variable 22 "f"))
                   (make-operation 24 "|")
                   (variable 26 "g"))))))
  (test-case "приоритет 5 : пропущенный операнд"
    (experr "a + ^ e ^ lol b & c * || || ")
    (experr "a + d + & b ^ x | y | ")
    (experr "a&e + c + !xyz^z|")
    (experr "x | (x + x | )"))
  (test-case "скобки чтобы поменять приоритеты"
    (expect 
      "(((((a | b) ^ c) & d) + e) * f)"
      (enclose 
        (make-Pr 
          (open-paren 0 "(")
          (make-E1
            (make-Pr 
              (open-paren 1 "(")
              (make-E2
                (make-Pr
                  (open-paren 2 "(")
                  (make-E3
                    (make-Pr 
                      (open-paren 3 "(")
                      (make-E4
                        (make-Pr 
                          (open-paren 4 "(")
                          (make-E5 (variable 5 "a")
                                   (make-operation 7 "|")
                                   (variable 9 "b"))
                          (close-paren 10 ")"))
                        (make-operation 12 "^")
                        (variable 14 "c"))
                      (close-paren 15 ")"))
                    (make-operation 17 "&")
                    (variable 19 "d"))
                  (close-paren 20 ")"))
                (make-operation 22 "+")
                (variable 24 "e"))
              (close-paren 25 ")"))
            (make-operation 27 "*")
            (variable 29 "f"))
          (close-paren 30 ")")))))
  
  (test-case "рандомные выраженья"
    (parameterize ([space-max 1]
                   [stop-nesting-after 50]
                   [variable-length-max 4]
                   [variable-length-min 1])
      (for ([i (range 1 81)])
        (random-test (spaced r>E)))))
  (displayln (format "passed: ~a/~a" passed (+ passed failed)))
  (displayln (format "failed: ~a" failed))
  (displayln (format "result: ~a" (if failed? "failed" "passed"))))

(provide test)
