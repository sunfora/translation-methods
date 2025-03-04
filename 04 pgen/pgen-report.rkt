#lang scribble/manual
@(require (for-label racket))
@(require scribble-math)
@(require scribble/base)
@(require scribble/example)
@(require racket/sandbox)
@(require scribble-include-text)
@(require racket/file)
@(require scribble/core)
@(require scribble/html-properties)
@(require racket/port)
@(require (only-in racket pi))
@(require (only-in pict inset ht-append vl-append pin-arrow-line lb-find cb-find ct-find rc-find rb-find scale pict->bitmap))
@(require (only-in pict/code
                   code))
@(require racket/class)
@(require racket/pretty)

@title[
       #:style (with-html5 manual-doc-style)
       #:tag "problem"
       #:version ""
       ]{Lab (4)}

@(define (red text) 
   (define red-style
     (make-style "red" (list 
                            (make-css-addition 
                              #"
                                .red{
                                  color: red !important;
                                }")
                             (alt-tag "span"))))
    (define selem @element[red-style text])
    selem)

@(define (green text) 
   (define red-style
     (make-style "green" (list 
                            (make-css-addition 
                              #"
                                .green{
                                  color: green !important;
                                }")
                             (alt-tag "span"))))
    (define selem @element[red-style text])
    selem)

@section[#:tag "done"]{Что сделано?}
@tabular[#:sep @hspace[5]
         (list (list @tt{LL(1) } @green{✓}   "10" )
               (list @tt{LALR  } @red{✗}   "" )
               (list @tt{SLR   } @red{✗}   "" )
               (list @tt{L-attr} @green{✓}   "10" )
               (list @tt{S-attr} @green{✓}   "10" )
               (list @tt{lab (2)} @green{✓}   "5" )
               (list @tt{arith } @green{✓}   "" )
               (list @tt{lab (3)} @green{✓}   "10" )
               (list @bold{итого:} ""   "45?"))]

@section[#:tag "overview"]{Запись и семантика}

@(define picture ((λ ()
    (define $2-value* (code $2-value*))
    (define $1 (code $1*))
    (define .x (inset (code .x) 5 0))
    (define type (inset (code type) 100 0 0 0))
    (define result (code (result #,.x #,type           (list #,$2-value* #,$1))))
    (define x1 (code x))
    (define x2 (code x))
    (define .r (code .r))
    (define r (code r))
    (define expr (code (expr (+ #,x1 1) #,.r)))
    (define op (code (op #,r #,x2   )))
    (define .type (code .type))
    (define s (code (s #,.type)))

    (define test2 (code [#,(ht-append 20 (ht-append 20 expr op) s) ]))
    (define test (inset (code [#,(vl-append 40 result test2)]) 30 10 30 60))

    (set! test (pin-arrow-line 7
                    test
                    .x cb-find
                    x1 ct-find))

    (set! test (pin-arrow-line 7
                    test
                    .x rc-find
                    x2 ct-find
                    #:start-angle 0
                    #:end-angle (/ (- pi) 2)))

    (set! test (pin-arrow-line 7
                    test
                    .type ct-find
                    type (λ (p f) (let-values ([(x y) (rb-find p f)])
                                    (values (- x 10) y)))
                    #:start-angle (/ pi 2)
                    #:end-angle (/ pi 2)))

    (set! test (pin-arrow-line 7
                    test
                    .r cb-find
                    r cb-find
                    #:start-angle (- (/ pi 2))
                    #:end-angle (/ pi 3)))

    (set! test (pin-arrow-line 7
                    test
                    op (λ (p f) (let-values ([(x y) (rb-find p f)])
                                        (values (- x 15) y)))
                    $2-value* cb-find
                    #:style 'long-dash
                    #:start-angle (- (/ pi 3.5))
                    #:end-angle (/ pi 2)))

    (set! test (pin-arrow-line 7
                    test
                    expr (λ (p f) (let-values ([(x y) (lb-find p f)])
                                              (values (+ x 15) y)))
                    $1 cb-find
                    #:style 'long-dash
                    #:start-angle (- (/ pi 3))
                    #:end-angle (/ pi 2.5)))

    (set! test (scale test 10))
    
    (send (pict->bitmap test) save-file "dataflow-pgen.png" 'png)
    test)))

Запись правил и общий dataflow отображен на картинке. Первым идёт нетерминал, затем его продукции.
Передача значений происходит через своеобразный late-binding. Слоты соответствуют полям. 
Данные идут от полей с точками в ту сторону где оно без точки.

@image["dataflow-pgen.png" #:scale 0.15]

Так же существует возможность доступа к полям которые не указаны явно. 
Для этого надо написать номер структуры и название поля со звездой.

Либо можно захватить всю структуру целиком: если @racket[$i*], то это будет копия структуры с значениями в данный момент.
Если просто @racket[$i], то там будут поля который возможно еще не посчитаны, надо делать @racket[force]

Вычисления происходят в целом слева направо. 
Если для вычислений требуется некоторое значение, но его еще нет, то вы @italic{ССЗБ}.

Для L/S атрибутных грамматик всё будет нормально работать.

@section[#:tag "lab-2"]{Пример: 2-ая лаба}

Начнём сразу с содержательных вещей, посмотрим как с помощью этого делать вторую вторую лабу.

@(racketblock
    (code:comment2 "мы должны написать кучу разных структурок для нашего парсера")
    (code:comment2 "ВАЖНО: все их поля должны быть mutable, чтобы оно работало")
    
    (code:comment2 "заведём нетерминалы")
    (struct nterm ()             #:transparent #:mutable)
    (struct node (children)             #:transparent #:mutable)
    (struct E   node () #:transparent #:mutable)
    (struct Un  node () #:transparent #:mutable)
    (struct Op1 node () #:transparent #:mutable)
    ...
    (struct C5  node () #:transparent #:mutable)
    (struct C5  node () #:transparent #:mutable)

    (code:comment2 "эта фигня будет хранить наши итоговые значения")
    (struct parse-result nterm (value) #:transparent #:mutable)

    (code:comment2 "заведём терминалы")
    (struct token (pos text)      #:transparent #:mutable)
    (struct end-of-input token () #:transparent #:mutable)
    (struct op-neg       token () #:transparent #:mutable)
    ...
    (struct violation    token () #:transparent #:mutable)

    
    (code:comment2 "лексер примерно полностью повторяет лексер из первой домашки, поэтому я его пропущу")
    (define (lexer in)
      ...)

    (code:comment2 "пишем как мы детей короче собираем и по сути просто повторяем обычную историю с LL(1) грамматикой")
    (define parse 
      (make-parser {
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
      }))
)

@subsection[#:tag "generated-code" #:tag-prefix "lab-2"]{Сгенерированный код}

В целом можно уже тут посмотреть и понять как устроен вот этот механизм передачи и наследования значений.
Мы в каждой функции перед телом выражения, которое заделеено, прописываем серию синтаксических подстановок.

И получается что мы забесплатно получаем копии обращений без необходимости явно вызывать @racket[force].

@(define (details summary [open? #t] . content)
   (define attr (if open? '((open . "")) '()))
   (define details-style 
     (make-style "Details" (list 
                             (attributes attr)
                             (alt-tag "details"))))

   (define summary-style
     (make-style "Summary" (list 
                            (make-css-addition 
                              #"
                                .Summary {
                                  font-size: 1.2rem !important;
                                  font-familty: 'Fira Mono', monospace !important;
                                }")
                             (alt-tag "summary"))))
    (define selem @paragraph[summary-style summary])
    (nested-flow details-style (cons selem content)))

@details["Спрятать"]{@(codeblock @(file->string "first/expanded-program.rkt"))}

@subsection[#:tag "execution" #:tag-prefix "lab-2"]{Примеры исполнения}

@(define first-eval 
      (parameterize ([sandbox-output 'string]
                     [sandbox-error-output 'string]
                     [sandbox-memory-limit 50])
        (make-base-eval)))

@(first-eval '(require pict racket/port "first/visual.rkt"))

@examples[ 
  #:label #f  
  #:eval first-eval
  (eval:error (parse-string " "))
  (visual "!abra & cadabra")
  (visual "a + b + c + d")
]

@section[#:tag "calc"]{Пример: парсер арифметических выражений}

@details["Типы" #t]{@(codeblock @(file->string "calc/types.rkt"))}
@details["Лексер" #f]{@(codeblock @(file->string "calc/lexer.rkt"))}
@details["Парсер" #t]{@(codeblock @(file->string "calc/parser.rkt"))}

@subsection[#:tag "generated" #:tag-prefix "calc"]{Код}

@details["После экспансии" #f]{@(codeblock @(file->string "calc/expanded-program.rkt"))}

@subsection[#:tag "examples" #:tag-prefix "calc"]{Примеры}

@(define calc-eval
      (parameterize ([sandbox-output 'string]
                     [sandbox-error-output 'string]
                     [sandbox-memory-limit 50])
        (make-base-eval)))

@(calc-eval '(require "calc/visual.rkt"))

@examples[ 
  #:label #f  
  #:eval calc-eval
  (eval:error (parse-string " "))
  (parse-string "1 + 2/3 * 5 + 8")
  (parse-string "1 / 2 / 3 / 4")
  (parse-string "1 - -4")
  (parse-string "6/7 * (2 - 5)")
]

@section[#:tag "lab-3"]{Пример: 3-я лаба}

@details["Типы" #t]{@(codeblock @(file->string "second/types.rkt"))}
@details["Лексер" #f]{@(codeblock @(file->string "second/lexer.rkt"))}
@details["Парсер" #t]{@(codeblock @(file->string "second/parser.rkt"))}

@subsection[#:tag "generated" #:tag-prefix "lab-3"]{Код}

@details["После экспансии" #f]{@(codeblock @(file->string "second/expanded-program.rkt"))}

@subsection[#:tag "examples" #:tag-prefix "second"]{Примеры}

@(define second-eval
      (parameterize ([sandbox-output 'string]
                     [sandbox-error-output 'string]
                     [sandbox-memory-limit 50])
        (make-base-eval)))

@(second-eval '(require "second/visual.rkt"))

@examples[ 
  #:label #f  
  #:eval second-eval
  (eval:error (calc " "))
  (calc "1 + 2/3 * 5 + 8")
  (calc "1 / 2 / 3 / 4")
  (calc "1 - -4")
  (calc "6/7 * (2 - 5)")
  (eval:error (calc "undefined-variable"))
  (calc "c = (v = 5) + v * v")
  (calc "v")
  (calc "c")
  (calc "(a) = 5")
  (eval:error (calc "(1 + a) = 5"))
  (eval:error (calc "(1 + ((b = a) = 1 + (a = 1 * 2 * 3 * 4 * 5))) = 5"))
  (eval:error (calc "a - a / (a - a)"))
  (eval:error (calc "x = (x = x) = 1"))
  (eval:error (calc "x = (x = 1/0) = 1"))
  (calc "x = (x = 3) = 1")
  (calc "(x = (x = 3)) = 1")
]

@section[#:tag "check"]{Что если грамматика не LL(1)?}

@(define check-eval
      (parameterize ([sandbox-output 'string]
                     [sandbox-error-output 'string]
                     [sandbox-memory-limit 50])
        (make-base-eval)))

@(check-eval '(require "pgen.rkt"))

Ну... фигулина наша радостно сообщит.

@examples[
  #:label #f
  #:eval check-eval
  (struct token (pos text) #:mutable #:transparent)
  (struct nterm () #:mutable #:transparent)
  (struct E nterm (value) #:mutable #:transparent)
  (define (lexer in)
    (error 'not-implemented))
  (eval:error
    (make-parser {
      [lexer lexer]
      [grammar #:start-with E
          [(E) [(E) (token) (E)]]
          [(E) []]]
    }))
]

@section[#:tag "gen-source"]{Исходники генератора}

Можно было бы в теории детальней поговорить об этом. 
Но по сути я просто использовал трансфомеры ракета и делал вещи в стиле того что предлагалось в лекциях. 

Ну то есть не бог весь какие интересные вещи.

@(codeblock @(file->string "pgen.rkt"))
