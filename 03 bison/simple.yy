%language "c++"

%code requires {
  #include <exception>
  #include <iostream>
  #include <sstream>
  #include <vector>
  #include <map>
  #include <unordered_map>


  namespace color {
      enum code_t {
          TEXT_RED      = 91,
          TEXT_GREEN    = 92,
          TEXT_BLUE     = 94,
          TEXT_WHITE    = 97
      };

      template <typename E>
      struct modifier {
          const E data;
          code_t code;
          modifier(E e, code_t c) 
            : data{e}
            , code{c}
          {}
      };

      template <typename E>
      std::string to_string(const modifier<E> & x) {
          std::ostringstream ss;
          ss << x;
          return ss.str();
      }

      template <typename T>
      std::ostream& operator<<(std::ostream& os, const modifier<T>& mod) {
          return os << "\033[" << mod.code << "m" << mod.data << "\033[0m";
      }
      
      template<typename X>
      auto red(X thing) {
        return modifier<X>{thing, code_t::TEXT_RED};
      }
      
      template<typename X>
      auto green(X thing) {
        return modifier<X>{thing, code_t::TEXT_GREEN};
      }
      
      template<typename X>
      auto blue(X thing) {
        return modifier<X>{thing, code_t::TEXT_BLUE};
      }
      
      template<typename X>
      auto white(X thing) {
        return modifier<X>{thing, code_t::TEXT_WHITE};
      }
  }

  struct parse_err : std::exception {
      std::string message;

      parse_err(const std::string& msg) 
        : message{msg} 
        {}

      const char* what() const noexcept override {
          return message.c_str();
      }
  };
  
  struct undefined_variable : std::exception {
      std::string message;

      undefined_variable(const std::string& varname) 
        : message(varname + " is referenced before assignment") 
        {}

      const char* what() const noexcept override {
          return message.c_str();
      }
  };


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

%parse-param { evaluation_context * ctx}

%define parse.error detailed
%define api.value.type variant
%define api.token.constructor

%code
{
  namespace yy
  {
    // Return the next token.
    parser::symbol_type yylex ()
    {
      const int SEMICOLON    = 0b10000000000;
      const int SET          = 0b01000000000;
      const int WHITESPACE   = 0b00100000000;
      const int VARIABLE     = 0b00010000000;
      const int NUMBER       = 0b00001000000;
      const int ADD          = 0b00000100000;
      const int DIV          = 0b00000010000;
      const int MUL          = 0b00000001000;
      const int SUB          = 0b00000000100;
      const int OPEN_PAREN   = 0b00000000010;
      const int CLOSED_PAREN = 0b00000000001;

      static std::string buffer;
      static int read = std::cin.get();
      static int fired;
      
      static auto collect = [&] (int what) {
        fired |= what;
        buffer.push_back(read);
        read = std::cin.get();
      };
     
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
          while (!std::cin.eof() && std::isdigit(read)) {
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

/* grammar */
%%
%nterm <std::string> statement;
%nterm <int> expr;

%token <std::string> VARIABLE;
%token <int>         NUMBER;

%token <int>         ADD;
%token <int>         DIV;
%token <int>         MUL;          
%token <int>         SUB;

%token <char>        OPEN_PAREN;
%token <char>        CLOSED_PAREN;
%token <char>        SEMICOLON;
%token <char>        SET;

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
    ctx->set($1, $3);
    $$ = $1 + " = " + color::to_string(color::blue($3));
  }
| expr {
    $$ = color::to_string(color::blue($1)); 
  };

expr:
    expr ADD expr { $$ = $1 + $3; }
|   expr SUB expr { $$ = $1 - $3; }
|   expr MUL expr { $$ = $1 * $3; }
|   expr DIV expr { $$ = $1 / $3; };

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
      try {
        $$ = ctx->eval($1); 
      }
      catch (undefined_variable e) {
        yy::parser::error(e.message);
        YYERROR;
      }
    }
| NUMBER { $$ = $1; };

%%
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
