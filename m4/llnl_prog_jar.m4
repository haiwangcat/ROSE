AC_DEFUN([LLNL_PROG_JAR],[
if test "x$JAVAPREFIX" = x; then
  if test "x$JAR" = x; then
    AC_PATH_PROG(JAR,jar)
  fi
else
  if test "x$JAR" = x; then
    AC_PATH_PROG(JAR,jar,"${JAVAPREFIX}/bin:${JAVAPREFIX}:${PATH}")
  fi
fi
if test "x$JAR" = x; then
  AC_MSG_ERROR([no acceptable jar program found in \$PATH])
fi
AC_PROVIDE([$0])dnl
])
