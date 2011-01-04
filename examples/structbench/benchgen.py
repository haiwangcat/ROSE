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
        print "splicing", impl
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
          for (i=0; i<"""+str((2**24)/i)+r"""; ++i) {
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
                       ' runC2C runC2CXX runC2F77 runC2F90 runC2F03 runC2Java runC2Python\n')
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
    f.write(r"""#!/usr/bin/bash
PYTHONPATH_1=$LIBDIR/python$PYTHON_VERSION/site-packages:$PYTHONPATH
LIBDIR=`babel-config --query-var=libdir`
PYTHON_VERSION=`babel-config --query-var=PYTHON_VERSION`
SIDL_VERSION=`babel-config --query-var=VERSION`
SIDL_DLL_PATH_1="$LIBDIR/libsidlstub_java.scl;$LIBDIR/libsidl.scl;$LIBDIR/libsidlx.scl"
export LD_LIBRARY_PATH="$LIBDIR:$LD_LIBRARY_PATH"

echo "runAll($i)"

function medtime {
   # measure the median running user time
   rm -f $2.all
   MAX=10
   for I in `seq $MAX`; do
     echo "measuring $1 [$I/$MAX]"
     echo SIDL_DLL_PATH=$SIDL_DLL_PATH
     echo PYTHONPATH=$PYTHONPATH
     /usr/bin/time -f %U -a -o $2.all $1 || (echo "FAIL" >$2; exit 1)
   done
   cat $2.all \
       | sort \
       | python -c 'import numpy,sys; \
           print numpy.mean( \
             sorted(map(lambda x: float(x), sys.stdin.readlines()))[1:9])' \
       >>$2
}
""")
    for lang in languages:
        f.write('''
rm -f out{lang}
export SIDL_DLL_PATH="../{lang}_{i}/libimpl.scl;$SIDL_DLL_PATH_1"
export PYTHONPATH="../Python_{i}:$PYTHONPATH_1"
export CLASSPATH="../Java_{i}:$LIBDIR/sidl-$SIDL_VERSION.jar:$LIBDIR/sidlstub_$SIDL_VERSION.jar"
medtime ./runC2{lang} out{lang}
'''.format(lang=lang,i=i))

    f.write("echo %d "%i+' '.join(['`cat out%s`'%lang 
                                   for lang in languages])+' >times\n')
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
