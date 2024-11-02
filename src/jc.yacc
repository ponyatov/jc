%{
    #include "jc.hpp"
%}

%defines %union { Object *o; }

%%
REPL :

%%

void yyerror(const char *msg) {
    fprintf(stderr, "\n\n%s:%i %s [%s]\n\n", yyfile, yylineno, msg, yytext);
    exit(-1);
}
