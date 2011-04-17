#include <assert.h>
#include "parser.h"
#include "scanner.h"
#include "Annotation.h"

// Lemon headers
void *ParseAlloc(void *(*mallocProc)(size_t));
void ParseFree(void *p,void (*freeProc)(void*));
void Parse(void *yyp,int yymajor,char *yyminor,Annotation **ann);

Annotation::~Annotation() {
  map<string,Dynamic*>::iterator i;
  for(i=attribs.begin(); i != attribs.end(); i++) {
    delete i->second;
  }
}

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
  if(attribs.count(key) > 0) {
    Dynamic *val = attribs[key];
    delete val;
  }
  attribs[key] = val;
}

Annotation *Annotation::parse(const string input) {
  Annotation *result;
  yyscan_t scanner;
  void *parser;
  int yv;
  
  yylex_init(&scanner);
  parser = ParseAlloc(malloc);
  yy_scan_string(input.c_str(),scanner);
  while((yv=yylex(scanner)) != 0) {
    char *tok = yyget_extra(scanner);
    Parse(parser,yv,tok,&result);
  }
  Parse(parser,0,NULL,&result);
  ParseFree(parser,free);
  yylex_destroy(scanner);
  return result;
}
