#lang racket

;;
;; TODO:
;; 1. делаем first follow для грамматики
;;    верифицируем на примере из первой лабы
;; 2. придумываем запись для нашего парсера
;; 3. будем делать LL(1) грамматику (10 баллов)
;;    с пробросом контекста 
;;    (наследуемыми + синтезируемыми атрибутами)  (10 баллов)
;;                                                (10 баллов)
;; 4. генерируем (возможно с помощью макроса результат)
;; 5.0 делаем калькулятор (но это моя вторая лаба)  (10 баллов)
;; 5.1 делаем первую лабу                           (5 баллов)
;;
;; итого вроде ожидаю чот на уровне 45 баллов
;; и надо будет написать report в котором всё это я покажу
;;
;; времени не очень много, я хотел бы конечно потыкать LALR и генерить бинарники какие-нибудь
;; управляющие таблички и всё такое
;; но я дурачок и всё зафакапил как всегда, так что забейте
;;
;;
'{
  ;; токены у нас будет обязан заполнять лексер
  ;; лексер должен юзать по идее интерфейс такой:
  ;;
  ;; у парсера есть правила, парсер знает что вот first
  ;; от E это набор токенов
  ;;
  ;; он эти токены создаёт и передаёт в лексер
  ;; если парсер не уверен по какому правилу раскрывать
  ;; токены прилетают (чтобы наследуемость соответственно отдаёт
  ;; ну например там будет что-то вроде
  ;; '((symbol "(") (number _))
  ;;
  ;; единственное отличие, что наследуемость для токенов будет немного отличаться
  ;; от наследуемости для нетерминалов
  ;;
  ;; в случае нетерминалов мы сначала создаём и потом углубляемся
  ;;
  ;; а в случае токенов нам сначала дают и мы проверяем что прибывший имеет либо
  ;; пустые значения на месте пропусков и тогда мы их заполняем
  ;; либо 
  ;;
  ;; единственное что он знает, что оно mutable
  ;; и что это struct с определенными полями
  [tokens (paren (kind)) 
          (number (value)) 
          (variable (name value))]
  (lexer my-lexer-defined-elsewhere-or-right-here-as-generator)
  ;; грамматику мы сделаем чуточку более вменяемой
  ;; мы сюда добавим всякие крутые штуки 
  ;; типа геттеров и сеттеров с 'вменяемым' синтаксисом
  [nterm (result (type-check value))
         (expr (type-check priority value))
         (cont (arg type-check priority value))]
  [grammar
    (result
      (number?) {
        [(expr-3 [$$.type-check] 3) ^{($$.value [$1.value])}]
      })
    (expr
     (_ 0) {
        [(paren "(") expr (paren ")") ^{($$.value [$1.value])}]
        [variable ^{($$.value 
                      (let ((result (read)))
                        (if ([$$.type-check] result)
                          result
                          (error 'type-error))))}]
        [number ^{($$.value [$1.value])}]
     }
     () {
       [(expr [$$.type-check]
              (- [$$.priority] 1))
        (cont [$1.value]
              [$$.type-check]
              [$$.priority])
        ^{($$.value [$2.value])}]
     })
    (cont
      () {
        [(operator [$$.priority]) 
         (expr [$$.type-check]
               (- [$$.priority] 1))                                  
         (cont ([$1.value] [$$.arg] [$2.value])
               [$$.type-check]
               [$$.priority])]
         ^{($$.value [$3.value])}
      })]


'{
  [tokens (operator [[priority :: 1 .. 3] action])
          (variable [name value])
          (number   [value])
          (paren    [kind :: '("(" ")")])]
  [nterms (expr     [[priority :: 0 .. 3] value])
          (cont     [acum [priority :: 1 .. 3] value])]
  
  [grammar
    [(expr 0) {
      (paren "(") (expr 3) (paren ")")
      ^{$$.value $2:value}
    }]
    [(expr 0) {
      (number)
      ^{$$.value $1:value}
    }]
    [(expr 0) {
      (variable)
      ^{(display "found variable! yey!")
        ($$.value (read))}
    }]

    [(expr .i value) {
     (expr (- i 1) .v) (cont v i .value)
    }]

    [(cont .acc .i r) {
     (operator i .a) (expr (- i 1) .e) (cont (a acc e) i .r)
    }]
    [(cont .v _ v) {
    }]
  ]
}


;; это должно превратиться во что-то такое:
'{
  ;; мы должны завести кучу всякого говна
  (struct get-attr ())
  ;; токены
  (struct token () #:transparent #:mutable)
  (struct symbol token (value) #:transparent #:mutable)
  (struct variable token (name value) #:transparent #:mutable)
  (struct result (type value) #:transparent #:mutable)
  (struct expr (type value) #:transparent #:mutable)
  (struct symbol (name value) #:transparent #:mutable)
  (struct number (value) #:transparent #:mutable)

  ;; далее для каждого правила мы должны сгенерировать соответствующую функцию
  ;; внутри каждой функции мы должны определить переменные и геттеры сеттеры
  ;; всё будем делать с сайд-эффектами, потому что чот вроде проще
  (define (parse-result/1 $$)
    ;; сгенерируем все остальные штуки
    (define $1 (expr '() '()))
    (define $2 (symbol '()))
    (define $3 (
    (define ($$.type [value (get-attr)])
      (if (get-attr? value)
        ;; pretend to be a getter
        (result-type $$)
        ;; pretend to be a setter
        (set-result-type! $$ value)))
    ;; дальше мы должны засунуть наш код


  (result (type value)
     ([{^ ($$.type  "int")} (expr [$$.type]) #\+ {^ print-something} result
        ;; or you can do action inline
        {^ ($$.value (+ [$1.value] [$3.value]))}]
       #:where 
         ^print-something (display $2)))
  (expr (type value)
    ([[variable ^read-var]
       {^ ($$.value $1.value)}]
      #:where
        ^read-var (begin (display "found a variable, give a value:") 
                         ($1.value (read))))
    ([[number]
      {^ ($$.value $1.value)}]))
}



;; Macro to generate `(set-age! p v)` -> `(set-person-age! p v)`
(require (for-syntax racket/syntax))

(define-syntax (set-attr! ctx)
  (syntax-case (field struct) value
    (format-id #'field "set-~a-~a" #'field
  ((string->symbol (string-append "set-" 
                                  (symbol->string (object-name struct))
                                  "-"
                                  (symbol->string 'field)
     
                                "!")) struct value))

(define-syntax (hyphen-define/ok1 stx)
    (syntax-case stx ()
      [(_ a b (args ...) body0 body ...)
       (syntax-case (syntax-format "~s-~s" #'a #'b)
                    ()
         [name #'(define (name args ...)
                   body0 body ...)])]))

;; Macro to get field `(age p)` -> `(person-age p)`
(define-syntax-rule (field struct)
  ((string->symbol (string-append (symbol->string 'struct) "-" (symbol->string 'field))) struct))

(define (parse-result-1)
  (define $$ (result "int" '()))
  (set-result-type! 

(define (skip-actions

(define (calc-first grammar)
