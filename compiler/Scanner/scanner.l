%option yylineno
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

enum Token { t_VOID = 256, t_ARRAY, t_RARRAY, t_BOOLEAN, t_CHAR, t_DCOMPLEX, t_DOUBLE,
          t_FCOMPLEX, t_FLOAT, t_INT, t_LONG, t_OPAQUE, t_STRING,

          t_CLASS, t_ENUM, t_STRUCT, t_INTERFACE,

          t_ABSTRACT, t_LOGICAL_AND, t_COPY, t_COMMA_COLUMN_MAJOR, t_ENSURE,
          t_EXTENDS, t_FINAL, t_FROM, t_IFF, t_IMPLEMENTS, t_IMPLEMENTS_ALL,
          t_IMPLIES, t_IMPORT, t_IN, t_INOUT, t_INVARIANT, t_IS, t_LOCAL,
          t_MODULUS, t_NOT, t_NULL, t_NONBLOCKING, t_ONEWAY, t_LOGICAL_OR,
          t_OUT, t_PACKAGE, t_PURE, t_REMAINDER, t_REQUIRE, t_RESULT, t_COMMA_ROW_MAJOR,
          t_STATIC, t_THROWS, t_VERSION, t_LOGICAL_XOR,
	  t_THEN, t_ELSE, t_ORDER,

          t_IDENTIFIER, t_EXTENSION, t_VERSION_STRING,

          t_LPAREN, t_RPAREN, t_LBRACE, t_RBRACE,
          t_SEMICOLON, t_COMMA, t_DOT, t_ATTRIB_BEGIN, t_ATTRIB_ID,
          t_ATTRIB_STRING, t_ATTRIB_EQ, t_ATTRIB_COMMA, t_ATTRIB_END,

          t_ASSIGN, t_BITWISE_AND, t_BITWISE_XOR, t_COLON, t_EQ, t_GE,
          t_GT, t_LE, t_LT, t_MINUS, t_NE, t_BITWISE_OR, t_PLUS, t_POWER,
          t_SLASH, t_STAR, t_TILDE, t_LSHIFT, t_RSHIFT,

          t_BOOLEAN_LITERAL, t_INTEGER_LITERAL,
          t_DECIMAL_LITERAL, t_FLOATING_POINT_LITERAL,
          t_SIMPLE_FLOATING_POINT_LITERAL, t_CHARACTER_LITERAL, t_STRING_LITERAL
};

#define update_yypos() { yypos += yyleng; }
#define RETURN_TOKEN(TOKEN) { enum Token token = TOKEN; update_yypos(); return (int)(token); }

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

void           RETURN_TOKEN(t_VOID);
array          RETURN_TOKEN(t_ARRAY);
rarray         RETURN_TOKEN(t_RARRAY);
bool           RETURN_TOKEN(t_CHAR);
char           RETURN_TOKEN(t_CHAR);
dcomplex       RETURN_TOKEN(t_DCOMPLEX);
double         RETURN_TOKEN(t_DOUBLE);
fcomplex       RETURN_TOKEN(t_FCOMPLEX);
float          RETURN_TOKEN(t_FLOAT);
int            RETURN_TOKEN(t_INT);
long           RETURN_TOKEN(t_LONG);
opaque         RETURN_TOKEN(t_OPAQUE);
string         RETURN_TOKEN(t_STRING);
	       		     
class          RETURN_TOKEN(t_CLASS);
enum           RETURN_TOKEN(t_ENUM);
struct         RETURN_TOKEN(t_STRUCT);
interface      RETURN_TOKEN(t_INTERFACE);
	       		     
abstract       RETURN_TOKEN(t_ABSTRACT);
and            RETURN_TOKEN(t_LOGICAL_AND);
copy           RETURN_TOKEN(t_COPY);
			     
  /*column-major   RETURN_TOKEN(t_COLUMN_MAJOR);*/
else           RETURN_TOKEN(t_ELSE);
ensure         RETURN_TOKEN(t_ENSURE);
extends        RETURN_TOKEN(t_EXTENDS);
final          RETURN_TOKEN(t_FINAL);
from           RETURN_TOKEN(t_FROM);
iff            RETURN_TOKEN(t_IFF);
implements     RETURN_TOKEN(t_IMPLEMENTS);
implements-all RETURN_TOKEN(t_IMPLEMENTS_ALL);
implies        RETURN_TOKEN(t_IMPLIES);
import         RETURN_TOKEN(t_IMPORT);
in             RETURN_TOKEN(t_IN);
			     
inout          RETURN_TOKEN(t_INOUT);
invariant      RETURN_TOKEN(t_INVARIANT);
is             RETURN_TOKEN(t_IS);
local          RETURN_TOKEN(t_LOCAL);
mod            RETURN_TOKEN(t_MODULUS);
not            RETURN_TOKEN(t_NOT);
null           RETURN_TOKEN(t_NULL);
nonblocking    RETURN_TOKEN(t_NONBLOCKING);
oneway         RETURN_TOKEN(t_ONEWAY);
order          RETURN_TOKEN(t_ORDER);
or             RETURN_TOKEN(t_LOGICAL_OR);
out            RETURN_TOKEN(t_OUT);
package        RETURN_TOKEN(t_PACKAGE);
			     
pure           RETURN_TOKEN(t_PURE);
rem            RETURN_TOKEN(t_REMAINDER);
require        RETURN_TOKEN(t_REQUIRE);
result         RETURN_TOKEN(t_RESULT);
  /*row-major      RETURN_TOKEN(t_ROW_MAJOR);*/
static         RETURN_TOKEN(t_STATIC);
then           RETURN_TOKEN(t_THEN);
throws         RETURN_TOKEN(t_THROWS);
version        RETURN_TOKEN(t_VERSION);
xor            RETURN_TOKEN(t_LOGICAL_XOR);

[a-zA-Z][a-zA-Z_0-9]* RETURN_TOKEN(t_IDENTIFIER);

"["[a-zA-Z0-9_]+"]" { RETURN_TOKEN(t_EXTENSION) }

[0-9]\.[0-9]+(\.[0-9]+)+ { RETURN_TOKEN(t_VERSION_STRING); }

  /* Work around the fact that we need a lookahead of 2 for the grammar at some points */
<INITIAL>{
","            update_yypos(); BEGIN(MULTI);
}
<MULTI>{
row-major      RETURN_TOKEN(t_COMMA_ROW_MAJOR);
column-major   RETURN_TOKEN(t_COMMA_COLUMN_MAJOR);
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
  /*	 RETURN_TOKEN( t									   */
  /*											   */
  /* identifier = r'[a-zA-Z][a-zA-Z_0-9]*'						   */
  /* @TOKEN(identifier)									   */
  /* def t_IDENTIFIER(t):								   */
  /*	 // While this code seems to defy the purpose of having an efficient		   */
  /*	 // scanner; the PLY documentation actually argues against defining		   */
  /*	 // rules for keywords. The reason is that apparently the regex			   */
  /*	 // engine is slower than the hashtable lookup below				   */
  /*	 t.type = reserved_words.get(t.value,'IDENTIFIER')    // Check for reserved words  */
  /*	 RETURN_TOKEN( t */

  /* separators */
"("|")"|"{"|"}"|";"|","|"." { RETURN_TOKEN(yytext[0]); }

  /* operators */
"="   { RETURN_TOKEN(t_ASSIGN); }
"&"   { RETURN_TOKEN(t_BITWISE_AND); }
"^"   { RETURN_TOKEN(t_BITWISE_XOR); }
":"   { RETURN_TOKEN(t_COLON); }
"=="  { RETURN_TOKEN(t_EQ); }
">="  { RETURN_TOKEN(t_GE); }
">"   { RETURN_TOKEN(t_GT); }
"<="  { RETURN_TOKEN(t_LE); }
"<"   { RETURN_TOKEN(t_LT); }
"-"   { RETURN_TOKEN(t_MINUS); }
"!="  { RETURN_TOKEN(t_NE); }
"|"   { RETURN_TOKEN(t_BITWISE_OR); }
"+"   { RETURN_TOKEN(t_PLUS); }
"**"  { RETURN_TOKEN(t_POWER); } 
"/"   { RETURN_TOKEN(t_SLASH); }
"*"   { RETURN_TOKEN(t_STAR); }
"~"   { RETURN_TOKEN(t_TILDE); }
"<<<" { RETURN_TOKEN(t_LSHIFT); }
">>>" { RETURN_TOKEN(t_RSHIFT); }

  /* literals */
false|true { RETURN_TOKEN(t_BOOLEAN_LITERAL); }


({DECIMAL_LITERAL}|{HEX_LITERAL}|{OCTAL_LITERAL})[lL]? {
        RETURN_TOKEN(t_INTEGER_LITERAL);
}

{SIMPLE_FLOATING_POINT_LITERAL}{EXPONENT}[fFdD]? |
{SIMPLE_FLOATING_POINT_LITERAL}({EXPONENT})?[fFdD] |
[0-9]+\.{EXPONENT}?[fFdD]? |
\.[0-9]+{EXPONENT}?[fFdD]? |
[0-9]+{EXPONENT}[fFdD]? |
[0-9]+{EXPONENT}?[fFdD] { 
	RETURN_TOKEN(t_FLOATING_POINT_LITERAL); 
}


%%

#include <Python.h>

static PyObject *
scanner_token(PyObject *self, PyObject *args)
{
  int type = yylex();
  return Py_BuildValue("{isii}", "type", type, "value", yytext, 
		       "lineno", yylineno, "lexpos", yypos);
}

static PyMethodDef ScannerMethods[] = {
    {"token",  scanner_token, METH_VARARGS,
     "return( a new token from the input stream."},
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
    /* Pass argv[0] to the Python interpreter */
    Py_SetProgramName(argv[0]);

    /* Initialize the Python interpreter.  Required. */
    Py_Initialize();

    /* Add a static module */
    initscanner();
}
