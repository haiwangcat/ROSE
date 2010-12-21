import ir, codegen

# Generator for testcases

# Measure two things:
# - Overhead of function call (struct passing)
# - Overhead of member access
#
# +--------------------------------------------------+ ^
# |                                                  | |
# |                                                  | |
# |                                                  | | time(Lang)-time(C)
# |                                                  |
# |                                                  |
# |                                                  |
# |                                                  |
# |                                                  |
# +--------------------------------------------------+
# 1 call                                           1000 calls
# 1000 accesses                                    1 access

"""
package s version 1.0  {
  struct Point1 {
    float m1;
  }

  class Benchmark {
    float dot1(Point1 a, Point1 b);
  }

}
"""

def sidl_code(n):
    return (ir.file_, [], [], [
            (ir.package, (ir.identifier, "s"), (ir.version, 1.0),
             [(ir.user_type, [], (ir.struct, (ir.identifier, 'Vector'), 
                                  [(ir.struct_item, (ir.primitive_type, 'float'), 
                                    (ir.identifier, 'm%d'%i))
                                   for i in range(1, n+1)])),
              (ir.user_type, [], 
               (ir.class_, (ir.identifier, "Benchmark"), [], [], [],
                [(ir.method, 
                  (ir.primitive_type, "float"), 
                  (ir.identifier, "dot"), [],
                  [(ir.arg, [], (ir.mode, "in"), 
                    (ir.scoped_id, ["Vector"], []), (ir.identifier, "a")),
                   (ir.arg, [], (ir.mode, "in"), 
                    (ir.scoped_id, ["Vector"], []), (ir.identifier, "b"))],
                  [], [], [], [])
                 ]))])])

def dotproduct_expr(n):
    def add(a, b):
        return ("+", a, b)

    a = (ir.struct, 'Point%d'%n, [(ir.struct_item, 'float', 'm%d'%i)
                               for i in range(1, n+1)]) # do we need the package, too?
    b = a
    e = reduce(add, map(lambda i:
                            ("*",
                             (ir.get_struct_item, a, (ir.identifier, "a"), 'm%d'%i),
                             (ir.get_struct_item, b, (ir.identifier, "b"), 'm%d'%i)),
                        range(1, n+1)))
    return (ir.stmt, ('return', e))




import subprocess, splicer
import argparse

if __name__ == '__main__':
    cmdline = argparse.ArgumentParser(description='auto-generate struct benchmarks')
    cmdline.add_argument('i', metavar='n', type=int,
			 help='number of elements in the Vector struct')
    # cmdline.add_argument('babel', metavar='babel',
    #			 help='the Babel executable')
    args = cmdline.parse_args()
    i = args.i
    babel = 'babel' #args.babel

    subprocess.check_call("mkdir -p out", shell=True)
    f = open('out/struct%d.sidl'%i, "w")
    f.write(codegen.generate("SIDL", sidl_code(i)))
    f.close()
    for lang in ["C", "CXX", "F77", "F90", "F03", "Python", "Java"]:
        ext = {"C"      : "c", 
               "CXX"    : "cxx",
               "F77"    : "f",
               "F90"    : "F90",
               "F03"    : "F03",
               "Python" : "py",
               "Java"   : "java"}
        prefix = {"C"   : "s_", 
               "CXX"    : "s_",
               "F77"    : "s_",
               "F90"    : "s_",
               "F03"    : "s_",
               "Python" : "s/",
               "Java"   : "s/"}

        print "generating", lang, i, "..."

        cmd = """
          mkdir -p out/{lang}_{i} && cd out/{lang}_{i} &&
          {babel} -s{lang} --makefile ../struct{i}.sidl
          """.format(lang=lang,i=i,babel=babel)
        #print cmd
        subprocess.check_call(cmd, shell=True)
        impl = ("out/{lang}_{i}/{prefix}Benchmark_Impl.{ext}".
                format(lang=lang, i=i, ext=ext[lang], prefix=prefix[lang]))
        if lang == "Python": 
            splicer_block = "dot"
        else: splicer_block = "s.Benchmark.dot"
        #print "splicing", impl
        splicer.replace(impl, splicer_block, 
                        codegen.generate(lang, dotproduct_expr(i))) 

    print "generating client", i, "..."
    cmd = """
      mkdir -p out/client_{i} && cd out/client_{i} &&
      {babel} -cC --makefile ../struct{i}.sidl
      """.format(i=i,babel=babel)
    #print cmd
    subprocess.check_call(cmd, shell=True)
    f = open('out/client_%d/main.c'%i, "w")
    f.write("""    
#       include <stdio.h>
#       include "s_Benchmark.h"
         
        int main(int argc, char** argv)
        {
          s_Benchmark h = s_Benchmark__create();
          struct s_Vector__data a, b;
          float result = s_Benchmark_dot(a, b);
          s_Benchmark_deleteRef(h);
        }
           """)
    f.close()



exit(0)
# expr = dotproduct_expr(12)
# csrc      =         CCodeGenerator().generate(expr)
# cxxsrc    =       CXXCodeGenerator().generate(expr)
# javasrc   =      JavaCodeGenerator().generate(expr)
# pythonsrc =    PythonCodeGenerator().generate(expr)
# f77src    = Fortran77CodeGenerator().generate(expr)
# f90src    = Fortran90CodeGenerator().generate(expr)
# f03src    = Fortran03CodeGenerator().generate(expr)
# print f77src
# print f90src
# print f03src
# print csrc
# print cxxsrc
# print pythonsrc
# print javasrc
