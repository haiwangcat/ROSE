/* -*- c-mode -*- */
%option yylineno
%option stack
%x IN_COMMENT
%x MULTI
%{
// File:
// Package:
// Revision:    @(#) $Id$
// Description: basic constants associated with generated source code
//
// Copyright (c) 2010, Lawrence Livermore National Security, LLC
// Produced at the Lawrence Livermore National Laboratory.
// Written by the Components Team <components@llnl.gov>
// UCRL-CODE-2002-054
// All rights reserved.
//
// This file is part of Babel. For more information, see
// http://www.llnl.gov/CASC/components/. Please read the COPYRIGHT file
// for Our Notice and the LICENSE file for the GNU Lesser General Public
// License.
//
// This program is free software; you can redistribute it and/or modify it
// under the terms of the GNU Lesser General Public License (as published by
// the Free Software Foundation) version 2.1 dated February 1999.
//
// This program is distributed in the hope that it will be useful, but
// WITHOUT ANY WARRANTY; without even the IMPLIED WARRANTY OF
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the terms and
// conditions of the GNU Lesser General Public License for more details.
//
// You should have recieved a copy of the GNU Lesser General Public License
// along with this program; if not, write to the Free Software Foundation,
// Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA

#include <string.h>

static const char* yytype = NULL; // The python token type

enum Token { /*t_VOID = 256, t_ARRAY, t_RARRAY, t_BOOLEAN, t_CHAR, t_DCOMPLEX, t_DOUBLE,
          t_FCOMPLEX, t_FLOAT, t_INT, t_LONG, t_OPAQUE, t_STRING,

          t_CLASS, t_ENUM, t_STRUCT, t_INTERFACE,

          t_ABSTRACT, t_LOGICAL_AND, t_COPY, t_ENSURE,
          t_EXTENDS, t_FINAL, t_FROM, t_IFF, t_IMPLEMENTS, t_IMPLEMENTS_ALL,
          t_IMPLIES, t_IMPORT, t_IN, t_INOUT, t_INVARIANT, t_IS, t_LOCAL,
          t_MODULUS, t_NOT, t_NULL, t_NONBLOCKING, t_ONEWAY, t_LOGICAL_OR,
          t_OUT, t_PACKAGE, t_PURE, t_REMAINDER, t_REQUIRE, t_RESULT,
          t_STATIC, t_THROWS, t_VERSION, t_LOGICAL_XOR,
	  t_THEN, t_ELSE, t_ORDER,*/

          t_KEYWORD=256,
          t_IDENTIFIER, t_EXTENSION, t_VERSION_STRING,

          t_LPAREN, t_RPAREN, t_LBRACE, t_RBRACE,
          t_SEMICOLON, t_COMMA, t_DOT, t_ATTRIB_BEGIN, t_ATTRIB_ID,
          t_ATTRIB_STRING, t_ATTRIB_EQ, t_ATTRIB_COMMA, t_ATTRIB_END,

	  t_COMMA_COLUMN_MAJOR, t_COMMA_ROW_MAJOR,

          t_ASSIGN, t_BITWISE_AND, t_BITWISE_XOR, t_COLON, t_EQ, t_GE,
          t_GT, t_LE, t_LT, t_MINUS, t_NE, t_BITWISE_OR, t_PLUS, t_POWER,
          t_SLASH, t_STAR, t_TILDE, t_LSHIFT, t_RSHIFT,

          t_BOOLEAN_LITERAL, t_INTEGER_LITERAL,
          t_DECIMAL_LITERAL, t_FLOATING_POINT_LITERAL,
          t_SIMPLE_FLOATING_POINT_LITERAL, t_CHARACTER_LITERAL, t_STRING_LITERAL
};

#define update_yypos() { yypos += yyleng; }
#define ID_TOKEN       { update_yypos(); yytype = yytext; return -1; }
#define TOKEN(TOKEN)   { update_yypos(); yytype = #TOKEN; return t_##TOKEN; }

static int yypos = 0;

%}

DECIMAL_LITERAL [1-9][0-9]*
HEX_LITERAL     0[xX][0-9a-fA-F]+
OCTAL_LITERAL   0[0-7]*
SIMPLE_FLOATING_POINT_LITERAL [0-9]+\.[0-9]+
EXPONENT        [eE][\+-]?[0-9]+
CHARACTER_LITERAL '(~['\\\n\r]|(\\[ntbrf\\'"]|([0-7][0-7]?)|([0-3][0-7][0-7]))'
STRING_LITERAL    "(~["\\\n\r]|(\\[ntbrf\\'"]|([0-7][0-7]?)|([0-3][0-7][0-7]))"

%%
 /*defeat emacs syntax highlighting"'*/
[ \t\f] ++yypos; // White Space

  /* Define a rule so we can track line numbers */
[\r\n] {
  //print "parsing line", t.lexer.lineno
  yylineno += strlen(yytext);
//  yypos = 0;
}
 
"//".*  // C++ comment (ignore)

<INITIAL,MULTI>{
  "/*"              update_yypos(); yy_push_state(IN_COMMENT);
}
<IN_COMMENT>{
  "*/"              update_yypos(); yy_pop_state();
  [^*\n]+     update_yypos(); /* eat comment in chunks */
    "*"       update_yypos(); /* eat the lone star */
    \n        /*yypos = 0;*/ yylineno++;
}

  /* TODO  <"/**" ~["/"] > { input_stream.backup(1); } : IN_DOC_COMMENT */

(void|array|rarray|bool|char|dcomplex|double|fcomplex|float|int|long|opaque|string) |
(class|enum|struct|interface) |
(abstract|and|copy) |
(else|ensure|extends|final|from|iff|implements|implements-all|implies|import|in) |
(inout|invariant|is|local|mod|not|null|nonblocking|oneway|order|or|out|package) |
(pure|rem|require|result) |
(static|then|throws|version|xor) {
  unsigned c;
  for (c = 0; c < yyleng; c++) {
    // parser expects upper case for terminal symbols
    yytext[c] = toupper(yytext[c]);
  }
  ID_TOKEN
}

[a-zA-Z][a-zA-Z_0-9]* TOKEN(IDENTIFIER)

"["[a-zA-Z0-9_]+"]" TOKEN(EXTENSION)

[0-9]\.[0-9]+(\.[0-9]+)+ TOKEN(VERSION_STRING)

  /* Work around the fact that we need a lookahead of 2 for the grammar at some points */
<INITIAL>{
","            update_yypos(); BEGIN(MULTI);
}
<MULTI>{
row-major      TOKEN(COMMA_ROW_MAJOR);
column-major   TOKEN(COMMA_COLUMN_MAJOR);
.              REJECT; BEGIN(INITIAL); TOKEN(COMMA);
}


   
  /*identifier_colon = r'[a-zA-Z][a-zA-Z_0-9]*'+ws+r':'					   */
  /*@TOKEN(identifier_colon)								   */
  /*def t_IDENTIFIER_COLON(t):								   */
  /*	// TODO: do this more efficiently						   */
  /*	t.value = re.search(r'^[a-zA-Z][a-zA-Z_0-9]*', t.value).group(0)		   */
  /*	updateLineNo(t)									   */
  /*											   */
  /* implements_all = r'implements-all'							   */
  /* @TOKEN(implements_all)								   */
  /* def t_IMPLEMENTS_ALL(t):								   */
  /*	  // we need to define version_string as a function, so it is			   */
  /*	  // applied before identifier							   */
  /*	 updateLineNo(t)								   */
  /*	 ID_TOKEN // RETURN_TOKEN( t									   */
  /*											   */
  /* identifier = r'[a-zA-Z][a-zA-Z_0-9]*'						   */
  /* @TOKEN(identifier)									   */
  /* def t_IDENTIFIER(t):								   */
  /*	 // While this code seems to defy the purpose of having an efficient		   */
  /*	 // scanner; the PLY documentation actually argues against defining		   */
  /*	 // rules for keywords. The reason is that apparently the regex			   */
  /*	 // engine is slower than the hashtable lookup below				   */
  /*	 t.type = reserved_words.get(t.value,'IDENTIFIER')    // Check for reserved words  */
  /*	 ID_TOKEN // RETURN_TOKEN( t */

  /* separators */
"(" TOKEN(LPAREN)
")" TOKEN(RPAREN) 
"{" TOKEN(LBRACE) 
"}" TOKEN(RBRACE) 
";" TOKEN(SEMICOLON) 
  /* "," TOKEN(COMMA) */
"." TOKEN(DOT) 

  /* operators */
"="   TOKEN(ASSIGN);
"&"   TOKEN(BITWISE_AND);
"^"   TOKEN(BITWISE_XOR);
":"   TOKEN(COLON);
"=="  TOKEN(EQ);
">="  TOKEN(GE);
">"   TOKEN(GT);
"<="  TOKEN(LE);
"<"   TOKEN(LT);
"-"   TOKEN(MINUS);
"!="  TOKEN(NE);
"|"   TOKEN(BITWISE_OR);
"+"   TOKEN(PLUS);
"**"  TOKEN(POWER); 
"/"   TOKEN(SLASH);
"*"   TOKEN(STAR);
"~"   TOKEN(TILDE);
"<<<" TOKEN(LSHIFT);
">>>" TOKEN(RSHIFT);

  /* literals */
false|true ID_TOKEN /* RETURN_TOKEN(BOOLEAN_LITERAL); */


({DECIMAL_LITERAL}|{HEX_LITERAL}|{OCTAL_LITERAL})[lL]? {
        TOKEN(INTEGER_LITERAL);
}

{SIMPLE_FLOATING_POINT_LITERAL}{EXPONENT}[fFdD]? |
{SIMPLE_FLOATING_POINT_LITERAL}({EXPONENT})?[fFdD] |
[0-9]+\.{EXPONENT}?[fFdD]? |
\.[0-9]+{EXPONENT}?[fFdD]? |
[0-9]+{EXPONENT}[fFdD]? |
[0-9]+{EXPONENT}?[fFdD] { 
	TOKEN(FLOATING_POINT_LITERAL);
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
  const char *fn;

  if (!PyArg_ParseTuple(args, "s", &fn))
    return NULL;
  //fprintf(stderr, "opening:%s\n", fn);
  yyin = fopen(fn, "r");
  return Py_BuildValue("i", 0); 
}

static PyObject*
scanner_token(PyObject *self, PyObject *args)
{
  int type = yylex();
  if (type == 0) {
    // Free references to Token
    Py_DECREF(token_init);
    Py_DECREF(token_dict);
    Py_DECREF(token_module);
    return Py_None;
  }

  if (token_init == NULL) {
     // Load the Token module
     token_module = PyImport_Import(PyString_FromString("token"));
     token_dict   = PyModule_GetDict(token_module);
     token_init   = PyDict_GetItemString(token_dict, "Token");
  }
  //fprintf(stderr, "token:%s", yytext); fflush(stderr);
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

int
main(int argc, char *argv[])
{
     fprintf(stderr, "hello\n");
    /* Pass argv[0] to the Python interpreter */
    Py_SetProgramName(argv[0]);

    /* Initialize the Python interpreter.  Required. */
    Py_Initialize();

    /* Add a static module */
    initscanner();
}
