import patmat

function = 'function'
void = 'void'
stmt = 'stmt'
arg = 'arg'

# Generator for testcases

# intermediate representation
ir = (function, void, 'f', [], (arg, 'x'), [], [], [], [], \
      (stmt, ('return', ('expr', '=', 'x', 0))))

# code generators for multiple languages
def gen_fortran03():
    gen = gen_fortran03
    with match(ir):
        if (function, void, Name, Attrs, Args, Excepts, Froms, Requires, Ensures, Body):
            return '''
            subroutine %s
              %s
              %s
            end subroutine %s
            ''' % (Name, gen(Args), gen(Body), Name)
        elif (function, Typ, Name, Attrs, Args, Excepts, Froms, Requires, Ensures):
            return '''
            function %s
              %s
              %s
            end function %s
        ''' % (Typ, Name, gen(Args), gen(Body), Name)
        elif (stmt, Expr): return pretty(Expr)

def gen_c():
    gen = gen_c
    with match(ir):
        if (function, Typ, Name, Attrs, Args, Excepts, Froms, Requires, Ensures):
            return '''
            %s %s(%s) {
              %s
            }
        ''' % (Typ, Name, pretty(Args), gen(Body))
        elif (stmt, Expr): return pretty(Expr)

# for babel core functionality ....
