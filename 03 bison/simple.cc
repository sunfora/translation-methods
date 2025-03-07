// A Bison parser, made by GNU Bison 3.8.2.

// Skeleton implementation for Bison LALR(1) parsers in C++

// Copyright (C) 2002-2015, 2018-2021 Free Software Foundation, Inc.

// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.

// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.

// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.

// As a special exception, you may create a larger work that contains
// part or all of the Bison parser skeleton and distribute that work
// under terms of your choice, so long as that work isn't itself a
// parser generator using the skeleton or a modified version thereof
// as a parser skeleton.  Alternatively, if you modify or redistribute
// the parser skeleton itself, you may (at your option) remove this
// special exception, which will cause the skeleton and the resulting
// Bison output files to be licensed under the GNU General Public
// License without this special exception.

// This special exception was added by the Free Software Foundation in
// version 2.2 of Bison.

// DO NOT RELY ON FEATURES THAT ARE NOT DOCUMENTED in the manual,
// especially those whose name start with YY_ or yy_.  They are
// private implementation details that can be changed or removed.





// "%code requires" blocks.
#line 3 "simple.yy"

  #include <exception>
  #include <iostream>
  #include <sstream>
  #include <vector>
  #include <map>
  #include <unordered_map>
  #include <functional>


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

#line 146 "simple.cc"


# include <cstdlib> // std::abort
# include <iostream>
# include <stdexcept>
# include <string>
# include <vector>

#if defined __cplusplus
# define YY_CPLUSPLUS __cplusplus
#else
# define YY_CPLUSPLUS 199711L
#endif

// Support move semantics when possible.
#if 201103L <= YY_CPLUSPLUS
# define YY_MOVE           std::move
# define YY_MOVE_OR_COPY   move
# define YY_MOVE_REF(Type) Type&&
# define YY_RVREF(Type)    Type&&
# define YY_COPY(Type)     Type
#else
# define YY_MOVE
# define YY_MOVE_OR_COPY   copy
# define YY_MOVE_REF(Type) Type&
# define YY_RVREF(Type)    const Type&
# define YY_COPY(Type)     const Type&
#endif

// Support noexcept when possible.
#if 201103L <= YY_CPLUSPLUS
# define YY_NOEXCEPT noexcept
# define YY_NOTHROW
#else
# define YY_NOEXCEPT
# define YY_NOTHROW throw ()
#endif

// Support constexpr when possible.
#if 201703 <= YY_CPLUSPLUS
# define YY_CONSTEXPR constexpr
#else
# define YY_CONSTEXPR
#endif



#ifndef YY_ATTRIBUTE_PURE
# if defined __GNUC__ && 2 < __GNUC__ + (96 <= __GNUC_MINOR__)
#  define YY_ATTRIBUTE_PURE __attribute__ ((__pure__))
# else
#  define YY_ATTRIBUTE_PURE
# endif
#endif

#ifndef YY_ATTRIBUTE_UNUSED
# if defined __GNUC__ && 2 < __GNUC__ + (7 <= __GNUC_MINOR__)
#  define YY_ATTRIBUTE_UNUSED __attribute__ ((__unused__))
# else
#  define YY_ATTRIBUTE_UNUSED
# endif
#endif

/* Suppress unused-variable warnings by "using" E.  */
#if ! defined lint || defined __GNUC__
# define YY_USE(E) ((void) (E))
#else
# define YY_USE(E) /* empty */
#endif

/* Suppress an incorrect diagnostic about yylval being uninitialized.  */
#if defined __GNUC__ && ! defined __ICC && 406 <= __GNUC__ * 100 + __GNUC_MINOR__
# if __GNUC__ * 100 + __GNUC_MINOR__ < 407
#  define YY_IGNORE_MAYBE_UNINITIALIZED_BEGIN                           \
    _Pragma ("GCC diagnostic push")                                     \
    _Pragma ("GCC diagnostic ignored \"-Wuninitialized\"")
# else
#  define YY_IGNORE_MAYBE_UNINITIALIZED_BEGIN                           \
    _Pragma ("GCC diagnostic push")                                     \
    _Pragma ("GCC diagnostic ignored \"-Wuninitialized\"")              \
    _Pragma ("GCC diagnostic ignored \"-Wmaybe-uninitialized\"")
# endif
# define YY_IGNORE_MAYBE_UNINITIALIZED_END      \
    _Pragma ("GCC diagnostic pop")
#else
# define YY_INITIAL_VALUE(Value) Value
#endif
#ifndef YY_IGNORE_MAYBE_UNINITIALIZED_BEGIN
# define YY_IGNORE_MAYBE_UNINITIALIZED_BEGIN
# define YY_IGNORE_MAYBE_UNINITIALIZED_END
#endif
#ifndef YY_INITIAL_VALUE
# define YY_INITIAL_VALUE(Value) /* Nothing. */
#endif

#if defined __cplusplus && defined __GNUC__ && ! defined __ICC && 6 <= __GNUC__
# define YY_IGNORE_USELESS_CAST_BEGIN                          \
    _Pragma ("GCC diagnostic push")                            \
    _Pragma ("GCC diagnostic ignored \"-Wuseless-cast\"")
# define YY_IGNORE_USELESS_CAST_END            \
    _Pragma ("GCC diagnostic pop")
#endif
#ifndef YY_IGNORE_USELESS_CAST_BEGIN
# define YY_IGNORE_USELESS_CAST_BEGIN
# define YY_IGNORE_USELESS_CAST_END
#endif

# ifndef YY_CAST
#  ifdef __cplusplus
#   define YY_CAST(Type, Val) static_cast<Type> (Val)
#   define YY_REINTERPRET_CAST(Type, Val) reinterpret_cast<Type> (Val)
#  else
#   define YY_CAST(Type, Val) ((Type) (Val))
#   define YY_REINTERPRET_CAST(Type, Val) ((Type) (Val))
#  endif
# endif
# ifndef YY_NULLPTR
#  if defined __cplusplus
#   if 201103L <= __cplusplus
#    define YY_NULLPTR nullptr
#   else
#    define YY_NULLPTR 0
#   endif
#  else
#   define YY_NULLPTR ((void*)0)
#  endif
# endif

/* Debug traces.  */
#ifndef YYDEBUG
# define YYDEBUG 0
#endif

namespace yy {
#line 281 "simple.cc"




  /// A Bison parser.
  class parser
  {
  public:
#ifdef YYSTYPE
# ifdef __GNUC__
#  pragma GCC message "bison: do not #define YYSTYPE in C++, use %define api.value.type"
# endif
    typedef YYSTYPE value_type;
#else
  /// A buffer to store and retrieve objects.
  ///
  /// Sort of a variant, but does not keep track of the nature
  /// of the stored data, since that knowledge is available
  /// via the current parser state.
  class value_type
  {
  public:
    /// Type of *this.
    typedef value_type self_type;

    /// Empty construction.
    value_type () YY_NOEXCEPT
      : yyraw_ ()
    {}

    /// Construct and fill.
    template <typename T>
    value_type (YY_RVREF (T) t)
    {
      new (yyas_<T> ()) T (YY_MOVE (t));
    }

#if 201103L <= YY_CPLUSPLUS
    /// Non copyable.
    value_type (const self_type&) = delete;
    /// Non copyable.
    self_type& operator= (const self_type&) = delete;
#endif

    /// Destruction, allowed only if empty.
    ~value_type () YY_NOEXCEPT
    {}

# if 201103L <= YY_CPLUSPLUS
    /// Instantiate a \a T in here from \a t.
    template <typename T, typename... U>
    T&
    emplace (U&&... u)
    {
      return *new (yyas_<T> ()) T (std::forward <U>(u)...);
    }
# else
    /// Instantiate an empty \a T in here.
    template <typename T>
    T&
    emplace ()
    {
      return *new (yyas_<T> ()) T ();
    }

    /// Instantiate a \a T in here from \a t.
    template <typename T>
    T&
    emplace (const T& t)
    {
      return *new (yyas_<T> ()) T (t);
    }
# endif

    /// Instantiate an empty \a T in here.
    /// Obsolete, use emplace.
    template <typename T>
    T&
    build ()
    {
      return emplace<T> ();
    }

    /// Instantiate a \a T in here from \a t.
    /// Obsolete, use emplace.
    template <typename T>
    T&
    build (const T& t)
    {
      return emplace<T> (t);
    }

    /// Accessor to a built \a T.
    template <typename T>
    T&
    as () YY_NOEXCEPT
    {
      return *yyas_<T> ();
    }

    /// Const accessor to a built \a T (for %printer).
    template <typename T>
    const T&
    as () const YY_NOEXCEPT
    {
      return *yyas_<T> ();
    }

    /// Swap the content with \a that, of same type.
    ///
    /// Both variants must be built beforehand, because swapping the actual
    /// data requires reading it (with as()), and this is not possible on
    /// unconstructed variants: it would require some dynamic testing, which
    /// should not be the variant's responsibility.
    /// Swapping between built and (possibly) non-built is done with
    /// self_type::move ().
    template <typename T>
    void
    swap (self_type& that) YY_NOEXCEPT
    {
      std::swap (as<T> (), that.as<T> ());
    }

    /// Move the content of \a that to this.
    ///
    /// Destroys \a that.
    template <typename T>
    void
    move (self_type& that)
    {
# if 201103L <= YY_CPLUSPLUS
      emplace<T> (std::move (that.as<T> ()));
# else
      emplace<T> ();
      swap<T> (that);
# endif
      that.destroy<T> ();
    }

# if 201103L <= YY_CPLUSPLUS
    /// Move the content of \a that to this.
    template <typename T>
    void
    move (self_type&& that)
    {
      emplace<T> (std::move (that.as<T> ()));
      that.destroy<T> ();
    }
#endif

    /// Copy the content of \a that to this.
    template <typename T>
    void
    copy (const self_type& that)
    {
      emplace<T> (that.as<T> ());
    }

    /// Destroy the stored \a T.
    template <typename T>
    void
    destroy ()
    {
      as<T> ().~T ();
    }

  private:
#if YY_CPLUSPLUS < 201103L
    /// Non copyable.
    value_type (const self_type&);
    /// Non copyable.
    self_type& operator= (const self_type&);
#endif

    /// Accessor to raw memory as \a T.
    template <typename T>
    T*
    yyas_ () YY_NOEXCEPT
    {
      void *yyp = yyraw_;
      return static_cast<T*> (yyp);
     }

    /// Const accessor to raw memory as \a T.
    template <typename T>
    const T*
    yyas_ () const YY_NOEXCEPT
    {
      const void *yyp = yyraw_;
      return static_cast<const T*> (yyp);
     }

    /// An auxiliary type to compute the largest semantic type.
    union union_type
    {
      // ADD
      // DIV
      // MUL
      // SUB
      // OPEN_PAREN
      // CLOSED_PAREN
      // SEMICOLON
      // SET
      // QUESTION
      // ELSE
      // THEN
      char dummy1[sizeof (char)];

      // NUMBER
      char dummy2[sizeof (int)];

      // tern
      // expr
      char dummy3[sizeof (std::function<int(void)>)];

      // VARIABLE
      // statement
      char dummy4[sizeof (std::string)];
    };

    /// The size of the largest semantic type.
    enum { size = sizeof (union_type) };

    /// A buffer to store semantic values.
    union
    {
      /// Strongest alignment constraints.
      long double yyalign_me_;
      /// A buffer large enough to store any of the semantic values.
      char yyraw_[size];
    };
  };

#endif
    /// Backward compatibility (Bison 3.8).
    typedef value_type semantic_type;


    /// Syntax errors thrown from user actions.
    struct syntax_error : std::runtime_error
    {
      syntax_error (const std::string& m)
        : std::runtime_error (m)
      {}

      syntax_error (const syntax_error& s)
        : std::runtime_error (s.what ())
      {}

      ~syntax_error () YY_NOEXCEPT YY_NOTHROW;
    };

    /// Token kinds.
    struct token
    {
      enum token_kind_type
      {
        YYEMPTY = -2,
    YYEOF = 0,                     // "end of file"
    YYerror = 256,                 // error
    YYUNDEF = 257,                 // "invalid token"
    VARIABLE = 258,                // VARIABLE
    NUMBER = 259,                  // NUMBER
    ADD = 260,                     // ADD
    DIV = 261,                     // DIV
    MUL = 262,                     // MUL
    SUB = 263,                     // SUB
    OPEN_PAREN = 264,              // OPEN_PAREN
    CLOSED_PAREN = 265,            // CLOSED_PAREN
    SEMICOLON = 266,               // SEMICOLON
    SET = 267,                     // SET
    QUESTION = 268,                // QUESTION
    ELSE = 269,                    // ELSE
    THEN = 270                     // THEN
      };
      /// Backward compatibility alias (Bison 3.6).
      typedef token_kind_type yytokentype;
    };

    /// Token kind, as returned by yylex.
    typedef token::token_kind_type token_kind_type;

    /// Backward compatibility alias (Bison 3.6).
    typedef token_kind_type token_type;

    /// Symbol kinds.
    struct symbol_kind
    {
      enum symbol_kind_type
      {
        YYNTOKENS = 16, ///< Number of tokens.
        S_YYEMPTY = -2,
        S_YYEOF = 0,                             // "end of file"
        S_YYerror = 1,                           // error
        S_YYUNDEF = 2,                           // "invalid token"
        S_VARIABLE = 3,                          // VARIABLE
        S_NUMBER = 4,                            // NUMBER
        S_ADD = 5,                               // ADD
        S_DIV = 6,                               // DIV
        S_MUL = 7,                               // MUL
        S_SUB = 8,                               // SUB
        S_OPEN_PAREN = 9,                        // OPEN_PAREN
        S_CLOSED_PAREN = 10,                     // CLOSED_PAREN
        S_SEMICOLON = 11,                        // SEMICOLON
        S_SET = 12,                              // SET
        S_QUESTION = 13,                         // QUESTION
        S_ELSE = 14,                             // ELSE
        S_THEN = 15,                             // THEN
        S_YYACCEPT = 16,                         // $accept
        S_result = 17,                           // result
        S_statement = 18,                        // statement
        S_tern = 19,                             // tern
        S_expr = 20                              // expr
      };
    };

    /// (Internal) symbol kind.
    typedef symbol_kind::symbol_kind_type symbol_kind_type;

    /// The number of tokens.
    static const symbol_kind_type YYNTOKENS = symbol_kind::YYNTOKENS;

    /// A complete symbol.
    ///
    /// Expects its Base type to provide access to the symbol kind
    /// via kind ().
    ///
    /// Provide access to semantic value.
    template <typename Base>
    struct basic_symbol : Base
    {
      /// Alias to Base.
      typedef Base super_type;

      /// Default constructor.
      basic_symbol () YY_NOEXCEPT
        : value ()
      {}

#if 201103L <= YY_CPLUSPLUS
      /// Move constructor.
      basic_symbol (basic_symbol&& that)
        : Base (std::move (that))
        , value ()
      {
        switch (this->kind ())
    {
      case symbol_kind::S_ADD: // ADD
      case symbol_kind::S_DIV: // DIV
      case symbol_kind::S_MUL: // MUL
      case symbol_kind::S_SUB: // SUB
      case symbol_kind::S_OPEN_PAREN: // OPEN_PAREN
      case symbol_kind::S_CLOSED_PAREN: // CLOSED_PAREN
      case symbol_kind::S_SEMICOLON: // SEMICOLON
      case symbol_kind::S_SET: // SET
      case symbol_kind::S_QUESTION: // QUESTION
      case symbol_kind::S_ELSE: // ELSE
      case symbol_kind::S_THEN: // THEN
        value.move< char > (std::move (that.value));
        break;

      case symbol_kind::S_NUMBER: // NUMBER
        value.move< int > (std::move (that.value));
        break;

      case symbol_kind::S_tern: // tern
      case symbol_kind::S_expr: // expr
        value.move< std::function<int(void)> > (std::move (that.value));
        break;

      case symbol_kind::S_VARIABLE: // VARIABLE
      case symbol_kind::S_statement: // statement
        value.move< std::string > (std::move (that.value));
        break;

      default:
        break;
    }

      }
#endif

      /// Copy constructor.
      basic_symbol (const basic_symbol& that);

      /// Constructors for typed symbols.
#if 201103L <= YY_CPLUSPLUS
      basic_symbol (typename Base::kind_type t)
        : Base (t)
      {}
#else
      basic_symbol (typename Base::kind_type t)
        : Base (t)
      {}
#endif

#if 201103L <= YY_CPLUSPLUS
      basic_symbol (typename Base::kind_type t, char&& v)
        : Base (t)
        , value (std::move (v))
      {}
#else
      basic_symbol (typename Base::kind_type t, const char& v)
        : Base (t)
        , value (v)
      {}
#endif

#if 201103L <= YY_CPLUSPLUS
      basic_symbol (typename Base::kind_type t, int&& v)
        : Base (t)
        , value (std::move (v))
      {}
#else
      basic_symbol (typename Base::kind_type t, const int& v)
        : Base (t)
        , value (v)
      {}
#endif

#if 201103L <= YY_CPLUSPLUS
      basic_symbol (typename Base::kind_type t, std::function<int(void)>&& v)
        : Base (t)
        , value (std::move (v))
      {}
#else
      basic_symbol (typename Base::kind_type t, const std::function<int(void)>& v)
        : Base (t)
        , value (v)
      {}
#endif

#if 201103L <= YY_CPLUSPLUS
      basic_symbol (typename Base::kind_type t, std::string&& v)
        : Base (t)
        , value (std::move (v))
      {}
#else
      basic_symbol (typename Base::kind_type t, const std::string& v)
        : Base (t)
        , value (v)
      {}
#endif

      /// Destroy the symbol.
      ~basic_symbol ()
      {
        clear ();
      }



      /// Destroy contents, and record that is empty.
      void clear () YY_NOEXCEPT
      {
        // User destructor.
        symbol_kind_type yykind = this->kind ();
        basic_symbol<Base>& yysym = *this;
        (void) yysym;
        switch (yykind)
        {
       default:
          break;
        }

        // Value type destructor.
switch (yykind)
    {
      case symbol_kind::S_ADD: // ADD
      case symbol_kind::S_DIV: // DIV
      case symbol_kind::S_MUL: // MUL
      case symbol_kind::S_SUB: // SUB
      case symbol_kind::S_OPEN_PAREN: // OPEN_PAREN
      case symbol_kind::S_CLOSED_PAREN: // CLOSED_PAREN
      case symbol_kind::S_SEMICOLON: // SEMICOLON
      case symbol_kind::S_SET: // SET
      case symbol_kind::S_QUESTION: // QUESTION
      case symbol_kind::S_ELSE: // ELSE
      case symbol_kind::S_THEN: // THEN
        value.template destroy< char > ();
        break;

      case symbol_kind::S_NUMBER: // NUMBER
        value.template destroy< int > ();
        break;

      case symbol_kind::S_tern: // tern
      case symbol_kind::S_expr: // expr
        value.template destroy< std::function<int(void)> > ();
        break;

      case symbol_kind::S_VARIABLE: // VARIABLE
      case symbol_kind::S_statement: // statement
        value.template destroy< std::string > ();
        break;

      default:
        break;
    }

        Base::clear ();
      }

      /// The user-facing name of this symbol.
      const char *name () const YY_NOEXCEPT
      {
        return parser::symbol_name (this->kind ());
      }

      /// Backward compatibility (Bison 3.6).
      symbol_kind_type type_get () const YY_NOEXCEPT;

      /// Whether empty.
      bool empty () const YY_NOEXCEPT;

      /// Destructive move, \a s is emptied into this.
      void move (basic_symbol& s);

      /// The semantic value.
      value_type value;

    private:
#if YY_CPLUSPLUS < 201103L
      /// Assignment operator.
      basic_symbol& operator= (const basic_symbol& that);
#endif
    };

    /// Type access provider for token (enum) based symbols.
    struct by_kind
    {
      /// The symbol kind as needed by the constructor.
      typedef token_kind_type kind_type;

      /// Default constructor.
      by_kind () YY_NOEXCEPT;

#if 201103L <= YY_CPLUSPLUS
      /// Move constructor.
      by_kind (by_kind&& that) YY_NOEXCEPT;
#endif

      /// Copy constructor.
      by_kind (const by_kind& that) YY_NOEXCEPT;

      /// Constructor from (external) token numbers.
      by_kind (kind_type t) YY_NOEXCEPT;



      /// Record that this symbol is empty.
      void clear () YY_NOEXCEPT;

      /// Steal the symbol kind from \a that.
      void move (by_kind& that);

      /// The (internal) type number (corresponding to \a type).
      /// \a empty when empty.
      symbol_kind_type kind () const YY_NOEXCEPT;

      /// Backward compatibility (Bison 3.6).
      symbol_kind_type type_get () const YY_NOEXCEPT;

      /// The symbol kind.
      /// \a S_YYEMPTY when empty.
      symbol_kind_type kind_;
    };

    /// Backward compatibility for a private implementation detail (Bison 3.6).
    typedef by_kind by_type;

    /// "External" symbols: returned by the scanner.
    struct symbol_type : basic_symbol<by_kind>
    {
      /// Superclass.
      typedef basic_symbol<by_kind> super_type;

      /// Empty symbol.
      symbol_type () YY_NOEXCEPT {}

      /// Constructor for valueless symbols, and symbols from each type.
#if 201103L <= YY_CPLUSPLUS
      symbol_type (int tok)
        : super_type (token_kind_type (tok))
#else
      symbol_type (int tok)
        : super_type (token_kind_type (tok))
#endif
      {}
#if 201103L <= YY_CPLUSPLUS
      symbol_type (int tok, char v)
        : super_type (token_kind_type (tok), std::move (v))
#else
      symbol_type (int tok, const char& v)
        : super_type (token_kind_type (tok), v)
#endif
      {}
#if 201103L <= YY_CPLUSPLUS
      symbol_type (int tok, int v)
        : super_type (token_kind_type (tok), std::move (v))
#else
      symbol_type (int tok, const int& v)
        : super_type (token_kind_type (tok), v)
#endif
      {}
#if 201103L <= YY_CPLUSPLUS
      symbol_type (int tok, std::string v)
        : super_type (token_kind_type (tok), std::move (v))
#else
      symbol_type (int tok, const std::string& v)
        : super_type (token_kind_type (tok), v)
#endif
      {}
    };

    /// Build a parser object.
    parser (evaluation_context * ctx_yyarg);
    virtual ~parser ();

#if 201103L <= YY_CPLUSPLUS
    /// Non copyable.
    parser (const parser&) = delete;
    /// Non copyable.
    parser& operator= (const parser&) = delete;
#endif

    /// Parse.  An alias for parse ().
    /// \returns  0 iff parsing succeeded.
    int operator() ();

    /// Parse.
    /// \returns  0 iff parsing succeeded.
    virtual int parse ();

#if YYDEBUG
    /// The current debugging stream.
    std::ostream& debug_stream () const YY_ATTRIBUTE_PURE;
    /// Set the current debugging stream.
    void set_debug_stream (std::ostream &);

    /// Type for debugging levels.
    typedef int debug_level_type;
    /// The current debugging level.
    debug_level_type debug_level () const YY_ATTRIBUTE_PURE;
    /// Set the current debugging level.
    void set_debug_level (debug_level_type l);
#endif

    /// Report a syntax error.
    /// \param msg    a description of the syntax error.
    virtual void error (const std::string& msg);

    /// Report a syntax error.
    void error (const syntax_error& err);

    /// The user-facing name of the symbol whose (internal) number is
    /// YYSYMBOL.  No bounds checking.
    static const char *symbol_name (symbol_kind_type yysymbol);

    // Implementation of make_symbol for each token kind.
#if 201103L <= YY_CPLUSPLUS
      static
      symbol_type
      make_YYEOF ()
      {
        return symbol_type (token::YYEOF);
      }
#else
      static
      symbol_type
      make_YYEOF ()
      {
        return symbol_type (token::YYEOF);
      }
#endif
#if 201103L <= YY_CPLUSPLUS
      static
      symbol_type
      make_YYerror ()
      {
        return symbol_type (token::YYerror);
      }
#else
      static
      symbol_type
      make_YYerror ()
      {
        return symbol_type (token::YYerror);
      }
#endif
#if 201103L <= YY_CPLUSPLUS
      static
      symbol_type
      make_YYUNDEF ()
      {
        return symbol_type (token::YYUNDEF);
      }
#else
      static
      symbol_type
      make_YYUNDEF ()
      {
        return symbol_type (token::YYUNDEF);
      }
#endif
#if 201103L <= YY_CPLUSPLUS
      static
      symbol_type
      make_VARIABLE (std::string v)
      {
        return symbol_type (token::VARIABLE, std::move (v));
      }
#else
      static
      symbol_type
      make_VARIABLE (const std::string& v)
      {
        return symbol_type (token::VARIABLE, v);
      }
#endif
#if 201103L <= YY_CPLUSPLUS
      static
      symbol_type
      make_NUMBER (int v)
      {
        return symbol_type (token::NUMBER, std::move (v));
      }
#else
      static
      symbol_type
      make_NUMBER (const int& v)
      {
        return symbol_type (token::NUMBER, v);
      }
#endif
#if 201103L <= YY_CPLUSPLUS
      static
      symbol_type
      make_ADD (char v)
      {
        return symbol_type (token::ADD, std::move (v));
      }
#else
      static
      symbol_type
      make_ADD (const char& v)
      {
        return symbol_type (token::ADD, v);
      }
#endif
#if 201103L <= YY_CPLUSPLUS
      static
      symbol_type
      make_DIV (char v)
      {
        return symbol_type (token::DIV, std::move (v));
      }
#else
      static
      symbol_type
      make_DIV (const char& v)
      {
        return symbol_type (token::DIV, v);
      }
#endif
#if 201103L <= YY_CPLUSPLUS
      static
      symbol_type
      make_MUL (char v)
      {
        return symbol_type (token::MUL, std::move (v));
      }
#else
      static
      symbol_type
      make_MUL (const char& v)
      {
        return symbol_type (token::MUL, v);
      }
#endif
#if 201103L <= YY_CPLUSPLUS
      static
      symbol_type
      make_SUB (char v)
      {
        return symbol_type (token::SUB, std::move (v));
      }
#else
      static
      symbol_type
      make_SUB (const char& v)
      {
        return symbol_type (token::SUB, v);
      }
#endif
#if 201103L <= YY_CPLUSPLUS
      static
      symbol_type
      make_OPEN_PAREN (char v)
      {
        return symbol_type (token::OPEN_PAREN, std::move (v));
      }
#else
      static
      symbol_type
      make_OPEN_PAREN (const char& v)
      {
        return symbol_type (token::OPEN_PAREN, v);
      }
#endif
#if 201103L <= YY_CPLUSPLUS
      static
      symbol_type
      make_CLOSED_PAREN (char v)
      {
        return symbol_type (token::CLOSED_PAREN, std::move (v));
      }
#else
      static
      symbol_type
      make_CLOSED_PAREN (const char& v)
      {
        return symbol_type (token::CLOSED_PAREN, v);
      }
#endif
#if 201103L <= YY_CPLUSPLUS
      static
      symbol_type
      make_SEMICOLON (char v)
      {
        return symbol_type (token::SEMICOLON, std::move (v));
      }
#else
      static
      symbol_type
      make_SEMICOLON (const char& v)
      {
        return symbol_type (token::SEMICOLON, v);
      }
#endif
#if 201103L <= YY_CPLUSPLUS
      static
      symbol_type
      make_SET (char v)
      {
        return symbol_type (token::SET, std::move (v));
      }
#else
      static
      symbol_type
      make_SET (const char& v)
      {
        return symbol_type (token::SET, v);
      }
#endif
#if 201103L <= YY_CPLUSPLUS
      static
      symbol_type
      make_QUESTION (char v)
      {
        return symbol_type (token::QUESTION, std::move (v));
      }
#else
      static
      symbol_type
      make_QUESTION (const char& v)
      {
        return symbol_type (token::QUESTION, v);
      }
#endif
#if 201103L <= YY_CPLUSPLUS
      static
      symbol_type
      make_ELSE (char v)
      {
        return symbol_type (token::ELSE, std::move (v));
      }
#else
      static
      symbol_type
      make_ELSE (const char& v)
      {
        return symbol_type (token::ELSE, v);
      }
#endif
#if 201103L <= YY_CPLUSPLUS
      static
      symbol_type
      make_THEN (char v)
      {
        return symbol_type (token::THEN, std::move (v));
      }
#else
      static
      symbol_type
      make_THEN (const char& v)
      {
        return symbol_type (token::THEN, v);
      }
#endif


    class context
    {
    public:
      context (const parser& yyparser, const symbol_type& yyla);
      const symbol_type& lookahead () const YY_NOEXCEPT { return yyla_; }
      symbol_kind_type token () const YY_NOEXCEPT { return yyla_.kind (); }
      /// Put in YYARG at most YYARGN of the expected tokens, and return the
      /// number of tokens stored in YYARG.  If YYARG is null, return the
      /// number of expected tokens (guaranteed to be less than YYNTOKENS).
      int expected_tokens (symbol_kind_type yyarg[], int yyargn) const;

    private:
      const parser& yyparser_;
      const symbol_type& yyla_;
    };

  private:
#if YY_CPLUSPLUS < 201103L
    /// Non copyable.
    parser (const parser&);
    /// Non copyable.
    parser& operator= (const parser&);
#endif


    /// Stored state numbers (used for stacks).
    typedef signed char state_type;

    /// The arguments of the error message.
    int yy_syntax_error_arguments_ (const context& yyctx,
                                    symbol_kind_type yyarg[], int yyargn) const;

    /// Generate an error message.
    /// \param yyctx     the context in which the error occurred.
    virtual std::string yysyntax_error_ (const context& yyctx) const;
    /// Compute post-reduction state.
    /// \param yystate   the current state
    /// \param yysym     the nonterminal to push on the stack
    static state_type yy_lr_goto_state_ (state_type yystate, int yysym);

    /// Whether the given \c yypact_ value indicates a defaulted state.
    /// \param yyvalue   the value to check
    static bool yy_pact_value_is_default_ (int yyvalue) YY_NOEXCEPT;

    /// Whether the given \c yytable_ value indicates a syntax error.
    /// \param yyvalue   the value to check
    static bool yy_table_value_is_error_ (int yyvalue) YY_NOEXCEPT;

    static const signed char yypact_ninf_;
    static const signed char yytable_ninf_;

    /// Convert a scanner token kind \a t to a symbol kind.
    /// In theory \a t should be a token_kind_type, but character literals
    /// are valid, yet not members of the token_kind_type enum.
    static symbol_kind_type yytranslate_ (int t) YY_NOEXCEPT;



    // Tables.
    // YYPACT[STATE-NUM] -- Index in YYTABLE of the portion describing
    // STATE-NUM.
    static const signed char yypact_[];

    // YYDEFACT[STATE-NUM] -- Default reduction number in state STATE-NUM.
    // Performed when YYTABLE does not specify something else to do.  Zero
    // means the default is an error.
    static const signed char yydefact_[];

    // YYPGOTO[NTERM-NUM].
    static const signed char yypgoto_[];

    // YYDEFGOTO[NTERM-NUM].
    static const signed char yydefgoto_[];

    // YYTABLE[YYPACT[STATE-NUM]] -- What to do in state STATE-NUM.  If
    // positive, shift that token.  If negative, reduce the rule whose
    // number is the opposite.  If YYTABLE_NINF, syntax error.
    static const signed char yytable_[];

    static const signed char yycheck_[];

    // YYSTOS[STATE-NUM] -- The symbol kind of the accessing symbol of
    // state STATE-NUM.
    static const signed char yystos_[];

    // YYR1[RULE-NUM] -- Symbol kind of the left-hand side of rule RULE-NUM.
    static const signed char yyr1_[];

    // YYR2[RULE-NUM] -- Number of symbols on the right-hand side of rule RULE-NUM.
    static const signed char yyr2_[];


#if YYDEBUG
    // YYRLINE[YYN] -- Source line where rule number YYN was defined.
    static const short yyrline_[];
    /// Report on the debug stream that the rule \a r is going to be reduced.
    virtual void yy_reduce_print_ (int r) const;
    /// Print the state stack on the debug stream.
    virtual void yy_stack_print_ () const;

    /// Debugging level.
    int yydebug_;
    /// Debug stream.
    std::ostream* yycdebug_;

    /// \brief Display a symbol kind, value and location.
    /// \param yyo    The output stream.
    /// \param yysym  The symbol.
    template <typename Base>
    void yy_print_ (std::ostream& yyo, const basic_symbol<Base>& yysym) const;
#endif

    /// \brief Reclaim the memory associated to a symbol.
    /// \param yymsg     Why this token is reclaimed.
    ///                  If null, print nothing.
    /// \param yysym     The symbol.
    template <typename Base>
    void yy_destroy_ (const char* yymsg, basic_symbol<Base>& yysym) const;

  private:
    /// Type access provider for state based symbols.
    struct by_state
    {
      /// Default constructor.
      by_state () YY_NOEXCEPT;

      /// The symbol kind as needed by the constructor.
      typedef state_type kind_type;

      /// Constructor.
      by_state (kind_type s) YY_NOEXCEPT;

      /// Copy constructor.
      by_state (const by_state& that) YY_NOEXCEPT;

      /// Record that this symbol is empty.
      void clear () YY_NOEXCEPT;

      /// Steal the symbol kind from \a that.
      void move (by_state& that);

      /// The symbol kind (corresponding to \a state).
      /// \a symbol_kind::S_YYEMPTY when empty.
      symbol_kind_type kind () const YY_NOEXCEPT;

      /// The state number used to denote an empty symbol.
      /// We use the initial state, as it does not have a value.
      enum { empty_state = 0 };

      /// The state.
      /// \a empty when empty.
      state_type state;
    };

    /// "Internal" symbol: element of the stack.
    struct stack_symbol_type : basic_symbol<by_state>
    {
      /// Superclass.
      typedef basic_symbol<by_state> super_type;
      /// Construct an empty symbol.
      stack_symbol_type ();
      /// Move or copy construction.
      stack_symbol_type (YY_RVREF (stack_symbol_type) that);
      /// Steal the contents from \a sym to build this.
      stack_symbol_type (state_type s, YY_MOVE_REF (symbol_type) sym);
#if YY_CPLUSPLUS < 201103L
      /// Assignment, needed by push_back by some old implementations.
      /// Moves the contents of that.
      stack_symbol_type& operator= (stack_symbol_type& that);

      /// Assignment, needed by push_back by other implementations.
      /// Needed by some other old implementations.
      stack_symbol_type& operator= (const stack_symbol_type& that);
#endif
    };

    /// A stack with random access from its top.
    template <typename T, typename S = std::vector<T> >
    class stack
    {
    public:
      // Hide our reversed order.
      typedef typename S::iterator iterator;
      typedef typename S::const_iterator const_iterator;
      typedef typename S::size_type size_type;
      typedef typename std::ptrdiff_t index_type;

      stack (size_type n = 200) YY_NOEXCEPT
        : seq_ (n)
      {}

#if 201103L <= YY_CPLUSPLUS
      /// Non copyable.
      stack (const stack&) = delete;
      /// Non copyable.
      stack& operator= (const stack&) = delete;
#endif

      /// Random access.
      ///
      /// Index 0 returns the topmost element.
      const T&
      operator[] (index_type i) const
      {
        return seq_[size_type (size () - 1 - i)];
      }

      /// Random access.
      ///
      /// Index 0 returns the topmost element.
      T&
      operator[] (index_type i)
      {
        return seq_[size_type (size () - 1 - i)];
      }

      /// Steal the contents of \a t.
      ///
      /// Close to move-semantics.
      void
      push (YY_MOVE_REF (T) t)
      {
        seq_.push_back (T ());
        operator[] (0).move (t);
      }

      /// Pop elements from the stack.
      void
      pop (std::ptrdiff_t n = 1) YY_NOEXCEPT
      {
        for (; 0 < n; --n)
          seq_.pop_back ();
      }

      /// Pop all elements from the stack.
      void
      clear () YY_NOEXCEPT
      {
        seq_.clear ();
      }

      /// Number of elements on the stack.
      index_type
      size () const YY_NOEXCEPT
      {
        return index_type (seq_.size ());
      }

      /// Iterator on top of the stack (going downwards).
      const_iterator
      begin () const YY_NOEXCEPT
      {
        return seq_.begin ();
      }

      /// Bottom of the stack.
      const_iterator
      end () const YY_NOEXCEPT
      {
        return seq_.end ();
      }

      /// Present a slice of the top of a stack.
      class slice
      {
      public:
        slice (const stack& stack, index_type range) YY_NOEXCEPT
          : stack_ (stack)
          , range_ (range)
        {}

        const T&
        operator[] (index_type i) const
        {
          return stack_[range_ - i];
        }

      private:
        const stack& stack_;
        index_type range_;
      };

    private:
#if YY_CPLUSPLUS < 201103L
      /// Non copyable.
      stack (const stack&);
      /// Non copyable.
      stack& operator= (const stack&);
#endif
      /// The wrapped container.
      S seq_;
    };


    /// Stack type.
    typedef stack<stack_symbol_type> stack_type;

    /// The stack.
    stack_type yystack_;

    /// Push a new state on the stack.
    /// \param m    a debug message to display
    ///             if null, no trace is output.
    /// \param sym  the symbol
    /// \warning the contents of \a s.value is stolen.
    void yypush_ (const char* m, YY_MOVE_REF (stack_symbol_type) sym);

    /// Push a new look ahead token on the state on the stack.
    /// \param m    a debug message to display
    ///             if null, no trace is output.
    /// \param s    the state
    /// \param sym  the symbol (for its value and location).
    /// \warning the contents of \a sym.value is stolen.
    void yypush_ (const char* m, state_type s, YY_MOVE_REF (symbol_type) sym);

    /// Pop \a n symbols from the stack.
    void yypop_ (int n = 1) YY_NOEXCEPT;

    /// Constants.
    enum
    {
      yylast_ = 41,     ///< Last index in yytable_.
      yynnts_ = 5,  ///< Number of nonterminal symbols.
      yyfinal_ = 2 ///< Termination state number.
    };


    // User arguments.
    evaluation_context * ctx;

  };

  parser::symbol_kind_type
  parser::yytranslate_ (int t) YY_NOEXCEPT
  {
    // YYTRANSLATE[TOKEN-NUM] -- Symbol number corresponding to
    // TOKEN-NUM as returned by yylex.
    static
    const signed char
    translate_table[] =
    {
       0,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     1,     2,     3,     4,
       5,     6,     7,     8,     9,    10,    11,    12,    13,    14,
      15
    };
    // Last valid token kind.
    const int code_max = 270;

    if (t <= 0)
      return symbol_kind::S_YYEOF;
    else if (t <= code_max)
      return static_cast <symbol_kind_type> (translate_table[t]);
    else
      return symbol_kind::S_YYUNDEF;
  }

  // basic_symbol.
  template <typename Base>
  parser::basic_symbol<Base>::basic_symbol (const basic_symbol& that)
    : Base (that)
    , value ()
  {
    switch (this->kind ())
    {
      case symbol_kind::S_ADD: // ADD
      case symbol_kind::S_DIV: // DIV
      case symbol_kind::S_MUL: // MUL
      case symbol_kind::S_SUB: // SUB
      case symbol_kind::S_OPEN_PAREN: // OPEN_PAREN
      case symbol_kind::S_CLOSED_PAREN: // CLOSED_PAREN
      case symbol_kind::S_SEMICOLON: // SEMICOLON
      case symbol_kind::S_SET: // SET
      case symbol_kind::S_QUESTION: // QUESTION
      case symbol_kind::S_ELSE: // ELSE
      case symbol_kind::S_THEN: // THEN
        value.copy< char > (YY_MOVE (that.value));
        break;

      case symbol_kind::S_NUMBER: // NUMBER
        value.copy< int > (YY_MOVE (that.value));
        break;

      case symbol_kind::S_tern: // tern
      case symbol_kind::S_expr: // expr
        value.copy< std::function<int(void)> > (YY_MOVE (that.value));
        break;

      case symbol_kind::S_VARIABLE: // VARIABLE
      case symbol_kind::S_statement: // statement
        value.copy< std::string > (YY_MOVE (that.value));
        break;

      default:
        break;
    }

  }




  template <typename Base>
  parser::symbol_kind_type
  parser::basic_symbol<Base>::type_get () const YY_NOEXCEPT
  {
    return this->kind ();
  }


  template <typename Base>
  bool
  parser::basic_symbol<Base>::empty () const YY_NOEXCEPT
  {
    return this->kind () == symbol_kind::S_YYEMPTY;
  }

  template <typename Base>
  void
  parser::basic_symbol<Base>::move (basic_symbol& s)
  {
    super_type::move (s);
    switch (this->kind ())
    {
      case symbol_kind::S_ADD: // ADD
      case symbol_kind::S_DIV: // DIV
      case symbol_kind::S_MUL: // MUL
      case symbol_kind::S_SUB: // SUB
      case symbol_kind::S_OPEN_PAREN: // OPEN_PAREN
      case symbol_kind::S_CLOSED_PAREN: // CLOSED_PAREN
      case symbol_kind::S_SEMICOLON: // SEMICOLON
      case symbol_kind::S_SET: // SET
      case symbol_kind::S_QUESTION: // QUESTION
      case symbol_kind::S_ELSE: // ELSE
      case symbol_kind::S_THEN: // THEN
        value.move< char > (YY_MOVE (s.value));
        break;

      case symbol_kind::S_NUMBER: // NUMBER
        value.move< int > (YY_MOVE (s.value));
        break;

      case symbol_kind::S_tern: // tern
      case symbol_kind::S_expr: // expr
        value.move< std::function<int(void)> > (YY_MOVE (s.value));
        break;

      case symbol_kind::S_VARIABLE: // VARIABLE
      case symbol_kind::S_statement: // statement
        value.move< std::string > (YY_MOVE (s.value));
        break;

      default:
        break;
    }

  }

  // by_kind.
  parser::by_kind::by_kind () YY_NOEXCEPT
    : kind_ (symbol_kind::S_YYEMPTY)
  {}

#if 201103L <= YY_CPLUSPLUS
  parser::by_kind::by_kind (by_kind&& that) YY_NOEXCEPT
    : kind_ (that.kind_)
  {
    that.clear ();
  }
#endif

  parser::by_kind::by_kind (const by_kind& that) YY_NOEXCEPT
    : kind_ (that.kind_)
  {}

  parser::by_kind::by_kind (token_kind_type t) YY_NOEXCEPT
    : kind_ (yytranslate_ (t))
  {}



  void
  parser::by_kind::clear () YY_NOEXCEPT
  {
    kind_ = symbol_kind::S_YYEMPTY;
  }

  void
  parser::by_kind::move (by_kind& that)
  {
    kind_ = that.kind_;
    that.clear ();
  }

  parser::symbol_kind_type
  parser::by_kind::kind () const YY_NOEXCEPT
  {
    return kind_;
  }


  parser::symbol_kind_type
  parser::by_kind::type_get () const YY_NOEXCEPT
  {
    return this->kind ();
  }


} // yy
#line 1717 "simple.cc"






// Unqualified %code blocks.
#line 113 "simple.yy"

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

#line 1874 "simple.cc"


#ifndef YY_
# if defined YYENABLE_NLS && YYENABLE_NLS
#  if ENABLE_NLS
#   include <libintl.h> // FIXME: INFRINGES ON USER NAME SPACE.
#   define YY_(msgid) dgettext ("bison-runtime", msgid)
#  endif
# endif
# ifndef YY_
#  define YY_(msgid) msgid
# endif
#endif


// Whether we are compiled with exception support.
#ifndef YY_EXCEPTIONS
# if defined __GNUC__ && !defined __EXCEPTIONS
#  define YY_EXCEPTIONS 0
# else
#  define YY_EXCEPTIONS 1
# endif
#endif



// Enable debugging if requested.
#if YYDEBUG

// A pseudo ostream that takes yydebug_ into account.
# define YYCDEBUG if (yydebug_) (*yycdebug_)

# define YY_SYMBOL_PRINT(Title, Symbol)         \
  do {                                          \
    if (yydebug_)                               \
    {                                           \
      *yycdebug_ << Title << ' ';               \
      yy_print_ (*yycdebug_, Symbol);           \
      *yycdebug_ << '\n';                       \
    }                                           \
  } while (false)

# define YY_REDUCE_PRINT(Rule)          \
  do {                                  \
    if (yydebug_)                       \
      yy_reduce_print_ (Rule);          \
  } while (false)

# define YY_STACK_PRINT()               \
  do {                                  \
    if (yydebug_)                       \
      yy_stack_print_ ();                \
  } while (false)

#else // !YYDEBUG

# define YYCDEBUG if (false) std::cerr
# define YY_SYMBOL_PRINT(Title, Symbol)  YY_USE (Symbol)
# define YY_REDUCE_PRINT(Rule)           static_cast<void> (0)
# define YY_STACK_PRINT()                static_cast<void> (0)

#endif // !YYDEBUG

#define yyerrok         (yyerrstatus_ = 0)
#define yyclearin       (yyla.clear ())

#define YYACCEPT        goto yyacceptlab
#define YYABORT         goto yyabortlab
#define YYERROR         goto yyerrorlab
#define YYRECOVERING()  (!!yyerrstatus_)

namespace yy {
#line 1947 "simple.cc"

  /// Build a parser object.
  parser::parser (evaluation_context * ctx_yyarg)
#if YYDEBUG
    : yydebug_ (false),
      yycdebug_ (&std::cerr),
#else
    :
#endif
      ctx (ctx_yyarg)
  {}

  parser::~parser ()
  {}

  parser::syntax_error::~syntax_error () YY_NOEXCEPT YY_NOTHROW
  {}

  /*---------.
  | symbol.  |
  `---------*/



  // by_state.
  parser::by_state::by_state () YY_NOEXCEPT
    : state (empty_state)
  {}

  parser::by_state::by_state (const by_state& that) YY_NOEXCEPT
    : state (that.state)
  {}

  void
  parser::by_state::clear () YY_NOEXCEPT
  {
    state = empty_state;
  }

  void
  parser::by_state::move (by_state& that)
  {
    state = that.state;
    that.clear ();
  }

  parser::by_state::by_state (state_type s) YY_NOEXCEPT
    : state (s)
  {}

  parser::symbol_kind_type
  parser::by_state::kind () const YY_NOEXCEPT
  {
    if (state == empty_state)
      return symbol_kind::S_YYEMPTY;
    else
      return YY_CAST (symbol_kind_type, yystos_[+state]);
  }

  parser::stack_symbol_type::stack_symbol_type ()
  {}

  parser::stack_symbol_type::stack_symbol_type (YY_RVREF (stack_symbol_type) that)
    : super_type (YY_MOVE (that.state))
  {
    switch (that.kind ())
    {
      case symbol_kind::S_ADD: // ADD
      case symbol_kind::S_DIV: // DIV
      case symbol_kind::S_MUL: // MUL
      case symbol_kind::S_SUB: // SUB
      case symbol_kind::S_OPEN_PAREN: // OPEN_PAREN
      case symbol_kind::S_CLOSED_PAREN: // CLOSED_PAREN
      case symbol_kind::S_SEMICOLON: // SEMICOLON
      case symbol_kind::S_SET: // SET
      case symbol_kind::S_QUESTION: // QUESTION
      case symbol_kind::S_ELSE: // ELSE
      case symbol_kind::S_THEN: // THEN
        value.YY_MOVE_OR_COPY< char > (YY_MOVE (that.value));
        break;

      case symbol_kind::S_NUMBER: // NUMBER
        value.YY_MOVE_OR_COPY< int > (YY_MOVE (that.value));
        break;

      case symbol_kind::S_tern: // tern
      case symbol_kind::S_expr: // expr
        value.YY_MOVE_OR_COPY< std::function<int(void)> > (YY_MOVE (that.value));
        break;

      case symbol_kind::S_VARIABLE: // VARIABLE
      case symbol_kind::S_statement: // statement
        value.YY_MOVE_OR_COPY< std::string > (YY_MOVE (that.value));
        break;

      default:
        break;
    }

#if 201103L <= YY_CPLUSPLUS
    // that is emptied.
    that.state = empty_state;
#endif
  }

  parser::stack_symbol_type::stack_symbol_type (state_type s, YY_MOVE_REF (symbol_type) that)
    : super_type (s)
  {
    switch (that.kind ())
    {
      case symbol_kind::S_ADD: // ADD
      case symbol_kind::S_DIV: // DIV
      case symbol_kind::S_MUL: // MUL
      case symbol_kind::S_SUB: // SUB
      case symbol_kind::S_OPEN_PAREN: // OPEN_PAREN
      case symbol_kind::S_CLOSED_PAREN: // CLOSED_PAREN
      case symbol_kind::S_SEMICOLON: // SEMICOLON
      case symbol_kind::S_SET: // SET
      case symbol_kind::S_QUESTION: // QUESTION
      case symbol_kind::S_ELSE: // ELSE
      case symbol_kind::S_THEN: // THEN
        value.move< char > (YY_MOVE (that.value));
        break;

      case symbol_kind::S_NUMBER: // NUMBER
        value.move< int > (YY_MOVE (that.value));
        break;

      case symbol_kind::S_tern: // tern
      case symbol_kind::S_expr: // expr
        value.move< std::function<int(void)> > (YY_MOVE (that.value));
        break;

      case symbol_kind::S_VARIABLE: // VARIABLE
      case symbol_kind::S_statement: // statement
        value.move< std::string > (YY_MOVE (that.value));
        break;

      default:
        break;
    }

    // that is emptied.
    that.kind_ = symbol_kind::S_YYEMPTY;
  }

#if YY_CPLUSPLUS < 201103L
  parser::stack_symbol_type&
  parser::stack_symbol_type::operator= (const stack_symbol_type& that)
  {
    state = that.state;
    switch (that.kind ())
    {
      case symbol_kind::S_ADD: // ADD
      case symbol_kind::S_DIV: // DIV
      case symbol_kind::S_MUL: // MUL
      case symbol_kind::S_SUB: // SUB
      case symbol_kind::S_OPEN_PAREN: // OPEN_PAREN
      case symbol_kind::S_CLOSED_PAREN: // CLOSED_PAREN
      case symbol_kind::S_SEMICOLON: // SEMICOLON
      case symbol_kind::S_SET: // SET
      case symbol_kind::S_QUESTION: // QUESTION
      case symbol_kind::S_ELSE: // ELSE
      case symbol_kind::S_THEN: // THEN
        value.copy< char > (that.value);
        break;

      case symbol_kind::S_NUMBER: // NUMBER
        value.copy< int > (that.value);
        break;

      case symbol_kind::S_tern: // tern
      case symbol_kind::S_expr: // expr
        value.copy< std::function<int(void)> > (that.value);
        break;

      case symbol_kind::S_VARIABLE: // VARIABLE
      case symbol_kind::S_statement: // statement
        value.copy< std::string > (that.value);
        break;

      default:
        break;
    }

    return *this;
  }

  parser::stack_symbol_type&
  parser::stack_symbol_type::operator= (stack_symbol_type& that)
  {
    state = that.state;
    switch (that.kind ())
    {
      case symbol_kind::S_ADD: // ADD
      case symbol_kind::S_DIV: // DIV
      case symbol_kind::S_MUL: // MUL
      case symbol_kind::S_SUB: // SUB
      case symbol_kind::S_OPEN_PAREN: // OPEN_PAREN
      case symbol_kind::S_CLOSED_PAREN: // CLOSED_PAREN
      case symbol_kind::S_SEMICOLON: // SEMICOLON
      case symbol_kind::S_SET: // SET
      case symbol_kind::S_QUESTION: // QUESTION
      case symbol_kind::S_ELSE: // ELSE
      case symbol_kind::S_THEN: // THEN
        value.move< char > (that.value);
        break;

      case symbol_kind::S_NUMBER: // NUMBER
        value.move< int > (that.value);
        break;

      case symbol_kind::S_tern: // tern
      case symbol_kind::S_expr: // expr
        value.move< std::function<int(void)> > (that.value);
        break;

      case symbol_kind::S_VARIABLE: // VARIABLE
      case symbol_kind::S_statement: // statement
        value.move< std::string > (that.value);
        break;

      default:
        break;
    }

    // that is emptied.
    that.state = empty_state;
    return *this;
  }
#endif

  template <typename Base>
  void
  parser::yy_destroy_ (const char* yymsg, basic_symbol<Base>& yysym) const
  {
    if (yymsg)
      YY_SYMBOL_PRINT (yymsg, yysym);
  }

#if YYDEBUG
  template <typename Base>
  void
  parser::yy_print_ (std::ostream& yyo, const basic_symbol<Base>& yysym) const
  {
    std::ostream& yyoutput = yyo;
    YY_USE (yyoutput);
    if (yysym.empty ())
      yyo << "empty symbol";
    else
      {
        symbol_kind_type yykind = yysym.kind ();
        yyo << (yykind < YYNTOKENS ? "token" : "nterm")
            << ' ' << yysym.name () << " (";
        YY_USE (yykind);
        yyo << ')';
      }
  }
#endif

  void
  parser::yypush_ (const char* m, YY_MOVE_REF (stack_symbol_type) sym)
  {
    if (m)
      YY_SYMBOL_PRINT (m, sym);
    yystack_.push (YY_MOVE (sym));
  }

  void
  parser::yypush_ (const char* m, state_type s, YY_MOVE_REF (symbol_type) sym)
  {
#if 201103L <= YY_CPLUSPLUS
    yypush_ (m, stack_symbol_type (s, std::move (sym)));
#else
    stack_symbol_type ss (s, sym);
    yypush_ (m, ss);
#endif
  }

  void
  parser::yypop_ (int n) YY_NOEXCEPT
  {
    yystack_.pop (n);
  }

#if YYDEBUG
  std::ostream&
  parser::debug_stream () const
  {
    return *yycdebug_;
  }

  void
  parser::set_debug_stream (std::ostream& o)
  {
    yycdebug_ = &o;
  }


  parser::debug_level_type
  parser::debug_level () const
  {
    return yydebug_;
  }

  void
  parser::set_debug_level (debug_level_type l)
  {
    yydebug_ = l;
  }
#endif // YYDEBUG

  parser::state_type
  parser::yy_lr_goto_state_ (state_type yystate, int yysym)
  {
    int yyr = yypgoto_[yysym - YYNTOKENS] + yystate;
    if (0 <= yyr && yyr <= yylast_ && yycheck_[yyr] == yystate)
      return yytable_[yyr];
    else
      return yydefgoto_[yysym - YYNTOKENS];
  }

  bool
  parser::yy_pact_value_is_default_ (int yyvalue) YY_NOEXCEPT
  {
    return yyvalue == yypact_ninf_;
  }

  bool
  parser::yy_table_value_is_error_ (int yyvalue) YY_NOEXCEPT
  {
    return yyvalue == yytable_ninf_;
  }

  int
  parser::operator() ()
  {
    return parse ();
  }

  int
  parser::parse ()
  {
    int yyn;
    /// Length of the RHS of the rule being reduced.
    int yylen = 0;

    // Error handling.
    int yynerrs_ = 0;
    int yyerrstatus_ = 0;

    /// The lookahead symbol.
    symbol_type yyla;

    /// The return value of parse ().
    int yyresult;

#if YY_EXCEPTIONS
    try
#endif // YY_EXCEPTIONS
      {
    YYCDEBUG << "Starting parse\n";


    /* Initialize the stack.  The initial state will be set in
       yynewstate, since the latter expects the semantical and the
       location values to have been already stored, initialize these
       stacks with a primary value.  */
    yystack_.clear ();
    yypush_ (YY_NULLPTR, 0, YY_MOVE (yyla));

  /*-----------------------------------------------.
  | yynewstate -- push a new symbol on the stack.  |
  `-----------------------------------------------*/
  yynewstate:
    YYCDEBUG << "Entering state " << int (yystack_[0].state) << '\n';
    YY_STACK_PRINT ();

    // Accept?
    if (yystack_[0].state == yyfinal_)
      YYACCEPT;

    goto yybackup;


  /*-----------.
  | yybackup.  |
  `-----------*/
  yybackup:
    // Try to take a decision without lookahead.
    yyn = yypact_[+yystack_[0].state];
    if (yy_pact_value_is_default_ (yyn))
      goto yydefault;

    // Read a lookahead token.
    if (yyla.empty ())
      {
        YYCDEBUG << "Reading a token\n";
#if YY_EXCEPTIONS
        try
#endif // YY_EXCEPTIONS
          {
            symbol_type yylookahead (yylex ());
            yyla.move (yylookahead);
          }
#if YY_EXCEPTIONS
        catch (const syntax_error& yyexc)
          {
            YYCDEBUG << "Caught exception: " << yyexc.what() << '\n';
            error (yyexc);
            goto yyerrlab1;
          }
#endif // YY_EXCEPTIONS
      }
    YY_SYMBOL_PRINT ("Next token is", yyla);

    if (yyla.kind () == symbol_kind::S_YYerror)
    {
      // The scanner already issued an error message, process directly
      // to error recovery.  But do not keep the error token as
      // lookahead, it is too special and may lead us to an endless
      // loop in error recovery. */
      yyla.kind_ = symbol_kind::S_YYUNDEF;
      goto yyerrlab1;
    }

    /* If the proper action on seeing token YYLA.TYPE is to reduce or
       to detect an error, take that action.  */
    yyn += yyla.kind ();
    if (yyn < 0 || yylast_ < yyn || yycheck_[yyn] != yyla.kind ())
      {
        goto yydefault;
      }

    // Reduce or error.
    yyn = yytable_[yyn];
    if (yyn <= 0)
      {
        if (yy_table_value_is_error_ (yyn))
          goto yyerrlab;
        yyn = -yyn;
        goto yyreduce;
      }

    // Count tokens shifted since error; after three, turn off error status.
    if (yyerrstatus_)
      --yyerrstatus_;

    // Shift the lookahead token.
    yypush_ ("Shifting", state_type (yyn), YY_MOVE (yyla));
    goto yynewstate;


  /*-----------------------------------------------------------.
  | yydefault -- do the default action for the current state.  |
  `-----------------------------------------------------------*/
  yydefault:
    yyn = yydefact_[+yystack_[0].state];
    if (yyn == 0)
      goto yyerrlab;
    goto yyreduce;


  /*-----------------------------.
  | yyreduce -- do a reduction.  |
  `-----------------------------*/
  yyreduce:
    yylen = yyr2_[yyn];
    {
      stack_symbol_type yylhs;
      yylhs.state = yy_lr_goto_state_ (yystack_[yylen].state, yyr1_[yyn]);
      /* Variants are always initialized to an empty instance of the
         correct type. The default '$$ = $1' action is NOT applied
         when using variants.  */
      switch (yyr1_[yyn])
    {
      case symbol_kind::S_ADD: // ADD
      case symbol_kind::S_DIV: // DIV
      case symbol_kind::S_MUL: // MUL
      case symbol_kind::S_SUB: // SUB
      case symbol_kind::S_OPEN_PAREN: // OPEN_PAREN
      case symbol_kind::S_CLOSED_PAREN: // CLOSED_PAREN
      case symbol_kind::S_SEMICOLON: // SEMICOLON
      case symbol_kind::S_SET: // SET
      case symbol_kind::S_QUESTION: // QUESTION
      case symbol_kind::S_ELSE: // ELSE
      case symbol_kind::S_THEN: // THEN
        yylhs.value.emplace< char > ();
        break;

      case symbol_kind::S_NUMBER: // NUMBER
        yylhs.value.emplace< int > ();
        break;

      case symbol_kind::S_tern: // tern
      case symbol_kind::S_expr: // expr
        yylhs.value.emplace< std::function<int(void)> > ();
        break;

      case symbol_kind::S_VARIABLE: // VARIABLE
      case symbol_kind::S_statement: // statement
        yylhs.value.emplace< std::string > ();
        break;

      default:
        break;
    }



      // Perform the reduction.
      YY_REDUCE_PRINT (yyn);
#if YY_EXCEPTIONS
      try
#endif // YY_EXCEPTIONS
        {
          switch (yyn)
            {
  case 3: // result: result statement SEMICOLON
#line 286 "simple.yy"
                             { 
    for (auto text_node : yystack_[1].value.as < std::string > ()) {
      std::cout << text_node;
    }
    std::cout << std::endl; 
  }
#line 2474 "simple.cc"
    break;

  case 4: // result: result error
#line 292 "simple.yy"
               {
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
#line 2499 "simple.cc"
    break;

  case 5: // statement: %empty
#line 315 "simple.yy"
         {
    yylhs.value.as < std::string > () = std::string{};
  }
#line 2507 "simple.cc"
    break;

  case 6: // statement: VARIABLE SET expr
#line 318 "simple.yy"
                    {
    /* assign */
      try {
        ctx->set(yystack_[2].value.as < std::string > (), yystack_[0].value.as < std::function<int(void)> > ()());
        yylhs.value.as < std::string > () = yystack_[2].value.as < std::string > () + " = " + color::to_string(color::blue(yystack_[0].value.as < std::function<int(void)> > ()()));
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
#line 2527 "simple.cc"
    break;

  case 7: // statement: expr
#line 333 "simple.yy"
       {
    try {
      yylhs.value.as < std::string > () = color::to_string(color::blue(yystack_[0].value.as < std::function<int(void)> > ()())); 
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
#line 2545 "simple.cc"
    break;

  case 8: // tern: OPEN_PAREN expr CLOSED_PAREN QUESTION expr ELSE expr
#line 347 "simple.yy"
                                                           {
      auto a = yystack_[5].value.as < std::function<int(void)> > (); 
      auto b = yystack_[2].value.as < std::function<int(void)> > (); 
      auto c = yystack_[0].value.as < std::function<int(void)> > (); 
      if (a()) {
        yylhs.value.as < std::function<int(void)> > () = b;
      } else {
        yylhs.value.as < std::function<int(void)> > () = c;
      }}
#line 2559 "simple.cc"
    break;

  case 9: // expr: expr ADD expr
#line 359 "simple.yy"
                  { auto a = yystack_[2].value.as < std::function<int(void)> > ();
                    auto b = yystack_[0].value.as < std::function<int(void)> > ();
                    yylhs.value.as < std::function<int(void)> > () = [=](){return a() + b(); }; 
                  }
#line 2568 "simple.cc"
    break;

  case 10: // expr: expr SUB expr
#line 363 "simple.yy"
                  { auto a = yystack_[2].value.as < std::function<int(void)> > (); 
                    auto b = yystack_[0].value.as < std::function<int(void)> > (); 
                    yylhs.value.as < std::function<int(void)> > () = [=](){return a() - b(); }; 
                  }
#line 2577 "simple.cc"
    break;

  case 11: // expr: expr MUL expr
#line 367 "simple.yy"
                  { auto a = yystack_[2].value.as < std::function<int(void)> > (); 
                    auto b = yystack_[0].value.as < std::function<int(void)> > (); 
                    yylhs.value.as < std::function<int(void)> > () = [=](){return a() * b(); }; 
                  }
#line 2586 "simple.cc"
    break;

  case 12: // expr: expr DIV expr
#line 371 "simple.yy"
                  { auto a = yystack_[2].value.as < std::function<int(void)> > (); 
                    auto b = yystack_[0].value.as < std::function<int(void)> > (); 
                    yylhs.value.as < std::function<int(void)> > () = [=](){
                      auto bv = b();
                      if (bv == 0) {
                        throw std::domain_error{"division by zero"};
                      }
                      return a() / bv; 
                    }; 
                  }
#line 2601 "simple.cc"
    break;

  case 13: // expr: tern
#line 381 "simple.yy"
         {yylhs.value.as < std::function<int(void)> > () = yystack_[0].value.as < std::function<int(void)> > ();}
#line 2607 "simple.cc"
    break;

  case 14: // expr: OPEN_PAREN expr CLOSED_PAREN
#line 391 "simple.yy"
                               {
    yylhs.value.as < std::function<int(void)> > () = yystack_[1].value.as < std::function<int(void)> > ();
  }
#line 2615 "simple.cc"
    break;

  case 15: // expr: VARIABLE
#line 396 "simple.yy"
           { 
      auto name = yystack_[0].value.as < std::string > ();
      yylhs.value.as < std::function<int(void)> > () = [=](){return ctx->eval(name);};
    }
#line 2624 "simple.cc"
    break;

  case 16: // expr: NUMBER
#line 400 "simple.yy"
         { int x = yystack_[0].value.as < int > ();
           yylhs.value.as < std::function<int(void)> > () = [=](){return x;}; }
#line 2631 "simple.cc"
    break;


#line 2635 "simple.cc"

            default:
              break;
            }
        }
#if YY_EXCEPTIONS
      catch (const syntax_error& yyexc)
        {
          YYCDEBUG << "Caught exception: " << yyexc.what() << '\n';
          error (yyexc);
          YYERROR;
        }
#endif // YY_EXCEPTIONS
      YY_SYMBOL_PRINT ("-> $$ =", yylhs);
      yypop_ (yylen);
      yylen = 0;

      // Shift the result of the reduction.
      yypush_ (YY_NULLPTR, YY_MOVE (yylhs));
    }
    goto yynewstate;


  /*--------------------------------------.
  | yyerrlab -- here on detecting error.  |
  `--------------------------------------*/
  yyerrlab:
    // If not already recovering from an error, report this error.
    if (!yyerrstatus_)
      {
        ++yynerrs_;
        context yyctx (*this, yyla);
        std::string msg = yysyntax_error_ (yyctx);
        error (YY_MOVE (msg));
      }


    if (yyerrstatus_ == 3)
      {
        /* If just tried and failed to reuse lookahead token after an
           error, discard it.  */

        // Return failure if at end of input.
        if (yyla.kind () == symbol_kind::S_YYEOF)
          YYABORT;
        else if (!yyla.empty ())
          {
            yy_destroy_ ("Error: discarding", yyla);
            yyla.clear ();
          }
      }

    // Else will try to reuse lookahead token after shifting the error token.
    goto yyerrlab1;


  /*---------------------------------------------------.
  | yyerrorlab -- error raised explicitly by YYERROR.  |
  `---------------------------------------------------*/
  yyerrorlab:
    /* Pacify compilers when the user code never invokes YYERROR and
       the label yyerrorlab therefore never appears in user code.  */
    if (false)
      YYERROR;

    /* Do not reclaim the symbols of the rule whose action triggered
       this YYERROR.  */
    yypop_ (yylen);
    yylen = 0;
    YY_STACK_PRINT ();
    goto yyerrlab1;


  /*-------------------------------------------------------------.
  | yyerrlab1 -- common code for both syntax error and YYERROR.  |
  `-------------------------------------------------------------*/
  yyerrlab1:
    yyerrstatus_ = 3;   // Each real token shifted decrements this.
    // Pop stack until we find a state that shifts the error token.
    for (;;)
      {
        yyn = yypact_[+yystack_[0].state];
        if (!yy_pact_value_is_default_ (yyn))
          {
            yyn += symbol_kind::S_YYerror;
            if (0 <= yyn && yyn <= yylast_
                && yycheck_[yyn] == symbol_kind::S_YYerror)
              {
                yyn = yytable_[yyn];
                if (0 < yyn)
                  break;
              }
          }

        // Pop the current state because it cannot handle the error token.
        if (yystack_.size () == 1)
          YYABORT;

        yy_destroy_ ("Error: popping", yystack_[0]);
        yypop_ ();
        YY_STACK_PRINT ();
      }
    {
      stack_symbol_type error_token;


      // Shift the error token.
      error_token.state = state_type (yyn);
      yypush_ ("Shifting", YY_MOVE (error_token));
    }
    goto yynewstate;


  /*-------------------------------------.
  | yyacceptlab -- YYACCEPT comes here.  |
  `-------------------------------------*/
  yyacceptlab:
    yyresult = 0;
    goto yyreturn;


  /*-----------------------------------.
  | yyabortlab -- YYABORT comes here.  |
  `-----------------------------------*/
  yyabortlab:
    yyresult = 1;
    goto yyreturn;


  /*-----------------------------------------------------.
  | yyreturn -- parsing is finished, return the result.  |
  `-----------------------------------------------------*/
  yyreturn:
    if (!yyla.empty ())
      yy_destroy_ ("Cleanup: discarding lookahead", yyla);

    /* Do not reclaim the symbols of the rule whose action triggered
       this YYABORT or YYACCEPT.  */
    yypop_ (yylen);
    YY_STACK_PRINT ();
    while (1 < yystack_.size ())
      {
        yy_destroy_ ("Cleanup: popping", yystack_[0]);
        yypop_ ();
      }

    return yyresult;
  }
#if YY_EXCEPTIONS
    catch (...)
      {
        YYCDEBUG << "Exception caught: cleaning lookahead and stack\n";
        // Do not try to display the values of the reclaimed symbols,
        // as their printers might throw an exception.
        if (!yyla.empty ())
          yy_destroy_ (YY_NULLPTR, yyla);

        while (1 < yystack_.size ())
          {
            yy_destroy_ (YY_NULLPTR, yystack_[0]);
            yypop_ ();
          }
        throw;
      }
#endif // YY_EXCEPTIONS
  }

  void
  parser::error (const syntax_error& yyexc)
  {
    error (yyexc.what ());
  }

  const char *
  parser::symbol_name (symbol_kind_type yysymbol)
  {
    static const char *const yy_sname[] =
    {
    "end of file", "error", "invalid token", "VARIABLE", "NUMBER", "ADD",
  "DIV", "MUL", "SUB", "OPEN_PAREN", "CLOSED_PAREN", "SEMICOLON", "SET",
  "QUESTION", "ELSE", "THEN", "$accept", "result", "statement", "tern",
  "expr", YY_NULLPTR
    };
    return yy_sname[yysymbol];
  }



  // parser::context.
  parser::context::context (const parser& yyparser, const symbol_type& yyla)
    : yyparser_ (yyparser)
    , yyla_ (yyla)
  {}

  int
  parser::context::expected_tokens (symbol_kind_type yyarg[], int yyargn) const
  {
    // Actual number of expected tokens
    int yycount = 0;

    const int yyn = yypact_[+yyparser_.yystack_[0].state];
    if (!yy_pact_value_is_default_ (yyn))
      {
        /* Start YYX at -YYN if negative to avoid negative indexes in
           YYCHECK.  In other words, skip the first -YYN actions for
           this state because they are default actions.  */
        const int yyxbegin = yyn < 0 ? -yyn : 0;
        // Stay within bounds of both yycheck and yytname.
        const int yychecklim = yylast_ - yyn + 1;
        const int yyxend = yychecklim < YYNTOKENS ? yychecklim : YYNTOKENS;
        for (int yyx = yyxbegin; yyx < yyxend; ++yyx)
          if (yycheck_[yyx + yyn] == yyx && yyx != symbol_kind::S_YYerror
              && !yy_table_value_is_error_ (yytable_[yyx + yyn]))
            {
              if (!yyarg)
                ++yycount;
              else if (yycount == yyargn)
                return 0;
              else
                yyarg[yycount++] = YY_CAST (symbol_kind_type, yyx);
            }
      }

    if (yyarg && yycount == 0 && 0 < yyargn)
      yyarg[0] = symbol_kind::S_YYEMPTY;
    return yycount;
  }






  int
  parser::yy_syntax_error_arguments_ (const context& yyctx,
                                                 symbol_kind_type yyarg[], int yyargn) const
  {
    /* There are many possibilities here to consider:
       - If this state is a consistent state with a default action, then
         the only way this function was invoked is if the default action
         is an error action.  In that case, don't check for expected
         tokens because there are none.
       - The only way there can be no lookahead present (in yyla) is
         if this state is a consistent state with a default action.
         Thus, detecting the absence of a lookahead is sufficient to
         determine that there is no unexpected or expected token to
         report.  In that case, just report a simple "syntax error".
       - Don't assume there isn't a lookahead just because this state is
         a consistent state with a default action.  There might have
         been a previous inconsistent state, consistent state with a
         non-default action, or user semantic action that manipulated
         yyla.  (However, yyla is currently not documented for users.)
       - Of course, the expected token list depends on states to have
         correct lookahead information, and it depends on the parser not
         to perform extra reductions after fetching a lookahead from the
         scanner and before detecting a syntax error.  Thus, state merging
         (from LALR or IELR) and default reductions corrupt the expected
         token list.  However, the list is correct for canonical LR with
         one exception: it will still contain any token that will not be
         accepted due to an error action in a later state.
    */

    if (!yyctx.lookahead ().empty ())
      {
        if (yyarg)
          yyarg[0] = yyctx.token ();
        int yyn = yyctx.expected_tokens (yyarg ? yyarg + 1 : yyarg, yyargn - 1);
        return yyn + 1;
      }
    return 0;
  }

  // Generate an error message.
  std::string
  parser::yysyntax_error_ (const context& yyctx) const
  {
    // Its maximum.
    enum { YYARGS_MAX = 5 };
    // Arguments of yyformat.
    symbol_kind_type yyarg[YYARGS_MAX];
    int yycount = yy_syntax_error_arguments_ (yyctx, yyarg, YYARGS_MAX);

    char const* yyformat = YY_NULLPTR;
    switch (yycount)
      {
#define YYCASE_(N, S)                         \
        case N:                               \
          yyformat = S;                       \
        break
      default: // Avoid compiler warnings.
        YYCASE_ (0, YY_("syntax error"));
        YYCASE_ (1, YY_("syntax error, unexpected %s"));
        YYCASE_ (2, YY_("syntax error, unexpected %s, expecting %s"));
        YYCASE_ (3, YY_("syntax error, unexpected %s, expecting %s or %s"));
        YYCASE_ (4, YY_("syntax error, unexpected %s, expecting %s or %s or %s"));
        YYCASE_ (5, YY_("syntax error, unexpected %s, expecting %s or %s or %s or %s"));
#undef YYCASE_
      }

    std::string yyres;
    // Argument number.
    std::ptrdiff_t yyi = 0;
    for (char const* yyp = yyformat; *yyp; ++yyp)
      if (yyp[0] == '%' && yyp[1] == 's' && yyi < yycount)
        {
          yyres += symbol_name (yyarg[yyi++]);
          ++yyp;
        }
      else
        yyres += *yyp;
    return yyres;
  }


  const signed char parser::yypact_ninf_ = -10;

  const signed char parser::yytable_ninf_ = -6;

  const signed char
  parser::yypact_[] =
  {
     -10,    12,   -10,   -10,    -9,   -10,    -2,     3,   -10,    30,
      -2,   -10,    24,   -10,    -2,    -2,    -2,    -2,    30,     4,
      33,   -10,    13,    -1,    -2,    19,    -2,    30
  };

  const signed char
  parser::yydefact_[] =
  {
       2,     0,     1,     4,    15,    16,     0,     0,    13,     7,
       0,    15,     0,     3,     0,     0,     0,     0,     6,    14,
       9,    12,    11,    10,     0,     0,     0,     8
  };

  const signed char
  parser::yypgoto_[] =
  {
     -10,   -10,   -10,   -10,    -6
  };

  const signed char
  parser::yydefgoto_[] =
  {
       0,     1,     7,     8,     9
  };

  const signed char
  parser::yytable_[] =
  {
      12,    11,     5,    10,    18,    15,    16,     6,    20,    21,
      22,    23,     2,     3,    13,     4,     5,    24,    25,    15,
      27,     6,     0,    -5,    14,    15,    16,    17,     0,    14,
      15,    16,    17,    26,    19,    14,    15,    16,    17,    15,
      16,    17
  };

  const signed char
  parser::yycheck_[] =
  {
       6,     3,     4,    12,    10,     6,     7,     9,    14,    15,
      16,    17,     0,     1,    11,     3,     4,    13,    24,     6,
      26,     9,    -1,    11,     5,     6,     7,     8,    -1,     5,
       6,     7,     8,    14,    10,     5,     6,     7,     8,     6,
       7,     8
  };

  const signed char
  parser::yystos_[] =
  {
       0,    17,     0,     1,     3,     4,     9,    18,    19,    20,
      12,     3,    20,    11,     5,     6,     7,     8,    20,    10,
      20,    20,    20,    20,    13,    20,    14,    20
  };

  const signed char
  parser::yyr1_[] =
  {
       0,    16,    17,    17,    17,    18,    18,    18,    19,    20,
      20,    20,    20,    20,    20,    20,    20
  };

  const signed char
  parser::yyr2_[] =
  {
       0,     2,     0,     3,     2,     0,     3,     1,     7,     3,
       3,     3,     3,     1,     3,     1,     1
  };




#if YYDEBUG
  const short
  parser::yyrline_[] =
  {
       0,   285,   285,   286,   292,   315,   318,   333,   347,   359,
     363,   367,   371,   381,   391,   396,   400
  };

  void
  parser::yy_stack_print_ () const
  {
    *yycdebug_ << "Stack now";
    for (stack_type::const_iterator
           i = yystack_.begin (),
           i_end = yystack_.end ();
         i != i_end; ++i)
      *yycdebug_ << ' ' << int (i->state);
    *yycdebug_ << '\n';
  }

  void
  parser::yy_reduce_print_ (int yyrule) const
  {
    int yylno = yyrline_[yyrule];
    int yynrhs = yyr2_[yyrule];
    // Print the symbols being reduced, and their result.
    *yycdebug_ << "Reducing stack by rule " << yyrule - 1
               << " (line " << yylno << "):\n";
    // The symbols being reduced.
    for (int yyi = 0; yyi < yynrhs; yyi++)
      YY_SYMBOL_PRINT ("   $" << yyi + 1 << " =",
                       yystack_[(yynrhs) - (yyi + 1)]);
  }
#endif // YYDEBUG


} // yy
#line 3064 "simple.cc"

#line 403 "simple.yy"

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
