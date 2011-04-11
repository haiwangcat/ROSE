%token_type {int}
%type nt {void*}
%destructor nt { free($$); }

%include {
#include <stdio.h>
#include <assert.h>
#include "parser.h"
}

%syntax_error {
  printf("Syntax error!\n");
}

program ::= kvpairs.

kvpairs ::= kvpairs kvpair.

kvpair(A) ::= ID(K) EQ value(V). {
  printf("Result %d:%d\n", K, V);
}

value(V) ::= ID(A) . {
  V = A;
}

value(V) ::= NUM(A) . {
  V = A;
}
