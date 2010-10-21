#
# LLNL_LIBPARSIFAL_CONFIG
#
AC_DEFUN([LLNL_LIBPARSIFAL_CONFIG],
[
  AC_ARG_WITH([libparsifal],
       	[AS_HELP_STRING([--with-libparsifal@<:@=DIR@:>@],[Check for an installed libparsifal; else fall back to =local.])],,[withval=yes])
  AC_ARG_WITH([junk],
	[AS_HELP_STRING([--with-libparsifal=local],[Compile with libparsifal bundled with Babel])],,)
  AC_ARG_WITH([junk],
	[AS_HELP_STRING([--with-libparsifal=local_babel],[Make bundled libparsifal linker symbols unique by prefixing them with babel.])],,)
  AC_ARG_ENABLE(iconv, AC_HELP_STRING([--disable-iconv],[(default enabled).]),,enable_iconv="yes")

  LIBPARSIFAL_CFLAGS=""
  LIBPARSIFAL_LIB=""
  LIBPARSIFAL_MODE="no"
    LIBPARSIFAL_PYSETUP=''
  llnl_found_libparsifal=no
  llnl_build_libparsifal=no
  AC_LANG_PUSH(C)
  case "$withval" in
  no|local|local_babel) ;;
  yes)
    AC_CHECK_HEADER([libparsifal/parsifal.h],[
      AC_CHECK_LIB([parsifal],[XMLParser_Create],
        [llnl_found_libparsifal=yes
	 LIBPARSIFAL_MODE=system
	 LIBPARSIFAL_LIB="-lparsifal"],
        [AC_MSG_WARN([Building local version of libparsifal (to prevent this use --without-libparsifal).])
	 withval=local])],[
      AC_MSG_WARN([Building local version of libparsifal (to prevent this use --without-libparsifal).])
      withval=local])
    ;;
  *)
    llnl_save_CFLAGS="$CFLAGS"
    CFLAGS="$CFLAGS -I$withval/include -L$withval/lib"
    AC_CHECK_HEADER([libparsifal/parsifal.h],[
      AC_CHECK_LIB([parsifal],[XMLParser_Create],
        [llnl_found_libparsifal=yes
	 LIBPARSIFAL_MODE=prefix
	 if test $enable_iconv != "no" ; then
	   AC_CHECK_LIB([iconv],[iconv_open],
	                [parsifal_extra_lib="-liconv"],
		        [parsifal_extra_lib=""])
	 fi
	 LIBPARSIFAL_LIB="-L$withval/lib -lparsifal $parsifal_extra_lib"
         LIBPARSIFAL_CFLAGS="-I$withval/include"
         LIBPARSIFAL_PYSETUP="--extra-library=parsifal `echo $parsifal_extra_lib | sed -e 's/-l/--extra-library=/g'`"],
	[AC_MSG_WARN([Unable to find libparsifal library in user specified prefix $withval (giving up).])])],[
      AC_MSG_WARN([Unable to find libparsifal header file in user specified prefix $withval (giving up).])])
    CFLAGS="$llnl_save_CFLAGS"
    ;;
  esac
  AC_LANG_POP(C)

  case "$withval" in
  local|local_babel)
    llnl_found_libparsifal=yes
    llnl_build_libparsifal=$withval
    AC_CHECK_LIB([iconv],[iconv_open],
	         [parsifal_extra_lib="--extra-library=iconv"],
		 [parsifal_extra_lib=""])
    LIBPARSIFAL_MODE=$withval
    LIBPARSIFAL_CFLAGS='-I${srcdir}/../libparsifal/include'
    LIBPARSIFAL_LIB=../libparsifal/src/libparsifal.la
    LIBPARSIFAL_PYSETUP="--extra-library=parsifal $parsifal_extra_lib"
    ;;
  esac

  if test "$withval" = local_babel ; then
    LIBPARSIFAL_CFLAGS="$LIBPARSIFAL_CFLAGS -D_PNS"
    if test "X$llnl_build_libparsifal" = "Xlocal_babel" ; then
      if test ${CPPFLAGS:+set} = set ; then
        CPPFLAGS="$CPPFLAGS -D_PNS"
       else
        CPPFLAGS="-D_PNS"
       fi
       export CPPFLAGS
    fi
  fi
  if test "$llnl_found_libparsifal" = yes; then
    AC_DEFINE(HAVE_LIBPARSIFAL,[1],[libparsifal support included])
  fi
  AC_SUBST(LIBPARSIFAL_MODE)
  AC_SUBST(LIBPARSIFAL_LIB)
  AC_SUBST(LIBPARSIFAL_CFLAGS)
  AC_SUBST(LIBPARSIFAL_PYSETUP)
])
