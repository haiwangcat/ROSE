# -*- python -*-
"""
File:
Package:
Revision:    @(#) $Id$
Description: A SIDL Class hierarchy

Copyright (c) 2010, Lawrence Livermore National Security, LLC
Produced at the Lawrence Livermore National Laboratory.
Written by the Components Team <components@llnl.gov>
UCRL-CODE-2002-054
All rights reserved.

This file is part of Babel. For more information, see
http://www.llnl.gov/CASC/components/. Please read the COPYRIGHT file
for Our Notice and the LICENSE file for the GNU Lesser General Public
License.

This program is free software; you can redistribute it and/or modify it
under the terms of the GNU Lesser General Public License (as published by
the Free Software Foundation) version 2.1 dated February 1999.

This program is distributed in the hope that it will be useful, but
WITHOUT ANY WARRANTY; without even the IMPLIED WARRANTY OF
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the terms and
conditions of the GNU Lesser General Public License for more details.

You should have recieved a copy of the GNU Lesser General Public License
along with this program; if not, write to the Free Software Foundation,
Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
"""

#             import pdb; pdb.set_trace()

def make_sexpr(child):
    """helper function for sexpr()"""
    if isinstance(child, AstNode):
        return child.sexpr()
    else:
#        print child
#        import pdb; pdb.set_trace()
        return child
        
class AstNode:
    """
    Base class. All other SIDL AST nodes should inherit from this one:
      * Calling str(astNode) will result in a human-readable version of the AST.

      * Calling repr(astNode) will return a Python-readable version of
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
        #print '@ ', self.type

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
    def __init__(self, children):
        self.type = []
        self.children = children
        assert(isinstance(self.children, list))

    def sexpr(self):
        """return an s-expression representing this node"""
        s = []
        #print self.children.__class__
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
    def __init__(self, *children): return AstNode.__init__(self, 'file', *children)
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
