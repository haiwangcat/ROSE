import re, sys

class Variable:
    'A variable for use with match()'
    def __init__(self):
        self.binding = None

    def bind(self, value, bindings):
        #print "binding", self, "to", value
        self.binding = value
        bindings.append(self)

    def unbind(self):
        #print "unbinding", self
        self.binding = None
        
    def free(self):
        return self.binding == None

    def __str__(self):
        if self.binding == None:
            return '_'
        else:
            return str(self.binding)

def match(a, b):
    return unify(a, b, [])

def unify(a, b, bindings):
    "a basic unification algorithm without occurs-check"
    
    def unbind():
        "remove all variable bindings in case of failure"
        for i in range(0,len(bindings)):
            bindings.pop().unbind()

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
                unbind()
                return False
            for i in range(0, len(a)):
                if not unify(a[i], b[i], bindings):
                    unbind()
                    return False
            return True
        else: # Atom
            unbind()
            return False
    else: # Atom
        if isinstance(b, tuple): # Term
            unbind()
            return False
        else: # Atom
            if a == b:
                return True
            else:
                unbind()
                return False
            

def matcher(f):
    "a decorator to perform the pattern matching transformation"

    compile_matcher(f)
    modname = '%s_matcher' % f.__name__
    sys.path.append('.')
    exec('import %s' % modname)
    exec('f = %s.%s' % (modname, f.__name__))
    return f

def compile_matcher(f):
    def indentlevel(s):
        if re.match(r'^ *$', s):
            return -1
        return len(re.match(r'^ *', s).group(0))

    def scan_variables(rexpr):
        matches = re.findall(r'([A-Z][a-zA-Z0-9]*)($|[^\(])', rexpr)

        for m in matches:
            regalloc[-1].append(m[0])
        numregs[-1] = max(numregs[-1], len(matches))

    def depthstr(n):
        if n == 0: return ""
        else: return chr(n+ord('a'))

    fc = f.func_code
    # access the original source code
    src = open(fc.co_filename, "r").readlines()
    f_indent = indentlevel(src[0])
    
    n = 0
    dest = []
    # assign a new function name
    # m = re.match(r'^def +([a-zA-Z_][a-zA-Z_0-9]*)(\(.*:) *$', dest[0])
    # print dest
    # funcname = m.group(1)
    # funcparms = m.group(2)
    dest.append("""
#!/usr/env python
# This file was automatically generated. Do not edit.
# module %s_matcher
import patmat
""" % f.__name__)
    dest.append(src[fc.co_firstlineno])

    # stacks
    lexpr = [] # lhs expr of current match block
    numregs = [] # number of simulatneously live variables
    regalloc = [] # associating variables with registers
    matchbegin = [] # beginning of current match block
    withindent = [] # indent level of current with block
    matchindent = [] # indent level of current match block
    for line in src[fc.co_firstlineno+1:]+['<<EOF>>']:
        n += 1
        # dest.append('# %s:%s\n' % (fc.co_filename, n+fc.co_firstlineno))

        # check for empty line
        il = indentlevel(line)
        if il < 0: 
            continue 

        # check for comment-only line
        if re.match(r'^( *#.*)$', line):
            continue

        # leaving a match block
        while len(matchindent) > 0 and il <= matchindent[-1]:
            # declare registers
            for i in range(numregs[-1], -1, -1):
                dest.insert(matchbegin[-1], ' '*(matchindent[-1]) \
                                + '_reg%d = patmat.Variable()\n' % i)
            matchindent.pop()
            withindent.pop()
            matchbegin.pop()
            regalloc.pop()
            numregs.pop()
            lexpr.pop()
            if len(withindent) <> len(matchindent):
                raise '**ERROR: %s:$d: missing if statement inside of if block' % \
                    (fc.co_filename. fc.co_firstlineno+2+n)
            # ... repeat for all closing blocks

        # end of function definition
        if il <= f_indent:
            break

        # entering a match block
        m = re.match(r'^ +with +match\((.*)\) *: *$', line)
        if m:
            lexpr.append(m.group(1))
            numregs.append(0)
            regalloc.append([])
            matchindent.append(il)
            matchbegin.append(n)
            line = ""
        
        # inside a matching rule
        if len(lexpr) > 0:
            skip = False
            # record the current indentation
            if len(withindent) <> len(matchindent):
                if re.match(r'^ *if', line):
                    withindent.append(il)
                else:
                    skip = True

            if not skip:
                # remove one layer of indentation
                newind = withindent[-1]-matchindent[-1]
                line = line[newind:]

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
                        dest.append(line)
                        line = ' '*il+then+'\n'

        # every time
        if len(matchbegin) > 0:
            # allocate registers for variables
            # ... can be done more efficiently
            j = 0
            for alloc in regalloc:
                print regalloc
                #trace()
                d = depthstr(j)
                for i in range(0,len(alloc)):
                    line = line.replace(alloc[i], '_reg%s%d.binding' % (d,i))
                j += 1

        dest.append(line)

    modname = '%s_matcher' % f.__name__    
    f = open(modname+'.py', "w")
    buf = "".join(dest)
    f.write(buf)
    f.close()

