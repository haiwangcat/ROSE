# -*- python -*-
# File:
# Package:
# Revision:    @(#) $Id$
# Description: basic constants associated with generated source code
#
# Copyright (c) 2010, Lawrence Livermore National Security, LLC
# Produced at the Lawrence Livermore National Laboratory.
# Written by the Components Team <components@llnl.gov>
# UCRL-CODE-2002-054
# All rights reserved.
#
# This file is part of Babel. For more information, see
# http://www.llnl.gov/CASC/components/. Please read the COPYRIGHT file
# for Our Notice and the LICENSE file for the GNU Lesser General Public
# License.
#
# This program is free software; you can redistribute it and/or modify it
# under the terms of the GNU Lesser General Public License (as published by
# the Free Software Foundation) version 2.1 dated February 1999.
#
# This program is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the IMPLIED WARRANTY OF
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the terms and
# conditions of the GNU Lesser General Public License for more details.
#
# You should have recieved a copy of the GNU Lesser General Public License
# along with this program; if not, write to the Free Software Foundation,
# Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA

import logging, string, sys
import ply.lex as lex
import ply.yacc as yacc
from ply.lex import TOKEN

import sidl


sidlFile = ''

tokens = [ 'VOID', 'ARRAY', 'RARRAY', 'BOOLEAN', 'CHAR', 'DCOMPLEX', 'DOUBLE',
           'FCOMPLEX', 'FLOAT', 'INT', 'LONG', 'OPAQUE', 'STRING',

           'CLASS', 'ENUM', 'STRUCT', 'INTERFACE',

           'ABSTRACT', 'LOGICAL_AND', 'COPY', 'COMMA_COLUMN_MAJOR', 'ENSURE',
           'EXTENDS', 'FINAL', 'FROM', 'IFF', 'IMPLEMENTS', 'IMPLEMENTS_ALL',
           'IMPLIES', 'IMPORT', 'IN', 'INOUT', 'INVARIANT', 'IS', 'LOCAL',
           'MODULUS', 'NOT', 'NULL', 'NONBLOCKING', 'ONEWAY', 'LOGICAL_OR',
           'OUT', 'PACKAGE', 'PURE', 'REMAINDER', 'REQUIRE', 'RESULT', 'COMMA_ROW_MAJOR',
           'STATIC', 'THROWS', 'VERSION', 'LOGICAL_XOR',
           # 'THEN', 'ELSE', 'ORDER', 

           'IDENTIFIER', 'EXTENSION', 'VERSION_STRING',

           'LPAREN', 'RPAREN', 'LBRACE', 'RBRACE', 'COMMA_RBRACE', 
           #'LBRACKET', 'RBRACKET',
           'SEMICOLON', 'COMMA', 'DOT', 'ATTRIB_BEGIN', 'ATTRIB_ID',
           'ATTRIB_STRING', 'ATTRIB_EQ', 'ATTRIB_COMMA', 'ATTRIB_END',

           'ASSIGN', 'BITWISE_AND', 'BITWISE_XOR', 'IDENTIFIER_COLON', 'EQ', 'GE',
           'GT', 'LE', 'LT', 'MINUS', 'NE', 'BITWISE_OR', 'PLUS', 'POWER',
           'SLASH', 'STAR', 'TILDE', 'LSHIFT', 'RSHIFT',

           'BOOLEAN_LITERAL', 'INTEGER_LITERAL',
           #'HEX_LITERAL', 'OCTAL_LITERAL', 'FALSE', 'TRUE', 
           'DECIMAL_LITERAL', 'FLOATING_POINT_LITERAL',
           'SIMPLE_FLOATING_POINT_LITERAL', 'CHARACTER_LITERAL', 'STRING_LITERAL'
           ]

# White Space
t_ignore = ' \t\f'

# Define a rule so we can track line numbers
def t_newline(t):
    r'[\r\n]+'
    t.lexer.lineno += len(t.value)

# Comments
# C or C++ comment (ignore)
comment = r'(/\*(.|\n)*?\*/)|(//.*)'
@TOKEN(comment)
def t_COMMENT(t):
    updateLineNo(t)

# TODO  <"/**" ~["/"] > { input_stream.backup(1); } : IN_DOC_COMMENT

reserved_words = {

#basic_types = {
    "void"     :  'VOID',
    "array"    :  'ARRAY',
    "rarray"   :  'RARRAY',
    "bool"     :  'BOOLEAN',
    "char"     :  'CHAR',
    "dcomplex" :  'DCOMPLEX',
    "double"   :  'DOUBLE',
    "fcomplex" :  'FCOMPLEX',
    "float"    :  'FLOAT',
    "int"      :  'INT',
    "long"     :  'LONG',
    "opaque"   :  'OPAQUE',
    "string"   :  'STRING'
#}
,

#user_defined_types = {
    "class"     : 'CLASS',
    "enum"      : 'ENUM',
    "struct"    : 'STRUCT',
    "interface" : 'INTERFACE'
#}
,
#reserved_words = {
    "abstract"         : 'ABSTRACT',
    "and"              : 'LOGICAL_AND',
    "copy"             : 'COPY',
#    "column-major"     : 'COLUMN_MAJOR',
    "else"             : 'ELSE',
    "ensure"           : 'ENSURE',
    "extends"          : 'EXTENDS',
    "final"            : 'FINAL',
    "from"             : 'FROM',
    "iff"              : 'IFF',
    "implements"       : 'IMPLEMENTS',
    "implements-all"   : 'IMPLEMENTS_ALL',
    "implies"          : 'IMPLIES',
    "import"           : 'IMPORT',
    "in"               : 'IN',
    "inout"            : 'INOUT',
    "invariant"        : 'INVARIANT',
    "is"               : 'IS',
    "local"            : 'LOCAL',
    "mod"              : 'MODULUS',
    "not"              : 'NOT',
    "null"             : 'NULL',
    "nonblocking"      : 'NONBLOCKING',
    "oneway"           : 'ONEWAY',
    "order"            : 'ORDER',
    "or"               : 'LOGICAL_OR',
    "out"              : 'OUT',
    "package"          : 'PACKAGE',
    "pure"             : 'PURE',
    "rem"              : 'REMAINDER',
    "require"          : 'REQUIRE',
    "result"           : 'RESULT',
#    "row-major"        : 'ROW_MAJOR',
    "static"           : 'STATIC',
    "then"             : 'THEN',
    "throws"           : 'THROWS',
    "version"          : 'VERSION',
    "xor"              : 'LOGICAL_XOR'
}

def t_IDENTIFIER(t):
    r'[a-zA-Z][a-zA-Z_0-9]*'
    # While this code seems to defy the purpose of having an efficient
    # scanner; the PLY documentation actually argues against defining
    # rules for keywords. The reason is that apparently the regex
    # engine is slower than the hastable lookup below
    t.type = reserved_words.get(t.value,'IDENTIFIER')    # Check for reserved words
    return t

# identifiers
t_EXTENSION       = r'\[([a-zA-Z]\d|_)+\]'
t_VERSION_STRING  = r'(\d)\.(\d)+(.(\d)+)+'

# count how many newline characters are included in the token
def updateLineNo(t):
    t.lexer.lineno += string.count(t.value, '\r')
    t.lexer.lineno += string.count(t.value, '\n')


# Work around the fact that we need a lookahead of 2 for the grammar at some points
ws = r'[ \r\n\f\t(' + comment + r')]*'
comma_column_major = r','+ws+r'column-major'
@TOKEN(comma_column_major)
def t_COMMA_COLUMN_MAJOR(t):
    updateLineNo(t)

comma_row_major = r','+ws+r'row-major'
@TOKEN(comma_row_major)
def t_COMMA_ROW_MAJOR(t):
    updateLineNo(t)

comma_rbrace = r','+ws+r'}'
@TOKEN(comma_rbrace)
def t_COMMA_RBRACE(t):
    updateLineNo(t)

identifier_colon = r'[a-zA-Z][a-zA-Z_0-9]*'+ws+r':'
@TOKEN(identifier_colon)
def t_IDENTIFIER_COLON(t):
    # TODO: do this more efficiently
    t.value = re.search('^[a-zA-Z][a-zA-Z_0-9]*', t.value).group(0)
    updateLineNo(t)

# separators
t_LPAREN     =   r'\('
t_RPAREN     =   r'\)'
t_LBRACE     =   r'{'
t_RBRACE     =   r'}'
#t_LBRACKET   =   r'\['
#t_RBRACKET   =   r'\]'
t_SEMICOLON  =   r';'
t_COMMA      =   r','
t_DOT        =   r'\.'


#/* SPECIAL MODES */
t_ATTRIB_BEGIN = r'%attrib{' # > : IN_ATTRIB_LIST
#
#<IN_ATTRIB_LIST
#TOKEN :
#{
#  < ATTRIB_ID      : <LETTER> ( <LETTER> | <DIGIT> | "_")*
#| < ATTRIB_STRING :
#      "\""
#      (   (~["\"","\\","\n","\r"])
#        | ("\\"
#            ( ["n","t","b","r","f","\\","'","\""]
#            | ["0"-"7"] ( ["0"-"7"] )?
#            | ["0"-"3"] ["0"-"7"] ["0"-"7"]
#            )
#          )
#      )*
#      "\""
#
#| < ATTRIB_EQ = "="
#| < ATTRIB_COMMA = ","
ATTRIB_END = r'}' # > : DEFAULT
#}
#
#<IN_ATTRIB_LIST
#SPECIAL_TOKEN :
#{
#  " "
#| "\t"
#| "\n"
#| "\r"
#| "\f"
#}

# operators
t_LSHIFT= r'<<<'
t_RSHIFT= r'>>>'
t_EQ= r'=='
t_GE= r'>='
t_GT= r'>'
t_LE= r'<='
t_LT= r'<'
t_ASSIGN= r'='
t_BITWISE_AND= r'&'
t_BITWISE_XOR= r'\^'
t_MINUS= r'-'
t_NE= r'!='
t_BITWISE_OR= r'\|'
t_PLUS= r'\+'
t_POWER = r'\*\*'
t_SLASH= r'/'
t_STAR= r'\*'
t_TILDE= r'~'

# literals
digit = r'(\d)'
digits = r'(\d)+'
exponent = r'([eE])([+-])?(\d)+'
exponentp = r'('+exponent+r')?'
decimal_literal = r'([1-9])(\d)*'
hex_literal     = r'0[xX]([0-9a-fA-F])+'
octal_literal   = r'0([0-7])*'
integer_literal = r'((' + decimal_literal + r'[lL]?' \
               + r')|(' + hex_literal + r'[lL]?' \
               + r')|(' + octal_literal + r'[lL]?' \
               + r'))'

dot = r'\.'
simple_floating_point_literal = digits + dot + digits

floating_point_literal = \
           r'(' + simple_floating_point_literal + exponent  + r'([fFdD])?' \
        +r')|(' + simple_floating_point_literal + exponentp + r'([fFdD])'  \
        +r')|(' + digit                   + dot + exponentp + r'([fFdD])?' \
        +r')|(' + dot + digits                  + exponentp + r'([fFdD])?' \
        +r')|(' + digits                        + exponent  + r'([fFdD])?' \
        +r')|'  + digits                        + exponentp + r'([fFdD])'  \
        +r')'


t_BOOLEAN_LITERAL = r'((false)|(true))'
#t_FALSE          = r'false'
#t_TRUE           = r'true'

@TOKEN(simple_floating_point_literal)
def t_SIMPLE_FLOATING_POINT_LITERAL(t):
    t.value = float(t.value)
    return t

@TOKEN(decimal_literal)
def t_DECIMAL_LITERAL(t):
    t.value = int(t.value)
    return t

@TOKEN(integer_literal)
def t_INTEGER_LITERAL(t):
    t.value = int(t.value)
    return t

string_innards = r'([^\'\\\n\r])'                    \
                 + r'|(\\' + r'([ntbrf\\\'"]'        \
                   + r'|(([0-7])([0-7])?)'           \
                   + r'|(([0-3])([0-7])([0-7]))'     \
                 + r')'                              \
               + r')'


character_literal = r'\'(' + string_innards + r')\''
string_literal = r'"(' + string_innards + r'*)"'


# Error handling rule
def t_error(t):
    print "Illegal character '%s'" % t.value[0]
    t.lexer.skip(1)

# ------------- Parser

def p_start(p):
    'start : requires imports userTypes'
    #{ return jjtThis; }
    p[0] = sidl.File(sidl.ListNode(p[1]), sidl.ListNode(p[2]), sidl.ListNode(p[3]))

def p_empty(p):
    'empty :'
    p[0] = []

def cons(p):
    # use this for 'token+' patterns
    # construct a list p[1]:p[2] and store result in p[0]
    if len(p) == 2:
        p[0] = [p[1]]
    else:
        p[0] = [p[1]] + p[2]

def consx(p):
    # use this for 'token*' patterns
    # construct a list p[1]:p[2] and store result in p[0]
    # if there is no p[2], return an empty list
    if len(p) == 2:
        p[0] = []
    else:
        p[0] = [p[1]] + p[2]

def cons13(p):
    # construct a list p[1]:p[3] and store result in p[0]
    if len(p) == 2:
        if p[1] == None:
            p[0] = p[1]
        else:
            p[0] = []
    else:
        p[0] = [p[1]] + p[3]

def try2nd(p):
    if p[1] == []:
        p[0] = []
    else:
        p[0] = p[2]

def error(p, description):
    print description
    p[0] = '<'+description+'>'
    exit(1)

# Generate a nice looking error report that highlights the suspicious token
def p_error(errorToken):
    global sidlFile

    if errorToken == None:
        print 'successfully parsed', sidlFile
        return

    sys.stdout.write('**ERROR: Syntax error near token "%s" in %s:%d:\n' % \
                         (errorToken.value, sidlFile, errorToken.lineno))
    
    i = 0
    pos = errorToken.lexpos
    for line in open(sidlFile):
        i += 1
        if i == errorToken.lineno:
            sys.stdout.write(line)
            print ' '*(pos)+'^'*len(errorToken.value)
            break
        pos -= len(line)
    sys.stdout.write("Possible reason(s): ")

def p_version(p):
    'version : VERSION version_'
    p[0] = sidl.AstNode('version', p[1])

def p_version_error(p):
    'version : VERSION error'
    error(p, 'Bad version string:')


def p_version_(p):
    '''version_ : VERSION_STRING
                | SIMPLE_FLOATING_POINT_LITERAL
                | DECIMAL_LITERAL'''
    p[0] = p[1]

def p_requires(p): # *
    '''requires : require requires
                | empty'''
    consx(p)

def p_require(p):
    'require : REQUIRE scopedID version SEMICOLON'
    p[0] = sidl.AstNode('require', p[2], p[3])

def p_require_error(p):
    'require : REQUIRE error version SEMICOLON'
    error(p, 'Bad require expression: Bad scoped identifier')

def p_imports(p): # *
    '''imports : import imports
               | empty'''
    consx(p)

def p_import_1(p):
    'import : IMPORT scopedID SEMICOLON'
    p[0] = sidl.AstNode('import', p[2])

def p_import_2(p):
    'import : IMPORT scopedID version SEMICOLON'
    p[0] = sidl.AstNode('import', p[2], p[3])

def p_import_error(p):
    'import : IMPORT error SEMICOLON'
    error(p, 'Bad import expression: Bad identifier')

def p_package_1(p):
    'package : PACKAGE name LBRACE userTypes RBRACE'
    p[0] = sidl.AstNode('package', p[2], 'no version', sidl.ListNode(p[4]))

def p_package_2(p):
    'package : PACKAGE name version LBRACE userTypes RBRACE'
    p[0] = sidl.AstNode('package', p[2], p[3], sidl.ListNode(p[5]))

def p_package_error_1(p):
    'package : PACKAGE error'
    error(p, 'Bad package definition: Bad package name')

def p_package_error_2(p):
    'package : PACKAGE name error'
    error(p, 'Bad package definition: Bad package version')

def p_userTypes(p): # *
    '''userTypes : userType userTypes
                 | empty'''
    consx(p)

def p_userType(p):
    'userType : typeCustomAttrs cipse'
    p[0] = sidl.AstNode('user type', sidl.ListNode(p[1]), p[2])

def p_cipse(p):
    '''cipse : class
             | interface
             | package
             | package SEMICOLON
             | struct
             | enum'''
    p[0] = p[1]

def p_cipse_error(p):
    'cipse : error'
    error(p, 'Bad user defined type: Unexpected keyword')
    
def p_typeCustomAttrs(p): # *
    '''typeCustomAttrs : typeAttrOrCustomAttrList typeCustomAttrs
                       | empty'''
    consx(p)

def p_typeAttrOrCustomAttrList(p):
    '''typeAttrOrCustomAttrList : typeAttr
                                | customAttrList'''
    p[0] = p[1]

def p_typeAttr(p):
    '''typeAttr : FINAL
                | ABSTRACT'''
    p[0] = sidl.AstNode('type attribute', p[1])

def p_name(p):
    'name : IDENTIFIER'
    p[0] = sidl.AstNode('identifier', p[1])

def p_enum(p):
    '''enum : ENUM name LBRACE enumerators RBRACE maybeSemicolon
            | ENUM name LBRACE enumerators COMMA_RBRACE maybeSemicolon'''
    p[0] = sidl.AstNode('enum', sidl.ListNode(p[2]), p[4])

def p_enumerators(p): # +
    '''enumerators : enumerator 
                   | enumerator COMMA enumerators'''
    cons13(p)

def p_enumerator(p):
    '''enumerator : name
                  | name ASSIGN integer'''
    if len(p) < 4:
        p[0] = sidl.AstNode('enumerator', p[1])
    else:
        p[0] = sidl.AstNode('enumerator', p[2], p[1], p[3])

def p_struct(p):
    'struct : STRUCT name LBRACE structItems RBRACE maybeSemicolon'
    p[0] = sidl.AstNode('struct', sidl.ListNode(p[2]), p[4])

def p_structItems(p): # *
    '''structItems : empty
                   | structItem structItems'''
    consx(p)

def p_structItem_1(p):
    'structItem : type name SEMICOLON'
    p[0] = sidl.AstNode('struct item', p[1], p[2])

def p_structItem_2(p):
    'structItem : rarray SEMICOLON'
    p[0] = p[1]

def p_class(p):
    'class : CLASS name maybeExtendsOne implementsSomeAllLists LBRACE invariants methods RBRACE maybeSemicolon'
    p[0] = sidl.AstNode('class', p[2], p[3], sidl.ListNode(p[4]), sidl.ListNode(p[6]), sidl.ListNode(p[7]))

def p_implementsSomeAllLists(p):
    '''implementsSomeAllLists : empty
                              | implementsLists 
                              | implementsAllLists'''
    p[0] = p[1]

def p_implementsLists(p): # +
    '''implementsLists : implementsList
                       | implementsList implementsLists '''
    cons(p)

def p_implementsAllLists(p): # +
    '''implementsAllLists : implementsAllList
                          | implementsAllList implementsAllLists'''
    cons(p)

def p_invariants(p): # *
    '''invariants : invariants invariant
                  | empty'''
    consx(p)

def p_methods(p): # *
    '''methods : method methods
               | empty'''
    consx(p)

def p_interface(p):
   'interface : INTERFACE name extendsList LBRACE invariants methods RBRACE maybeSemicolon'
   p[0] = sidl.AstNode('interface', p[2], sidl.ListNode(p[3]), sidl.ListNode(p[5]), sidl.ListNode(p[6]))

def p_scopedIDs(p): # +
    '''scopedIDs : scopedID
                 | scopedID COMMA scopedIDs'''
    cons13(p)

def p_extendsList(p):
    'extendsList : EXTENDS scopedIDs'
    p[0] = p[2]

def p_maybeExtendsOne(p):
    '''maybeExtendsOne : empty
                       | EXTENDS scopedID'''
    try2nd(p)

def p_implementsList(p):
    'implementsList : IMPLEMENTS scopedIDs'
    p[0] = sidl.ListNode(p[1])

def p_implementsAllList(p):
    'implementsAllList : IMPLEMENTS_ALL scopedIDs'
    p[0] = sidl.ListNode(p[1])

def p_method(p):
    'method : methodAttrs typeVoid methodName LPAREN maybeArgList RPAREN maybeExceptClause maybeFromClause  SEMICOLON requireAssertions ensureAssertions'
    p[0] = sidl.AstNode('method', p[2], p[3], sidl.ListNode(p[1]), sidl.ListNode(p[5]), p[7], p[8], sidl.ListNode(p[10]), sidl.ListNode(p[11]))

def p_method_error(p):
    '''method : methodAttrs typeVoid methodName error maybeArgList RPAREN maybeExceptClause maybeFromClause  SEMICOLON requireAssertions ensureAssertions 
              | methodAttrs typeVoid methodName LPAREN maybeArgList error maybeExceptClause maybeFromClause  SEMICOLON requireAssertions ensureAssertions'''
    error(p, 'missing parenthesis?')

def p_typeVoid(p):
    '''typeVoid : type 
                | VOID'''
    if p[1] == 'void': return sidl.AstNode('type', 'void')
    else: p[0] = p[1]

def p_methodAttrs(p): # *
    '''methodAttrs : methodAttrs methodAttr
                   | methodAttrs customAttrList
                   | empty'''
    consx(p)

def p_methodAttr(p):
    '''methodAttr : ONEWAY
                  | LOCAL
                  | STATIC
                  | ABSTRACT
                  | FINAL
                  | NONBLOCKING
                  | COPY'''
    p[0] = p[1]

def p_methodName(p):
    '''methodName : IDENTIFIER empty
                  | IDENTIFIER EXTENSION'''
    p[0] = p[1], p[2]

def p_maybeExceptClause(p):
    '''maybeExceptClause : exceptClause
                         | empty'''
    p[0] = p[1]

def p_exceptClause(p):
    'exceptClause : THROWS scopedIDs'
    p[0] = p[2]

def p_maybeFromClause(p):
    '''maybeFromClause : fromClause
                       | empty'''
    p[0] = p[1]

def p_fromClause(p):
    'fromClause : FROM scopedID'
    p[0] = 'from', p[2]

def p_invariant(p):
    'invariant : INVARIANT error' #( LOOKAHEAD( Assertion ) Assertion )+
    p[0] = p[1]
    
def p_requireAssertions(p):
    '''requireAssertions : REQUIRE assertions
                         | empty empty'''
    p[0] = p[2]

def p_ensureAssertions(p):
    '''ensureAssertions : ENSURE assertions
                        | empty empty'''
    p[0] = p[2]

def p_assertions(p): # +
    '''assertions : assertion
                  | assertion assertions'''
    cons(p)

def p_assertion_1(p):
    'assertion : IDENTIFIER_COLON assertExpr SEMICOLON'
    p[0] = 'assertion', p[1], p[2]

def p_assertion_2(p):
    'assertion : assertExpr SEMICOLON'
    p[0] = 'assertion', '<anonymous>', p[1]

def p_maybeArgList(p):
   '''maybeArgList : argList
                   | empty'''
   p[0] = p[1]

def p_argList(p): # +
   '''argList : arg
              | arg COMMA argList'''
   cons13(p)

def p_arg_1(p):
    'arg : argAttrs mode type name'
    p[0] = sidl.AstNode('arg', sidl.ListNode(p[1]), p[2], p[3], p[4])

def p_arg_2(p):
    'arg : argAttrs mode rarray'
    p[0] = sidl.AstNode('arg', p[1], p[2], p[3])

def p_argAttrs(p):
    '''argAttrs : COPY
                | customAttrList
                | empty'''
    p[0] = p[1]

def p_customAttrList(p):
    'customAttrList : ATTRIB_BEGIN customAttrs ATTRIB_END'
    p[0] = p[2]

def p_customAttrs(p):
    '''customAttrs : ATTRIB_COMMA customAttr customAttrs
                   | empty empty empty'''
    p[0] = [p[2]] + p[3]


def p_customAttr_1(p):
    'customAttr : ATTRIB_ID'
    p[0] = sidl.AstNode('custom attribute', p[1])

def p_customAttr_2(p):
    'customAttr : ATTRIB_ID ATTRIB_EQ ATTRIB_STRING'
    p[0] = sidl.AstNode('custom assoc attribute', p[1], p[3])

def p_mode(p):
    '''mode : IN 
            | OUT
            | INOUT'''
    p[0] = sidl.AstNode('mode', p[1])

def p_type(p):
  '''type : primitiveType 
          | array 
          | scopedID'''
  p[0] = p[1]

def p_primitiveType(p):
  '''primitiveType : BOOLEAN 
                   | CHAR
                   | INT 
                   | LONG 
                   | FLOAT
                   | DOUBLE
                   | FCOMPLEX
                   | DCOMPLEX 
                   | STRING 
                   | OPAQUE'''
  p[0] = sidl.AstNode('primitiveType', p[1])

def p_array(p):
    'array : ARRAY LT scalarType dimension orientation GT'
    p[0] = 'array', p[3], p[4], p[5]

def p_scalarType(p):
    '''scalarType : primitiveType 
                  | scopedID
                  | empty'''
    p[0] = p[1]

def p_dimension(p):
    '''dimension : COMMA INTEGER_LITERAL
                 | empty'''
    try2nd(p)

def p_orientation(p):
    '''orientation : COMMA_ROW_MAJOR
                   | COMMA_COLUMN_MAJOR
                   | empty'''
    try2nd(p)

def p_rarray(p):
    'rarray : RARRAY LT primitiveType dimension GT name LPAREN maybeExtents RPAREN'
    p[0] = 'rarray', p[3], p[4], p[6], sidl.ListNode(p[8])

def p_maybeExtents(p):
    '''maybeExtents : empty
                    | extents'''
    p[0] = p[1]

def p_extents(p): # +
    '''extents : simpleIntExpression 
               | simpleIntExpression COMMA extents'''
    cons13(p)

def p_simpleIntExpression(p):
    '''simpleIntExpression : simpleIntTerm
                           | simpleIntTerm plusMinus simpleIntTerm'''
    if len(p) == 1:
        p[0] = p[1]
    elif p[2] == '+':
        p[0] = p[1] + p[3]
    else:
        p[0] = p[1] - p[3]

def p_simpleIntTerm_1(p):
    'simpleIntTerm : simpleIntPrimary'
    p[0] = p[1]

def p_simpleIntTerm_2(p):
    'simpleIntTerm : simpleIntPrimary STAR simpleIntPrimary'
    p[0] = p[1] * p[3]

def p_simpleIntTerm_3(p):
    'simpleIntTerm : simpleIntPrimary SLASH simpleIntPrimary'
    p[0] = p[1] / p[3]

def p_simpleIntPrimary_1(p):
    'simpleIntPrimary : name'
    p[0] = lookup(p[1])

def p_simpleIntPrimary_2(p):
    'simpleIntPrimary : integer'
    p[0] = p[1]

def p_simpleIntPrimary_3(p):
    'simpleIntPrimary : LPAREN simpleIntExpression RPAREN'
    p[0] = p[2]

def p_assertExpr(p):
    '''assertExpr : orExpr IMPLIES orExpr
                  | orExpr IFF orExpr'''
    p[0] = p[2], p[1], p[3]

# TODO:
#   simplify the grammar by using the following declaration
# precedence = (
#    ('left', 'LOGICAL_OR', 'LOGICAL_XOR'),
#    ('left', 'LOGICAL_AND'),
#    ('left', 'BITWISE_AND', 'BITWISE_OR', 'BITWISE_XOR'),
#    ('nonassoc', 'EQ', 'NE'),
#    ('nonassoc', 'LT', 'GT', 'LE', 'GE'),
#    ('left', 'LSHIFT', 'RSHIFT'),
#    ('left', 'PLUS', 'MINUS'),
#    ('left', 'STAR', 'SLASH', 'MODULUS', 'REMAINDER'),
#    ('left', 'POWER'),
#    ('right', 'IS', 'NOT', 'TILDE')
# 

def p_orExpr_1(p):
    'orExpr : andExpr'
    p[0] = p[1]

def p_orExpr_2(p):
    '''orExpr : andExpr LOGICAL_OR orExpr
              | andExpr LOGICAL_XOR orExpr'''
    p[0] = sidl.IfxExpression(p[2], p[1], p[3])

def p_andExpr_1(p):
    'andExpr : bitwiseExpr'
    p[0] = p[1]

def p_andExpr_2(p):
    'andExpr : bitwiseExpr LOGICAL_AND andExpr'
    p[0] = sidl.IfxExpression(p[2], p[1], p[3])

def p_bitwiseExpr_1(p):
    'bitwiseExpr : equalityExpr'
    p[0] = p[1]

def p_bitwiseExpr_2(p):
    '''bitwiseExpr : equalityExpr BITWISE_AND bitwiseExpr
                   | equalityExpr BITWISE_OR bitwiseExpr
                   | equalityExpr BITWISE_XOR bitwiseExpr'''
    p[0] = sidl.IfxExpression(p[2], p[1], p[3])

def p_equalityExpr_1(p):
    'equalityExpr : relationalExpr'
    p[0] = p[1]

def p_equalityExpr_2(p):
    '''equalityExpr : relationalExpr EQ equalityExpr
                    | relationalExpr NE equalityExpr'''
    p[0] = sidl.IfxExpression(p[2], p[1], p[3])

def p_relationalExpr_1(p):
    'relationalExpr : shiftExpr'
    p[0] = p[1]

def p_relationalExpr_2(p):
    '''relationalExpr : shiftExpr LT relationalExpr
                      | shiftExpr GT relationalExpr
                      | shiftExpr LE relationalExpr
                      | shiftExpr GE relationalExpr'''
    p[0] = sidl.IfxExpression(p[2], p[1], p[3])

def p_shiftExpr_1(p):
    'shiftExpr : addExpr'
    p[0] = p[1]

def p_shiftExpr_2(p):
    '''shiftExpr : addExpr LSHIFT shiftExpr
                 | addExpr RSHIFT shiftExpr'''
    p[0] = sidl.IfxExpression(p[2], p[1], p[3])

def p_addExpr_1(p):
    'addExpr : multExpr'
    p[0] = p[1]

def p_addExpr_2(p):
    '''addExpr : multExpr PLUS addExpr
               | multExpr MINUS addExpr'''
    p[0] = sidl.IfxExpression(p[2], p[1], p[3])

def p_multExpr_1(p):
    'multExpr : powerExpr'
    p[0] = p[1]

def p_multExpr_2(p):
    '''multExpr : powerExpr STAR multExpr
                | powerExpr SLASH multExpr
                | powerExpr MODULUS multExpr
                | powerExpr REMAINDER multExpr'''
    p[0] = sidl.IfxExpression(p[2], p[1], p[3])

def p_powerExpr_1(p):
    'powerExpr : unaryExpr'
    p[0] = p[1]

def p_powerExpr_2(p):
    '''powerExpr : unaryExpr POWER powerExpr'''
    p[0] = sidl.IfxExpression(p[2], p[1], p[3])

def p_unaryExpr_1(p):
    '''unaryExpr : IS funcEval
                 | NOT funcEval
                 | TILDE funcEval'''
    p[0] = sidl.Expression(p[1], p[2])

# TODO funcEval is btw. not a good name...
def p_funcEval_1(p):
    'funcEval : IDENTIFIER LPAREN funcArgs RPAREN'
    p[0] = sidl.Expression('funcEval', p[1], p[3])

def p_funcEval_2(p):
    'funcEval : IDENTIFIER LPAREN RPAREN'
    p[0] = sidl.Expression('funcEval', p[1], [])

def p_funcEval_3(p):
    'funcEval : IDENTIFIER'
    p[0] = sidl.Expression('variableReference', p[1])

def p_funcEval_4(p):
    'funcEval : literal'
    p[0] = p[1]

def p_funcEval_5(p):
    'funcEval : LPAREN orExpr RPAREN'
    p[0] = p[2]

def p_funcArgs(p): # +
   '''funcArgs : orExpr
               | orExpr COMMA funcArgs'''
   cons13(p)

def p_maybeDot(p):
    '''maybeDot : DOT
                | empty'''
    pass

def p_maybeSemicolon(p):
    '''maybeSemicolon : SEMICOLON
                      | empty'''
    pass

def p_scopedID(p):
    '''scopedID : maybeDot identifiers empty
                | maybeDot identifiers EXTENSION'''
    p[0] = sidl.Expression('scope', sidl.ListNode(p[2]), p[3])

def p_identifiers(p): # +
    '''identifiers : IDENTIFIER
                   | IDENTIFIER DOT identifiers'''
    cons13(p)

def p_literal(p):
    '''literal : number 
               | complex
               | NULL
               | PURE
               | RESULT
               | BOOLEAN_LITERAL
               | CHARACTER_LITERAL
               | STRING_LITERAL'''
    p[0] = p[1]

def p_complex(p):
   'complex : LBRACE number COMMA number RBRACE'
   p[0] = ('complex', p[2], p[4])

def p_number(p):
    '''number : empty numliteral 
              |  PLUS numliteral
              | MINUS numliteral'''
    plusMinus(p)
    
def plusMinus(p):
    if p[1] == '-': 
        p[0] = -p[2]
    else:
        p[0] = p[2]

def p_plusmins(p):
   '''plusMinus : PLUS
                | MINUS'''
   p[0] = p[1]

def p_numliteral(p):
   '''numliteral : INTEGER_LITERAL 
                 | SIMPLE_FLOATING_POINT_LITERAL 
                 | FLOATING_POINT_LITERAL'''
   p[0] = p[1]

def p_integer(p):
    'integer : plusMinus INTEGER_LITERAL'
    plusMinus(p)

# # def prettyprint(t):
# #     call 'print_'t

# # give every node an id, use id for an indirect call

# # @decorator 
# # def pattern(f, *args, **kw):
# #     return f(*args, **kw)

# # def pretty:
# pretty('+', a, b) --> print pretty(a), '+', pretty(b)
# pretty(op, a, b)  --> print pretty(a), pretty(op), pretty(b)
# pretty(a)         --> print a

# --------------
# def pretty((op, a, b)):
#     op.pretty

# # @pattern
# # def pretty((op, a, b)):
# #     print a, op, b


def sidlParse(_sidlFile):
    global sidlFile
    sidlFile = _sidlFile

    debug = 0
    optimize = 1

    lex.lex(debug=debug,optimize=optimize)
    #lex.runmain()
    logging.basicConfig(filename='parser.log',level=logging.DEBUG,
                        filemode = "w", format = "%(filename)10s:%(lineno)4d:%(message)s")
    log = logging.getLogger()
    parser = yacc.yacc(debug=debug,optimize=optimize)

    try:
        f = open(sidlFile)
        data = f.read()
        f.close()
    except IndexError:
        print "Cannot read file", sidlFile

    result = parser.parse(data) #, debug=log)
    print(str(result))
    print
    print(repr(result))
    return 0

if __name__ == '__main__':
    # TODO: use getopt instead
    if sys.argv[1] == '--compile':
        # Run the scanner and parser in non-optimizing mode. This will
        # generate 'parsetab.py' which contains the
        # automaton. Subsequent runs can then use python -O $0.
        print 'Generating scanner...'
        lex.lex(debug=0, optimize=1)
        print 'Generating parser...'
        yacc.yacc(debug=0, optimize=1)

    else:
        sidlParse(sys.argv[1])
