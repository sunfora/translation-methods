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
@(require racket/pretty)

@title[
       #:style (with-html5 manual-doc-style)
       #:tag "problem"
       #:version ""
       ]{Lab (4)}

@section{ Запись и семантика }

Грамматику я решил сделать в стиле лиспа: куча списочков просто и всё.
Не хочу особо ничего парсить, пусть парсит сам язык.

Это вот пример того макроса который я в итоге сделал для первой домашки.
Тут есть всякие специальные переменные вида @racket[$i*], @racket[$i], @racket[$i-field*].

Зачем нужны звёздочки и что это вообще значит? 
Доллары примерно как в бизоне обозначают структурки распаршенные или еще нет.

Но при этом в отличие от бизона все поля изначально заполняются как @racket[(delay #,(italic "FIELD-EXPR"))].
Поэтому чтобы получить реальное значение, нам надо еще дёрнуть @racket[(force (#,(italic "NTERM-FIELD") $i))]. 

Переменные @racket[$i*] и @racket[$i-field*] делают это автоматически. 
Первая вещь это копия структурки со всеми полями зафоршенными. Что-то вроде @racket[(#,(italic "NTERM") $i-field_1* $i-field_2* ...)].

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

    (code:comment2 "структура грамматики примерно следующая: мы пишем поля которые мы хотим заполнить в структуре")
    (code:comment2 "например в данном примере поле children у результата заполняется детьми")
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

@section{ Пример сгенерированного кода из парсера }

Устроено оно примерно следующим образом: мы делаем как и всегда для подобных парсеров обыкновенные вещи вроде функций которые чот парсят. 

За единственным исключением, что мы дополнительно говорим, что давайте промапим все специальные переменные, которые по сути являются просто обёрткой над полем некой структуры, как специальный синтаксис. 

И после этого лисп правильно проставит значения, в наши выражения. Заместо обращения к каким-то значениям, мы будем что-то эдакое вычислять. Ну в частности какое-то поле.

В сами поля мы заранее засунем выражения в delay форме. Когда надо тогда вычислим.

Это всё дело по сути позволяет нам совершенно тривиально сделать как наследуемые, так и синтезируемые атрибуты.


@(define (details summary . content) 
   (define details-style 
     (make-style "Details" (list 
                             (attributes '((open . "")))
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

@section{ Примеры работы }

@(define base-eval 
      (parameterize ([sandbox-output 'string]
                     [sandbox-error-output 'string]
                     [sandbox-memory-limit 50])
        (make-base-eval)))

@(base-eval '(require pict racket/port "first/visual.rkt"))

@examples[ 
  #:label #f  
  #:eval base-eval
  (eval:error (parse-string " "))
  (visual "!abra & cadabra")
  (visual "a + b + c + d")
]
