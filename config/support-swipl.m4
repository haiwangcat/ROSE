dnl -*- autoconf -*-
AC_DEFUN([ROSE_SUPPORT_SWIPL], [
  ROSE_ARG_WITH(
    [swi-prolog],
    [SWI Prolog],
    [enable SWI-Prolog in minitermite  @<:@default=no@:>@],
    [])
   
  AS_IF([test "x$CONFIG_HAS_ROSE_WITH_SWI_PROLOG" = xyes], [
   
    PKG_CHECK_MODULES(PL, [pl >= 5.8.0],
        [AC_SUBST([SWIPL_PREFIX], [`$PKG_CONFIG pl --variable prefix`])
         AS_IF([test -x $SWIPL_PREFIX/bin/swipl],
               [AC_SUBST([SWIPL], ["${SWIPL_PREFIX}/bin/swipl"])],
               [AC_SUBST([SWIPL], ["${SWIPL_PREFIX}/bin/pl"])])
         AC_SUBST([SWIPL_VERSION], [`${SWIPL} --version | awk '{print $3}'`])
         AC_MSG_RESULT([using ${SWIPL}])
        ],
        [# alternate pkg-config name
         PKG_CHECK_MODULES(SWIPL, [swipl >= 5.8.0], 
            [AC_SUBST([SWIPL_PREFIX], [`$PKG_CONFIG swipl --variable prefix`])
             AC_SUBST([SWIPL], ["${SWIPL_PREFIX}/bin/swipl"])
             AC_SUBST([SWIPL_VERSION], [`${SWIPL} --version | awk '{print $3}'`])
        ],
        [AC_MSG_NOTICE([Did not find SWI-Prolog version 5.8 or later! 
    Please remember to set PKG_CONFIG_PATH accordingly.])
             AC_SUBST([SWIPL], [""])
            ])
        ])
     
    AS_IF([test "x$with_swi_prolog" != xno], dnl yes or autodetect
          [AS_IF([test -n "$SWIPL" -a -x "$SWIPL"], 
                 [with_swi_prolog=yes],
                 [AS_IF([test "x$with_swi_prolog" != xcheck],
                        [AC_MSG_FAILURE([--with-swi_prolog was given, but test for SWI Prolog failed])])],
                        [with_swi_prolog=no])])
     
    AS_IF([test "x$with_swi_prolog" = xyes],
          [eval `$SWIPL --dump-runtime-variables |grep -v '^CC='`
           AC_SUBST([SWI_PL], ["$SWIPL"])
           AC_SUBST([SWI_PROLOG_LIBS], ["$PLLIBS"])
           AC_SUBST([SWI_PROLOG_LDADD], ["-L'$PLBASE/lib/$PLARCH' -Wl,-rpath '$PLBASE/lib/$PLARCH' $PLLIB $PLLIBS"])
           AC_SUBST([SWI_PROLOG_HOME_DIR], ["$PLBASE"])
           AC_SUBST([SWI_PROLOG_INCLUDE_DIR], ["$PLBASE/include"])
           AC_SUBST([SWI_PLC], ["$SWIPL -q -t main -O -L0 -G0 -T0"])
           AC_DEFINE([HAVE_SWI_PROLOG], [1], [Define if you have SWI Prolog])
           AC_MSG_RESULT([Termite will be built with SWI-Prolog support.])
           have_swi_prolog=1],
          [AC_SUBST([SWI_PL], ["false"])
           AC_SUBST([SWI_PROLOG_LDADD], [""])  # set a safe dummy default path
           AC_SUBST([SWI_PROLOG_INCLUDE_DIR], ["/usr/include"])
           AC_DEFINE([HAVE_SWI_PROLOG], [0], [Define if you have SWI Prolog])
           AC_MSG_RESULT([Termite will be built WITHOUT SWI-Prolog support.])
           have_swi_prolog=0])
     
  ])
  AM_CONDITIONAL(ROSE_HAVE_SWI_PROLOG, [test "x$have_swi_prolog" = x1])
  AS_IF([test "x$have_swi_prolog" = x1],
      [AC_DEFINE(ROSE_HAVE_SWI_PROLOG, 1, [linking against libswipl])],
      [AC_DEFINE(ROSE_HAVE_SWI_PROLOG, 0, [linking against libswipl])])
  AC_SUBST(have_swi_prolog)
])
