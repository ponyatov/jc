/// @file
/// @brief `jc:` JavaScript AOT compiler
#pragma once

/// @defgroup jc jc
/// @brief JavaScript AOT compiler
/// @{

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

/// @defgroup main main
/// @{

/// @brief POSIX entry point
/// @param[in] argc number of command line arguments
/// @param[in] argv values (0 = binary program file)
int main(int argc, char *argv[]);
/// @brief print command line argument
void arg(int argc, char *argv);
/// @brief ESP32 `main()`
extern "C" void app_main(void);
/// @}

/// @defgroup graph graph
/// @{

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
    std::string dump(int depth = 0, std::string prefix = "");

    /// @brief short `<T:V>` header
    virtual std::string head(std::string prefix = "");

    /// @brief tree padding
    std::string pad(int depth);

    /// @brief type/class tag (lowercased class name)
    virtual std::string tag();

    /// @brief stringified @ref value
    virtual std::string val();
};

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

/// @defgroup parser parser
/// @{
extern int yylex();                    ///< lexer
extern int yylineno;                   ///< curren line
extern char *yytext;                   ///< parsed literal
extern FILE *yyin;                     ///< input file
extern char *yyfile;                   ///< file name
extern int yyparse();                  ///< parser
extern void yyerror(const char *msg);  ///< syntax error callback
#include "jc.parser.hpp"
#define TOKEN(C, X)               \
    {                             \
        yylval.o = new C(yytext); \
        return X;                 \
    }
#define TOKEN2(C, X)                  \
    {                                 \
        yylval.o = new C(&yytext[2]); \
        return X;                     \
    }
/// @}
