dnl @synopsis LLNL_CONFIRM_BABEL_F03_SUPPORT
dnl
dnl  This checks for support of the iso_c_binding intrinsic
dnl  modules that is used in the Fortran 2003 bindings. 
dnl
dnl  If Babel support for F03 is enabled:
dnl     the cpp macro FORTRAN03_DISABLED is undefined
dnl     the automake conditional SUPPORT_FORTRAN03 is true
dnl
dnl  If Babel support for F03 is disabled:
dnl     the cpp macro FORTRAN03_DISABLED is defined as true
dnl     the automake conditional SUPPORT_FORTRAN03 is false
dnl
dnl  @author ebner

AC_DEFUN([LLNL_CONFIRM_BABEL_F03_SUPPORT], [
  AC_REQUIRE([AC_PROG_FC])
  #begin LLNL_CONFIRM_BABEL_F03_SUPPORT
  if test \( -z "$FC" \) -a \( -n "$F03" \); then
	AC_MSG_WARN([FC environment variable is preferred over F03.  compensating])
	FC="$F03"
  fi
  if test \( -z "$FC" \) -a \( -n "$F03" \); then
	AC_MSG_WARN([FCFLAGS environment variable is preferred over F03FLAGS.  compensating])
	FCFLAGS="$F03FLAGS"
  fi

  AC_ARG_ENABLE([fortran03],
        AS_HELP_STRING(--enable-fortran03@<:@=FC@:>@,fortran 03 language bindings @<:@default=yes@:>@),
               [enable_fortran03="$enableval"],
               [enable_fortran03=yes])
  test -z "$enable_fortran03" && enable_fortran03=yes
  if test "$enable_fortran03" != no; then
    if test "$enable_fortran03" != yes; then 
      FC=$enable_fortran03
      enable_fortran03=yes
    fi
  fi
  if test "X$enable_fortran03" != "Xno" -a "X$enable_fortran03" != "Xbroken" ; then
    AC_PROG_FC(,2000)
    AC_LANG_PUSH(Fortran)
    if test -n "$FC"; then
      AC_FC_SRCEXT([f03],[])
      LLNL_LIB_CHASM
    else
      if echo $enable_auto_disable | egrep -i "yes|f03" 2>&1 >/dev/null ; then
        enable_fortran03=broken
      else
	AC_MSG_ERROR([Halting configure: Fortran 03 is required])
      fi
    fi
    AC_LANG_POP(Fortran) dnl gkk Do I need this?
  else
    FC=
  fi
  #end LLNL_CONFIRM_BABEL_F03_SUPPORT
])

AC_DEFUN([LLNL_CONFIRM_BABEL_F03_SUPPORT2],[
  AC_REQUIRE([LLNL_CONFIRM_BABEL_F03_SUPPORT])
    #begin LLNL_CONFIRM_BABEL_F03_SUPPORT2
    if test \( -n "$FC" \) ; then 
	F03="$FC"
        # confirm that that F03 compiler can compile a trivial file issue146
	AC_MSG_CHECKING([if the Fortran 2003 compiler works])
        AC_LANG_PUSH(Fortran)dnl
        AC_COMPILE_IFELSE([AC_LANG_PROGRAM([],[       write (*,*) 'Hello world'])],
	  AC_MSG_RESULT([yes]),[
          AC_MSG_RESULT([no])
	  AC_MSG_WARN([The F03 compiler $FC fails to compile a trivial program (see config.log).])
      	  if echo $enable_auto_disable | egrep -i "yes|f03" 2>&1 >/dev/null ; then
	    AC_MSG_WARN([Disabling F03 Support])
            enable_fortran03=broken
     	  else
	    AC_MSG_ERROR([Halting configure: Fortran 03 is required])
	  fi
        ])
        AC_LANG_POP([])
        if test "X$enable_fortran03" = "Xyes"; then
          AC_CACHE_CHECK([if the Fortran 2003 compiler has support for the iso_c_binding intrinsic module],
          llnl_cv_has_bindc,
          [AC_LANG_PUSH(Fortran)dnl
          AC_COMPILE_IFELSE([
            program main  
                use, intrinsic :: iso_c_binding
                type, bind(c) :: ftest
                  real(c_double)            :: d_dbl
                  real(c_float)             :: d_flt
                  complex(c_float_complex)  :: d_fcmplx
       	        complex(c_double_complex) :: d_dcmplx
                  integer(c_int32_t)        :: d_int
                  integer(c_int64_t)        :: d_long
                  type(c_ptr)               :: d_opaque
                end type ftest
            end
            ],
            [llnl_cv_has_bindc="yes"],
            [llnl_cv_has_bindc="no"])
          AC_LANG_POP(Fortran)dnl
          ])
        fi
    else
      if echo $enable_auto_disable | egrep -i "yes|f03" 2>&1 > /dev/null ; then
        AC_MSG_WARN([Disabling F03 Support])
        if test \( -n "$FC" \); then
          enable_fortran03="no_chasm"
        else
          enable_fortran03="broken"	
        fi
      else
        AC_MSG_ERROR([Halting configure: Fortran 03 is required])
      fi
  fi
    #end LLNL_CONFIRM_BABEL_F03_SUPPORT2
])

AC_DEFUN([LLNL_CONFIRM_BABEL_F03_SUPPORT3],[
  #begin LLNL_CONFIRM_BABEL_F03_SUPPORT3
  if test "X$enable_fortran03" = "Xno"; then
    msgs="$msgs
	  Fortran03 disabled by request.";
  elif test "X$enable_fortran03" = "Xyes"; then
    msgs="$msgs
	  Fortran03 enabled.";
  elif test "X$enable_fortran03" = "Xno_chasm"; then
    msgs="$msgs
 	  Fortran03 disabled against user request: CHASMLITE config failed.";
  elif test "X$enable_fortran03" = "Xno_bindc"; then
    msgs="$msgs
 	  Fortran compiler does not support the iso_c_binding intrinsic module.";
  else
    msgs="$msgs
	  Fortran03 disabled against user request: no viable compiler found.";
  fi 
  if test "X$enable_fortran03" != "Xyes"; then
    AC_DEFINE(FORTRAN03_DISABLED, 1, [If defined, F03 support was disabled at configure time])
    FC=""
  fi
  AM_CONDITIONAL(SUPPORT_FORTRAN03, test "X$enable_fortran03" = "Xyes" -a "X$llnl_cv_has_bindc" = "Xyes")
  if test "X$F03CPPSUFFIX" = "X" ; then
     F03CPPSUFFIX=".f03"
  fi
  AC_SUBST(F03CPPSUFFIX)
  LLNL_WHICH_PROG(WHICH_FC)
  #end LLNL_CONFIRM_BABEL_F03_SUPPORT3
])
