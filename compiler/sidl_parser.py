#!/usr/bin/env python
# -*- python -*-
## @package parser
#
# A parser for SIDL files.
#
# The parser is known to parse all .sidl files contained in
# the Babel distribution.
#
# This parser uses the PLY (Python Lex & Yacc) published under BSD
# license and available at http://www.dabeaz.com/ply/ . For practical
# reasons, this library is included in this distribution in the ply/
# subdirectory.
#
# There are two choices of scanners available. The first one is
# written in Python and is included in this file. For performance
# resons, there exists also a second scanner written in C and
# flex. Currently the Python scanner is commented out and the faster C
# scanner is used.
#
# The parser generates a sidl class hierarchy which can then be
# converted to s-expressions. Future versions may skip the sidl class
# and generate the s-expressions directly.
# http://people.csail.mit.edu/rivest/Sexp.txt
#
# Please report bugs to <adrian@llnl.gov>.
#
# \authors <pre>
# Copyright (c) 2010, Lawrence Livermore National Security, LLC
# Produced at the Lawrence Livermore National Laboratory.
# Written by the Components Team <components@llnl.gov>
# UCRL-CODE-????-???
# All rights reserved.
#
# This file is part of Babel. For more information, see
# http://www.llnl.gov/CASC/components/. Please read the COPYRIGHT file
# for Our Notice and the LICENSE file for ????
# License.
#
# </pre>    \TODO insert License

import logging, operator, sys
#import re
#import ply.lex as lex
#from ply.lex import TOKEN
import ply.yacc as yacc

def trace():
    import pdb; pdb.set_trace();

import ir, sidl
from patmat import matcher, Variable, match

sys.path.append('.libs')
import scanner

sidlFile = ''

tokens = [ 'VOID', 'ARRAY', 'RARRAY', 'BOOL', 'CHAR', 'DCOMPLEX', 'DOUBLE',
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

            'LPAREN', 'RPAREN', 'LBRACE', 'RBRACE',
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

# # White Space
# t_ignore = ' \t\f'

# # Define a rule so we can track line numbers
# def t_newline(t):
#     r'[\r\n]+'
#     #print "parsing line", t.lexer.lineno
#     t.lexer.lineno += len(t.value)

# # Comments
# # C or C++ comment (ignore)
# comment = r'(/\*(.|\n)*?\*/)|(//.*)'
# @TOKEN(comment)
# def t_COMMENT(t):
#     updateLineNo(t)

# # TODO  <"/**" ~["/"] > { input_stream.backup(1); } : IN_DOC_COMMENT

# reserved_words = {

# #basic_types = {
#     "void"     :  'VOID',
#     "array"    :  'ARRAY',
#     "rarray"   :  'RARRAY',
#     "bool"     :  'BOOL',
#     "char"     :  'CHAR',
#     "dcomplex" :  'DCOMPLEX',
#     "double"   :  'DOUBLE',
#     "fcomplex" :  'FCOMPLEX',
#     "float"    :  'FLOAT',
#     "int"      :  'INT',
#     "long"     :  'LONG',
#     "opaque"   :  'OPAQUE',
#     "string"   :  'STRING'
# #}
# ,

# #user_defined_types = {
#     "class"     : 'CLASS',
#     "enum"      : 'ENUM',
#     "struct"    : 'STRUCT',
#     "interface" : 'INTERFACE'
# #}
# ,
# #reserved_words = {
#     r'abstract'         : 'ABSTRACT',
#     r'and'              : 'LOGICAL_AND',
#     r'copy'             : 'COPY',
# #   r'column-major'     : 'COLUMN_MAJOR',
#     r'else'             : 'ELSE',
#     r'ensure'           : 'ENSURE',
#     r'extends'          : 'EXTENDS',
#     r'final'            : 'FINAL',
#     r'from'             : 'FROM',
#     r'iff'              : 'IFF',
#     r'implements'       : 'IMPLEMENTS',
#     r'implies'          : 'IMPLIES',
#     r'import'           : 'IMPORT',
#     r'in'               : 'IN',
#     r'inout'            : 'INOUT',
#     r'invariant'        : 'INVARIANT',
#     r'is'               : 'IS',
#     r'local'            : 'LOCAL',
#     r'mod'              : 'MODULUS',
#     r'not'              : 'NOT',
#     r'null'             : 'NULL',
#     r'nonblocking'      : 'NONBLOCKING',
#     r'oneway'           : 'ONEWAY',
#     r'order'            : 'ORDER',
#     r'or'               : 'LOGICAL_OR',
#     r'out'              : 'OUT',
#     r'package'          : 'PACKAGE',
#     r'pure'             : 'PURE',
#     r'rem'              : 'REMAINDER',
#     r'require'          : 'REQUIRE',
#     r'result'           : 'RESULT',
# #   r'row-major'        : 'ROW_MAJOR',
#     r'static'           : 'STATIC',
#     r'then'             : 'THEN',
#     r'throws'           : 'THROWS',
#     r'version'          : 'VERSION',
#     r'xor'              : 'LOGICAL_XOR'
# }

# t_EXTENSION     = r'\[\w+\]'

# version_string  = r'(\d)\.(\d)+(\.(\d)+)+'
# @TOKEN(version_string)
# def t_VERSION_STRING(t):
#      # we need to define version_string as a function, so it is
#      # applied before float_literal
#     updateLineNo(t)
#     return t


# # count how many newline characters are included in the token
# def updateLineNo(t):
#     t.lexer.lineno += t.value.count('\r')
#     t.lexer.lineno += t.value.count('\n')


# # Work around the fact that we need a lookahead of 2 for the grammar at some points
# ws = r'([ \r\n\f\t]|' + comment + r')*'
# comma_column_major = r','+ws+r'column-major'
# @TOKEN(comma_column_major)
# def t_COMMA_COLUMN_MAJOR(t):
#     updateLineNo(t)

# comma_row_major = r','+ws+r'row-major'
# @TOKEN(comma_row_major)
# def t_COMMA_ROW_MAJOR(t):
#     updateLineNo(t)

# # comma_rbrace_msc = r'(,'+ws+r')?}('+ws+r';)?'
# # @TOKEN(comma_rbrace_msc)
# # def t_COMMA_RBRACE_MSC(t):
# #     print 'COMMARBRACEMSC "', t.value, '"'
# #     updateLineNo(t)

# identifier_colon = r'[a-zA-Z][a-zA-Z_0-9]*'+ws+r':'
# @TOKEN(identifier_colon)
# def t_IDENTIFIER_COLON(t):
#     # TODO: do this more efficiently
#     t.value = re.search(r'^[a-zA-Z][a-zA-Z_0-9]*', t.value).group(0)
#     updateLineNo(t)

# implements_all = r'implements-all'
# @TOKEN(implements_all)
# def t_IMPLEMENTS_ALL(t):
#      # we need to define version_string as a function, so it is
#      # applied before identifier
#     updateLineNo(t)
#     return t

# identifier = r'[a-zA-Z][a-zA-Z_0-9]*'
# @TOKEN(identifier)
# def t_IDENTIFIER(t):
#     # While this code seems to defy the purpose of having an efficient
#     # scanner; the PLY documentation actually argues against defining
#     # rules for keywords. The reason is that apparently the regex
#     # engine is slower than the hashtable lookup below
#     t.type = reserved_words.get(t.value,'IDENTIFIER')    # Check for reserved words
#     return t

# # separators
# t_LPAREN     =   r'\('
# t_RPAREN     =   r'\)'
# t_LBRACE     =   r'{'
# t_RBRACE     =   r'}'
# #t_LBRACKET   =   r'\['
# #t_RBRACKET   =   r'\]'
# t_SEMICOLON  =   r';'
# t_COMMA      =   r','
# t_DOT        =   r'\.'


# #/* SPECIAL MODES */
# t_ATTRIB_BEGIN = r'%attrib{' # > : IN_ATTRIB_LIST
# #
# #<IN_ATTRIB_LIST
# #TOKEN :
# #{
# #  < ATTRIB_ID      : <LETTER> ( <LETTER> | <DIGIT> | "_")*
# #| < ATTRIB_STRING :
# #      "\""
# #      (   (~["\"","\\","\n","\r"])
# #        | ("\\"
# #            ( ["n","t","b","r","f","\\","'","\""]
# #            | ["0"-"7"] ( ["0"-"7"] )?
# #            | ["0"-"3"] ["0"-"7"] ["0"-"7"]
# #            )
# #          )
# #      )*
# #      "\""
# #
# #| < ATTRIB_EQ = "="
# #| < ATTRIB_COMMA = ","
# ATTRIB_END = r'}' # > : DEFAULT
# #}
# #
# #<IN_ATTRIB_LIST
# #SPECIAL_TOKEN :
# #{
# #  " "
# #| "\t"
# #| "\n"
# #| "\r"
# #| "\f"
# #}

# # operators
# t_LSHIFT= r'<<<'
# t_RSHIFT= r'>>>'
# t_EQ= r'=='
# t_GE= r'>='
# t_GT= r'>'
# t_LE= r'<='
# t_LT= r'<'
# t_NE= r'!='
# t_ASSIGN= r'='
# t_BITWISE_AND= r'&'
# t_BITWISE_XOR= r'\^'
# t_MINUS= r'-'
# t_BITWISE_OR= r'\|'
# t_PLUS= r'\+'
# t_POWER = r'\*\*'
# t_SLASH= r'/'
# t_STAR= r'\*'
# t_TILDE= r'~'

# # literals
# digit = r'(\d)'
# digits = r'(\d)+'
# exponent = r'([eE])([+-])?(\d)+'
# exponentp = r'('+exponent+r')?'
# decimal_literal = r'([1-9])(\d)*'
# hex_literal     = r'0[xX]([0-9a-fA-F])+'
# octal_literal   = r'0([0-7])*'
# integer_literal = r'((' + decimal_literal + r'[lL]?' \
#                + r')|(' + hex_literal + r'[lL]?' \
#                + r')|(' + octal_literal + r'[lL]?' \
#                + r'))'

# dot = r'\.'
# simple_floating_point_literal = digits + dot + digits

# floating_point_literal = \
#            r'(' + simple_floating_point_literal + exponent  + r'([fFdD])?' \
#         +r')|(' + simple_floating_point_literal + exponentp + r'([fFdD])'  \
#         +r')|(' + digit                   + dot + exponentp + r'([fFdD])?' \
#         +r')|(' + dot + digits                  + exponentp + r'([fFdD])?' \
#         +r')|(' + digits                        + exponent  + r'([fFdD])?' \
#         +r')|'  + digits                        + exponentp + r'([fFdD])'  \
#         +r')'


# t_BOOLEAN_LITERAL = r'((false)|(true))'
# #t_FALSE          = r'false'
# #t_TRUE           = r'true'

# @TOKEN(simple_floating_point_literal)
# def t_SIMPLE_FLOATING_POINT_LITERAL(t):
#     t.value = float(t.value)
#     return t

# @TOKEN(integer_literal)
# def t_INTEGER_LITERAL(t):
#     t.value = int(t.value)
#     return t

# @TOKEN(decimal_literal)
# def t_DECIMAL_LITERAL(t):
#     t.value = int(t.value)
#     return t

# string_innards = r'([^\'\\\n\r])'                    \
#                  + r'|(\\' + r'([ntbrf\\\'"]'        \
#                    + r'|(([0-7])([0-7])?)'           \
#                    + r'|(([0-3])([0-7])([0-7]))'     \
#                  + r')'                              \
#                + r')'


# character_literal = r'\'(' + string_innards + r')\''
# string_literal = r'"(' + string_innards + r'*)"'


# Error handling rule
def t_error(t):
    print "Illegal character '%s'" % t.value[0]
    t.lexer.skip(1)

# ------------- Parser

def p_start(p):
    '''start : requires imports userTypes'''
    #{ return jjtThis; }
    p[0] = sidl.File(sidl.ListNode(p[1]), sidl.ListNode(p[2]), sidl.ListNode(p[3]))

def p_empty(p):
    '''empty :'''
    p[0] = []

def cons(p):
    """
    use this for \c 'token+' patterns

    Construct a list \c p[1]:p[2] and store result in \c p[0].
    """
    if len(p) == 2:
        p[0] = [p[1]]
    else:
        p[0] = [p[1]] + p[2]


def cons13(p):
    """
    use this for \c '(token , )+' patterns

    Construct a list \c p[1]:p[3] and store result in \c p[0].
    """
    # for i in range(0, len(p)):
    #     print i, p[i]
    if len(p) < 4:
        if p[1] == None:
            p[0] = []
        else:
            p[0] = [p[1]]
    else:
        p[0] = [p[1]] + p[3]
    # print "->", p[0]
    # print ""

def consx(p):
    """
    use this for \c 'token*' patterns

    Construct a list \c p[1]:p[2] and store result in \c p[0].

    If there is no \c p[1], return an empty list.
    """
    if p[1] == []:
        p[0] = []
    else:
        p[0] = [p[1]] + p[2]

def consx13(p):
    """
    use this for '(token , )*' patterns

    Construct a list \c p[1]:p[3] and store result in \c p[0].

    If there is no \c p[1], return an empty list.
    """
    if p[1] == []:
        p[0] = []
    else:
        p[0] = [p[1]] + p[3]

def try2nd(p):
    if p[1] == []:
        p[0] = []
    else:
        p[0] = p[2]

# FIXME: this is all necessary because of the lookahead problem mentioned above
def no_comma(t):
    if t[0] == ',':
        error([t], "unexpected ','")

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

    sys.stdout.write('**ERROR: in %s:%d:\n  Syntax error near "%s" (recognized as %s).\n' %
                         (sidlFile, errorToken.lineno, errorToken.value, errorToken.type))

    i = 0
    pos = errorToken.lexpos
    for line in open(sidlFile):
        i += 1
        if i == errorToken.lineno:
            sys.stdout.write(line)
            l = 1
            if hasattr(errorToken.value, '__len__'):
                l = len(errorToken.value)
            print ' '*(pos)+'^'*l
            break
        pos -= len(line)
    sys.stdout.write("Possible reason(s): ")

def p_version(p):
    '''version : VERSION version_'''
    p[0] = sidl.AstNode(ir.version, p[2])

def p_version_error(p):
    '''version : VERSION error'''
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
    '''require : REQUIRE scopedID version SEMICOLON'''
    p[0] = sidl.AstNode(ir.require, p[2], p[3])

def p_require_error(p):
    '''require : REQUIRE error version SEMICOLON'''
    error(p, 'Bad require expression: Bad scoped identifier')

def p_imports(p): # *
    '''imports : import imports
               | empty'''
    consx(p)

def p_import_1(p):
    '''import : IMPORT scopedID SEMICOLON'''
    p[0] = sidl.AstNode(ir.import_, p[2])

def p_import_2(p):
    '''import : IMPORT scopedID version SEMICOLON'''
    p[0] = sidl.AstNode(ir.import_, p[2], p[3])

def p_import_error(p):
    '''import : IMPORT error SEMICOLON'''
    error(p, 'Bad import expression: Bad identifier')

def p_package_1(p):
    '''package : PACKAGE name LBRACE userTypes RBRACE'''
    no_comma(p[5])
    p[0] = sidl.AstNode(ir.package, p[2], 'no version', sidl.ListNode(p[4]))

def p_package_2(p):
    '''package : PACKAGE name version LBRACE userTypes RBRACE'''
    no_comma(p[6])
    p[0] = sidl.AstNode(ir.package, p[2], p[3], sidl.ListNode(p[5]))

def p_package_error_1(p):
    '''package : PACKAGE error'''
    error(p, 'Bad package definition: Bad package name')

def p_package_error_2(p):
    '''package : PACKAGE name error'''
    error(p, 'Bad package definition: Bad package version')

def p_userTypes(p): # *
    '''userTypes : userType userTypes
                 | empty'''
    consx(p)

def p_userType(p):
    '''userType : typeCustomAttrs cipse maybeSemicolon'''
    p[0] = sidl.AstNode(ir.user_type, sidl.ListNode(p[1]), p[2])

def p_cipse(p):
    '''cipse : class
             | interface
             | package
             | struct
             | enum'''
    p[0] = p[1]

def p_cipse_error(p):
    '''cipse : error'''
    error(p, 'Bad user-defined type: Unexpected keyword')

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
    p[0] = sidl.AstNode(ir.type_attribute, p[1])

def p_name(p):
    '''name : IDENTIFIER'''
    p[0] = sidl.AstNode(ir.identifier, p[1])

def p_enum(p):
    '''enum : ENUM name LBRACE enumerators RBRACE'''
    p[0] = sidl.AstNode(ir.enum, p[2], sidl.ListNode(p[4]))

def p_enumerators(p): # +
    '''enumerators : enumerator
                   | enumerator COMMA
                   | enumerator COMMA enumerators'''
    cons13(p)

def p_enumerator(p):
    '''enumerator : name
                  | name ASSIGN integer'''
    if len(p) < 4:
        p[0] = sidl.AstNode(ir.enumerator, p[1])
    else:
        p[0] = sidl.AstNode(ir.enumerator, p[2], p[1], p[3])

def p_struct(p):
    '''struct : STRUCT name LBRACE structItems RBRACE'''
    no_comma(p[5])
    p[0] = sidl.AstNode(ir.struct, p[2], sidl.ListNode(p[4]))

def p_structItems(p): # *
    '''structItems : empty
                   | structItem structItems'''
    consx(p)

def p_structItem_1(p):
    '''structItem : type name SEMICOLON'''
    p[0] = sidl.AstNode(ir.struct_item, p[1], p[2])

def p_structItem_2(p):
    '''structItem : rarray SEMICOLON'''
    p[0] = p[1]

def p_class(p):
    '''class : CLASS name maybeExtendsOne implementsSomeAllLists LBRACE invariants methods RBRACE'''
    no_comma(p[8])
    p[0] = sidl.AstNode(ir.class_, p[2], p[3], sidl.ListNode(p[4]), sidl.ListNode(p[6]), sidl.ListNode(p[7]))

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
    '''interface : INTERFACE name extendsList LBRACE invariants methods RBRACE'''
    no_comma(p[7])
    p[0] = sidl.AstNode(ir.interface, p[2], sidl.ListNode(p[3]), sidl.ListNode(p[5]), sidl.ListNode(p[6]))

def p_scopedIDs(p): # +
    '''scopedIDs : scopedID
                 | scopedID COMMA scopedIDs'''
    cons13(p)

def p_extendsList(p):
    '''extendsList : empty
                   | EXTENDS scopedIDs'''
    try2nd(p)

def p_maybeExtendsOne(p):
    '''maybeExtendsOne : empty
                       | EXTENDS scopedID'''
    try2nd(p)

def p_implementsList(p):
    '''implementsList : IMPLEMENTS scopedIDs'''
    p[0] = sidl.AstNode(ir.implements, p[2])

def p_implementsAllList(p):
    '''implementsAllList : IMPLEMENTS_ALL scopedIDs'''
    p[0] = sidl.AstNode(ir.implements_all, p[2])

def p_method(p):
    '''method : methodAttrs typeVoid methodName LPAREN maybeArgList RPAREN maybeExceptClause maybeFromClause  SEMICOLON requireAssertions ensureAssertions'''
    p[0] = sidl.AstNode(ir.method, p[2], p[3], sidl.ListNode(p[1]), sidl.ListNode(p[5]), p[7], p[8], sidl.ListNode(p[10]), sidl.ListNode(p[11]))

def p_method_error(p):
    '''method : methodAttrs typeVoid methodName error maybeArgList RPAREN maybeExceptClause maybeFromClause  SEMICOLON requireAssertions ensureAssertions
              | methodAttrs typeVoid methodName LPAREN maybeArgList error maybeExceptClause maybeFromClause  SEMICOLON requireAssertions ensureAssertions'''
    error(p, 'missing parenthesis?')

def p_typeVoid(p):
    '''typeVoid : type
                | VOID'''
    if p[1] == 'void':
        return sidl.AstNode(ir.type, ir.void)
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
    p[0] = sidl.AstNode(ir.method_name, p[1], p[2])

def p_maybeExceptClause(p):
    '''maybeExceptClause : exceptClause
                         | empty'''
    p[0] = p[1]

def p_exceptClause(p):
    '''exceptClause : THROWS scopedIDs'''
    p[0] = p[2]

def p_maybeFromClause(p):
    '''maybeFromClause : fromClause
                       | empty'''
    p[0] = p[1]

def p_fromClause(p):
    '''fromClause : FROM scopedID'''
    p[0] = sidl.AstNode(ir.from_, p[2])

def p_invariant(p):
    '''invariant : INVARIANT assertion'''
    p[0] = sidl.AstNode(ir.invariant, p[1])

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
    # FIXME: one last shift/reduce conflict lurking here
    cons(p)

def p_assertion_1(p):
    '''assertion : IDENTIFIER_COLON assertExpr SEMICOLON'''
    p[0] = sidl.AstNode(ir.assertion, p[1], p[2])

def p_assertion_2(p):
    '''assertion : assertExpr SEMICOLON'''
    p[0] = sidl.AstNode(ir.assertion, '<anonymous>', p[1])

def p_maybeArgList(p):
    '''maybeArgList : argList
                    | empty'''
    p[0] = p[1]

def p_argList(p): # +
    '''argList : arg
               | arg COMMA argList'''
    cons13(p)

def p_arg_1(p):
    '''arg : argAttrs mode type name'''
    p[0] = sidl.AstNode(ir.arg, sidl.ListNode(p[1]), p[2], p[3], p[4])

def p_arg_2(p):
    '''arg : argAttrs mode rarray'''
    p[0] = sidl.AstNode(ir.arg, p[1], p[2], p[3])

def p_argAttrs(p):
    '''argAttrs : COPY
                | customAttrList
                | empty'''
    p[0] = p[1]

def p_customAttrList(p):
    '''customAttrList : ATTRIB_BEGIN customAttrs ATTRIB_END'''
    p[0] = p[2]

def p_customAttrs(p):
    '''customAttrs : ATTRIB_COMMA customAttr customAttrs
                   | empty empty empty'''
    p[0] = [p[2]] + p[3]


def p_customAttr_1(p):
    '''customAttr : ATTRIB_ID'''
    p[0] = sidl.AstNode(ir.custom_attribute, p[1])

def p_customAttr_2(p):
    '''customAttr : ATTRIB_ID ATTRIB_EQ ATTRIB_STRING'''
    p[0] = sidl.AstNode(ir.custom_attribute_assoc, p[1], p[3])

def p_mode(p):
    '''mode : IN
            | OUT
            | INOUT'''
    p[0] = sidl.AstNode(ir.mode, p[1])

def p_type(p):
    '''type : primitiveType
            | array
            | scopedID'''
    p[0] = p[1]

def p_primitiveType(p):
    '''primitiveType : BOOL
                     | CHAR
                     | INT
                     | LONG
                     | FLOAT
                     | DOUBLE
                     | FCOMPLEX
                     | DCOMPLEX
                     | STRING
                     | OPAQUE'''
    p[0] = sidl.AstNode(ir.primitive_type, p[1])

def p_array(p):
    '''array : ARRAY LT scalarType dimension orientation GT'''
    p[0] = sidl.AstNode(ir.array, p[3], p[4], p[5])

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
    p[0] = p[1]

def p_rarray(p):
    '''rarray : RARRAY LT primitiveType dimension GT name LPAREN maybeExtents RPAREN'''
    p[0] = sidl.AstNode(ir.rarray, p[3], p[4], p[6], sidl.ListNode(p[8]))

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
    if len(p) == 2:
        p[0] = p[1]
    elif p[2] == '+':
        p[0] = p[1] + p[3]
    else:
        p[0] = p[1] - p[3]

def p_simpleIntTerm_1(p):
    '''simpleIntTerm : simpleIntPrimary'''
    p[0] = p[1]

def p_simpleIntTerm_2(p):
    '''simpleIntTerm : simpleIntPrimary STAR simpleIntPrimary'''
    p[0] = p[1] * p[3]

def p_simpleIntTerm_3(p):
    '''simpleIntTerm : simpleIntPrimary SLASH simpleIntPrimary'''
    p[0] = p[1] / p[3]

def p_simpleIntPrimary_1(p):
    '''simpleIntPrimary : name'''
    p[0] = p[1]

def p_simpleIntPrimary_2(p):
    '''simpleIntPrimary : integer'''
    p[0] = p[1]

def p_simpleIntPrimary_3(p):
    '''simpleIntPrimary : LPAREN simpleIntExpression RPAREN'''
    p[0] = p[2]


def p_assertExpr_1(p):
    '''assertExpr : orExpr'''
    p[0] = p[1]

def p_assertExpr_2(p):
    '''assertExpr : orExpr IMPLIES orExpr
                  | orExpr IFF orExpr'''
    p[0] = sidl.IfxExpression(p[2], p[1], p[3])

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
    '''orExpr : andExpr'''
    p[0] = p[1]

def p_orExpr_2(p):
    '''orExpr : andExpr LOGICAL_OR orExpr
              | andExpr LOGICAL_XOR orExpr'''
    p[0] = sidl.IfxExpression(p[2], p[1], p[3])

def p_andExpr_1(p):
    '''andExpr : bitwiseExpr'''
    p[0] = p[1]

def p_andExpr_2(p):
    '''andExpr : bitwiseExpr LOGICAL_AND andExpr'''
    p[0] = sidl.IfxExpression(p[2], p[1], p[3])

def p_bitwiseExpr_1(p):
    '''bitwiseExpr : equalityExpr'''
    p[0] = p[1]

def p_bitwiseExpr_2(p):
    '''bitwiseExpr : equalityExpr BITWISE_AND bitwiseExpr
                   | equalityExpr BITWISE_OR bitwiseExpr
                   | equalityExpr BITWISE_XOR bitwiseExpr'''
    p[0] = sidl.IfxExpression(p[2], p[1], p[3])

def p_equalityExpr_1(p):
    '''equalityExpr : relationalExpr'''
    p[0] = p[1]

def p_equalityExpr_2(p):
    '''equalityExpr : relationalExpr EQ equalityExpr
                    | relationalExpr NE equalityExpr'''
    p[0] = sidl.IfxExpression(p[2], p[1], p[3])

def p_relationalExpr_1(p):
    '''relationalExpr : shiftExpr'''
    p[0] = p[1]

def p_relationalExpr_2(p):
    '''relationalExpr : shiftExpr LT relationalExpr
                      | shiftExpr GT relationalExpr
                      | shiftExpr LE relationalExpr
                      | shiftExpr GE relationalExpr'''
    p[0] = sidl.IfxExpression(p[2], p[1], p[3])

def p_shiftExpr_1(p):
    '''shiftExpr : addExpr'''
    p[0] = p[1]

def p_shiftExpr_2(p):
    '''shiftExpr : addExpr LSHIFT shiftExpr
                 | addExpr RSHIFT shiftExpr'''
    p[0] = sidl.IfxExpression(p[2], p[1], p[3])

def p_addExpr_1(p):
    '''addExpr : multExpr'''
    p[0] = p[1]

def p_addExpr_2(p):
    '''addExpr : multExpr PLUS addExpr
               | multExpr MINUS addExpr'''
    p[0] = sidl.IfxExpression(p[2], p[1], p[3])

def p_multExpr_1(p):
    '''multExpr : powerExpr'''
    p[0] = p[1]

def p_multExpr_2(p):
    '''multExpr : powerExpr STAR multExpr
                | powerExpr SLASH multExpr
                | powerExpr MODULUS multExpr
                | powerExpr REMAINDER multExpr'''
    p[0] = sidl.IfxExpression(p[2], p[1], p[3])

def p_powerExpr_1(p):
    '''powerExpr : unaryExpr'''
    p[0] = p[1]

def p_powerExpr_2(p):
    '''powerExpr : unaryExpr POWER powerExpr'''
    p[0] = sidl.IfxExpression(p[2], p[1], p[3])

def p_unaryExpr_1(p):
    '''unaryExpr : IS funcEval
                 | NOT funcEval
                 | TILDE funcEval'''
    p[0] = sidl.Expression(p[1], p[2])

def p_unaryExpr_2(p):
    '''unaryExpr : funcEval'''
    p[0] = p[1]


# TODO funcEval is btw. not a good name...
def p_funcEval_1(p):
    '''funcEval : IDENTIFIER LPAREN funcArgs RPAREN'''
    p[0] = sidl.Expression(ir.fn_eval, p[1], p[3])

def p_funcEval_2(p):
    '''funcEval : IDENTIFIER LPAREN RPAREN'''
    p[0] = sidl.Expression(ir.fn_eval, p[1], [])

def p_funcEval_3(p):
    '''funcEval : IDENTIFIER'''
    p[0] = sidl.Expression(ir.var_ref, p[1])

def p_funcEval_4(p):
    '''funcEval : literal'''
    p[0] = p[1]

def p_funcEval_5(p):
    '''funcEval : LPAREN orExpr RPAREN'''
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
    print p[1], p[2],p[3]
    p[0] = sidl.AstNode(ir.scoped_id, sidl.ListNode(p[2]), p[3])

def p_identifiers(p): # +
    '''identifiers : IDENTIFIER
                   | IDENTIFIER DOT identifiers'''
    print 'X',p[1]
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
    '''complex : LBRACE number COMMA number RBRACE'''
    no_comma(p[5])
    if operator.indexof(';', p[5]) > -1:
        error(p, "Unexpected ';'")
    p[0] = sidl.AstNode(ir.complex_, p[2], p[4])

def p_number(p):
    '''number : empty numliteral
              | plusMinus numliteral'''
    plusMinus(p)

def plusMinus(p):
    if p[1] == '-':
        p[0] = -int(p[2])
    else:
        p[0] = int(p[2])

def p_plusminus(p):
    '''plusMinus : PLUS
                 | MINUS'''
    p[0] = p[1]

def p_numliteral_1(p):
    '''numliteral : INTEGER_LITERAL'''
    p[0] = int(p[1])

def p_numliteral_2(p):
    '''numliteral : SIMPLE_FLOATING_POINT_LITERAL
                  | FLOATING_POINT_LITERAL'''
    p[0] = float(p[1])

def p_integer_1(p):
    '''integer : plusMinus INTEGER_LITERAL'''
    plusMinus(p)

def p_integer_2(p):
    '''integer : INTEGER_LITERAL'''
    p[0] = int(p[1])



# ----------------------------------------------------------------------



def parse(sidl_file, debug=False):
    """
    Parse the .sidl file and return the object-oriented intermediate
    representation.

    \param sidl_file   the name of the input file
    \param debug       turn on debugging output
    """
    global sidlFile
    sidlFile = sidl_file

    optimize = not debug

    #lex.lex(debug=debug,optimize=optimize)
    #lex.runmain()

    parser = yacc.yacc(debug=debug, optimize=optimize)

    # try:
    #     f = open(sidlFile)
    #     data = f.read()
    #     f.close()
    # except IndexError:
    #     print "Cannot read file", sidlFile

    if debug == 1:
        logging.basicConfig(filename='parser.log', level=logging.DEBUG,
                            filemode = "w",
                            format = "%(filename)10s:%(lineno)4d:%(message)s")
        log = logging.getLogger()
        debug = log

    #import pdb; pdb.set_trace()
    return parser.parse(sidlFile, lexer=scanner, debug=debug)

if __name__ == '__main__':
    # Run the scanner and parser in non-optimizing mode. This will
    # generate 'parsetab.py' which contains the
    # automaton. Subsequent runs can then use python -O $0.
    # print 'Generating scanner...'
    # lex.lex(debug=_debug, optimize=1-_debug)
    print 'Generating parser...'
    _debug=0
    yacc.yacc(debug=_debug, optimize=1-_debug)

    # # Profiling
    # import hotshot, hotshot.stats
    # prof = hotshot.Profile('parser.prof')
    # prof.runcall(sidlParse, sys.argv[1])
    # stats = hotshot.stats.load("parser.prof")
    # stats.strip_dirs()
    # stats.sort_stats('time', 'calls')
    # stats.print_stats(20)
