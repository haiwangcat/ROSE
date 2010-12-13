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
# @matcher(globals()) def demo(sexpr):
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
# @matcher(globals()) def demo(sexpr):
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
# \li The underscore \c _ is treated as an anonymous variable.
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

import re, string

class Variable:
    """
    A logical variable for use with \c match and \c unify.
    """

    def __init__(self):
        self.binding = None

    def bind(self, value, bindings):
        """
        Bind the variable to a \c value and record the variable onto
        the trail stack \param bindings the trail stack.
        \param value     the new value for the variable.
        \param bindings  a mutable list of bindings
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

def member(a, l):
    """
    Match \c a against each member of the list \c l.

    This generator will yield subsequent bindings for each element in
    \c l that can be unified with \c a.

    \todo is this a good idea? do we want something more general?
    """
    bindings = []
    for b in l:
        if unify(a, b, bindings):
            yield True
            unbind(bindings)

def unbind(bindings):
    """
    Remove all variable bindings recorded in \c bindings.
    """
    for var in bindings:
        var.binding = None
    bindings = []

def unify(a, b, bindings):
    """
    A basic unification algorithm without occurs-check

    >>> A = Variable(); B = Variable(); unify(A, B, [])
    True
    >>> A = Variable(); _ = unify(A, 1, []); A.binding
    1
    >>> A = Variable(); _ = unify((1,A), (1,2), []); A.binding
    2
    >>> A = Variable(); unify((1,2), (A,A), [])
    False
    """
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

class matcher(object):
    """
    A decorator to perform the pattern matching transformation

    Usage: prefix a function definition with \c \@matcher(globals())
    """
    def __init__(self, glob, debug=False):
        """
        \param glob   the globals dictionary to use for global variables
                      used by the function (just pass \c globals())
        \param debug  if set to \c True: print the generated code to stdout
        """
        self.debug = debug
        self.glob = glob

    def __call__(self, f):
        fn = compile_matcher(f)
        if self.debug:
            n = 0
            for line in fn.split('\n'):
                n += 1
                print n, line
        # by using compile we can supply a filename, which results in
        # more readable backtraces
        exec(compile(fn, f.func_code.co_filename, 'exec'), self.glob, locals())
        exec('f = %s' % f.__name__)
        # modname = '%s_matcher' % f.__name__
        # sys.path.append('.')
        # exec('import %s' % modname)
        # exec('f = %s.%s' % (modname, f.__name__))
        return f

class Counter(object):
    """
    A simple counter. Work around the fact that Python functions
    cannot modify variables in parent scopes.
    """
    def __init__(self, value=0):
        self.n = value
    def inc(self):
        self.n += 1
    def read(self):
        return self.n

def compile_matcher(f):
    """
    Compile a function f with pattern matching into a regular Python function.
    \return None.

    The function is written to a file <f.__name__>_matcher.py
    \bug  not any more
    \todo rewrite this using the proper Python AST rewriting mechanisms
    """

    def indentlevel(s):
        if re.match(r'^\w*(#.*)?$', s):
            return -1
        return len(re.match(r'^ *', s).group(0))

    def scan_variables(rexpr):
        reserved_words = r'(False)|(True)|(None)|(NotImplemented)|(Ellipsis)'
        matches = re.findall(r'(^|\W)([_A-Z]\w*)($|[^\(])', rexpr)
        names = set([])
        for m in matches:
            var = m[1]
            if re.match(reserved_words, var):
                # ignore reserved words
                continue
            name = var
            if name[0] == '_':
                # Generate names for anonymous variables
                anonymous_vars.inc()
                name = '_G%d'%anonymous_vars.read()
                rexpr = string.replace(rexpr, var, name, 1)

            # Check against duplicates
            if var not in names:
                regalloc[-1].append(name)
                names.add(name)

        numregs[-1] = max(numregs[-1], len(names))
        return rexpr

    def depthstr(n):
        """generate unique register names for each nesting level"""
        if n == 0:
            return ""
        else: return chr(n+ord('a'))

    def append_line(line):
        num_lines.inc()
        dest.append(line[base_indent:])

    def insert_line(pos, line):
        num_lines.inc()
        dest.insert(pos, line[base_indent:])

    fc = f.func_code
    # access the original source code
    src = open(fc.co_filename, "r").readlines()

    # get the indentation level of the first nonempty line
    while True:
        base_indent = indentlevel(src[fc.co_firstlineno])
        if base_indent > -1:
            break

    # imports = ', '.join(
    #     filter(lambda s: s <> f.__name__, parse_globals(src, base_indent)))

    dest = []
    # assign a new function name
    # m = re.match(r'^def +([a-zA-Z_][a-zA-Z_0-9]*)(\(.*:) *$', dest[0])
    # funcname = m.group(1)
    # funcparms = m.group(2)
    dest.append("""
#!/usr/env python
# This file was automatically generated by the @matcher decorator. Do not edit.
# module %s_matcher
# from patmat import matcher, Variable, match
""" % f.__name__)

    # match line numbers with original source
    dest.append('\n'*(fc.co_firstlineno-5))
    num_lines = Counter(3) # number of elements in dest
    anonymous_vars = Counter(0) # number of anonymous variables
    append_line(src[fc.co_firstlineno])

    # stacks
    lexpr = [] # lhs expr of current match block
    numregs = [] # number of simulatneously live variables
    regalloc = [] # associating variables with registers
    withbegin = [] # beginning of current with block
    withindent = [] # indent level of current with block
    matchindent = [] # indent level of current match block
    patmat_prefix = ''
    for line in src[fc.co_firstlineno+1:]+['<<EOF>>']:
        # append_line('# %s:%s\n' % (fc.co_filename, n+fc.co_firstlineno))

        il = indentlevel(line)
        # check for empty/comment-only line (they mess with the indentation)
        if re.match(r'^(\w*#.*)*$', line):
            # make sure it still is a comment after shifting the line
            # to the left
            line = "#"*base_indent+line
            append_line(line)
            continue

        # leaving a with block
        while len(withindent) > 0 and il <= withindent[-1]:
            # insert registers declarations
            decls = []
            for i in range(0, numregs[-1]):
                decls.append('_reg%d = %sVariable()' % (i, patmat_prefix))

            # put all in one line, so we don't mess with the line numbering
            insert_line(withbegin[-1],
                        ' '*(withindent[-1]) + '; '.join(decls) + '\n')

            matchindent.pop()
            withindent.pop()
            withbegin.pop()
            regalloc.pop()
            numregs.pop()
            lexpr.pop()
            if len(withindent) <> len(matchindent):
                raise('**ERROR: %s:%d: missing if statement inside of if block'%
                    (fc.co_filename, fc.co_firstlineno+2+num_lines.read()))
            # ... repeat for all closing blocks

        # end of function definition
        if il <= base_indent:
            break

        # entering a with block
        m = re.match(r'^ +with +(patmat\.)?match\((.*)\) *: *$', line)
        if m:
            if m.group(1):
                patmat_prefix = m.group(1)
            lexpr.append(m.group(2))
            numregs.append(0)
            regalloc.append([])
            withindent.append(il)
            withbegin.append(num_lines.read()-1)
            line = ""

        # inside a matching rule
        if len(lexpr) > 0:
            skip_blanks = False
            # record the current indentation
            if len(withindent) <> len(matchindent):
                if re.match(r'^ *if', line):
                    matchindent.append(il)
                else:
                    skip_blanks = True

            if not skip_blanks:
                # remove one layer of indentation
                leftshift = matchindent[-1]-withindent[-1]
                line = line[leftshift:]
                matchind = matchindent[-1]-leftshift

                # match if() / elif()
                m = re.match(r'^('+' '*matchind+r')((el)?if) +(.*):(.*)$', line)

                if m:
                    rexpr = m.group(4)
                    regalloc[-1] = []
                    line = '%s%s %smatch(%s, %s):\n' \
                        % (m.group(1), m.group(2),
                           patmat_prefix,
                           lexpr[-1],
                           scan_variables(rexpr))
                    # allocate registers for variables
                    d = depthstr(len(lexpr)-1)
                    for i in range(0, len(regalloc[-1])):
                        line = re.sub(r'(\W|^)'+regalloc[-1][i]+r'(\W|$)',
                                      r'\1_reg%s%d\2' % (d, i),
                                      line)

                    # split off the part behind the ':' as new line
                    then = m.group(5)
                    if len(then) > 0:
                        append_line(line)
                        line = ' '*il+then+'\n'

        # every time
        if len(withbegin) > 0:
            # allocate registers for variables
            # ... can be done more efficiently
            j = 0
            for alloc in regalloc:
                d = depthstr(j)
                for i in range(0, len(alloc)):
                    line = line.replace(alloc[i], '_reg%s%d.binding' % (d, i))
                j += 1

        # copy the line to the output
        append_line(line)

    #modname = '%s_matcher' % f.__name__
    #f = open(modname+'.py', "w")
    buf = "".join(dest)
    #f.write(buf)
    #f.close()
    return buf
