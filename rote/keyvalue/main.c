#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include "parser.h"
#include "Annotation.h"
#include "token.h"
#include "lemon.h"

#define BUFS (1024)

extern FILE *yyin;
extern YYSTYPE yylval;
int yylex();
struct yy_buffer_state *yy_scan_string(const char *);
void yy_delete_buffer(struct yy_buffer_state *);

Annotation *ann;

void handle_parsed_pair(char *key, char *value) {
  printf("%s->%s\n",key,value);
  ann->add_attrib(key,value);
}

int main() {
  int n;
  int yv;
  char buf[BUFS+1];
  void* parser = ParseAlloc(malloc);
  ann = new Annotation("ann");

  while((n=read(fileno(stdin),buf,BUFS)) > 0) {
    buf[n] = '\0';
    yy_scan_string(buf);
    // on EOF yylex will return 0
    while((yv=yylex()) != 0) {
      Parse(parser, yv, yylval.text);
    }
  }
  
  Parse(parser,NULL,0);
  ParseFree(parser,free);  
  return 0;
}
