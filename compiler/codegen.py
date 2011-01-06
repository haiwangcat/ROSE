#!/usr/bin/env python
# -*- python -*-
## @package codegen
# Several code generators.
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
    import sys # apparently CPython does not implement proper tail recursion
    sys.setrecursionlimit(max(sys.getrecursionlimit(), 2**16))

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


class Scope(object):
    """
    we need at least stmt, block, function, module

    <pre>
    +--------------------+     +-----------------------------------+
    | header             |  +  | defs                              |
    +--------------------+     +-----------------------------------+
    </pre>
    """
    def __init__(self, relative_indent=0, indent_level=0, separator='\n'):
        """
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
        Append definition \c s to the scope
        \return  \c self
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
    def __init__(self, relative_indent=0, indent_level=0):
        super(SourceFile, self).__init__(relative_indent, 
                                         indent_level, 
                                         separator='\n')

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
                    self._sep.join(self._defs)]))


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
            elif (ir.value, Value):     return str(Value)
            elif (Op, A, B): return ' '.join((gen(A), Op, gen(B)))
            elif (Op, A):    return ' '.join(        (Op, gen(A)))
            elif (A):        return A
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
        _, _, _, items = struct
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
    def __init__(self):
        super(F77File, self).__init__(relative_indent=0,
                                      indent_level=0)
    def new_def(self, s):
        """
        Append definition \c s to the scope
        \return  \c self
        """
        # split long lines
        tokens = s.split()
        line = ' '*self.relative_indent
        while len(tokens) > 0: 
            while (len(tokens) > 0 and 
                   len(line)+len(tokens[0]) < 62):
                line += tokens.pop(0)+' '
            super(F77File, self).new_def(line)
            line = '&' # continuation character
        return self


    def __str__(self):
        """
        Perform the actual translation into a readable string,
        complete with indentation and newlines.
        """
        #print self._header, '+', self._defs, 'sep="',self._sep,'"'
        #import pdb; pdb.set_trace()        
        def f77line(defn):
            if defn[0] == '&': return '     &      '+defn[1:]+'\n'
            else:              return '        '+defn+'\n'

        data = ''
        for defn in self._header:
            data += f77line(defn)

        for defn in self._defs:
            data += f77line(defn)

        return data

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
            elif ('string'):      return "character*(*)"
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
            while not s.has_declaration_section:
                s = s.get_parent()
            decl = self.get_type(typ)+' '+gen(name)
            if list(member(decl, s._header)) == []:
                s.new_header_def(decl)

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
                tmp = 'tmp_%s_%s'%(gen(Name), gen(Item))
                declare_var(self.get_item_type(Struct, Item), tmp)
                pre_def('call %s_get_%s_f(%s, %s)' % (
                             gen(self.get_type(Struct)), gen(Item), gen(Name), tmp))
                return tmp

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
    def __init__(self):
        super(F90File, self).__init__(relative_indent=2,indent_level=2)

    def new_def(self, s):
        """
        Append definition \c s to the scope
        \return  \c self
        """
        # split long lines
        tokens = s.split()
        while len(tokens) > 0: 
            line = ' '*self.relative_indent
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
            while not s.has_declaration_section:
                s = s.get_parent()
            s.new_header_def(self.get_type(typ)+' '+gen(name))

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
        super(F03File, self).__init__()
    pass

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

    @matcher(globals(), debug=False)
    def generate(self, node, scope=F03File()):
        # recursion
        def gen(node):
            return self.generate(node, scope)

        def declare_var(typ, name):
            s = scope
            while not s.has_declaration_section:
                s = s.get_parent()
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

            elif (ir.get_struct_item, _, Name, Item):
                return 'get_'+gen(Item)+'('+gen(Name)+')'

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
        super(CFile, self).__init__(indent_level=0)
    pass

class ClikeCodeGenerator(GenericCodeGenerator):
    """
    C-like code generator
    """
    @matcher(globals(), debug=False)
    def generate(self, node, scope=CFile()):
        # recursion
        def gen(node):
            return self.generate(node, scope)

        with match(node):
            if (ir.stmt, Expr):
                return scope.new_def(gen(Expr)+';\n')
            elif ('return', Expr):
                return "return %s" % gen(Expr)
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

        def declare_var(typ, name):
            s = scope
            while not s.has_declaration_section:
                s = s.get_parent()
            s.new_header_def(self.get_type(typ)+' '+gen(name))

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
            elif ('return', Expr):
                return "return(%s)" % gen(Expr)

            elif (ir.get_struct_item, _, StructName, Item):
                return gen(StructName)+'->'+gen(Item)

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

        def declare_var(typ, name):
            s = scope
            while not s.has_declaration_section:
                s = s.get_parent()
            s.new_header_def(self.get_type(typ)+' '+gen(name))

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
        super(JavaFile, self).__init__(indent_level=0)

class JavaCodeGenerator(ClikeCodeGenerator):
    """
    Java code generator
    """
    @matcher(globals(), debug=False)
    def get_type(self, node):
        """\return a string with the type of the IR node \c node."""
        with match(node):
            if ('struct', Type, _): return Type
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

        def declare_var(typ, name):
            s = scope
            while not s.has_declaration_section:
                s = s.get_parent()
            s.new_header_def(self.get_type(typ)+' '+gen(name))

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
    def __init__(self):
        super(PythonFile, self).__init__(4, 4)

    def __str__(self):
        """
        Perform the actual translation into a readable string,
        complete with indentation and newlines.
        """
        return ' '*self.relative_indent+(
            '\n'+' '*self.relative_indent).join(self._header+self._defs)+'\n'

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
