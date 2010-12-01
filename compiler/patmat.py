#!/usr/bin/env python
# -*- python -*-
## @package patmat
#
# Pattern matching support for s-expressions in Python.
#
# This module augments Python with a pattern-matchng syntax which
# significantly reduces the amount of typing necessary to write sidl
# code generators.
#
# The functionality is implemented in 100% Python. To use pattern
# matching in a function, the function must use the \@matcher
# decorator.
#
# \subsection example Example
#
# \code
# @matcher def demo(sexpr):
#    with match(sexpr):
#        if ('first', Second):
#            print "found second:", Second
#        elif None:
#            print "found None"
#        elif A:
#            print "found other: ", A
#        else: raise # never reached
# \endcode
#
# The pattern matching block begins with the \code with match(expr):
# \endcode expression. In the enclosed block, the \c if and \c elif
# statements receive a new semantic, thich can be thought of a
# translation to the following form:
#
# \code
# @matcher def demo(sexpr):
#    Second = Variable()
#    A = Variable()
#    if match(sexpr, ('first', Second)):
#        print "found second:", Second.binding
#    elif match(sexpr, None):
#        print "found None"
#    elif match(sexpr, A):
#        print "found other: ", A.binding
#    else: raise # never reached
# \endcode
#
# \li All variables starting with upper case characters are treated as
#     free variables; this is following the conventions of
#     logic-oriented programming languages.
#
# \li \todo The underscore \c _ is treated as an anonymous variable.
#
# \li The first level of \c if and \c elif expressions under the \c
#     with \c match(expr): line are expanded to call the function \c
#     match(expr, ... .
#
# \li All occurences of upper case variables are replaced by
#     references to the values bound by those variables.
#
# \li These match blocks can be infinitely nested.
#
# This transformation is performed by the matcher decorator. The
# transformed version of the function can be compiled to a python
# source file an loaded at a later time if desired for performance
# reasons.
#
# Please report bugs to <adrian@llnl.gov>.
#
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
#                                                                           \n
import re, sys

class Variable:
    '''A logical variable for use with match()'''
    def __init__(self):
        self.binding = None

    def bind(self, value, bindings):
        """
        Bind the variable to a \c value and record the variable onto the trail stack
        \param bindings   the trail stack
        """
        #print "binding", self, "to", value
        self.binding = value
        bindings.append(self)

    def free(self):
        """
        Remove any binding of this variable
        """
        return self.binding == None

    def __str__(self):
        if self.binding == None:
            return '_'
        else:
            return str(self.binding)

def match(a, b):
    """
    Unify the expression \c a with the expression \c b.

    Although often conveniently used in the \c with \c match():
    syntax, this function can also be called directly. Note that match
    is commutative. \code match(a, b) == match(b, a) \endcode
    """
    return unify(a, b, [])

def unify(a, b, bindings):
    """a basic unification algorithm without occurs-check"""

    def unbind(bindings):
        """remove all variable bindings in case of failure"""
        for var in bindings:
            var.binding = None
        bindings = []

    if isinstance(a, Variable): # Variable
        if a.free():
            a.bind(b, bindings)
            return True
    if isinstance(b, Variable): # Variable
        if b.free():
            b.bind(a, bindings)
            return True
    elif isinstance(a, tuple): # Term
        if isinstance(b, tuple): # Term
            if len(a) != len(b):
                unbind(bindings)
                return False
            for i in range(0, len(a)):
                if not unify(a[i], b[i], bindings):
                    unbind(bindings)
                    return False
            return True
        else: # Atom
            unbind(bindings)
            return False
    else: # Atom
        if isinstance(b, tuple): # Term
            unbind(bindings)
            return False
        else: # Atom
            if a == b:
                return True
            else:
                unbind(bindings)
                return False


def matcher(f):
    """a decorator to perform the pattern matching transformation"""

    compile_matcher(f)
    modname = '%s_matcher' % f.__name__
    sys.path.append('.')
    exec('import %s' % modname)
    exec('f = %s.%s' % (modname, f.__name__))
    return f

def compile_matcher(f):
    """
    Compile a function f with pattern matching into a regular Python function.
    \return None. The function is written to a file <f.__name__>_matcher.py
    """

    def indentlevel(s):
        if re.match(r'^ *$', s):
            return -1
        return len(re.match(r'^ *', s).group(0))

    def scan_variables(rexpr):
        reserved_words = r'(False)|(True)|(None)|(NotImplemented)|(Ellipsis)'
        matches = re.findall(r'([A-Z][a-zA-Z0-9]*)($|[^\(])', rexpr)

        for m in matches:
            if not re.match(reserved_words, m[0]):
                regalloc[-1].append(m[0])
        numregs[-1] = max(numregs[-1], len(matches))

    def depthstr(n):
        if n == 0: return ""
        else: return chr(n+ord('a'))

    def copy_line():
        n += 1
        dest.append(line)

    fc = f.func_code
    # access the original source code
    src = open(fc.co_filename, "r").readlines()
    f_indent = indentlevel(src[0])

    dest = []
    # assign a new function name
    # m = re.match(r'^def +([a-zA-Z_][a-zA-Z_0-9]*)(\(.*:) *$', dest[0])
    # print dest
    # funcname = m.group(1)
    # funcparms = m.group(2)
    dest.append("""
#!/usr/env python
# This file was automatically generated by the @matcher decorator. Do not edit.
# module %s_matcher
import patmat
""" % f.__name__)
    dest.append(src[fc.co_firstlineno])

    n = 2 # number of lines
    # stacks
    lexpr = [] # lhs expr of current match block
    numregs = [] # number of simulatneously live variables
    regalloc = [] # associating variables with registers
    withbegin = [] # beginning of current with block
    withindent = [] # indent level of current with block
    matchindent = [] # indent level of current match block
    for line in src[fc.co_firstlineno+1:]+['<<EOF>>']:
        # dest.append('# %s:%s\n' % (fc.co_filename, n+fc.co_firstlineno))

        # check for empty line
        il = indentlevel(line)
        if il < 0:
            n += 1
            dest.append(line)
            continue

        # check for comment-only line (they mess with the indentation)
        if re.match(r'^( *#.*)$', line):
            n += 1
            dest.append(line)
            continue

        # leaving a with block
        while len(withindent) > 0 and il <= withindent[-1]:
            # insert registers declarations
            for i in range(numregs[-1], -1, -1):
                dest.insert(withbegin[-1], ' '*(withindent[-1])
                            + '_reg%d = patmat.Variable()\n' % i)
            matchindent.pop()
            withindent.pop()
            withbegin.pop()
            regalloc.pop()
            numregs.pop()
            lexpr.pop()
            if len(withindent) <> len(matchindent):
                raise('**ERROR: %s:$d: missing if statement inside of if block'%
                    (fc.co_filename. fc.co_firstlineno+2+n))
            # ... repeat for all closing blocks

        # end of function definition
        if il <= f_indent:
            break

        # entering a with block
        m = re.match(r'^ +with +match\((.*)\) *: *$', line)
        if m:
            lexpr.append(m.group(1))
            numregs.append(0)
            regalloc.append([])
            withindent.append(il)
            withbegin.append(n-1)
            line = ""

        # inside a matching rule
        if len(lexpr) > 0:
            skip = False
            # record the current indentation
            if len(withindent) <> len(matchindent):
                if re.match(r'^ *if', line):
                    matchindent.append(il)
                else:
                    skip = True

            if not skip:
                # remove one layer of indentation
                newind = matchindent[-1]-withindent[-1]
                line = line[newind:]

                # match if() / elif()
                m = re.match(r'^('+' '*newind+r')((el)?if) +(.*):(.*)$', line)

                if m:
                    rexpr = m.group(4)
                    regalloc[-1] = []
                    scan_variables(rexpr)
                    line = '%s%s patmat.match(%s, %s):\n' \
                        % (m.group(1), m.group(2), lexpr[-1], rexpr)
                    # allocate registers for variables
                    d = depthstr(len(lexpr)-1)
                    for i in range(0,len(regalloc[-1])):
                        line = line.replace(regalloc[-1][i], '_reg%s%d' % (d,i))

                    # split off the part behind the ':' as new line
                    then = m.group(5)
                    if len(then) > 0:
                        n += 1
                        dest.append(line)
                        line = ' '*il+then+'\n'

        # every time
        if len(withbegin) > 0:
            # allocate registers for variables
            # ... can be done more efficiently
            j = 0
            for alloc in regalloc:
                d = depthstr(j)
                for i in range(0,len(alloc)):
                    line = line.replace(alloc[i], '_reg%s%d.binding' % (d,i))
                j += 1

        # copy the line to the output
        n += 1
        dest.append(line)

    modname = '%s_matcher' % f.__name__
    f = open(modname+'.py', "w")
    buf = "".join(dest)
    f.write(buf)
    f.close()

