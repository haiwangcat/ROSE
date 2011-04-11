void *ParseAlloc(void *(*mallocProc)(size_t));
void Parse(void *yyp,int yymajor,int yyminor);
void ParseFree(void *p,void (*freeProc)(void*));
