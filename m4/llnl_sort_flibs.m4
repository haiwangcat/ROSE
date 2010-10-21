
dnl 
dnl @synopsis LLNL_SORT_FLIBS
dnl 
dnl With certain Fortran compilers, the FLIBS macro can be out of order.
dnl This macros moves all the arguments beginning with "-l" at the end
dnl but does not alter the relative ordering of "-l" arguments and non-"-l" 
dnl arguments; otherwise,
dnl   If the answer is yes, 
dnl     it defines AR_CXX=$CXX, ARFLAGS_CXX=-xar, and RANLIB_CXX=echo
dnl   otherwise AR_CXX=ar, ARFLAGS_CXX=cuv, RANLIB_CXX=ranlib
dnl
dnl @version 
dnl @author Gary Kumfert <kumfert1@llnl.gov>
dnl
AC_DEFUN([LLNL_SORT_FLIBS],
[AC_REQUIRE([LLNL_F77_LIBRARY_LDFLAGS])dnl
AC_MSG_CHECKING([form of Fortran 77 library flags])
flibs1=
flibs2=
for arg in $FLIBS; do
  arg1=
  arg2=
  case "$arg" in 
    -l*)
      arg2=$arg
      ;;
    -L*)
      dir1=`echo $ECHO_N $arg | sed -e 's/^-L//'`
      if test -n "$dir1" -a -d "$dir1" ; then
	dir1ac=`cd "$dir1" && pwd`
        if test -n "$dir1ac" -a "$dir1ac" != '/usr/lib' -a "$dir1ac" != '/lib' -a "$dir1ac" != '/usr/lib64' -a "$dir1ac" != '/lib64' ; then
	  arg1=-L$dir1
	fi
      fi
      ;;
    /*.a)
      dir1=`dirname $arg`
      if test -n "$dir1" -a -d "$dir1" ; then
	dir1ac=`cd "$dir1" && pwd`
        if test -n "$dir1ac" -a "$dir1ac" != '/usr/lib' -a "$dir1ac" != '/lib' -a "$dir1ac" != '/usr/lib64' -a "$dir1ac" != '/lib64' ; then
	  arg1=-L$dir1
	fi
      fi
      arg2=`basename $arg .a`
      arg2=`echo $ECHO_N $arg2 | sed -e 's/^lib/-l/'`
      ;;
    /*.so)
      dir1=`dirname $arg`
      if test -n "$dir1" -a -d "$dir1" ; then
	dir1ac=`cd "$dir1" && pwd`
        if test -n "$dir1ac" -a "$dir1ac" != '/usr/lib' -a "$dir1ac" != '/lib' -a "$dir1ac" != '/usr/lib64' -a "$dir1ac" != '/lib64' ; then
	  arg1=-L$dir1
	fi
      fi
      arg2=`basename $arg .so`
      arg2=`echo $ECHO_N $arg2 | sed -e 's/^lib/-l/'`
      ;;
    *)
      arg1=$arg
      ;;
  esac; 
  if test -n "$arg1"; then
    exists=false
    for f in $flibs1; do
      if test "x$arg1" = "x$f"; then 
        exists=true
      fi
    done
    if test "$exists" = true; then
      :
    else
      flibs1="$flibs1 $arg1"
    fi
  fi
  if test -n "$arg2"; then
    exists=false
    for f in $flibs2; do
      if test "x$arg2" = "x$f"; then 
        exists=true
      fi
    done
    if test "$exists" = true; then
      :
    else
      flibs2="$flibs2 $arg2"
    fi
  fi
done
FLIBS="$flibs1 $flibs2"
AC_SUBST(FLIBS)
AC_MSG_RESULT($FLIBS)
])
