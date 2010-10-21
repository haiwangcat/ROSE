dnl @synopsis LLNL_PYTHON_NUMERIC
dnl
dnl @author ?
AC_DEFUN([LLNL_PYTHON_NUMERIC],[
  AC_REQUIRE([LLNL_PROG_PYTHON])dnl
  AC_REQUIRE([LLNL_PYTHON_LIBRARY])dnl
  AC_ARG_ENABLE([numeric],
	AS_HELP_STRING(--disable-numeric,do not enable Numeric Python),
	[enable_numeric="$enableval"],
	[enable_numeric=default])
  AC_ARG_ENABLE([numpy],
	AS_HELP_STRING(--disable-numpy,do not enable NumPy),
	[enable_numpy="$enableval"],
	[enable_numpy=default])
  if test "X$enable_numeric" == "Xyes" -a "X$enable_numpy" == "Xdefault" ; then
    enable_numpy=no
  fi
  if test "X$enable_numpy" == "Xyes" -a "X$enable_numeric" == "Xdefault" ; then
    enable_numeric=no
  fi
  if test "X$enable_numpy" == "Xdefault" ; then
    enable_numpy=yes
  fi
  if test "X$enable_numeric" == "Xdefault" ; then
    enable_numeric=yes
  fi
  AC_CACHE_CHECK(for Numerical Python, llnl_cv_python_numerical, [
    llnl_cv_python_numerical=no
    if test "X$PYTHON" != "X" -a "X$enable_numeric" == "Xyes" ; then
      if AC_TRY_COMMAND($PYTHON -c "import Numeric") > /dev/null 2>&1; then
        if test -f $llnl_cv_python_include/Numeric/arrayobject.h; then
          llnl_cv_python_numerical=yes
	else
	  llnl_cv_python_numerical="no (missing C header file)"
        fi
      fi
    fi
  ])
  if test "$llnl_cv_python_numerical" = yes; then
    AC_DEFINE(SIDL_HAVE_NUMERIC_PYTHON,1,[Numeric Python is installed])
  fi
  AC_CACHE_CHECK(for NumPy, llnl_cv_python_numpy, [
    llnl_cv_python_numpy=no
    if test "X$PYTHON" != "X" -a "X$enable_numpy" == "Xyes"; then
      if AC_TRY_COMMAND($PYTHON -c "import numpy") > /dev/null 2>&1; then
dnl-----------------------------------------------------------------------------
dnl THIS USED TO TRY TO MATCH THE EXACT NUMBER OF TERMS IN THE VERSION, BUT numpy 
dnl ADDED ANOTHER TERM.  SINCE WE'RE REALLY ONLY INTERESTED IN THE FIRST TERM,
dnl (at least version 1.0.0) I CUT THE REST OUT
dnl-----------------------------------------------------------------------------
dnl	llnl_numpy_ver=`$PYTHON -c "import numpy; print numpy.__version__" 2>/dev/null | awk -F . '/^@<:@0-9@:>@*\.@<:@0-9@:>@*[$]/ { printf "%d", 1000 * (1000 * [$]1 + [$]2); } /^@<:@0-9@:>@*\.@<:@0-9@:>@*\.@<:@0-9@:>@*[$]/ { printf "%d", ([$]1 * 1000 + [$]2) * 1000 + [$]3;} /^@<:@0-9@:>@*\.@<:@0-9@:>@*\.@<:@0-9@:>@*\.@<:@0-9@:>@*[$]/ { printf "%d", ([$]1 * 1000 + [$]2) * 1000 + [$]3 + [$]4;}'`
dnl 	if test $llnl_numpy_ver -ge 1000000 ; then
dnl------------------------------------------------------------------------------
	llnl_numpy_ver=`$PYTHON -c "import numpy; print numpy.__version__" 2>/dev/null | awk -F . '/^@<:@0-9@:>@*\..*/ { printf "%d", [$]1; }'`
	if test $llnl_numpy_ver -ge 1 ; then
	  llnl_cv_python_numpy_incl=`$PYTHON -c "import numpy; print numpy.__path__[[0]]" 2>/dev/null`"/core/include/numpy"
          if test -f "$llnl_cv_python_numpy_incl/oldnumeric.h"; then
            llnl_cv_python_numpy=yes
	  else
	    llnl_cv_python_numpy="no (missing C header file)"
          fi
        else
	  llnl_cv_python_numpy="no (version 1.0.0 or later required)"
	fi
      fi
    fi
  ])
  if test "X$llnl_cv_python_numpy" = "Xyes"; then
    AC_DEFINE(SIDL_HAVE_NUMPY,1,[NumPy is installed])
    PYTHONINC="$PYTHONINC -I$llnl_cv_python_numpy_incl"
  fi
  AC_SUBST(PYTHONINC)
])
