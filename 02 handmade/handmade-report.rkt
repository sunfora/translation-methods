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
       ]{Lab (2)}

@section{ ''Естественная'' грамматика}

Построим грамматику как слоёный пирог из уровней по приоритетам.
Сначала приоритеты нулевые, потом выше и выше. 

Каждое выражение соответственно либо выражение уровня ниже, либо комбинация выражений с помощью операции соответсвующего приоритета.

@$${
\begin{align*}
\\& Un  &\to & \quad !
\\& Op_1 &\to & \quad \&
\\& Op_2 &\to & \quad \wedge
\\& Op_3 &\to & \quad |
\\ 
\\& Pr  &\to & \quad Un     \quad   Pr
\\& Pr  &\to & \quad (      \quad   E \quad )
\\& Pr  &\to & \quad var
\\
\\& E_1  &\to & \quad Pr
\\& E_1  &\to & \quad E_1 \quad Op_1    \quad   E_1
\\
\\& E_2  &\to & \quad E_1
\\& E_2  &\to & \quad E_2 \quad Op_2    \quad   E_2
\\
\\& E_3  &\to & \quad E_2
\\& E_3  &\to & \quad E_3 \quad Op_3    \quad   E_3
\\
\\& E   &\to & \quad E_3
\end{align*}
}

@tabular[#:sep @hspace[8]
         #:style 'boxed
         #:row-properties '(bottom-border ())
         (list (list @bold{Нетерминал} @bold{Описание})
               (list @${Un}       "Унарные операции")
               (list @${Op_1}       "Операции приоритета 1")
               (list @${Op_2}       "Операции приоритета 2")
               (list @${Op_3}       "Операции приоритета 3")
               (list @${Pr}       "Примитивное выражение")
               (list @${E_1}       "Выражение с операцией уровня 1")
               (list @${E_2}       "Выражение с операцией уровня 2")
               (list @${E_3}       "Выражение с операцией уровня 3")
               (list @${E}       "Выражение"))]

@section{Устранение левой рекурсии}

В предыдущей грамматике есть левая рекурсия.
Давайте её устраним.

@$${
\begin{align*}
\\& Un  &\to & \quad !
\\& Op_1 &\to & \quad \&
\\& Op_2 &\to & \quad \wedge
\\& Op_3 &\to & \quad |
\\ 
\\& Pr  &\to & \quad Un     \quad   Pr
\\& Pr  &\to & \quad (      \quad   E \quad )
\\& Pr  &\to & \quad var
\\
\\& E_1  &\to & \quad Pr      \quad   C_1
\\& C_1  &\to & \quad Op_1    \quad   E_1
\\& C_1  &\to & \quad ε
\\
\\& E_2  &\to & \quad E_1     \quad   C_2
\\& C_2  &\to & \quad Op_2    \quad   E_2
\\& C_2  &\to & \quad ε
\\
\\& E_3  &\to & \quad E_2     \quad   C_3
\\& C_3  &\to & \quad Op_3    \quad   E_3
\\& C_3  &\to & \quad ε
\\
\\& E   &\to & \quad E_3
\end{align*}
}

@tabular[#:sep @hspace[8]
         #:style 'boxed
         #:row-properties '(bottom-border ())
         (list (list @bold{Нетерминал} @bold{Описание})
               (list @${Un}       "Унарные операции")
               (list @${Op_1}       "Операции приоритета 1")
               (list @${Op_2}       "Операции приоритета 2")
               (list @${Op_3}       "Операции приоритета 3")
               (list @${Pr}       "Примитивное выражение")
               (list @${E_1}       "Выражение с операцией уровня 1")
               (list @${C_1}       "Продолжение выражения уровня 1")
               (list @${E_2}       "Выражение с операцией уровня 2")
               (list @${C_2}       "Продолжение выражения уровня 2")
               (list @${E_3}       "Выражение с операцией уровня 3")
               (list @${C_3}       "Продолжение выражения уровня 3")
               (list @${E}       "Выражение"))]

@section{Лексер}

@(codeblock @(file->string "lex.rkt"))

@(define lex-eval
      (parameterize ([sandbox-output 'string]
                     [sandbox-error-output 'string]
                     [sandbox-memory-limit 50])
        (make-base-eval)))

@(lex-eval '(require "lex.rkt"))

@examples[ 
  #:label "Пример исполнения:"
  #:eval lex-eval
  (code:comment "modification")
  (define in (open-input-string "some-random-variable & (other + __snake__)"))
  (define next-lexeme (lexer in))
  (next-lexeme)
  (next-lexeme)
  (next-lexeme)
  (next-lexeme)
  (next-lexeme)
  (next-lexeme)
  (next-lexeme)
  (next-lexeme)
  (define in (open-input-string "ababcaba & (badacabad + cdwdW * dfeQfwe)"))
  (define next-lexeme (lexer in))
  (next-lexeme)
  (next-lexeme)
  (next-lexeme)
  (next-lexeme)
  (next-lexeme)
  (next-lexeme)
  (next-lexeme)
  (next-lexeme)
  (next-lexeme)
]

@section{First & Follow}

@tabular[#:sep @hspace[0]
         #:style 'boxed
         #:row-properties '(bottom-border ())
         (list (list @bold{Нетерминал} @bold{First}              @bold{Follow}               )
               (list @${Un}            @${!}                     @${!\ \ (\ \ var                  }    )
               (list @${Op_1}          @${\&}                    @${!\ \ (\ \ var                  }    )
               (list @${Op_2}          @${\wedge}                @${!\ \ (\ \ var                  }    )
               (list @${Op_3}          @${|}                     @${!\ \ (\ \ var                  }    )
               (list @${Pr}            @${!\ \ (\ \ var}         @${\&\ \ \wedge\ \ |\ \ \$\ \ )   }    )
               (list @${E_1}           @${!\ \ (\ \ var}         @${\wedge\ \ |\ \ \$ \ \ )        }    )
               (list @${C_1}           @${\&\ \ \varepsilon}     @${\wedge\ \ |\ \ \$ \ \ )        }    )
               (list @${E_2}           @${!\ \ (\ \ var}         @${|\ \ \$\ \ )                   }    )
               (list @${C_2}           @${\wedge\ \ \varepsilon} @${|\ \ \$\ \ )                   }    )
               (list @${E_3}           @${!\ \ (\ \ var}         @${\$\ \ )                        }    )
               (list @${C_3}           @${|\ \ \varepsilon}      @${\$\ \ )                        }    )
               (list @${E}             @${!\ \ (\ \ var}         @${\$ \ \ )                       }    ))]

Согласно теореме можно видеть (надо проверить только C1, C2, C3) что данная грамматика является LL(1) грамматикой.

@section{Парсер }

Ну заведем стандартные немножко абстракции в виде take, expect.
И на этом собственно дальнейшее происходящее эквивалентно любым другим языкам.

@(codeblock @(file->string "parser.rkt"))

@section{Визуально}

@(define base-eval 
      (parameterize ([sandbox-output 'string]
                     [sandbox-error-output 'string]
                     [sandbox-memory-limit 50])
        (make-base-eval)))

@(base-eval '(require racket/port "visual.rkt" "parser.rkt" ))

Я использовал более менее стандартную здешнюю библиотеку @racket[pict], ну а по идее @racket[pict/tree-layout]. 
Надо было просто оттранслировать итоговое дерево в лейаут и сгенерировать финальную штуку.

В целом, с тем же успехом можно было бы написать обвзяку над graphviz, но мне было немного лень.

@(codeblock @(file->string "visual.rkt"))

@examples[ 
  #:label "Давайте теперь пару примеров:"
  #:eval base-eval

  (code:comment "")
  (code:comment "пустой тест")
  (code:comment "")
  (eval:error (parse-string " "))
  (code:comment "")
  (code:comment "самый примитивный тест")
  (code:comment "")
  (parse-string "a  ")
  (parse-string "  a")
  (parse-string "a")
  (code:comment "")
  (code:comment "primary тесты")
  (code:comment "")
  (visual "! a")
  (visual "((\n(a))) ")

  (code:comment "")
  (code:comment "более сложные выражения")
  (code:comment "")
  (visual "!!!!a & b")
  (visual "b&!!!!a&c")
  (code:comment "")
  (code:comment "несуществующий (существующий после модификации) оператор")
  (code:comment "")
  (visual "x^var | !a & (b + c) * dubious * epr + snak")
  (code:comment "")
  (code:comment "несуществующий оператор")
  (code:comment "")
  (eval:error (visual "dubious % epr + snak"))
  (code:comment "")
  (code:comment "много разных операторов и скобок")
  (code:comment "")
  (visual "a & (b ^ c) | d")
  (visual "!a & (b ^ c) | d")
  (visual "!a & (b ^ c | d)")
  (visual "!a & b ^ c | d")
  (visual "d | c^ b  & !a")
  (visual "d | c | (b & b)  | a")
  (code:comment "")
  (code:comment "незакрытая скобка")
  (code:comment "")
  (eval:error (parse-string "!a & (b ^ c | d"))
  (eval:error (parse-string "!a & b ^ c) | d"))
  (code:comment "")
  (code:comment "пропущенный оператор")
  (code:comment "")
  (eval:error (parse-string "!a(b ^ c | d)"))
  (code:comment "")
  (code:comment "пропущенное выражение")
  (code:comment "")
  (eval:error (parse-string "!a && (b ^ c | d)"))
]

@section{Тесты}

@(base-eval '(require "test.rkt"))
@examples[ 
  #:label "Тесты"
  #:eval base-eval
  (test)
]

@section{Исходники тестов}
@(codeblock @(file->string "test.rkt"))
