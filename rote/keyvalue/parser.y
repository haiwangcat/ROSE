%include {
#include <stdio.h>
#include <assert.h>
#include <iostream>
#include "parser.h"
#include "token.h"
extern YYSTYPE yylval;
extern void handle_parsed_pair(char *key, char *value);
}

%token_type {char *}
%token_destructor {free($$);}

%syntax_error {
  printf("Syntax error!\n");
}

program ::= kvpairs.

kvpairs ::= kvpairs kvpair.
kvpairs ::= .

kvpair ::= key(K) EQ value(V). {
  handle_parsed_pair(K, V);
}

key(K) ::= ID(A) . {
  K = A;
}

value(V) ::= ID(A) . {
  V = A;
}

value(V) ::= NUM(A) . {
  V = A;
}
