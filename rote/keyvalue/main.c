#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include "parser.h"
#include "lemon.h"

#define BUFS (1024)

extern FILE *yyin;

int yylex();
struct yy_buffer_state *yy_scan_string(const char *);
void yy_delete_buffer(struct yy_buffer_state *);

int main() {
  int n;
  int yv;
  char buf[BUFS+1];
  void* parser = ParseAlloc(malloc);

  while((n=read(fileno(stdin),buf,BUFS)) > 0) {
    buf[n]='\0';
    yy_scan_string(buf);
    // on EOF yylex will return 0
    while((yv=yylex()) != 0) {
      printf("Read %d\n",yv);
    }
  }
  
  Parse(parser,0,0);
  ParseFree(parser,free);
  return 0;
}
