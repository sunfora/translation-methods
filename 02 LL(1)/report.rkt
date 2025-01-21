#lang scribble/manual
@(require scribble-math)
@(require scribble/base)
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
