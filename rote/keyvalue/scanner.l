%{
#include "parser.h"
%}

%option reentrant
%option outfile="scanner.c" header-file="scanner.h"

%%

[ \t\n] {}

"="                  { return EQ; }
[0-9]+|[0-9]*        { return NUM; }
[A-Za-z][A-Za-z0-9]* { return ID; }

%%

/*
void yyerror(char *s) {
  printf("Error: %s at line: %d\n",s,yylineno);
}
*/

int yywrap() {
  return 1;
}
