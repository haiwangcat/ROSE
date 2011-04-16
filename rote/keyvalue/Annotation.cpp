#include <assert.h>
#include "parser.h"
#include "scanner.h"
#include "Annotation.h"

// Lemon headers
void *ParseAlloc(void *(*mallocProc)(size_t));
void ParseFree(void *p,void (*freeProc)(void*));
void Parse(void *yyp,int yymajor,char *yyminor,Annotation **ann);

const string Annotation::get_id() {
  return id;
}

Dynamic *Annotation::get_attrib(const string key) {
  return attribs[key];
}

void Annotation::set_id(const string aid) {
  id = aid;
}

void Annotation::add_attrib(const string key, Dynamic *val) {
  assert(attribs.count(key) == 0);
  attribs[key] = val;
}

Annotation *Annotation::parse(const string input) {
  Annotation *result;
  yyscan_t scanner;
  yylex_init(&scanner);
  void *parser = ParseAlloc(malloc);
  yy_scan_string(input.c_str(),scanner);
  
  int yv;
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
