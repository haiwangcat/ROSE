#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include "parser.h"
#include "Dynamic.h"
#include "token.h"
#include "lemon.h"

#define BUFS (1024)

extern FILE *yyin;

int yylex();
struct yy_buffer_state *yy_scan_string(const char *);
void yy_delete_buffer(struct yy_buffer_state *);

// int main() {
//   Annotation ann("ok");
//   ann.add_attrib("a1", Dynamic::dynamic_int(5));
//   ann.add_attrib("a2", Dynamic::dynamic_string("hello"));
//   cout << ann.get_id() << endl;
//   cout << ann.get_attrib("a1")->int_value() << endl;
//   cout << ann.get_attrib("a2")->string_value() << endl;
//   return 0;
// }

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
  
  //Parse(parser,NULL,NULL);
  ParseFree(parser,free);
  return 0;
}
