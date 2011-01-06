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

def sidl_code(n, datatype):
    """
    Generate SIDL definition file
    """
    return (ir.file_, [], [], [
            (ir.package, (ir.identifier, "s"), (ir.version, 1.0),
             [(ir.user_type, [], (ir.struct, (ir.identifier, 'Vector'), 
                                  [(ir.struct_item, (ir.primitive_type, datatype), 
                                    (ir.identifier, 'm%d'%i))
                                   for i in range(1, n+1)])),
              (ir.user_type, [], 
               (ir.class_, (ir.identifier, "Benchmark"), [], [], [],
                [(ir.method, 
                  (ir.primitive_type, datatype), 
                  (ir.identifier, "dot"), [],
                  [(ir.arg, [], (ir.mode, "in"), 
                    (ir.scoped_id, ["Vector"], []), (ir.identifier, "a")),
                   (ir.arg, [], (ir.mode, "inout"), 
                    (ir.scoped_id, ["Vector"], []), (ir.identifier, "b"))],
                  [], [], [], [])
                 ]))])])

#-----------------------------------------------------------------------
# benchmark kernels
#-----------------------------------------------------------------------
def dotproduct_expr(n, datatype):
    def add(a, b):
        return ("+", a, b)

    a = (ir.struct, (ir.identifier, "s"), (ir.identifier, 'Vector'), 
         [(ir.struct_item, datatype, 'm%d'%i) for i in range(1, n+1)])
    b = a
    e = reduce(add, map(lambda i:
                            ("*",
                             (ir.get_struct_item, a, (ir.identifier, "a"), 'm%d'%i),
                             (ir.get_struct_item, b, (ir.identifier, "b"), 'm%d'%i)),
                        range(1, n+1)))
    return (ir.stmt, ('return', e))

def const_access_expr(n, datatype):
    def add(a, b):
        return ("+", a, b)

    a = (ir.struct, (ir.identifier, "s"), (ir.identifier, 'Vector'), 
         [(ir.struct_item, datatype, 'm%d'%i) for i in range(1, n+1)])
    b = a
    e = reduce(add, map(lambda i:
                            ("*",
                             (ir.get_struct_item, a, (ir.identifier, "a"), 'm%d'%(i%n+1)),
			     (ir.get_struct_item, b, (ir.identifier, "b"), 'm%d'%(i%n+1))),
                        range(1, 129)))
    return (ir.stmt, ('return', e))

def reverse_expr(n, datatype):
    'b_i = a_{n-i}'
    a = (ir.struct, (ir.identifier, "s"), (ir.identifier, 'Vector'), 
         [(ir.struct_item, datatype, 'm%d'%i) for i in range(1, n+1)])
    b = a
    revs = [(ir.stmt, (ir.set_struct_item, b, (ir.identifier, "b"), 'm%d'%(n-i+1),
                       (ir.get_struct_item, a, (ir.identifier, "a"), 'm%d'%(n-i+1))))
            for i in range(1, n+1)]
    return revs+[(ir.stmt, ('return', (ir.get_struct_item, a, (ir.identifier, "a"), 'm1')))]


def nop_expr(n):
    return (ir.stmt, ('return', (ir.value, n)))

#-----------------------------------------------------------------------
# return a main.c for the client implementation
#-----------------------------------------------------------------------
def gen_main_c(datatype):
    t = codegen.CCodeGenerator().get_type(datatype)
    return r"""    
#include <stdlib.h>
#include <stdio.h>
#include "s_Benchmark.h"
#include "sidl_BaseInterface.h"
#include "sidl_Exception.h"
  
 int main(int argc, char** argv)
 {
   int i; long num_runs;
	  sidl_BaseInterface ex;
   s_Benchmark h = s_Benchmark__create(&ex); SIDL_CHECK(ex);
   struct s_Vector__data a, b;
   if (argc != 2) {
     fprintf(stderr,"Usage: %s <number of runs>", argv[0]);
     return 1;
   }
   
   num_runs = strtol(argv[1], (char **) NULL, 10);
   fprintf(stderr, "running %ld times\n", num_runs);

   for (i=0; i<num_runs; ++i) {
     volatile """+t+r""" result = s_Benchmark_dot(h, &a, &b, &ex); SIDL_CHECK(ex);
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
"""


import subprocess, splicer, argparse, os, re
#-----------------------------------------------------------------------
if __name__ == '__main__':
#-----------------------------------------------------------------------
    cmdline = argparse.ArgumentParser(description='auto-generate struct benchmarks')
    cmdline.add_argument('i', metavar='n', type=int,
			 help='number of elements in the Vector struct')
    cmdline.add_argument('datatype', metavar='t', 
			 help='data type for the Vector struct')
    # cmdline.add_argument('babel', metavar='babel',
    #			 help='the Babel executable')
    args = cmdline.parse_args()
    i = args.i
    datatype = args.datatype
    babel = 'babel' #args.babel

    print "-------------------------------------------------------------"
    print "generating servers"
    print "-------------------------------------------------------------"
    subprocess.check_call("mkdir -p out", shell=True)
    f = open('out/struct_%d_%s.sidl'%(i,datatype), "w")
    f.write(codegen.generate("SIDL", sidl_code(i, datatype)))
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

        print "generating", lang, i, datatype, "..."

        cmd = """
          mkdir -p out/{lang}_{i}_{t} && cd out/{lang}_{i}_{t} &&
          {babel} -s{lang} --makefile ../struct_{i}_{t}.sidl
          """.format(lang=lang,i=i,babel=babel,t=datatype)
        #print cmd
        subprocess.check_call(cmd, shell=True)
        impl = ("out/{lang}_{i}_{t}/{prefix}Benchmark_Impl.{ext}".
                format(lang=lang, i=i, t=datatype, ext=ext[lang], prefix=prefix[lang]))
        if lang == "Python":
            splicer_block = "dot"
        else: splicer_block = "s.Benchmark.dot"
        code = codegen.generate(lang, reverse_expr(i,datatype))
        if code == None:
            raise Exception('Code generation failed')
        print "splicing", impl
        splicer.replace(impl, splicer_block, code) 

    print "-------------------------------------------------------------"
    print "generating client", i, datatype, "..."
    print "-------------------------------------------------------------"
    cmd = """
      mkdir -p out/client_{i}_{t} && cd out/client_{i}_{t} &&
      {babel} -cC --makefile ../struct_{i}_{t}.sidl
      """.format(i=i,babel=babel,t=datatype)
    #print cmd
    subprocess.check_call(cmd, shell=True)
    f = open('out/client_%d_%s/main.c'%(i,datatype), "w")
    f.write(gen_main_c(datatype))
    f.close


    print "-------------------------------------------------------------"
    print "adapting client Makefile..."
    print "-------------------------------------------------------------"
    filename = 'out/client_%d_%s/GNUmakefile'%(i,datatype)
    os.rename(filename, filename+'~')
    dest = open(filename, 'w')
    src = open(filename+'~', 'r')

    for line in src:
        m = re.match(r'^(all *:.*)$', line)
        if m:
            dest.write(m.group(1)+
                       ' runC2C runC2CXX runC2F77 runC2F90 runC2F03 runC2Java runC2Python\n')
            dest.write("CXX=`babel-config --query-var=CXX`\n"+
                       '\n'.join([
"""
runC2{lang}: lib$(LIBNAME).la ../{lang}_{i}_{t}/libimpl.la main.lo
\tbabel-libtool --mode=link $(CC) -static main.lo lib$(LIBNAME).la \
\t    ../{lang}_{i}_{t}/libimpl.la -o runC2{lang}
""".format(lang=lang, i=i, t=datatype) for lang in languages[:6]]))
            dest.write("""
runC2Python: lib$(LIBNAME).la ../Python_{i}_{t}/libimpl1.la main.lo
\tbabel-libtool --mode=link $(CC) -static main.lo lib$(LIBNAME).la \
\t    ../Python_{i}_{t}/libimpl1.la -o runC2Python
""".format(i=i, t=datatype))
        else:
            dest.write(line)
    dest.close()
    src.close()

    print "-------------------------------------------------------------"
    print "generating benchmark script..."
    print "-------------------------------------------------------------"
    f = open('out/client_%d_%s/runAll.sh'%(i,datatype), 'w')
    f.write(r"""#!/usr/bin/bash
PYTHONPATH_1=$LIBDIR/python$PYTHON_VERSION/site-packages:$PYTHONPATH
LIBDIR=`babel-config --query-var=libdir`
PYTHON_VERSION=`babel-config --query-var=PYTHON_VERSION`
SIDL_VERSION=`babel-config --query-var=VERSION`
SIDL_DLL_PATH_1="$LIBDIR/libsidlstub_java.scl;$LIBDIR/libsidl.scl;$LIBDIR/libsidlx.scl"
export LD_LIBRARY_PATH="$LIBDIR:$LD_LIBRARY_PATH"

echo "runAll($i)"

function count_insns {
   # measure the number of instructions of $1, save output to $2.all
   # perform one run with only one iteration and subtract that from the result 
   # to eliminate startup time
   perf stat -- $1 1 2>$2.base || (echo "FAIL" >$2; exit 1)
   base=`grep instructions $2.base | awk '{print $1}'`
   perf stat -- $1 1000001 2>$2.perf || (echo "FAIL" >$2; exit 1)
   grep instructions $2.perf | awk "{print \$1-$base}" >> $2.all
}

function medtime {
   # measure the median running user time
   rm -f $2.all
   MAX=10
   for I in `seq $MAX`; do
     echo "measuring $1 ($3@$4) [$I/$MAX]"
     # echo SIDL_DLL_PATH=$SIDL_DLL_PATH
     # echo PYTHONPATH=$PYTHONPATH
     # /usr/bin/time -f %U -a -o $2.all $1 || (echo "FAIL" >$2; exit 1)
     count_insns $1 $2
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
export SIDL_DLL_PATH="../{lang}_{i}_{t}/libimpl.scl;$SIDL_DLL_PATH_1"
export PYTHONPATH="../Python_{i}_{t}:$PYTHONPATH_1"
export CLASSPATH="../Java_{i}_{t}:$LIBDIR/sidl-$SIDL_VERSION.jar:$LIBDIR/sidlstub_$SIDL_VERSION.jar"
medtime ./runC2{lang} out{lang} {i} {t}
'''.format(lang=lang,i=i,t=datatype))

    f.write("echo %d "%i+' '.join(['`cat out%s`'%lang 
                                   for lang in languages])+' >times\n')
    f.close()

