#!/usr/bin/env python
# -*- python -*-
## @package sidl
#
# A SIDL class hierarchy
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

import ir
#             import pdb; pdb.set_trace()

def make_sexp(child):
    """helper function for sexp()"""
    if isinstance(child, AstNode):
        return child.sexp()
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
    def __init__(self, typ, *children):
        #print 'new', type, '(', str(children), ')'
        self.type = typ
        self.children = children

    def __repr__(self):
        return self.myrepr()

    def sexp(self):
        """return an s-expression representing this node"""
        #print '@', self.type

        s = [self.type]
        for child in self.children:
            s.append(make_sexp(child))
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

    def sexp(self):
        """return an s-expression representing this node"""
        s = []
        # try:
        #     print self.children.__class__
        #     print self.children.type
        # except:
        #     pass
        for child in self.children:
            s.append(make_sexp(child))
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
        AstNode.__init__(self, ir.file_, *children)
    def requires(self): return self.hildren[0]
    def imports(self):  return self.hildren[1]
    def packages(self): return self.hildren[2]

class Expression(AstNode):
    def __init__(self, *children):
        AstNode.__init__(self, ir.expr, *children)

class IfxExpression(Expression):
    """Base class for infix operators"""
    def __init__(self, *children):
        AstNode.__init__(self, ir.expr, *children)

    def __str__(self):
        return str(self.children[0]) + ' ' \
            + self.type + ' ' \
            + str(self.children[1])
