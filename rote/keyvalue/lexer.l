%{
#include <string.h>
#include <math.h>
#include "parser.h"
#include "token.h"

YYSTYPE yylval;
%}

%%

[ \t\n] {}

[0-9]+|[0-9]* {
  yylval.int_val = atoi(yytext);
  return NUM;
}

[A-Za-z][A-Za-z0-9]* {
  yylval.string_val = yytext;
  return ID;
}

"=" {
  return EQ;
}

%%

void yyerror(char *s) {
  printf("Error: %s at line: %d\n",s,yylineno);
}

int yywrap() {
  return 1;
}
