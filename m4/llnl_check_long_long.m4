
dnl @synopsis LLNL_CHECK_LONG_LONG
dnl
dnl checks for a `long long' type
dnl 
dnl @version 
dnl @author Gary Kumfert, LLNL
AC_DEFUN([LLNL_CHECK_LONG_LONG],
[AC_CHECK_SIZEOF(long long,8)
 if test "$ac_cv_type_long_long" = yes ; then
   AC_DEFINE(HAVE_LONG_LONG,,[define if long long is a built in type])
 fi
])


