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
/// @}
"
  |> h;
  "
int main(int argc, char *argv[]) {  //
    arg(0, argv[0]);
    for (int i = 1; i < argc; i++) {  //
        arg(i, argv[i]);
    }
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
  cpp |> close_out;
  hpp |> close_out;
  doxy;
  cmake;
  apt;
  sdkconfig
