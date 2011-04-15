#include <stdlib.h>
#include <string.h>
#include "Annotation.h"
#include "parser.h"
#include "scanner.h"

void *ParseAlloc(void *(*mallocProc)(size_t));
void Parse(void *yyp,int yymajor,char *yyminor,Annotation **ann);
void ParseFree(void *p,void (*freeProc)(void*));

Annotation *parse_annotation(std::string input) {
  Annotation *result;
  int yv;
  void* parser;
  yyscan_t scanner;
  yylex_init(&scanner);
  parser = ParseAlloc(malloc);

  yy_scan_string(input.c_str(),scanner);
  // on EOF yylex will return 0
  while((yv=yylex(scanner)) != 0) {
    int tok_len = yyget_leng(scanner);
    char *tok = (char *)calloc(tok_len + 1, sizeof(char));
    strcpy(tok,yyget_text(scanner));
    Parse(parser,yv,tok,&result);
  }
  Parse(parser,0,NULL,&result);
  ParseFree(parser,free);
  yylex_destroy(scanner);
  return result;
}

int main() {
  Annotation *ann = parse_annotation("ok = 5 test = null key = value");
  if(ann != NULL) {
    cout << "ok=" << ann->get_attrib("ok") << endl;
  }
  cout << "done" << endl;
  return 0;
}
