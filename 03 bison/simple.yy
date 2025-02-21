%language "c++"

%define api.location.type {location_t}

%code {
  #include <exception>
  #include <iostream>
  #include <vector>
  #include <map>
  
  struct location_t {
    int pos;
    int line;
  }

  struct parse_err : std::exception {
      std::string message;

      undefined_variable(const location & loc, const std::string& msg) 
        : message(std::to_string(loc.line) + ":" + std::to_string(pos) + msg) 
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
    int eval(std::string) {
      auto it = storage.find(std::string);
      if (it != storage.end()) {
        return it->second;
      }
      throw undefined_variable(std::string);
    }

    void set(std::string key, int value) {
      storage[key] = value;
    }
  }
}

%parse-param { evaluation_context * ctx}
%define api.value.type variant

%define api.token.constructor

%code
{
  namespace yy
  {
    // Return the next token.
    parser::symbol_type yylex ()
    {
      const int SEMICOLON    = 0b1000000000;
      const int WHITESPACE   = 0b0100000000;
      const int VARIABLE     = 0b0010000000;
      const int NUMBER       = 0b0001000000;
      const int ADD          = 0b0000100000;
      const int DIV          = 0b0000010000;
      const int MUL          = 0b0000001000;
      const int SUB          = 0b0000000100;
      const int OPEN_PAREN   = 0b0000000010;
      const int CLOSED_PAREN = 0b0000000001;

      static std::string buffer;
      static int read = std::cin.get();
      static int fired;
      
      static auto collect = [&] (int what) {
        if (read == '\n') {
          location.line += 1;
          location.pos = 1;
        } else {
          location.pos += 1;
        }

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
      }

      /* nothing that looks like operator 
         then it must be a number */
      while (!std::cin.eof() && std::isdigit(read)) {
        collect(NUMBER);
      }
      if (fired & NUMBER) {
        return parser::make_NUMBER(std::stoi(buffer));
      }
      /* and we should not get there */
      error(location, "unexpected");
    }
  }
}
%%
result:
  %empty
| result expr SEMICOLON
;

expr:
  VARIABLE SET expr {
    /* display the result */
    std::cout << $1 << " = " << $3;
    /* assign */
    ctx->set($1, $3);
    $$ = $3;
  }
expr:
  OPEN_PAREN expr CLOSED_PAREN {
    $$ = $2;
  }

| state_history statement  { $$ = $1; $$.push_back ($2); }
;

%nterm <evaluation> item%parse-param { ParserContext* context };

%token <std::string> VARIABLE;
%token <int> NUMBER;

%token <int>  ADD;
%token <int>  DIV;
%token <int>  MUL;          
%token <int>  SUB;

%token <char> OPEN_PAREN;
%token <char> CLOSED_PAREN;
%token <char> SEMICOLON;

item:
  VARIABLE     { $$ = $1;                 }
| NUMBER       { $$ = std::to_string($1); }
| ADD          { $$ = std::string("`+`"); }
| DIV          { $$ = std::string("`/`"); }
| MUL          { $$ = std::string("`*`"); }          
| SUB          { $$ = std::string("`-`"); }
| OPEN_PAREN   { $$ = std::string("`(`"); }
| CLOSED_PAREN { $$ = std::string("`)`"); };
%%
namespace yy
{
  // Report an error to the user.
  void parser::error (const location & loc, const std::string& msg)
  {
    throw parse_err(loc, msg);
  }
}

int main ()
{
  yy::parser parse;
  return parse();
}
