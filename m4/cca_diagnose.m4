dnl A set of macros to log named variables in the event
dnl of intermediate crash during testing.
dnl Benjamin Allan, Sandia National Laboratories, Livermore, CA 2006.
dnl 

dnl macro CCA_DIAGNOSE_INIT([filename])
dnl --------------------------------------------------------------------
dnl Set up the diagnostics file.
dnl The expected lifecycle of the diagnose_ vars is:
dnl unchecked, crashed_in_check, checked.
dnl and if checked, then diagnose_${VAR}_value=/setting
dnl If the configure runs all the way through, then all the
dnl crashed_in_check lines will have been subsequently redefined.
dnl If filename is not given, toolcheck.log is assumed.
dnl Variables of which CCA_DIAGNOSE_INIT is not aware
dnl will have a shorter lifecycle: (undefined, crashed_in_check, check.
dnl --------------------------------------------------------------------
AC_DEFUN([CCA_DIAGNOSE_INIT],
[
AC_PROVIDE([$0])
if test "x$1" = "x"; then
	cca_diagnose_file=toolcheck.log
else
	cca_diagnose_file=$1
fi
rm -f $cca_diagnose_file 2>/dev/null
cat<<EOF>$cca_diagnose_file
diagnose_CC=unchecked
diagnose_CXX=unchecked
diagnose_F77=unchecked
diagnose_F90=unchecked
diagnose_JAVAC=unchecked
diagnose_PYTHON=unchecked
diagnose_MPICC=unchecked
diagnose_MPICXX=unchecked
diagnose_MPIF77=unchecked
diagnose_MPIFC=unchecked
diagnose_XML2=unchecked
diagnose_PTHREAD_LIBS=unchecked
diagnose_LIBTOOL=unchecked
EOF
]
)

dnl macro CCA_DIAGNOSE_SKIP([var])
dnl --------------------------------------------------------------------
dnl Cause the var to be appended to the named file.
dnl This sets the value to skipped. The pre-skipped
dnl value is saved as well.
dnl --------------------------------------------------------------------
AC_DEFUN([CCA_DIAGNOSE_SKIP],
[
  AC_REQUIRE([CCA_DIAGNOSE_INIT])
  echo "diagnose_$1_preskipvalue=`echo $$1 2>/dev/null`" >> $cca_diagnose_file
  echo "diagnose_$1=skipped" >> $cca_diagnose_file
]
)

dnl macro CCA_DIAGNOSE_BEGIN([var])
dnl --------------------------------------------------------------------
dnl Cause the var to be appended to the named file.
dnl Normally the msg is a variable redefinition to
dnl unchecked, crashed_in_check, checked.
dnl The pre-check value is also recorded, if any.
dnl --------------------------------------------------------------------
AC_DEFUN([CCA_DIAGNOSE_BEGIN],
[
AC_REQUIRE([CCA_DIAGNOSE_INIT])
echo "diagnose_$1_precheckvalue=`echo $$1 2>/dev/null`" >> $cca_diagnose_file
echo "diagnose_$1=crashed_in_check" >> $cca_diagnose_file
]
)

dnl macro CCA_DIAGNOSE_END([var])
dnl --------------------------------------------------------------------
dnl Cause the var to be appended to the named file
dnl normally the msg is a variable redefinition.
dnl unchecked, crashed_in_check, checked.
dnl --------------------------------------------------------------------
AC_DEFUN([CCA_DIAGNOSE_END],
[
AC_REQUIRE([CCA_DIAGNOSE_INIT])
echo "diagnose_$1=checked" >> $cca_diagnose_file
echo "diagnose_$1_value=`echo $$1 2>/dev/null`" >> $cca_diagnose_file
]
)
