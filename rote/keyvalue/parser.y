%token_type {int}

%include {
#include <stdio.h>
#include <assert.h>
#include "parser.h"
#include "token.h"

extern YYSTYPE yylval;
}

%syntax_error {
  printf("Syntax error!\n");
}

program ::= kvpairs.

kvpairs ::= kvpairs kvpair.
kvpairs ::= .

kvpair ::= ID(K) EQ value(V). {
  printf("%d->%d\n", K, V);
}

value(V) ::= ID(A) . {
  V = A;
}

value(V) ::= NUM(A) . {
  V = A;
}
