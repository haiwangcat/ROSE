#!/usr/bin/env python
# -*- python -*-
## @package codegen
# Several code generators.
#
# General design principles (a.k.a. lessons learned from Babel code generators
#
# * It is ok to duplicate code if it increases locality and thus
#   improves readability
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
from patmat import matcher, Variable, match, member

def generate(language, ir_code):
    """
    Call the appropriate generate() function.  

    \param language One of
    \c ["C", "CXX", "F77", "F90", "F03", "Python", "Java"]
    
    \param ir_code  Intermediate representation input.
    \return         string
    """
    # apparently CPython does not implement proper tail recursion
    import sys
    sys.setrecursionlimit(max(sys.getrecursionlimit(), 2**16))

    try:
        if language == "C": 
            return str(CCodeGenerator().generate(ir_code, CFile()))

        elif language == "CXX": 
            return str(CXXCodeGenerator().generate(ir_code, CXXFile()))

        elif language == "F77": 
            return str(Fortran77CodeGenerator().generate(ir_code, F77File()))

        elif language == "F90": 
            return str(Fortran90CodeGenerator().generate(ir_code, F90File()))

        elif language == "F03": 
            return str(Fortran03CodeGenerator().generate(ir_code, F03File()))

        elif language == "Python": 
            return str(PythonCodeGenerator().generate(ir_code, PythonFile()))

        elif language == "Java": 
            return str(JavaCodeGenerator().generate(ir_code, JavaFile()))

        elif language == "SIDL": 
            return str(SIDLCodeGenerator().generate(ir_code, SIDLFile()))

        else: raise Exception("unknown language")
    except:
        # Invoke the post-mortem debugger
        import pdb, sys
        print sys.exc_info()
        pdb.post_mortem()



class Scope(object):
    """
    we need at least stmt, block, function, module

    <pre>
    +--------------------+     +-----------------------------------+
    | header             |  +  | defs                              |
    +--------------------+     +-----------------------------------+
    </pre>
    """
    def __init__(self, parent=None, 
                 relative_indent=0, indent_level=0, separator='\n'):
        """
        \param parent         The enclosing scope.
        \param relative_indent The amount of indentation relative to
                              the enclosing scope.

        \param indent_level   This is the level of indentation used by
                              this \c Scope object. The \c
                              indent_level is constant for each \c
                              Scope object. If you want to change the
                              indentation, the idea is to create a
                              child \Scope object with a different
                              indentation.


        \param separator      This string will be inserted between every
                              two definitions.
        """
        self.parent = parent
        self._header = []
        self._defs = []
        self._pre_defs = []
        self._post_defs = []
        self.relative_indent = relative_indent
        self.indent_level = indent_level
        self._sep = separator+' '*indent_level

    def has_declaration_section(self):
        """
        \return whether this scope has a section for variable declarations.
        """
        return False

    def new_header_def(self, s):
        """
        append definition \c s to the header of the scope
        """
        self._header.append(s)

    def new_def(self, s):
        """
        Append definition \c s to the scope. Also adds anything
        previously recorded by \c pre_def or \c post_def.  For
        convenience reasons it returns \c self, see the code
        generators on examples why this is useful

        \return \c self
        """
        #print 'new_def', s
        self._defs.extend(self._pre_defs)
        self._defs.append(str(s))
        self._defs.extend(self._post_defs)
        self._pre_defs = []
        self._post_defs = []
        return self

    def pre_def(self, s):
        """
        Record a definition \c s to be added to \c defs before the
        next call of \c new_def.
        """
        self._pre_defs.append(s)

    def post_def(self, s):
        """
        Record a definition \c s to be added to \c defs after the
        next call of \c new_def.
        """
        self._post_defs.append(s)

    def get_defs(self):
        """
        return a list of all definitions in the scope
        """
        return self._header+self._defs

    def __str__(self):
        """
        Perform the actual translation into a readable string,
        complete with indentation and newlines.
        """
        #print self._header, '+', self._defs, 'sep="',self._sep,'"'
        #import pdb; pdb.set_trace()
        return (' '*self.relative_indent +
                self._sep.join(self._header) +
                self._sep.join(self._defs))

class SourceFile(Scope):
    """
    This class represents a generic source file
    """
    def __init__(self, parent=None, relative_indent=0, indent_level=0):
        super(SourceFile, self).__init__(
            parent, relative_indent, indent_level, separator='\n')

    def has_declaration_section(self):
        return True

    def __str__(self):
        """
        Perform the actual translation into a readable string,
        complete with indentation and newlines.
        """
        #print self._header, '+', self._defs, 'sep="',self._sep,'"'
        #import pdb; pdb.set_trace()
        return (' '*self.relative_indent+
                ('\n'+' '*self.relative_indent).join([
                    self._sep.join(self._header),
                    self._sep.join(self._defs)])+self._sep)


class Function(Scope):
    """
    This class represents a function/procedure
    """
    def has_declaration_section(self):
        return True

class GenericCodeGenerator(object):

    @matcher(globals(), debug=False)
    def generate(self, node, scope=SourceFile()):
        """
        Language-independent generator rules

        \param node       s-expression-based intermediate representation (input)
        \param scope      the \c Scope object the output will be written to
        \return           a string containing the expression for \c node
        """
        def gen(node):
            return self.generate(node, scope)

        with match(node):
            if (ir.stmt, Expr):
                return scope.new_def(gen(Expr))

            elif (ir.identifier, Name): return Name
            elif (ir.value, Value):     return gen(Value)
            elif (Op, A, B): return ' '.join((gen(A), gen(Op), gen(B)))
            elif (Op, A):    return ' '.join(        (gen(Op), gen(A)))
            elif (A):        
                if (isinstance(A, list)):
                    for defn in A:
                        gen(defn)
                    return scope
                else:
                    return str(A)
            else: raise Exception("match error: "+node.str())

    def get_type(self, node):
        """
        \return a string with the type of the IR node \c node.
        """
        import pdb; pdb.set_trace()
        return "sFIXME "+str(node)

    def get_item_type(self, struct, item):
        """
        \return the type of the item named \c item
        """
        _, (_, _, _, items), _ = struct
        Type = Variable()
        for _ in member((ir.struct_item, Type, item), items):
            return Type.binding
        raise Exception("Struct has no member "+item)

# ----------------------------------------------------------------------
# C      FORTRAN 77
# ----------------------------------------------------------------------
class F77File(SourceFile):
    """
    This class represents a Fortran 77 source file
    """
    def __init__(self, parent=None, relative_indent=0):
        super(F77File, self).__init__(
            parent=parent,
            relative_indent=relative_indent,
            indent_level=0)
        self.label = 0

    def new_def(self, s, indent=0):
        """
        Append definition \c s to the scope
        \return  \c self
        """
        # split long lines
        tokens = s.split()
        line = ' '*(self.relative_indent+indent)
        while len(tokens) > 0: 
            while (len(tokens) > 0 and 
                   len(line)+len(tokens[0]) < 62):
                line += tokens.pop(0)+' '
            super(F77File, self).new_def(line)
            line = '&' # continuation character
        return self

    def new_label(self):
        """
        Create a new label before the current definition.
        """
        self.label += 10
        l = self.label
        self.pre_def('@%3d'%l)
        return l

    def __str__(self):
        """
        Perform the actual translation into a readable string,
        complete with indentation and newlines.
        """
        #print self._header, '+', self._defs, 'sep="',self._sep,'"'
        #import pdb; pdb.set_trace()        
        data = ''
        label = False
        for defn in self.get_defs():
            if label: 
                label = False
                data += defn+'\n'            
            elif defn[0] == '&': data += '     &      '+defn[1:]+'\n'
            elif defn[0] == '@':       
                   label = True; data += ' %s    '% defn[1:]
            else:                data += '        '+defn+'\n'

        return data

class F77Scope(F77File):
    """Represents a list of statements in an indented block"""
    def __init__(self, parent):
        super(F77Scope, self).__init__(
            parent,
            relative_indent=parent.relative_indent+2)
        self._defs = [''] # start on a new line
    
    def has_declaration_section(self):
        return False

class Fortran77CodeGenerator(GenericCodeGenerator):
    @matcher(globals(), debug=False)
    def get_type(self, node):
        """\return a string with the type of the IR node \c node."""
        with match(node):
            if ('struct', (ir.identifier, Package), (ir.identifier, Name), _): 
                return ("%s_%s"%(Package, Name)).lower()
            elif ('void'):        return "void"
            elif ('bool'):        return "logical"
            elif ('character'):   return "character"
            elif ('dcomplex'):    return "double complex"
            elif ('double'):      return "double precision"
            elif ('fcomplex'):    return "complex"
            elif ('float'):       return "real"
            elif ('int'):         return "integer*4"
            elif ('long'):        return "integer*8"
            elif ('opaque'):      return "integer*8"
            elif ('string'):      return "character*256"
            elif ('enum'):        return "integer*8"
            elif ('struct'):      return "integer*8"
            elif ('class'):       return "integer*8"
            elif ('interface'):   return "integer*8"
            elif ('package'):     return "void"
            elif ('symbol'):      return "integer*8"
            else: return super(Fortran77CodeGenerator, self).get_type(node)

    @matcher(globals(), debug=False)
    def generate(self, node, scope):
        """
        Fortran 77 code generator

        \param node         sexp-based intermediate representation (input)
        \param scope  the Scope object the output will be written to
        """
        # recursion
        def gen(node):
            return self.generate(node, scope)

        def declare_var(typ, name):
            """
            add a declaration for a variable to the innermost scope if
            such a declaration is not already there
            """
            s = scope
            while not s.has_declaration_section():
                s = s.parent
            decl = self.get_type(typ)+' '+gen(name)
            if list(member(decl, s._header)) == []:
                s.new_header_def(decl)

        def new_def(s):
            # print "new_def", s
            return scope.new_def(s)

        def pre_def(s):
            # print "pre_def", s
            return scope.pre_def(s)

        def new_scope(prefix, body, suffix=''):
            '''used for things like if, for, ...'''
            s = F77Scope(parent=scope)
            new_def(prefix)
            self.generate(body, s)
            # copy all defs into the F77File which takes care of the
            # F77's weird indentation rules
            # FIXME get rid of these side effects.. this is just asking for trouble
            for defn in s.get_defs():
                scope.new_def(defn, s.relative_indent)
            new_def(suffix)
            return scope

        with match(node):
            if ('return', Expr):
                return "retval = %s" % gen(Expr)

            elif (ir.get_struct_item, Struct, Name, Item):
                tmp = 'tmp_%s_%s'%(gen(Name), gen(Item))
                declare_var(self.get_item_type(Struct, Item), tmp)
                _, type_, _ = Struct
                pre_def('call %s_get_%s_f(%s, %s)' % (
                        gen(self.get_type(type_)), gen(Item), gen(Name), tmp))
                return tmp

            elif (ir.set_struct_item, (_, Struct, _), Name, Item, Value):
                return 'call %s_set_%s_f(%s, %s)' % (
                    gen(self.get_type(Struct)), gen(Item), gen(Name), gen(Value))

            elif (ir.function, ir.void, Name, Attrs, Args, Excepts, From, Requires, Ensures, Body):
                return new_def('''
                subroutine %s
                  %s
                  %s
                end subroutine %s
                ''' % (Name, gen(Args),
                       gen(FunctionScope(scope), Body), Name))

            elif (ir.function, Typ, Name, Attrs, Args, Excepts, Froms, Requires, Ensures):
                return new_def('''
                subroutine %s
                  %s
                  %s,
                  retval
                end function %s
            ''' % (Typ, Name, gen(Args),
                   gen(FunctionScope(scope), Body), Name))

            elif (ir.do_while, Condition, Body):
                label = scope.new_label()
                gen(Body)
                return new_scope('if (%s) then'%gen(Condition), 
                                      (ir.stmt, (ir.goto, str(label))), 
                                      'end if')

            elif (ir.if_, Condition, Body):
                return new_scope('if (%s) then'%gen(Condition), Body, 'end if')

            elif (ir.decl, (ir.type_, Type), Name): declare_var(Type, gen(Name))
            elif (ir.goto, Label):    return 'goto '+Label
            elif (ir.assignment):     return '='
            elif (ir.eq):             return '.eq.'
            elif (ir.true):           return '.true.'
            elif (ir.false):          return '.false.'
            elif ((ir.literal, Lit)): return "'%s'"%Lit
            elif (Expr):
                return super(Fortran77CodeGenerator, self).generate(Expr, scope)

            else: raise Exception("match error")

# ----------------------------------------------------------------------
# Fortran 90
# ----------------------------------------------------------------------
class F90File(SourceFile):
    """
    This class represents a Fortran 90 source file
    """
    def __init__(self,parent=None,relative_indent=2, indent_level=2):
        super(F90File, self).__init__(parent,relative_indent,indent_level)

    def new_def(self, s, indent=0):
        """
        Append definition \c s to the scope
        \return  \c self
        """
        # split long lines
        tokens = s.split()
        while len(tokens) > 0: 
            line = ' '*(self.relative_indent+indent)
            while (len(tokens) > 0 and 
                   len(line)+len(tokens[0]) < 62):
                line += tokens.pop(0)+' '
            
            if len(tokens) > 0:
                line += '&'
            super(F90File, self).new_def(line)
        return self


    def __str__(self):
        """
        Perform the actual translation into a readable string,
        complete with indentation and newlines.
        """
        return '\n'.join(self._header+self._defs)+'\n'

class F90Scope(F90File):
    """Represents a list of statements in an indented block"""
    def __init__(self, parent):
        super(F90Scope, self).__init__(
            parent,
            relative_indent=parent.relative_indent+2)
        self._defs = [''] # start on a new line
    
    def has_declaration_section(self):
        return False

class Fortran90CodeGenerator(GenericCodeGenerator):
    """
    Fortran 90 code generator
    """
    @matcher(globals(), debug=False)
    def get_type(self, node):
        """\return a string with the type of the IR node \c node."""
        with match(node):
            if ('struct', Type, _): return Type
            elif ('void'):        return "void"
            elif ('bool'):        return "logical"
            elif ('character'):   return "character (len=1)"
            elif ('dcomplex'):    return "complex (kind=sidl_dcomplex)"
            elif ('double'):      return "real (kind=sidl_double)"
            elif ('fcomplex'):    return "complex (kind=sidl_fcomplex)"
            elif ('float'):       return "real (kind=sidl_float)"
            elif ('int'):         return "integer (kind=sidl_int)"
            elif ('long'):        return "integer (kind=sidl_long)"
            elif ('opaque'):      return "integer (kind=sidl_opaque)"
            elif ('string'):      return "character (len=*)"
            elif ('enum'):        return "integer (kind=sidl_enum)"
            elif ('struct'):      return ""
            elif ('class'):       return ""
            elif ('interface'):   return ""
            elif ('package'):     return ""
            elif ('symbol'):      return ""
            else: return super(Fortran90CodeGenerator, self).get_type(node)

    @matcher(globals(), debug=False)
    def generate(self, node, scope=F90File()):
        # recursion
        def gen(node):
            return self.generate(node, scope)

        def declare_var(typ, name):
            s = scope
            while not s.has_declaration_section():
                s = s.parent
            s.new_header_def(self.get_type(typ)+' '+gen(name))

        def new_scope(prefix, body, suffix=''):
            '''used for things like if, for, ...'''
            s = F90Scope(parent=scope)
            new_def(prefix)
            self.generate(body, s)
            # copy all defs into the F90File which takes care of the
            # F90's weird indentation rules
            # FIXME! should really be the file! not scope (messes with
            # indentation otherwise)
            for defn in s.get_defs():
                scope.new_def(defn, s.relative_indent)
            new_def(suffix)
            return scope

        def new_def(s):
            # print "new_def", s
            return scope.new_def(s)

        def pre_def(s):
            # print "pre_def", s
            return scope.pre_def(s)

        with match(node):
            if (ir.stmt, Expr):
                return scope.new_def(gen(Expr)+'\n')

            if ('return', Expr):
                return "retval = %s" % gen(Expr)

            elif (ir.get_struct_item, _, Name, Item):
                return gen(Name)+'%'+gen(Item)

            elif (ir.set_struct_item, _, Name, Item, Value):
                return gen(Name)+'%'+gen(Item)+' = '+gen(Value)

            elif (ir.function, ir.void, Name, Attrs, Args, Excepts, Froms, Requires, Ensures, Body):
                return '''
                subroutine %s
                  %s
                  %s
                end subroutine %s
                ''' % (Name, gen(Args), gen(Body), Name)

            elif (ir.function, Typ, Name, Attrs, Args, Excepts, Froms, Requires, Ensures):
                return '''
                function %s
                  %s
                  %s
                end function %s
            ''' % (Typ, Name, gen(Args), gen(Body), Name)
            elif (ir.do_while, Condition, Body):
                new_scope('do', Body, '  if (.not.%s) exit'%gen(Condition))
                new_def('end do')
                return scope
            elif (ir.if_, Condition, Body):
                return new_scope('if (%s) then'%gen(Condition), Body, 'end if')
            elif (ir.decl, (ir.type_, Type), Name): declare_var(Type, gen(Name))
            elif (ir.assignment):     return '='
            elif (ir.eq):             return '.eq.'
            elif (ir.true):           return '.true.'
            elif (ir.false):          return '.false.'
            elif ((ir.literal, Lit)): return "'%s'"%Lit
            elif (Expr):
                return super(Fortran90CodeGenerator, self).generate(Expr, scope)

            else: raise Exception("match error")

# ----------------------------------------------------------------------
# Fortran 2003
# ----------------------------------------------------------------------
class F03File(F90File):
    """
    This class represents a Fortran 03 source file
    """
    def __init__(self):
        super(F03File, self).__init__(relative_indent=4,indent_level=2)

class Fortran03CodeGenerator(Fortran90CodeGenerator):
    """
    Fortran 2003 code generator
    """
    @matcher(globals(), debug=False)
    def get_type(self, node):
        """\return a string with the type of the IR node \c node."""
        with match(node):
            if ('struct', Type, _): return Type
            elif ('void'):        return "void"
            elif ('bool'):        return "logical"
            elif ('character'):   return "character (len=1)"
            elif ('dcomplex'):    return "complex (kind=sidl_dcomplex)"
            elif ('double'):      return "real (kind=sidl_double)"
            elif ('fcomplex'):    return "complex (kind=sidl_fcomplex)"
            elif ('float'):       return "real (kind=sidl_float)"
            elif ('int'):         return "integer (kind=sidl_int)"
            elif ('long'):        return "integer (kind=sidl_long)"
            elif ('opaque'):      return "integer (kind=sidl_opaque)"
            elif ('string'):      return "character (len=*)"
            elif ('enum'):        return "integer (kind=sidl_enum)"
            elif ('struct'):      return ""
            elif ('class'):       return ""
            elif ('interface'):   return ""
            elif ('package'):     return ""
            elif ('symbol'):      return ""
            else: return super(Fortran03CodeGenerator, self).get_type(node)

    """
    Struct members: These types do not need to be accessed via a function call.
    """
    struct_direct_access = ['dcomplex', 'double', 'fcomplex', 'float', 
                            'int', 'long', 'enum']

    @matcher(globals(), debug=False)
    def generate(self, node, scope=F03File()):
        # recursion
        def gen(node):
            return self.generate(node, scope)

        def declare_var(typ, name):
            s = scope
            while not s.has_declaration_section():
                s = s.parent
            s.new_header_def(self.get_type(typ)+' '+gen(name))

        def new_def(s):
            # print "new_def", s
            return scope.new_def(s)

        def pre_def(s):
            # print "pre_def", s
            return scope.pre_def(s)

        with match(node):
            if ('return', Expr):
                return "retval = %s" % gen(Expr)

            elif (ir.get_struct_item, Struct, Name, Item):
                t = self.get_item_type(Struct, Item)
                if t in self.struct_direct_access:
                    return gen(Name)+'%'+gen(Item)
                else:
                    return 'get_'+gen(Item)+'('+gen(Name)+')'

            elif (ir.set_struct_item, Struct, Name, Item, Value):
                t = self.get_item_type(Struct, Item)
                if t in self.struct_direct_access:
                    return gen(Name)+'%'+gen(Item)+" = "+gen(Value)
                else:
                    return 'call set_%s(%s, %s)'%(gen(Item), gen(Name), gen(Value))

            elif (ir.function, ir.void, Name, Attrs, Args, Excepts, Froms, Requires, Ensures, Body):
                return '''
                subroutine %s
                  %s
                  %s
                end subroutine %s
                ''' % (Name, gen(Args), gen(Body), Name)

            elif (ir.function, Typ, Name, Attrs, Args, Excepts, Froms, Requires, Ensures):
                return '''
                function %s
                  %s
                  %s
                end function %s
            ''' % (Typ, Name, gen(Args), gen(Body), Name)
            elif (ir.decl, (ir.type_, Type), Name): declare_var(Type, gen(Name))
            elif (ir.true):           return '.true.'
            elif (ir.false):          return '.false.'
            elif ((ir.literal, Lit)): return "'%s'"%Lit
            elif (Expr):
                return super(Fortran03CodeGenerator, self).generate(Expr, scope)

            else: raise Exception("match error")

# ----------------------------------------------------------------------
# C
# ----------------------------------------------------------------------
class CFile(SourceFile):
    """
    This class represents a C source file
    """
    def __init__(self):
        #FIXME should be 0 see java comment
        super(CFile, self).__init__(indent_level=2)
    
class CCompoundStmt(Scope):
    """Represents a list of statements enclosed in braces {}"""
    def __init__(self, parent_scope):
        super(CCompoundStmt, self).__init__(
            parent_scope,
            indent_level=parent_scope.indent_level+2, 
            separator='\n')
    def __str__(self):
        return (' {\n'
                + ' '*self.indent_level 
                + super(CCompoundStmt, self).__str__() +'\n'
                + ' '*(self.indent_level-2) + '}')
    
class ClikeCodeGenerator(GenericCodeGenerator):
    """
    C-like code generator
    """

    @matcher(globals(), debug=False)
    def generate(self, node, scope=CFile()):
        # recursion
        def gen(node):
            return self.generate(node, scope)

        def new_def(s):
            #print 'new_def:', str(s)
            #import pdb; pdb.set_trace()
            return scope.new_def(s)

        def new_scope(prefix, body, suffix='\n'):
            '''used for things like if, while, ...'''
            comp_stmt = CCompoundStmt(scope)
            return new_def(prefix+str(self.generate(body, comp_stmt))+suffix)

        def declare_var(typ, name):
            '''unless, of course, var were declared'''
            s = scope
            while not s.has_declaration_section():
                s = s.parent
            s.new_header_def(self.get_type(typ)+' '+gen(name)+';')

        with match(node):
            if (ir.stmt, Expr):
                return new_def(gen(Expr)+';')
            elif ('return', Expr):
                return "return %s" % gen(Expr)
            elif (ir.do_while, Condition, Body):
                return new_scope('do', Body, ' while (%s);'%gen(Condition))
            elif (ir.if_, Condition, Body):
                return new_scope('if (%s)'%gen(Condition), Body)
            elif (ir.decl, (ir.type_, Type), Name): declare_var(Type, gen(Name))
            elif (ir.not_):           return '!'
            elif (ir.assignment):     return '='
            elif (ir.eq):             return '=='
            elif (ir.true):           return 'TRUE'
            elif (ir.false):          return 'FALSE'
            elif ((ir.literal, Lit)): return '"%s"'%Lit
            elif (Expr):
                return super(ClikeCodeGenerator, self).generate(Expr, scope)
            else: raise Exception("match error")

class CCodeGenerator(ClikeCodeGenerator):
    """
    C code generator
    """
    @matcher(globals(), debug=False)
    def get_type(self, node):
        """\return a string with the type of the IR node \c node."""
        with match(node):
            if ('struct', Type, _): return Type
            elif ('void'):        return "void"
            elif ('bool'):        return "int"
            elif ('character'):   return "char"
            elif ('dcomplex'):    return ""
            elif ('double'):      return "double"
            elif ('fcomplex'):    return ""
            elif ('float'):       return "float"
            elif ('int'):         return "int"
            elif ('long'):        return "long"
            elif ('opaque'):      return "void*"
            elif ('string'):      return "char*"
            elif ('enum'):        return "enum"
            elif ('struct'):      return "struct"
            elif ('class'):       return ""
            elif ('interface'):   return ""
            elif ('package'):     return ""
            elif ('symbol'):      return ""
            else: return super(CCodeGenerator, self).get_type(node)

    @matcher(globals(), debug=False)
    def generate(self, node, scope=CFile()):
        # recursion
        def gen(node):
            return self.generate(node, scope)

        def new_def(s):
            # print "new_def", s
            return scope.new_def(s)

        def pre_def(s):
            # print "pre_def", s
            return scope.pre_def(s)

        with match(node):
            if (ir.function, Typ, Name, Attrs, Args, Excepts, Froms, Requires, Ensures):
                return '''
                %s %s(%s) {
                  %s
                }
            ''' % (Typ, Name, pretty(Args), gen(Body))
            elif (ir.get_struct_item, _, StructName, Item):
                return gen(StructName)+'->'+gen(Item)

            elif (ir.set_struct_item, _, StructName, Item, Value):
                return gen(StructName)+'->'+gen(Item)+' = '+gen(Value)
            elif (Expr):
                return super(CCodeGenerator, self).generate(Expr, scope)
            else: raise Exception("match error")


# ----------------------------------------------------------------------
# C++
# ----------------------------------------------------------------------
class CXXFile(CFile):
    """
    This class represents a C source file
    """
    def __init__(self):
        super(CXXFile, self).__init__()
    pass

class CXXCodeGenerator(CCodeGenerator):
    """
    C++ code generator
    """
    @matcher(globals(), debug=False)
    def get_type(self, node):
        """\return a string with the type of the IR node \c node."""
        return super(CXXCodeGenerator, self).get_type(node)

    @matcher(globals(), debug=False)
    def generate(self, node, scope=CXXFile()):
        # recursion
        def gen(node):
            return self.generate(node, scope)

        def new_def(s):
            # print "new_def", s
            return scope.new_def(s)

        def pre_def(s):
            # print "pre_def", s
            return scope.pre_def(s)

        with match(node):
            if (ir.function, Typ, Name, Attrs, Args, Excepts, Froms, Requires, Ensures):
                return '''
                %s %s(%s) {
                  %s
                }
            ''' % (Typ, Name, pretty(Args), gen(Body))

            elif (ir.get_struct_item, _, StructName, Item):
                return gen(StructName)+'.'+gen(Item)

            elif (ir.set_struct_item, _, StructName, Item, Value):
                return gen(StructName)+'.'+gen(Item)+' = '+gen(Value)

            elif (Expr):
                return super(CXXCodeGenerator, self).generate(Expr, scope)
            else: raise Exception("match error")

# ----------------------------------------------------------------------
# Java
# ----------------------------------------------------------------------
class JavaFile(SourceFile):
    """
    This class represents a Java source file
    """
    def __init__(self):
        #FIXME: file sould be 0 and there should be a class and package scope
        super(JavaFile, self).__init__(indent_level=4) 

class JavaCodeGenerator(ClikeCodeGenerator):
    """
    Java code generator
    """
    @matcher(globals(), debug=False)
    def get_type(self, node):
        """\return a string with the type of the IR node \c node."""
        with match(node):
            if ('struct', Package, Type, _): 
                return self.generate(Package)+'.'+self.generate(Type)
            elif ('void'):        return "void"
            elif ('bool'):        return "boolean"
            elif ('character'):   return "char"
            elif ('dcomplex'):    return ""
            elif ('double'):      return "double"
            elif ('fcomplex'):    return ""
            elif ('float'):       return "float"
            elif ('int'):         return "int"
            elif ('long'):        return "long"
            elif ('opaque'):      return ""
            elif ('string'):      return "String"
            elif ('enum'):        return "enum"
            elif ('struct'):      return "struct"
            elif ('class'):       return ""
            elif ('interface'):   return ""
            elif ('package'):     return ""
            elif ('symbol'):      return ""
            else: return super(JavaCodeGenerator, self).get_type(node)

    @matcher(globals(), debug=False)
    def generate(self, node, scope=JavaFile()):
        # recursion
        def gen(node):
            return self.generate(node, scope)

        def new_def(s):
            # print "new_def", s
            return scope.new_def(s)

        def pre_def(s):
            # print "pre_def", s
            return scope.pre_def(s)

        def get_function_scope():
            s = scope
            while s.parent != None:
                s = s.parent
            return s

        def deref((arg, struct, mode), structname):
            'dereference the holder object for inout and out arguments'
            if mode == ir.in_: 
                return gen(structname)
            else:
                s = get_function_scope()
                tmp = '_held_'+gen(structname)
                decl = '%s %s = %s.get();'%(
                    self.get_type(struct), tmp, gen(structname))
                if list(member(decl, s._header)) == []:
                    s.new_header_def(decl)
                return tmp

        with match(node):
            if (ir.function, Typ, Name, Attrs, Args, Excepts, Froms, Requires, Ensures):
                return '''
                %s %s(%s) {
                  %s
                }
            ''' % (Typ, Name, pretty(Args), gen(Body))

            elif (ir.get_struct_item, Type, StructName, Item):
                return deref(Type, StructName)+'.'+gen(Item)

            elif (ir.set_struct_item, Type, StructName, Item, Value):
                return deref(Type, StructName)+'.'+gen(Item)+' = '+gen(Value)

            elif (ir.true):           return 'true'
            elif (ir.false):          return 'false'
            elif (Expr):
                return super(JavaCodeGenerator, self).generate(Expr, scope)
            else: raise Exception("match error")

# ----------------------------------------------------------------------
# Python
# ----------------------------------------------------------------------
class PythonFile(SourceFile):
    """
    This class represents a Python source file
    """
    def __init__(self, parent=None, indent_level=4):
        super(PythonFile, self).__init__(parent, indent_level=indent_level)

    def __str__(self):
        """
        Perform the actual translation into a readable string,
        complete with indentation and newlines.
        """
        return ' '*self.indent_level+(
            '\n'+' '*self.indent_level).join(self._header+self._defs)+'\n'

class PythonIndentedBlock(PythonFile):
    """Represents an indented block of statements"""
    def __init__(self, parent_scope):
        super(PythonIndentedBlock, self).__init__(
            parent_scope,
            indent_level=parent_scope.indent_level+4)
    def __str__(self):
        return (':\n'+
                super(PythonIndentedBlock, self).__str__())


class PythonCodeGenerator(GenericCodeGenerator):
    """
    Python code generator
    """
    @matcher(globals(), debug=False)
    def generate(self, node, scope=PythonFile()):
        # recursion
        def gen(node):
            return self.generate(node, scope)

        def new_def(s):
            # print "new_def", s
            return scope.new_def(s)

        def pre_def(s):
            # print "pre_def", s
            return scope.pre_def(s)

        def new_block(prefix, body, suffix='\n'):
            '''used for things like if, while, ...'''
            block = PythonIndentedBlock(scope)
            return new_def(prefix+
                           str(self.generate(body, block))+
                           suffix)

        with match(node):
            if (ir.function, Typ, Name, Attrs, Args, Excepts, Froms, Requires, Ensures):
                return '''
                def %s(%s):
                  %s
            ''' % (Name, gen(Args), gen(Body))
            elif ('return', Expr):
                return "return(%s)" % gen(Expr)

            elif (ir.get_struct_item, _, StructName, Item):
                return gen(StructName)+'.'+gen(Item)

            elif (ir.set_struct_item, _, StructName, Item, Value):
                return gen(StructName)+'.'+gen(Item)+' = '+gen(Value)

            elif (ir.do_while, Condition, Body):
                return new_block('while True', Body
                                 +[(ir.if_, (ir.not_, Condition), (ir.stmt, ir.break_))])

            elif (ir.if_, Condition, Body):
                return new_block('if %s'%gen(Condition), Body)

            elif (ir.decl, Type, Name): return ''
            elif (ir.assignment):     return '='
            elif (ir.eq):             return '=='
            elif (ir.not_):           return 'not'
            elif (ir.true):           return 'True'
            elif (ir.false):          return 'False'
            elif ((ir.literal, Lit)): return "'%s'"%Lit
            elif (Expr):
                return super(PythonCodeGenerator, self).generate(Expr, scope)
            else: raise Exception("match error")



# ----------------------------------------------------------------------
# SIDL
# ----------------------------------------------------------------------
class SIDLFile(Scope):
    """
    This class represents a SIDL source file
    """
    def __init__(self):
        super(SIDLFile, self).__init__()


class SIDLCodeGenerator(GenericCodeGenerator):
    """
    SIDL code generator
    """
    @matcher(globals(), debug=False)
    def generate(self, node, scope=SIDLFile()):
        # recursion
        def gen(node):
            return self.generate(node, scope)

        def gen_(node):
            "like gen but with trailing ' ', if nonempty"
            if node == []: return ''
            return self.generate(node, scope)+' '

        def _gen(node):
            "like gen but with preceding ' ', if nonempty"
            if node == []: return ''
            return ' '+self.generate(node, scope)

        def _comma_gen(node):
            "like gen but with preceding ', ', if nonempty"
            if node == []: return ''
            return ', '+self.generate(node, scope)

        def new_def(s):
            if s == scope:
                import pdb; pdb.set_trace()
                raise Exception("Hey! No cycles, please.")
            if isinstance(s, list):
                import pdb; pdb.set_trace()
                raise Exception("Hey! No lists, neither.")
            #print "new_def", s
            if s <> '':
                scope.new_def(s)

        def pre_def(s):
            # print "pre_def", s
            return scope.pre_def(s)

        def gen_in_scope(defs, child_scope):
            r = self.generate(defs, child_scope)
            if (r <> ''):
                raise Exception("unexpected retval")
            return str(child_scope)


        def gen_scope(pre, defs, post):
            sep = '\n'+' '*scope.indent_level
            new_def(pre+sep+
                    gen_in_scope(defs, 
                                 Scope(4, scope.indent_level+4, 
                                       separator=';\n'))+';'+
                    sep+post)

        def gen_comma_sep(defs):
            return gen_in_scope(defs, Scope(indent_level=1, separator=','))

        def gen_ws_sep(defs):
            return gen_in_scope(defs, Scope(indent_level=0, separator=' '))

        def gen_dot_sep(defs):
            return gen_in_scope(defs, Scope(indent_level=0, separator='.'))

        def tmap(f, l):
            return tuple(map(f, l))

        #import pdb; pdb.set_trace()

        with match(node):
            if (ir.file_, Requires, Imports, Packages):
                new_def(gen(Requires))
                new_def(gen(Imports))
                new_def(gen(Packages))
                return str(scope)

            elif (ir.package, (ir.identifier, Name), Version, Usertypes):
                gen_scope('package %s %s {' % (Name, gen(Version)),
                          Usertypes,
                          '}')

            elif (ir.user_type, Attrs, Defn): 
                return gen_(Attrs)+gen(Defn)

            elif (ir.class_, Name, Extends, Implements, Invariants, Methods):
                head = 'class '+gen(Name)
                if (Extends)    <> []: head.append('extends '+gen_ws_sep(Extends))
                if (Implements) <> []: head.append('implements '+gen_ws_sep(Implements))
                if (Invariants) <> []: head.append('invariants '+gen_ws_sep(Invariants))
                gen_scope(head+'{', Methods, '}')

            elif (ir.interface, Name, Extends, Invariants, Methods):
                head = 'interface '+gen(Name)
                if (Extends)    <> []: head.append('extends '+gen_ws_sep(Extends))
                if (Invariants) <> []: head.append('invariants '+gen_ws_sep(Invariants))
                gen_scope(head+'{', Methods, '}')

            elif (ir.method, Typ, Name, Attrs, Args, Excepts, Froms, Requires, Ensures):
                return (gen_ws_sep(Attrs)+
                        gen(Typ)+' '+gen(Name)+'('+gen_comma_sep(Args)+')'+
                        _gen(Excepts)+
                        _gen(Froms)+
                        _gen(Requires)+
                        _gen(Ensures))

            elif (ir.arg, Attrs, Mode, Typ, Name):
                return gen_(Attrs) + '%s %s %s' % tmap(gen, (Mode, Typ, Name))

            elif (ir.array, Typ, Dimension, Orientation):
                return ('array<%s%s%s>' % 
                        (gen(Typ), _comma_gen(Dimension), _comma_gen(Orientation)))

            elif (ir.rarray, Typ, Dimension, Name, Extents):
                return ('rarray<%s%s> %s(%s)' %
                        (gen(Typ), _comma_gen(Dimension), gen(Name), gen_comma_sep(Extents)))

            elif (ir.enum, (ir.identifier, Name), Enumerators):
                gen_scope('enum %s {' % gen(Name), Enumerators, '}')

            elif (ir.struct, (ir.identifier, Name), Items):
                gen_scope('struct %s {' % gen(Name), Items, '}')

            elif (ir.scoped_id, A, B):
                return '%s%s' % (gen_dot_sep(A), gen(B))

            elif (ir.attribute,   Name):    return Name
            elif (ir.identifier,  Name):    return Name
            elif (ir.version,     Version): return 'version %2.1f'%Version
            elif (ir.mode,        Name):    return Name
            elif (ir.method_name, Name, []):return Name
            elif (ir.method_name, Name, Extension): return Name+' '+Extension
            elif (ir.primitive_type, Name): return Name.lower()
            elif (ir.struct_item, Type, Name): return ' '.join((gen(Type), gen(Name)))
            elif (Op, A, B):                return ' '.join((gen(A), Op, gen(B)))
            elif (Op, A):                   return ' '.join((Op, gen(A)))
            elif []: return ''
            elif A:
                if (isinstance(A, list)):
                    for defn in A:
                        new_def(gen(defn))
                else:
                    return str(A)
            else:
                raise Exception("match error")
        return ''
