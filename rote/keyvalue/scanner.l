%{
#include "parser.h"

#define MAX_STRING_LENGTH (1024)

char *copy(char *s, int len) {
  char *d = (char *)calloc(sizeof(char),len+1);
  strcpy(d,s);
  return d;
}

// This is a slow way to append, we should keep a pointer to the end of the 
// string instead, but we have to pass it around somehow.
void append(char *d, char *s) {
  strcpy(d + strlen(d),s);
}

void append_char(char *d, char c) {
  d[strlen(d)] = c;
}


%}

%x STR
%option reentrant
%option extra-type="char *"
%option outfile="scanner.c" header-file="scanner.h"

%%

[ \t\n]              {}
=                    { yyextra = copy(yytext,yyleng); return EQ; }
[0-9]+|[0-9]*        { yyextra = copy(yytext,yyleng); return NUM; }
[A-Za-z][A-Za-z0-9]* { yyextra = copy(yytext,yyleng); return ID; }
\" { 
  yyextra = (char *)calloc(sizeof(char),MAX_STRING_LENGTH);
  BEGIN(STR);
}

<STR>{
  \"                 { BEGIN(INITIAL); return STRING; }
  \n                 { /* unterminated string, error */ }
  \\n                { append_char(yyextra,'\n'); }
  \\t                { append_char(yyextra,'\t'); }
  \\r                { append_char(yyextra,'\r'); }
  \\b                { append_char(yyextra,'\b'); }
  \\f                { append_char(yyextra,'\f'); }
  \\(.|\n)           { append(yyextra,yytext); }
  [^\\\n\"]+         { append(yyextra,yytext); }
}

%%

int yywrap() {
  return 1;
}
