dnl
dnl @synopsis LLNL_CONFIRM_BABEL_C_SUPPORT
dnl
dnl  This is a meta-command that orchestrates a bunch of sub-checks.
dnl  I made it a separate M4 Macro to make synchronization between 
dnl  the main configure script and the runtime configure script easier.
dnl
dnl  @author Gary Kumfert

AC_DEFUN([LLNL_CONFIRM_BABEL_C_SUPPORT], [
  AC_REQUIRE([AC_LTDL_SHLIBPATH])dnl
  ############################################################
  #
  # C Compiler
  #
  # AC_PROG_CC
  # Verify C compiler can compile trivial C program issue146
  AC_MSG_CHECKING([if C compiler works])
  AC_LANG_PUSH([C])
  AC_TRY_COMPILE([],[],AC_MSG_RESULT([yes]),[
    AC_MSG_RESULT([no])
    AC_MSG_ERROR([The C compiler $CC fails to compile a trivial program (see config.log)])])
  AC_LANG_POP([])
  AC_DEFINE(SIDL_CAST_INCREMENTS_REFCOUNT,,[This should always be defined for Babel 0.11.0 and beyond])
  LLNL_WHICH_PROG(WHICH_CC)
  # a. Libraries (existence)
  # b. Header Files.
  AC_HEADER_DIRENT
  AC_HEADER_STDC
  AC_HEADER_STDBOOL
  AC_CHECK_HEADERS([argz.h float.h limits.h malloc.h memory.h netinet/in.h sched.h stddef.h stdlib.h string.h strings.h sys/socket.h unistd.h ctype.h sys/stat.h sys/time.h])
  AC_HEADER_TIME
  # c. Typedefs, Structs, Compiler Characteristics
  AC_C_CONST
  AC_TYPE_SIZE_T
  AC_TYPE_PID_T
  AC_CHECK_TYPES([ptrdiff_t])
  AC_CHECK_SIZEOF(short,2)
  AC_CHECK_SIZEOF(int,4)
  AC_CHECK_SIZEOF(long,8)
  LLNL_CHECK_LONG_LONG
  AC_CHECK_SIZEOF(ptrdiff_t,4)
  AC_CHECK_SIZEOF(size_t,4)
  LLNL_FIND_32BIT_SIGNED_INT
  LLNL_CHECK_INT32_T
  LLNL_FIND_64BIT_SIGNED_INT
  LLNL_CHECK_INT64_T
  AC_CHECK_SIZEOF(void *,4)
  AC_C_INLINE
  AC_C_RESTRICT
  AC_C_VOLATILE
  LLNL_C_HAS_INLINE
  # d. Specific Library Functions.
  AC_FUNC_MALLOC
  AC_FUNC_REALLOC
  AC_FUNC_MEMCMP 
  AC_FUNC_STAT
  AC_FUNC_CLOSEDIR_VOID
  AC_FUNC_ERROR_AT_LINE
  AC_FUNC_FORK
  AC_FUNC_SELECT_ARGTYPES
  AC_LANG_C
  AC_LANG_PUSH([C])
  llnl_new_cflag=""  
  if test "$ac_compiler_gnu" = yes; then
    llnl_new_cflag="-fno-strict-aliasing"
  else
    case "$CC" in
    *xlc | *xlc_r )
	# note -qsuppress squashes messages like this
	# "../sidl/sidl_rmi_Call.h", line 347.1: 1506-1108 (I) The use of keyword '__inline__' is non-portable.
       llnl_new_cflag="-qsuppress=1506-1108 -qalias=noansi"
       ;;
    *icc* | ecc*)
       llnl_new_cflag="-ansi_alias-"
       ;;
    esac
  fi
  AC_LANG_POP([])
dnl additional push required to apply change to CFLAGS
  if test -n "$llnl_new_cflag" ; then
    save_CFLAGS="$CFLAGS"
    CFLAGS="$CFLAGS $llnl_new_cflag"
    AC_MSG_CHECKING([if C compiler accepts $llnl_new_cflag])
    AC_LANG_PUSH([C])
    AC_TRY_COMPILE([],[],[AC_MSG_RESULT([yes])],[
        AC_MSG_RESULT([no])
        CFLAGS="$save_CFLAGS"])
    AC_LANG_POP([])
  fi
  unset llnl_new_cflag
  AC_CHECK_FUNCS([atexit bzero getcwd memset socket strchr strdup strrchr])
  SHARED_LIB_VAR=${shlibpath_var}
  AC_SUBST(SHARED_LIB_VAR)
])
