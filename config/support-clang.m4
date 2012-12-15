AC_DEFUN([ROSE_SUPPORT_CLANG],
[

ROSE_ARG_ENABLE(
  [clang-frontend],
  [if the Clang frontend should be enabled],
  [whether or not we will use Clang as a frontend for C/C++-like languages],
  []
)

AM_CONDITIONAL(ROSE_USE_CLANG_FRONTEND, [test "x$enable_clang_frontend" = xyes])
if test "x$CONFIG_HAS_ROSE_ENABLE_CLANG_FRONTEND" = "xyes"; then
  AC_PATH_TOOL([LLVM_CONFIG], [llvm-config])
  
  if test -e "$LLVM_CONFIG"; then
     AC_MSG_CHECKING([for Clang include path])
         if test -z "$CLANG_CXXFLAGS"; then
             # Use "--cppflags" for cpp macros (does not want cxxflags because O3, etc)
             llvm_include_path=`$LLVM_CONFIG --cppflags`
             if test -n "${llvm_include_path}"; then
                 llvm_include_path="$llvm_include_path"
             fi
             CLANG_CXXFLAGS=$llvm_include_path
         fi
     AC_MSG_RESULT([$CLANG_CXXFLAGS])
     AC_SUBST([CLANG_CXXFLAGS])
     
     AC_MSG_CHECKING([for Clang ld flags])
         if test -z "$CLANG_LDFLAGS"; then
             llvm_ldflags="`$LLVM_CONFIG --ldflags` -lclangFrontendTool -lclangStaticAnalyzerFrontend -lclangStaticAnalyzerCheckers -lclangStaticAnalyzerCore -lclangIndex -lclangFrontend -lclangCodeGen  -lclangARCMigrate -lclangRewrite -lclangSerialization -lclangDriver -lclangParse -lclangSema -lclangAnalysis -lclangAST -lclangLex -lclangBasic "
             llvm_ldflags+=`$LLVM_CONFIG --libs engine ipo bitwriter linker asmparser instrumentation`
             if test -n "${llvm_ldflags}"; then
                 llvm_ldflags="$llvm_ldflags"
             fi
             CLANG_LDFLAGS=$llvm_ldflags
         fi
     AC_MSG_RESULT([$CLANG_LDFLAGS])
     AC_SUBST([CLANG_LDFLAGS])
     
     CLANG_LIBDIR=`$LLVM_CONFIG --libdir`
     AC_SUBST([CLANG_LIBDIR])

     AC_DEFINE([ROSE_USE_CLANG_FRONTEND], [], [Use Clang for parsing C/C++-like languages])
  else
     ROSE_MSG_ERROR([requested Clang frontend, but llvm-config was not found])
  fi
fi

AM_CONDITIONAL(ROSE_USE_CLANG_FRONTEND, [test "x$CONFIG_HAS_ROSE_ENABLE_CLANG_FRONTEND" = "xyes"])

])

AC_DEFUN([INSTALL_CLANG_SPECIFIC_HEADERS],
[
mkdir -p ./include-staging/clang
cp ${srcdir}/src/frontend/CxxFrontend/Clang/clang-builtin-c.h ./include-staging/clang
cp ${srcdir}/src/frontend/CxxFrontend/Clang/clang-builtin-cpp.hpp ./include-staging/clang
cp ${srcdir}/src/frontend/CxxFrontend/Clang/clang-builtin-cuda.hpp ./include-staging/clang
cp ${srcdir}/src/frontend/CxxFrontend/Clang/clang-builtin-opencl.h ./include-staging/clang
]
)

