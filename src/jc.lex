%{
    #include "jc.hpp"
    char *yyfile = nullptr;
%}

%option noyywrap yylineno

sign [+\-]
dec  [0-9]
hex  [0-9a-fA-F]
oct  [0-7]
bin  [01]

%%

#[^\n]*         {}              // line comment
[ \t\r\n]+      {}              // drop spaces
{sign}?{dec}+   TOKEN(Int,INT)  // numbers
"0x"{hex}+      TOKEN2(Hex,INT)
"0o"{oct}+      TOKEN2(Oct,INT)
"0b"{bin}+      TOKEN2(Bin,INT)
.               {yyerror("");}  // any undetected char
