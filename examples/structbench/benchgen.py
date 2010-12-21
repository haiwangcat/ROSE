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

    a = (ir.struct, (ir.identifier, "s"), (ir.identifier, 'Vector'), 
         [(ir.struct_item, 'float', 'm%d'%i) for i in range(1, n+1)])
    b = a
    e = reduce(add, map(lambda i:
                            ("*",
                             (ir.get_struct_item, a, (ir.identifier, "a"), 'm%d'%i),
                             (ir.get_struct_item, b, (ir.identifier, "b"), 'm%d'%i)),
                        range(1, n+1)))
    return (ir.stmt, ('return', e))




import subprocess, splicer, argparse, os, re

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
    languages = ["C", "CXX", "F77", "F90", "F03", "Java", "Python"]
    for lang in languages:
        ext = {"C"      : "c", 
               "CXX"    : "cxx",
               "F77"    : "f",
               "F90"    : "F90",
               "F03"    : "F03",
               "Java"   : "java",
               "Python" : "py"}
        prefix = {"C"   : "s_", 
               "CXX"    : "s_",
               "F77"    : "s_",
               "F90"    : "s_",
               "F03"    : "s_",
               "Java"   : "s/",
               "Python" : "s/"}

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
    f.write(r"""    

#       include <stdio.h>
#       include "s_Benchmark.h"
#       include "sidl_BaseInterface.h"
#       include "sidl_Exception.h"
         
        int main(int argc, char** argv)
        {
          int i;
	  sidl_BaseInterface ex;
          s_Benchmark h = s_Benchmark__create(&ex); SIDL_CHECK(ex);
          struct s_Vector__data a, b;
          for (i=0; i<1000000; ++i) {
            volatile float result = s_Benchmark_dot(h, &a, &b, &ex); SIDL_CHECK(ex);
          }
          s_Benchmark_deleteRef(h, &ex); SIDL_CHECK(ex);
	  return 0;
EXIT: /* this is error handling code for any exceptions that were thrown */
	  {
	    char* msg;
	    fprintf(stderr,"%s:%d: Error, exception caught\n",__FILE__,__LINE__);
	    sidl_BaseInterface ignore = NULL;
	    sidl_BaseException be = sidl_BaseException__cast(ex,&ignore);
  
	    msg = sidl_BaseException_getNote(be, &ignore);
	    fprintf(stderr,"%s\n",msg);
	    sidl_String_free(msg);
  
	    msg = sidl_BaseException_getTrace(be, &ignore);
	    fprintf(stderr,"%s\n",msg);
	    sidl_String_free(msg);
  
	    sidl_BaseException_deleteRef(be, &ignore);
	    SIDL_CLEAR(ex);
	    return 1;
	  }

        }
           """)
    f.close

    filename = 'out/client_%d/GNUmakefile'%i
    os.rename(filename, filename+'~')
    dest = open(filename, 'w')
    src = open(filename+'~', 'r')

    for line in src:
        m = re.match(r'^(all *:.*)$', line)
        if m:
            dest.write(m.group(1)+
                       'runC2C runC2CXX runC2F77 runC2F90 runC2F03 runC2Java runC2Python\n')
            dest.write("CXX=`babel-config --query-var=CXX`\n"+
                       '\n'.join(["""
runC2{lang}: lib$(LIBNAME).la ../{lang}_{i}/libimpl.la main.lo
\tbabel-libtool --mode=link $(CC) -static main.lo lib$(LIBNAME).la \
\t    ../{lang}_{i}/libimpl.la -o runC2{lang}
""".format(lang=lang, i=i) for lang in languages[:6]]))
            dest.write("""
runC2Python: lib$(LIBNAME).la ../Python_{i}/libimpl1.la main.lo
\tbabel-libtool --mode=link $(CC) -static main.lo lib$(LIBNAME).la \
\t    ../Python_{i}/libimpl1.la -o runC2Python
""".format(i=i))
        else:
            dest.write(line)
    dest.close()
    src.close()

    f = open('out/client_%d/runAll.sh'%i, 'w')
    for lang in languages:
        f.write('/usr/bin/time -f %U -o out{lang} ./runC2{lang} || echo "FAIL" >out{lang}\n'
                .format(lang=lang))
    f.write("echo %d "%i+' '.join(['`cat out%s`'%lang for lang in languages])+' >times')
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
