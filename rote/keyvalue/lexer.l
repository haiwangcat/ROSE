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
  char *text = (char *)calloc(yyleng + 1, sizeof(char));
  strcpy(text,yytext);
  text[yyleng] = '\0';
  yylval.text = text;
  return NUM;
}

[A-Za-z][A-Za-z0-9]* {
  char *text = (char *)calloc(yyleng + 1, sizeof(char));
  strcpy(text,yytext);
  text[yyleng] = '\0';
  yylval.text = text;
  return ID;
}

"=" {
  yylval.text = NULL;
  return EQ;
}

%%

void yyerror(char *s) {
  printf("Error: %s at line: %d\n",s,yylineno);
}

int yywrap() {
  return 1;
}
