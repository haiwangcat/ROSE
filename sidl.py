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

#             import pdb; pdb.set_trace()

class AstNode:
    """
    Base class. All other SIDL AST nodes should inherit from this one:
      * Calling str(astNode) will result in a human-readable version of the AST.

      * Calling repr(astNode) will return a Python-readable version of
        the AST that can be passed to eval() to generate a new Python
        object.
    """
    def __init__(self, nodeType, *children):
        print 'new', nodeType, '(', str(children), ')'
        self.nodeType = nodeType
        self.children = children

    def unquote(self, s):
        """
        remove one layer of quotation in a string:
        "'hello\\n'" --> "hello\n"
        """
        r = ""
        i = 1
        while i < len(s)-1:
            c = s[i]
            if c == '\\':
                i += 1
            else:
                r += s[i]
            i += 1
        return r

    def __repr__(self):
        return self.myrepr()

    def myrepr(self): 
        r = str(self.__class__.__name__) + '(' + str(self.nodeType)
        for i in range(0, len(self.children)):
            r += ', '
            if isinstance(self.children[i], AstNode):
                r += self.children[i].myrepr()
            else:
                r += repr(self.children[i])
        r += ')'
        return r

    def __str__(self):
        #print 'in str', self.__class__.__name__, ': ', self.nodeType, ', len =', len(self.children)
        #import pdb; pdb.set_trace()
        def mystr(x):
            if x == []: return ''
            else: return str(x)+' '

        if len(self.children) < 2:
            return str(self.nodeType) + ' ' + str(self.children)

        return str(self.nodeType) + ' ' \
            + reduce(lambda x, y: mystr(x)+str(y), self.children)

class IfxNode(AstNode):
    """Base class for infix operators"""
    def __str__(self):
        return str(self.children[0]) + ' ' \
            + self.nodeType + ' ' \
            + str(self.children[1])

class ListNode(AstNode):
    def __init__(self, children):
        self.children = children
    def myrepr(self):
        #print 'list node repr(), len =', len(self.children)
        
        if len(self.children) == 0:
            return 'ListNode([])'
        elif len(self.children) == 1:
            return 'ListNode(' + repr(self.children[0]) + ')'
        else:
            r = 'ListNode(['
            l = len(self.children)
            for i in range(0, l):
                if isinstance(self.children[i], AstNode):
                    r += self.children[i].myrepr()
                else:
                    r += repr(self.children[i])
                if (i < l-1):
                    r += ', '
        return r + '])'
        
    def __str__(self):
        #print 'list node str(), len =', len(self.children)
        
        if len(self.children) == 0:
            return ''
        elif len(self.children) == 1:
            return str(self.children[0])
        return reduce(lambda x,y: str(x)+', '+str(y), self.children)
   

class File(AstNode):
    def requires(): return children[0]
    def imports():  return children[1]
    def packages(): return children[2]

class Expression(AstNode):
    pass

class IfxExpression(IfxNode, Expression):
    pass
