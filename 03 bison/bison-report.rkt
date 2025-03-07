#lang scribble/manual
@(require (for-label racket))
@(require scribble-math)
@(require scribble/base)
@(require scribble/example)
@(require racket/sandbox)
@(require racket/file)
@(require scribble/core)
@(require scribble/html-properties)
@(require racket/port)
@(require racket/pretty)
@(require racket/system)

@title[
       #:style (with-html5 manual-doc-style)
       #:tag "problem"
       #:version ""
       ]{Lab (3)}

@(define (bison-code . content) 
   (define code-style 
     (make-style "language-bison"
                 (list (make-css-addition "prism.css")
                       (make-js-addition "prism.js")
                       (alt-tag "code"))))
    (paragraph (make-style "codeblock" (list (make-css-addition #"
                                                .language-bison {
                                                  font-size: 1rem !important;
                                                  white-space: pre-wrap !important;
                                                  background-color: white !important;
                                                }
                                              ")
                                             (alt-tag "pre"))) 
        (elem #:style code-style content)))

@section{Выбор инструмента}

Я выбрал bison. Потому что плюсики.
Ну еще у них замечательный мануал с примерами вроде как.

Начал я по сути с C++ @link["https://www.gnu.org/software/bison/manual/html_node/A-Simple-C_002b_002b-Example.html"]{simple example}. Нагло его стырил и потихоньку под себя переписывал.

@section{Пролог}

Сначала мы скажем что мы ваще плюсы используем.
Потом укажем всякое барахло которое нам позже очень понадобиться, в частности например чтобы поддерживать состояние вычислений.

Нам как бы очень важен и жизненно необходим контекст вычислений.
И мы должны как-то решить проблему того что мы его пробросить должны.

Кроме того нам нужны user-defined ошибки, ну потому что например какие-нибудь переменные могут быть не задефайнены по какой-то причине.
И мы должны это учитывать.

В общем следующий кусок кода именно этим и занимается.
@filebox[
  "simple.yy"
  @bison-code{
    %language "c++"

    %code requires {
      #include <exception>
      #include <iostream>
      #include <sstream>
      #include <vector>
      #include <map>
      #include <unordered_map>
      #include <functional>


      namespace color {
        /* куча кода связанная с цветами для консольки
           можно и в отдельный файл вынести */
      }
      
      /* штука которую будем выбрасывать в случае если что-то с контекстом не то */
      struct undefined_variable : std::exception {
          std::string message;

          undefined_variable(const std::string& varname) 
            : message(varname + " is referenced before assignment") 
            {}

          const char* what() const noexcept override {
              return message.c_str();
          }
      };

      /* собственно сам контекст вычислений */
      struct evaluation_context {
        std::unordered_map<std::string, int> storage;

        int eval(const std::string & name) {
          auto it = this->storage.find(name);
          if (it != this->storage.end()) {
            return it->second;
          }
          throw undefined_variable(name);
        }

        void set(std::string key, int value) {
          storage[key] = value;
        }
      };
    }
  }]

Теперь когда мы завели кучу барахла, которое мы будем использовать и точно знаем что это окажется где-то наверху сгенерированного файла.
Мы теперь должны указать что мы этот контекст собственно хотим как параметр задать для парсера, чтобы он был как глобальная переменная.


@filebox[
  "simple.yy"
  @bison-code{
    /* здесь мы говорим использовать контекст */
    %parse-param { evaluation_context * ctx}

    /* более адекватные ошибки */
    %define parse.error detailed 
    /* различные типы для нетерминалов и токенов */
    %define api.value.type variant 
    /* пусть парсер генерит конструкторы токенов */
    %define api.token.constructor 
  }]

@section{yylex}

Тупейшая ерунда короче, switch технологии, все дела.
Из интересного только то что мы выбрасываем типа стандартные штуки в ответ в виде YYUNDEF.

И когда мы заходим парсить и видим что мы в начале выражения ;, ( или мы стоим после оператора.
То мы можем интепретировать последовательность +124214 как число.

А иначе так делать низя. Потому что бывают вещи вроде 1 +2;

@filebox[
  "simple.yy"
  @bison-code{
    %code
    {
      namespace yy
      {
        // Return the next token.
        parser::symbol_type yylex ()
        {
          const int SEMICOLON    = 0b100000000000000;
          const int ELSE         = 0b010000000000000;
          const int THEN         = 0b001000000000000;
          const int QUESTION     = 0b000100000000000;
          const int SET          = 0b000001000000000;
          const int WHITESPACE   = 0b000000100000000;
          const int VARIABLE     = 0b000000010000000;
          const int NUMBER       = 0b000000001000000;
          const int ADD          = 0b000000000100000;
          const int DIV          = 0b000000000010000;
          const int MUL          = 0b000000000001000;
          const int SUB          = 0b000000000000100;
          const int OPEN_PAREN   = 0b000000000000010;
          const int CLOSED_PAREN = 0b000000000000001;

          static std::string buffer;
          static int read = std::cin.get();
          static int fired;
          
          static auto collect = [&] (int what) {
            fired |= what;
            buffer.push_back(read);
            read = std::cin.get();
          };
          
          /* test if last was operator (in case we gonna parse number literal with +-) */
          bool previous_was_operator = fired & ((ADD | DIV | MUL | SUB) & (~ NUMBER));
          bool previous_was_start = !fired || (fired & (OPEN_PAREN | SET | SEMICOLON));
          bool treat_as_operator = !previous_was_operator && !previous_was_start;
          
          /* clear everything from previous use */
          buffer.clear();
          fired = 0;

          /* lets start */
          
          /* skip whitespace */    
          for (
            /* already initialized */ ;
            !std::cin.eof() && std::isspace(read);
            read = std::cin.get(), fired |= WHITESPACE
          ) {
            continue;
          }
          /* if input exhausted after that 
             then we are done */
          if (std::cin.eof()) {
            return parser::make_YYEOF();
          }

          /* collect if it is variable */
          while(!std::cin.eof() && std::isalpha(read)) {
            collect(VARIABLE);
          }

          /* we either must have collected it
             or we can assume input is not exhausted */
          if (fired & VARIABLE) {
            return parser::make_VARIABLE(std::move(buffer));
          }

          /* now let's do operators and numbers */
          switch (read) {
            case '*': {
              collect(MUL);
              return parser::make_MUL(1);
            }
            case '/': {
              collect(DIV);
              return parser::make_DIV(1);
            }
            case '+':
            case '-': {
              if (read == '+') {
                collect(ADD);
              } else {
                collect(SUB);
              }
              /* but apart from being an operator it can be a number */
              while (
                   !treat_as_operator      /* case like +1 +1, 
                                              we should tokenize as (+1) (+)(1)
                                              */
                && !std::cin.eof() 
                && std::isdigit(read)
              ) {
                collect(NUMBER);
              }

              if (fired & NUMBER) {
                return parser::make_NUMBER(std::stoi(buffer));
              } else if (fired & ADD) {
                return parser::make_ADD(2);
              } else {
                return parser::make_SUB(1);
              }
            }
            case '(': {
              collect(OPEN_PAREN);
              return parser::make_OPEN_PAREN('(');
            }
            case ')': {
              collect(CLOSED_PAREN);
              return parser::make_CLOSED_PAREN(')');
            }
            case ';': {
              collect(SEMICOLON);
              return parser::make_SEMICOLON(';');
            }
            case '=': {
              collect(SET);
              return parser::make_SET('=');
            }
            case '>': {
              collect(THEN);
              return parser::make_THEN('>');
            }
            case ':': {
              collect(ELSE);
              return parser::make_ELSE(':');
            }
            case '?': {
              collect(QUESTION);
              return parser::make_QUESTION('?');
            }
          }

          /* nothing that looks like operator 
             then it must be a number */
          while (!std::cin.eof() && std::isdigit(read)) {
            collect(NUMBER);
          }
          if (fired & NUMBER) {
            return parser::make_NUMBER(std::stoi(buffer));
          }

          /* undefined */
          collect(0);
          return parser::make_YYUNDEF();
        }
      }
    }
}]

@section{Грамматика}

Тут интересно несколько вещей.
Для начала то что мы пишем не однозначную грамматику по идее.

Но за счёт указания приоритетов операций, бизон может вполне себе такое парсить, что весьма замечательно.

Второе замечание связано с тем что мы занимаемся восстановлением состояния парсера после ошибки с помощью встроенных средства.
А именно мы считаем что в принципе ошибка это нормально, мы её пользователю выведем, а дальше будем просто считывать весь инпут пока стейтмент не закончится, иначе говоря пока не появится точка с запятой.

Делаем мы это с помощью соответствующего API бизона, единственное что, я использую немного внутряк в виде yyla, который по сути lookahead токен, по идее я должен использовать для этих целей yychar, но это не точно. Короче не знаю. Мейби есть лучше вариант.

@filebox[
  "simple.yy"
  @bison-code{
    /* grammar */
    %%
    %nterm <std::string> statement;
    %nterm <std::function<int(void)>> expr;
    %nterm <std::function<int(void)>> tern;

    %token <std::string> VARIABLE;
    %token <int>         NUMBER;

    %token <char>         ADD;
    %token <char>         DIV;
    %token <char>         MUL;          
    %token <char>         SUB;

    %token <char>        OPEN_PAREN;
    %token <char>        CLOSED_PAREN;
    %token <char>        SEMICOLON;
    %token <char>        SET;
    %token <char>        QUESTION;
    %token <char>        ELSE;
    %token <char>        THEN;

    result:
      %empty
    | result statement SEMICOLON { 
        for (auto text_node : $2) {
          std::cout << text_node;
        }
        std::cout << std::endl; 
      }
    | result error {
        /* skip everything up to semicolon */
        using sk = parser::symbol_kind;

        auto should_skip = [&] (parser::symbol_type tok) {
          return tok.kind() != sk::S_SEMICOLON 
          &&     tok.kind() != sk::S_YYEOF;
        };
        
        /* it should be yychar or something like that 
           but it is not available for C++ 
           so I use some internal details */
        while (should_skip(yyla)) {
          parser::symbol_type lookahead = yylex();
          yyla.move(lookahead);
        }
        /* clear the token */
        yyclearin;
        yyerrok;
      }
    ;

    statement:
      %empty {
        $$ = std::string{};
      }
    | VARIABLE SET expr {
        /* assign */
          try {
            ctx->set($1, $3());
            $$ = $1 + " = " + color::to_string(color::blue($3()));
          }
          catch (undefined_variable e) {
            yy::parser::error(e.message);
            YYERROR;
          }
          catch (std::domain_error e) {
            yy::parser::error(std::string{e.what()});
            YYERROR;
          }
      }
    | expr {
        try {
          $$ = color::to_string(color::blue($1())); 
        }
        catch (undefined_variable e) {
          yy::parser::error(e.message);
          YYERROR;
        }
        catch (std::domain_error e) {
          yy::parser::error(std::string{e.what()});
          YYERROR;
        }
      };

    tern: OPEN_PAREN expr CLOSED_PAREN QUESTION expr ELSE expr {
          auto a = $2; 
          auto b = $5; 
          auto c = $7; 
          if (a()) {
            $$ = b;
          } else {
            $$ = c;
          }};


    expr:
        expr ADD expr { auto a = $1;
                        auto b = $3;
                        $$ = [=](){return a() + b(); }; 
                      }
    |   expr SUB expr { auto a = $1; 
                        auto b = $3; 
                        $$ = [=](){return a() - b(); }; 
                      }
    |   expr MUL expr { auto a = $1; 
                        auto b = $3; 
                        $$ = [=](){return a() * b(); }; 
                      }
    |   expr DIV expr { auto a = $1; 
                        auto b = $3; 
                        $$ = [=](){
                          auto bv = b();
                          if (bv == 0) {
                            throw std::domain_error{"division by zero"};
                          }
                          return a() / bv; 
                        }; 
                      }
    |   tern {$$ = $1;};

    %left ELSE;
    %left ADD;
    %left SUB;
    %left MUL;
    %left DIV;


    expr:
      OPEN_PAREN expr CLOSED_PAREN {
        $$ = $2;
      };

    expr: 
      VARIABLE { 
          auto name = $1;
          $$ = [=](){return ctx->eval(name);};
        }
    | NUMBER { int x = $1;
               $$ = [=](){return x;}; };

    %%
  }]

@section{main}

Ну и наконец предоставим как бы финал всего этого действия.
Просто будем выводить красненьким ошибочки на экран и запустим наш парсер с контекстом для переменных.

@filebox[
  "simple.yy"
  @bison-code{
    namespace yy
    {
      // Report an error to the user.
      void parser::error (const std::string& msg)
      {
        std::cerr << color::red(msg) << std::endl;
      }
    }

    int main ()
    {
      evaluation_context ctx;
      yy::parser parse(&ctx);
      return parse();
    }
  }]

@section{примеры исполнения}

А тут их нет 😅.

Но зато есть интерактивный WASM.

@(if (system "bash /home/ivan/.profile && bash ./wasm-build")
   null
   (error "building stage"))

@(define term
   (make-style "term"
               (list (make-css-addition "xterm.css")
                     (make-css-addition #".term {
                                          padding: 1em;
                                          background-color: black;
                                          border-radius: 10px;
                                        }")
                     (alt-tag "div")
                     (attributes '((id . "terminal"))))))

@elem[#:style term]{}

@elem[
  #:style (make-style #f (list (alt-tag "script") 
                               (make-js-addition "index.mjs")
                               (install-resource "example.mjs")
                               (make-js-addition "xterm.js")
                               (install-resource "example.wasm")
                               (attributes '((type . "module")))))
  @literal|{
    import './xterm.js';
    import { openpty } from './index.mjs';
    import initEmscripten from './example.mjs';

    var xterm = new Terminal();
    xterm.open(document.getElementById('terminal'));

    // Create master/slave objects
    const { master, slave } = openpty();

    // Connect the master object to xterm.js
    xterm.loadAddon(master);

    await initEmscripten({ pty: slave });
  }|]
