#!/usr/bin/env python
# -*- python -*-
## @package sidl
#
# A SIDL class hierarchy
#
# \authors Please report bugs to <adrian@llnl.gov>.
# \authors
# Copyright (c) 2010, Lawrence Livermore National Security, LLC             \n 
# Produced at the Lawrence Livermore National Laboratory.                   \n 
# Written by the Components Team <components@llnl.gov>                      \n 
# UCRL-CODE-2002-054                                                        \n 
# All rights reserved.                                                      \n 
#                                                                           \n 
# This file is part of Babel. For more information, see                     \n 
# http://www.llnl.gov/CASC/components/. Please read the COPYRIGHT file      \n 
# for Our Notice and the LICENSE file for the GNU Lesser General Public     \n 
# License.                                                                  \n 
#                                                                           \n 
# This program is free software; you can redistribute it and/or modify it   \n 
# under the terms of the GNU Lesser General Public License (as published by \n 
# the Free Software Foundation) version 2.1 dated February 1999.            \n 
#                                                                           \n 
# This program is distributed in the hope that it will be useful, but       \n 
# WITHOUT ANY WARRANTY; without even the IMPLIED WARRANTY OF                \n 
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the terms and    \n 
# conditions of the GNU Lesser General Public License for more details.     \n 
#                                                                           \n 
# You should have recieved a copy of the GNU Lesser General Public License  \n 
# along with this program; if not, write to the Free Software Foundation,   \n 
# Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA               \n 
#


#             import pdb; pdb.set_trace()

def make_sexpr(child):
    """helper function for sexpr()"""
    if isinstance(child, AstNode):
        return child.sexpr()
    else:
        return child
        
class AstNode:
    """
    Base class. All other SIDL AST nodes should inherit from this one.
    \li Calling str(astNode) will result in a human-readable version of the AST.

    \li  Calling repr(astNode) will return a Python-readable version of
        the AST that can be passed to eval() to generate a new Python
        object.
    """
    def __init__(self, type, *children):
        #print 'new', type, '(', str(children), ')'
        self.type = type
        self.children = children

    def __repr__(self):
        return self.myrepr()

    def sexpr(self):
        """return an s-expression representing this node"""
        #print '@', self.type

        s = [self.type]
        for child in self.children:
            s.append(make_sexpr(child))
        return tuple(s)

    def myrepr(self): 
        r = str(self.__class__.__name__) + '(' + str(self.type)
        for i in range(0, len(self.children)):
            r += ', '
            if isinstance(self.children[i], AstNode):
                r += self.children[i].myrepr()
            else:
                r += repr(self.children[i])
        r += ')'
        return r

    def __str__(self):
        #print 'in str', self.__class__.__name__, ': ', self.type, ', len =', len(self.children)
        #import pdb; pdb.set_trace()
        def mystr(x):
            if x == []: return ''
            else: return str(x)+' '

        if len(self.children) < 2:
            return str(self.type) + ' ' + str(self.children)

        return str(self.type) + ' ' \
            + reduce(lambda x, y: mystr(x)+str(y), self.children)

class ListNode(AstNode):
    """Node that is a list of other nodes"""
    def __init__(self, children):
        assert isinstance(children, list)
        self.type = []
        self.children = children

    def sexpr(self):
        """return an s-expression representing this node"""
        s = []
        try:
            print self.children.__class__
            print self.children.type
        except:
            pass
        for child in self.children:
            s.append(make_sexpr(child))
        return s

    def myrepr(self):
        #print 'list node repr(), len =', len(self.children)
        
        if len(self.children) == 0:
            return 'list'
        elif len(self.children) == 1:
            return 'sidl.ListNode(' + repr(self.children[0]) + ')'
        else:
            r = 'sidl.ListNode('
            l = len(self.children)
            for i in range(0, l):
                if isinstance(self.children[i], AstNode):
                    r += self.children[i].myrepr()
                else:
                    r += repr(self.children[i])
                if (i < l-1):
                    r += ', '
        return r + ')'
        
    def __str__(self):
        #print 'list node str(), len =', len(self.children)
        
        if len(self.children) == 0:
            return ''
        elif len(self.children) == 1:
            return str(self.children[0])
        return reduce(lambda x, y: str(x)+', '+str(y), self.children)
   

class File(AstNode):
    def __init__(self, *children): 
        return AstNode.__init__(self, 'file', *children)
    def requires(): return children[0]
    def imports():  return children[1]
    def packages(): return children[2]

class Expression(AstNode):
    def __init__(self, *children): return AstNode.__init__(self, 'expression', *children)
    pass

class IfxExpression(Expression):
    """Base class for infix operators"""
    def __init__(self, *children): return AstNode.__init__(self, 'ifxexpr', *children)
    def __str__(self):
        return str(self.children[0]) + ' ' \
            + self.type + ' ' \
            + str(self.children[1])
    pass
