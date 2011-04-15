%include {
#include <stdio.h>
#include <stdlib.h>
#include <assert.h>
#include <iostream>
#include "parser.h"
#include "Annotation.h"
}

%extra_argument{Annotation **ann}

%token_type {char *}
%token_destructor {free($$);}

%type kvpairs {Annotation *}
%type key     {std::string *}
%type value   {std::string *}

%syntax_error {
  printf("Syntax error!\n");
}

%parse_failure {
  *ann = NULL;
}

program ::= kvpairs(A). {
  *ann = A;
}

kvpairs(Q) ::= kvpairs(S) key(K) EQ value(V) . {
  Q = S;
  Q->add_attrib(*K,*V);
}

kvpairs(Q) ::= . {
  Annotation *ann = new Annotation("ok");
  Q = ann;
}

key(K) ::= ID(A) . {
  K = new std::string(A);
}

value(V) ::= ID(A) . {
  V = new std::string(A);
}

value(V) ::= NUM(A) . {
  V = new std::string(A);
}
