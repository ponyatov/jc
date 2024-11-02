%{
    #include "jc.hpp"
%}

%defines %union { Object *o; }

%token<o> INT
%type<o> ex

%%
REPL : | REPL ex    { std::cout << $2->dump() << std::endl; }

ex : INT

%%

void yyerror(const char *msg) {
    fprintf(stderr, "\n%s:%i %s [%s]\n\n", yyfile, yylineno, msg, yytext);
    exit(-1);
}
