#ifndef YYSTYPE

typedef union {
  int int_val;
  char *string_val;
} yystype;

#define YYSTYPE yystype
#define YYSTYPE_IS_TRIVIAL 1

#endif

/* extern YYSTYPE yylval; */

