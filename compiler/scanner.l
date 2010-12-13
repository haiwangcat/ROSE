/* -*- C -*- */
%option yylineno
%option stack
%x IN_COMMENT
%x MULTI1
%x MULTI2
%{
/**
 * This is a scanner for SIDL files. For performance reasons it is
 * written in C and 100% replaces the Python scanner in parser.py .
 * Report bugs to <adrian@llnl.gov>
 *
 * \authors <pre>
 * Copyright (c) 2010, Lawrence Livermore National Security, LLC
 * Produced at the Lawrence Livermore National Laboratory.
 * Written by the Components Team <components@llnl.gov>
 * UCRL-CODE-????-???
 * All rights reserved.
 *
 * This file is part of Babel. For more information, see
 * http://www.llnl.gov/CASC/components/. Please read the COPYRIGHT file
 * for Our Notice and the LICENSE file for ????
 * License.
 *
 * </pre>    \TODO insert License
 *
 */
#include <string.h>

enum Token {
          t_KEYWORD=256,
          t_IDENTIFIER, t_EXTENSION, t_VERSION_STRING,

          t_LOGICAL_AND, t_LOGICAL_OR, t_LOGICAL_XOR,

          t_LPAREN, t_RPAREN, t_LBRACE, t_RBRACE,
          t_SEMICOLON, t_COMMA, t_DOT, t_ATTRIB_BEGIN, t_ATTRIB_ID,
          t_ATTRIB_STRING, t_ATTRIB_EQ, t_ATTRIB_COMMA, t_ATTRIB_END,

          t_COMMA_COLUMN_MAJOR, t_COMMA_ROW_MAJOR, t_IDENTIFIER_COLON,

          t_ASSIGN, t_BITWISE_AND, t_BITWISE_XOR, /*t_COLON,*/ t_EQ, t_GE,
          t_GT, t_LE, t_LT, t_MINUS, t_NE, t_BITWISE_OR, t_PLUS, t_POWER,
          t_SLASH, t_STAR, t_TILDE, t_LSHIFT, t_RSHIFT,

          t_BOOLEAN_LITERAL, t_INTEGER_LITERAL,
          t_DECIMAL_LITERAL, t_FLOATING_POINT_LITERAL,
          t_SIMPLE_FLOATING_POINT_LITERAL, t_CHARACTER_LITERAL, t_STRING_LITERAL
};

#define update_yypos() { yypos += yyleng; }
#define ID_TOKEN       { update_yypos(); yytype = yytext; return -1; }
#define TOKEN(TOKEN)   { update_yypos(); yytype = #TOKEN; return t_##TOKEN; }

static int yypos = 0;             // Character count in file
static const char* yytype = NULL; // The python token type
static char* ident = NULL;        // Used by IDENTIFIER_COLON
static char* ident_end = NULL;    // Used by IDENTIFIER_COLON
static const char *fn;            // Input file name

%}

DECIMAL_LITERAL               [1-9][0-9]*
HEX_LITERAL                   0[xX][0-9a-fA-F]+
OCTAL_LITERAL                 0[0-7]*
SIMPLE_FLOATING_POINT_LITERAL [0-9]+\.[0-9]+
EXPONENT                      [eE][\+-]?[0-9]+
CHARACTER_LITERAL             '(~['\\\n\r]|(\\[ntbrf\\'"]|([0-7][0-7]?)|([0-3][0-7][0-7]))'
STRING_LITERAL                "(~["\\\n\r]|(\\[ntbrf\\'"]|([0-7][0-7]?)|([0-3][0-7][0-7]))"
IDENTIFIER                    [a-zA-Z][a-zA-Z_0-9]*

%%
 /*defeat emacs syntax highlighting"'*/


<INITIAL,MULTI1,MULTI2>{
  [ \t\f] update_yypos(); // White Space
  [\r\n]  update_yypos();

  "//".*  update_yypos(); // C++ comment
  "/*"    update_yypos(); yy_push_state(IN_COMMENT); /* C comment */
}
<IN_COMMENT>{
  "*/"        update_yypos(); yy_pop_state();
  [^*\n]+     update_yypos(); // eat comment in chunks
  "*"         update_yypos(); // eat the lone star
  [\r\n]      update_yypos();
}

  /* TODO  <"/**" ~["/"] > { input_stream.backup(1); } : IN_DOC_COMMENT */

  /* Keywords */
void|array|rarray|bool|char|dcomplex|double|fcomplex|float|int|long|opaque|string |
class|enum|struct|interface|abstract|copy |
else|ensure|extends|final|from|iff|implements|implements-all|implies|import|in |
inout|invariant|is|local|mod|not|null|nonblocking|oneway|order|out|package |
pure|rem|require|result |
static|then|throws|version {
  char *c;
  for (c = yytext; c < yytext+yyleng; c++) {
    // parser expects upper case for terminal symbols
    if (*c == '-')
      *c = '_';
    else
      *c = toupper(*c);
  }
  ID_TOKEN
}

and TOKEN(LOGICAL_AND)
or  TOKEN(LOGICAL_OR)
xor TOKEN(LOGICAL_XOR)

"["[a-zA-Z0-9_]+"]"      TOKEN(EXTENSION)
[0-9]\.[0-9]+(\.[0-9]+)+ TOKEN(VERSION_STRING)

  /* Work around the fact that we need a lookahead of 2 for the
     grammar at some points */

<INITIAL>{
  ","           BEGIN(MULTI1); update_yypos();
}
<MULTI1>{
  row-major     BEGIN(INITIAL);            TOKEN(COMMA_ROW_MAJOR);
  column-major  BEGIN(INITIAL);            TOKEN(COMMA_COLUMN_MAJOR);
  .             BEGIN(INITIAL); yyless(0); TOKEN(COMMA);
}

<INITIAL>{
  {IDENTIFIER}  BEGIN(MULTI2); update_yypos(); ident = yytext; ident_end = yytext+yyleng;
}
<MULTI2>{
  ":"           BEGIN(INITIAL); yytext=ident; *ident_end=0; TOKEN(IDENTIFIER_COLON)
   .            BEGIN(INITIAL); yyless(0);    yytext=ident; TOKEN(IDENTIFIER);
}

  /* separators */
"("   TOKEN(LPAREN)
")"   TOKEN(RPAREN)
"{"   TOKEN(LBRACE)
"}"   TOKEN(RBRACE)
";"   TOKEN(SEMICOLON)
"."   TOKEN(DOT)

  /* operators */
"="   TOKEN(ASSIGN)
"&"   TOKEN(BITWISE_AND)
"^"   TOKEN(BITWISE_XOR)
"=="  TOKEN(EQ)
">="  TOKEN(GE)
">"   TOKEN(GT)
"<="  TOKEN(LE)
"<"   TOKEN(LT)
"-"   TOKEN(MINUS)
"!="  TOKEN(NE)
"|"   TOKEN(BITWISE_OR)
"+"   TOKEN(PLUS)
"**"  TOKEN(POWER)
"/"   TOKEN(SLASH)
"*"   TOKEN(STAR)
"~"   TOKEN(TILDE)
"<<<" TOKEN(LSHIFT)
">>>" TOKEN(RSHIFT)

  /* literals */
false|true ID_TOKEN

({DECIMAL_LITERAL}|{HEX_LITERAL}|{OCTAL_LITERAL})[lL]? {
        TOKEN(INTEGER_LITERAL)
}

{SIMPLE_FLOATING_POINT_LITERAL} TOKEN(SIMPLE_FLOATING_POINT_LITERAL)

{SIMPLE_FLOATING_POINT_LITERAL}{EXPONENT}[fFdD]? |
{SIMPLE_FLOATING_POINT_LITERAL}({EXPONENT})?[fFdD] |
[0-9]+\.{EXPONENT}?[fFdD]? |
\.[0-9]+{EXPONENT}?[fFdD]? |
[0-9]+{EXPONENT}[fFdD]? |
[0-9]+{EXPONENT}?[fFdD] {
        TOKEN(FLOATING_POINT_LITERAL)
}

<<EOF>>   return 0;

. {

    fprintf(stderr, "**ERROR: %s:%d:\n  unexpected token '%s'.\n",
            fn, yylineno, yytext);
    exit(1);
}
%%

#include <Python.h>
#include <stdio.h>

static PyObject* token_module = NULL;
static PyObject* token_dict   = NULL;
static PyObject* token_init   = NULL;

static PyObject*
scanner_input(PyObject *self, PyObject *args)
{
  if (!PyArg_ParseTuple(args, "s", &fn))
    return NULL;
  yyin = fopen(fn, "r");
  return Py_BuildValue("i", 0);
}

static PyObject*
scanner_token(PyObject *self, PyObject *args)
{
  int type = yylex();
  //while (yylex()) { fprintf(stdout, "token:'%s' :: %s\n", yytext, yytype); fflush(stdout);} exit(1);
  if (type == 0) {
    // Free references to Token
    Py_DECREF(token_init);
    Py_DECREF(token_dict);
    Py_DECREF(token_module);
    return Py_None;
  }

  if (token_init == NULL) {
     // Load the Token module
     token_module = PyImport_Import(PyString_FromString("sidl_token"));
     token_dict   = PyModule_GetDict(token_module);
     token_init   = PyDict_GetItemString(token_dict, "Token");
  }
  //fprintf(stderr, "token:%s\n", yytext); fflush(stderr);
  return PyObject_CallFunction(token_init, "(ssii)",
			       yytype, yytext, yylineno, yypos);
}

static PyMethodDef ScannerMethods[] = {
    {"input",  scanner_input, METH_VARARGS,
     "set the input stream."},
    {"token",  scanner_token, METH_VARARGS,
     "return a new token from the input stream."},
    {NULL, NULL, 0, NULL}        /* Sentinel */
};

PyMODINIT_FUNC
initscanner(void)
{
    (void) Py_InitModule("scanner", ScannerMethods);
}
