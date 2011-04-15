#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include "parser.h"
#include "Annotation.h"
#include "token.h"

#define BUFS (1024)

extern FILE *yyin;
extern YYSTYPE yylval;
int yylex();
struct yy_buffer_state *yy_scan_string(const char *);
void yy_delete_buffer(struct yy_buffer_state *);
void *ParseAlloc(void *(*mallocProc)(size_t));
void Parse(void *yyp,int yymajor,char *yyminor,Annotation **ann);
void ParseFree(void *p,void (*freeProc)(void*));

Annotation *parse_annotation() {
  int n;
  int yv;
  char buf[BUFS+1];
  void* parser = ParseAlloc(malloc);
  Annotation *result;

  while((n=read(fileno(stdin),buf,BUFS)) > 0) {
    buf[n] = '\0';
    yy_scan_string(buf);
    // on EOF yylex will return 0
    while((yv=yylex()) != 0) {
      Parse(parser, yv, yylval.text,&result);
    }
  }
  Parse(parser,0,NULL,&result);
  ParseFree(parser,free);  
  return result;
}

int main() {
  Annotation *ann = parse_annotation();
  cout << ann->get_attrib("ok") << endl;
  return 0;
}
