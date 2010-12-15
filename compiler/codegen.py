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

class Scope(object):
    """
    we need at least stmt, block, function, module

    <pre>
    +--------------------+     +-----------------------------------+
    | header             |  +  | defs                              |
    +--------------------+     +-----------------------------------+
    </pre>
    """
    def __init__(self, indent_level):
        self.header = []
        self.defs = []
        self.pre_defs = []
        self.post_defs = []
        self.indent_level = indent_level

    def has_declaration_section(self):
        """
        \return whether this scope has a section for variable declarations.
        """
        return False

    def new_header_def(self, s):
        """
        append definition \c s to the header of the scope
        """
        self.header.append(s)

    def new_def(self, s):
        """
        append definition \c s to the scope
        """
        self.defs.extend(self.pre_defs)
        self.defs.append(s)
        self.defs.extend(self.post_defs)
        self.pre_defs = []
        self.post_defs = []
        return self

    def pre_def(self, s):
        """
        record a definition \c s to be added to \c defs before the
        next call of \c new_def.
        """
        self.pre_defs.append(s)
    def post_def(self, s):
        """
        record a definition \c s to be added to \c defs after the
        next call of \c new_def.
        """
        self.post_defs.append(s)

    def __str__(self):
        prefix = '\n'+' '*self.indent_level
        print prefix.join(self.header), '+', prefix.join(self.defs)
        return prefix.join(self.header) + prefix.join(self.defs)

class SourceFile(Scope):
    """
    This class represents a generic source file
    """
    def has_declaration_section(self):
        return True
    pass

class Function(Scope):
    """
    This class represents a function/procedure
    """
    def has_declaration_section(self):
        return True

class GenericCodeGenerator(object):

    @matcher(globals(), debug=False)
    def generate(self, node, scope):
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
        _, _, items = struct
        Type = Variable()
        for _ in member((ir.struct_item, Type, item), items):
            return Type.binding
        raise

# ----------------------------------------------------------------------
# C      FORTRAN 77
# ----------------------------------------------------------------------
class F77File(SourceFile):
    """
    This class represents a Fortran 77 source file
    """
    def __init__(self):
        super(F77File, self).__init__(indent_level=6)
    pass

class Fortran77CodeGenerator(GenericCodeGenerator):
    @matcher(globals(), debug=False)
    def get_type(self, node):
        """\return a string with the type of the IR node \c node."""
        with match(node):
            if ('struct', Type, _): return Type
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

        \param node         sexpr-based intermediate representation (input)
        \param scope  the Scope object the output will be written to
        """
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

            elif (ir.get_struct_item, Struct, Item):
                (_, name, _) = Struct
                tmp = 'tmp_'+gen(Item)
                declare_var(self.get_item_type(Struct, Item), tmp)
                pre_def('call %s_get_%s(%s, %s)' % (
                             gen(self.get_type(Struct)), gen(Item), name, tmp))
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
        super(F90File, self).__init__(indent_level=6)
    pass

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
    def generate(self, node, scope):
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

            elif (ir.get_struct_item, (_, Name, _), Item):
                return Name+'%'+gen(Item)

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
class F03File(SourceFile):
    """
    This class represents a Fortran 03 source file
    """
    def __init__(self):
        super(F03File, self).__init__(indent_level=6)
    pass

class Fortran03CodeGenerator(GenericCodeGenerator):
    """
    Fortran 03 code generator
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
    def generate(self, node, scope):
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

            elif (ir.get_struct_item, (_, StructName, _), Item):
                return 'get_'+gen(Item)+'('+gen(StructName)+')'

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

class CCodeGenerator(GenericCodeGenerator):
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
    def generate(self, node, scope):
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

            elif (ir.get_struct_item, (_, StructName, _), Item):
                return StructName+'.'+gen(Item)

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
    def generate(self, node, scope):
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

            elif (ir.get_struct_item, (_, StructName, _), Item):
                return StructName+'.'+gen(Item)

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

class JavaCodeGenerator(GenericCodeGenerator):
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
    def generate(self, node, scope):
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

            elif (ir.get_struct_item, (_, StructName, _), Item):
                return StructName+'.'+gen(Item)

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
        super(PythonFile, self).__init__(indent_level=0)

class PythonCodeGenerator(GenericCodeGenerator):
    """
    Python code generator
    """
    @matcher(globals(), debug=False)
    def generate(self, node, scope):
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

            elif (ir.get_struct_item, (_, StructName, _), Item):
                return StructName+'.'+gen(Item)

            elif (Expr):
                return super(PythonCodeGenerator, self).generate(Expr, scope)
            else: raise Exception("match error")

# for babel core functionality ....
