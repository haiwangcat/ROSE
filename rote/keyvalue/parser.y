%include {
#include <assert.h>
#include "parser.h"
#include "Annotation.h"
}

%extra_argument{Annotation **ann}

%token_type {char *}
%token_destructor {free($$);}

%type kvpairs {Annotation *}
%type key     {char *}
%type value   {char *}

%syntax_error {
  printf("Syntax error!\n");
}

%parse_failure {
  *ann = NULL;
}

program ::= ID(K) kvpairs(A). {
  A->set_id(K);
  *ann = A;
}

kvpairs(Q) ::= kvpairs(S) key(K) EQ value(V) . {
  Q = S;
  Q->add_attrib(K,V);
}

kvpairs(Q) ::= . {
  Q = new Annotation();
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
