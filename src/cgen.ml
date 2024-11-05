(* minimal C++ code generation *)

open Printf

let m = "jc"
let about = "JavaScript AOT compiler"

let incl cpp hpp =
  let _c = fprintf cpp in
  let h = fprintf hpp in
  fprintf cpp "#include \"%s.hpp\"\n" m;
  "/// @file\n" |> h;
  fprintf hpp "/// @brief `%s:` %s\n" m about;
  "#pragma once\n\n" |> h;
  fprintf hpp "/// @defgroup %s %s\n" m m;
  fprintf hpp "/// @brief %s\n/// @{\n" about

let libc cpp hpp =
  let _c = fprintf cpp in
  let h = fprintf hpp in
  "
/// @defgroup libc libc
/// @{
#include <stdio.h>
#include <stdlib.h>
#include <assert.h>

#include <iostream>
#include <sstream>
#include <list>
#include <bitset>
/// @}
"
  |> h

let number cpp hpp =
  let c = fprintf cpp in
  let h = fprintf hpp in
  "
/// @defgroup prim primitive
/// @{

class Int : public Object {
   protected:
    long value;

   public:
    Int() : Object() {}
    Int(long n) : Int() { value = n; }
    Int(std::string V) : Int(stol(V, NULL, 0x0A)) {}
    std::string val();
};

class Hex : public Int {
   public:
    Hex(std::string V) : Int(stol(V, NULL, 0x10)) {}
    std::string val();
};

class Oct : public Int {
   public:
    Oct(std::string V) : Int(stol(V, NULL, 0x08)) {}
    std::string val();
};

class Bin : public Int {
   public:
    Bin(std::string V) : Int(stol(V, NULL, 0x02)) {}
    std::string val();
};

/// @}
"
  |> h;
  "
std::string Int::val() { return std::to_string(value); }

std::string Hex::val() {
    std::ostringstream os;
    os << std::hex << value;
    return os.str();
}

std::string Oct::val() {
    std::ostringstream os;
    os << std::oct << value;
    return os.str();
}

std::string Bin::val() {
    std::ostringstream os;
    os << std::bitset<8>(value);
    return os.str();
}
"
  |> c

let obj cpp hpp =
  let c = fprintf cpp in
  let h = fprintf hpp in
  "
class Object {

    /// @name gargabe collection
    size_t ref;                       ///< reference counter
    static std::list<Object *> pool;  ///< global objects pool

   protected:
    std::string value;  ///< scalar: name, string/number value

   public:
    /// @name constructor
    Object();               ///< construct empty
    Object(std::string V);  ///< construct with name
    virtual ~Object();      ///< clean up

    /// @name stringify

    /// @brief full text tree dump
    std::string dump(int depth = 0, std::string prefix = \"\");

    /// @brief short `<T:V>` header
    virtual std::string head(std::string prefix = \"\");
    /// @brief tree padding
    std::string pad(int depth);

    /// @brief type/class tag (lowercased class name)
    virtual std::string tag();

    /// @brief stringified @ref value
    virtual std::string val();
};
"
  |> h;
  "
std::list<Object *> Object::pool;

Object::Object() {
    ref = 0;
    pool.push_front(this);
}

Object::Object(std::string V) : Object() { value = V; }

Object::~Object() { pool.remove(this); }

#include <cxxabi.h>
std::string Object::tag() {
    std::string ret = abi::__cxa_demangle(typeid(*this).name(), 0, 0, nullptr);
    for (char &c : ret) c = tolower(c);
    return ret;
}

std::string Object::val() { return value; }

std::string Object::pad(int depth) {
    std::ostringstream os('\\n');
    for (int i = 0; i < depth; i++) os << '\\t';
    return os.str();
}

std::string Object::dump(int depth, std::string prefix) {
    std::ostringstream os;
    os << pad(depth) << head(prefix);
    return os.str();
}

std::string Object::head(std::string prefix) {
    std::ostringstream ret(prefix);
    ret << '<' << tag() << ':' << val() << '>';  // <T:V>
    ret << \" @\" << this << \" #\" << ref;          // allocation
    return ret.str();
}
"
  |> c

let graph cpp hpp =
  let _c = fprintf cpp in
  let h = fprintf hpp in
  "
/// @defgroup graph graph
/// @{
" |> h;
  obj cpp hpp;
  number cpp hpp;
  "
/// @}
" |> h

let skelex cpp hpp =
  let _c = fprintf cpp in
  let h = fprintf hpp in
  "
/// @defgroup parser parser
/// @{
extern int yylex();                    ///< lexer
extern int yylineno;                   ///< curren line
extern char *yytext;                   ///< parsed literal
extern FILE *yyin;                     ///< input file
extern char *yyfile;                   ///< file name
extern int yyparse();                  ///< parser
extern void yyerror(const char *msg);  ///< syntax error callback
#include \"jc.parser.hpp\"
#define TOKEN(C, X)               \\
    {                             \\
        yylval.o = new C(yytext); \\
        return X;                 \\
    }
#define TOKEN2(C, X)                  \\
    {                                 \\
        yylval.o = new C(&yytext[2]); \\
        return X;                     \\
    }
/// @}
"
  |> h

let main cpp hpp =
  let c = fprintf cpp in
  let h = fprintf hpp in
  "
/// @defgroup main main
/// @{

/// @brief POSIX entry point
/// @param[in] argc number of command line arguments
/// @param[in] argv values (0 = binary program file)
int main(int argc, char *argv[]);

/// @brief print command line argument
void arg(int argc, char *argv);
/// @brief ESP32 `main()`
extern \"C\" void app_main(void);
/// @}

/// @}
"
  |> h;
  "
int main(int argc, char *argv[]) {
    arg(0, argv[0]);
    for (int i = 1; i < argc; i++) {
        arg(i, argv[i]);
        yyfile = argv[i];
        assert(yyin = fopen(yyfile, \"r\"));
        yyparse();
        fclose(yyin);
        yyfile = nullptr;
    }
    app_main();
}

void arg(int argc, char *argv) {  //
    fprintf(stderr, \"argv[%%i] = <%%s>\\n\", argc, argv);
}
"
  |> c

let doxy =
  let doxy = open_out ".doxygen" in
  let d = fprintf doxy in
  fprintf doxy "PROJECT_NAME           = \"%s\"\n" m;
  fprintf doxy "PROJECT_BRIEF          = \"%s\"" about;
  "
PROJECT_LOGO           = vscode/logo.png
HTML_OUTPUT            = docs
OUTPUT_DIRECTORY       =
INPUT                  = README.md doc src inc
EXCLUDE                = ref/* *.pdf *.djvu
WARN_IF_UNDOCUMENTED   = NO
RECURSIVE              = YES
USE_MDFILE_AS_MAINPAGE = README.md
GENERATE_LATEX         = NO
FILE_PATTERNS         += *.lex *.yacc
EXTENSION_MAPPING      = lex=C++ yacc=C++ ino=C++
EXTRACT_ALL            = YES
EXTRACT_PRIVATE        = YES
LAYOUT_FILE            = doc/DoxygenLayout.xml
SORT_GROUP_NAMES       = YES
REPEAT_BRIEF           = NO
"
  |> d;
  doxy |> close_out

let cmake =
  let root = open_out "CMakeLists.txt" in
  let src = open_out "src/CMakeLists.txt" in
  fprintf root
    "cmake_minimum_required(VERSION 3.16)
include($ENV{IDF_PATH}/tools/cmake/project.cmake)
project(%s)
idf_build_set_property(COMPILE_OPTIONS \"-Wno-write-strings\" APPEND)
"
    m;
  fprintf src
    "idf_component_register(SRCS \"jc.cpp\"
                    INCLUDE_DIRS \"../inc\")\"
";
  root |> close_out;
  src |> close_out

let apt =
  fprintf (open_out "apt.txt")
    "git make curl
code meld doxygen clang-format
g++ flex bison libreadline-dev ragel
cmake
"

let sdkconfig =
  fprintf (open_out "sdkconfig")
    "
CONFIG_APP_BUILD_TYPE_RAM=y
CONFIG_APP_BUILD_TYPE_PURE_RAM_APP=y
CONFIG_APP_NO_BLOBS=y
"

let _ =
  let cpp = open_out (sprintf "src/%s.cpp" m) in
  let hpp = open_out (sprintf "inc/%s.hpp" m) in
  incl cpp hpp;
  libc cpp hpp;
  main cpp hpp;
  graph cpp hpp;
  skelex cpp hpp;
  cpp |> close_out;
  hpp |> close_out;
  doxy;
  cmake;
  apt;
  sdkconfig
