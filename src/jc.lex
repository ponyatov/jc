%{
    #include "jc.hpp"
    char *yyfile = nullptr;
%}

%option noyywrap yylineno

%%
[ \t\r\n]+      {}              // drop spaces
.               {yyerror("");}  // any undetected char
