%token_type {Token}

%include {
#include <stdio.h>
#include <assert.h>
#include "parser.h"
#include "Dynamic.h"
#include "token.h"
}

%syntax_error {
  printf("Syntax error!\n");
}

program ::= kvpairs.

kvpairs ::= kvpairs kvpair.
kvpairs(A) ::= . {
  A = new Annotation("ann");
}

kvpair ::= ID(K) EQ value(V). {
  printf("Result %d:%d\n", K.tok_type, V.tok_type);
}

value(V) ::= ID(A) . {
  V = A;
}

value(V) ::= NUM(A) . {
  V = A;
}
