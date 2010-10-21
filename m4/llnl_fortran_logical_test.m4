# LLNL_FORTRAN_LOGICAL_SIZE
# -------------------------
# Test for the size of a Fortran logical
#

AC_DEFUN([LLNL_FORTRAN_LOGICAL_TEST_PROLOGUE],[
#ifdef SIDL_$1_ONE_UNDERSCORE
#ifdef SIDL_$1_UPPER_CASE
#define TESTFUNC LOG_TST_
#else
#define TESTFUNC log_tst_
#endif
#else
#ifdef SIDL_$1_TWO_UNDERSCORE
#ifdef SIDL_$1_UPPER_CASE
#define TESTFUNC LOG_TST__
#else
#define TESTFUNC log_tst__
#endif
#else
#ifdef SIDL_$1_UPPER_CASE
#define TESTFUNC LOG_TST
#else
#define TESTFUNC log_tst
#endif
#endif
#endif
#ifdef HAVE_INTTYPES_H
#include <inttypes.h>
#else
#include <sys/types.h>
#endif
#include <stdio.h>
#ifdef __cplusplus
extern "C"
#else
extern
#endif
])

dnl LLNL_FORTRAN_LOGICAL_SIZE(longname,shortname)
AC_DEFUN([LLNL_FORTRAN_LOGICAL_SIZE],
[AC_REQUIRE([LLNL_$2_NAME_MANGLING])dnl
AC_CACHE_CHECK(dnl
[for $1 ($2) logical variable size],llnl_cv_$2_logical_size,
[
AC_LANG_PUSH(C)dnl
AC_COMPILE_IFELSE([
  AC_LANG_SOURCE([LLNL_FORTRAN_LOGICAL_TEST_PROLOGUE($2)
void TESTFUNC(char *a, char *b)
{
  printf("%d\n", b - a);
  fflush(stdout); /* needed for gfortran */
}
])],
[
  mv conftest.$ac_objext cfortran_test.$ac_objext
  AC_LANG_PUSH($1)dnl
  ac_save_LIBS=$LIBS
  
  LIBS="cfortran_test.$ac_objext $LIBS -lc"
  AC_LINK_IFELSE(
     [AC_LANG_PROGRAM(,[
       implicit none
       external log_tst
       logical data(2)
       call log_tst(data(1), data(2))
])],
     [ llnl_cv_$2_logical_size=`./conftest$ac_exeext` 
       if test -z "$llnl_cv_$2_logical_size" ; then
         AC_MSG_ERROR([unable to determine the size of a $2 logical (running ./conftest$ac_exeext produced no output])
       fi
     ],
     [ AC_MSG_ERROR([unable to determine the size of a $2 logical]) ])
  LIBS=$ac_save_LIBS
  AC_LANG_POP($1)dnl
  rm -f cfortran_test* conftest*
],
[
  AC_MSG_ERROR([unable to compile C subroutine to determine logical size])
])
AC_LANG_POP(C)dnl
])
AC_DEFINE_UNQUOTED(SIDL_$2_LOGICAL_SIZE,$llnl_cv_$2_logical_size,[$2 logical variable size])
])
