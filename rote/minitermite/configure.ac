#                                               -*- Autoconf -*-
# Process this file with autoconf to produce a configure script.

AC_PREREQ(2.68)
AC_INIT(minitermite, 1.0, adrian@complang.tuwien.ac.at)
AC_CONFIG_SRCDIR([README])
AC_CONFIG_MACRO_DIR([m4])

AM_INIT_AUTOMAKE([silent-rules foreign no-installinfo no-texinfo.tex 1.11 
  dist-bzip2 parallel-tests color-tests silent-rules std-options])
dnl do `make V=1' or `./configure --disable-silent-rules' for a verbose build
AM_SILENT_RULES([yes])

# Checks for programs.
AC_PROG_YACC
AS_IF([test "x`which $YACC`" = x],[AC_MSG_FAILURE([Please install bison])])
AC_PROG_CXX
AS_IF([test "x`which $CXX`" = x],[AC_MSG_FAILURE([Please install g++])])
AC_PROG_CC
AS_IF([test "x`which $CC`" = x],[AC_MSG_FAILURE([Please install gcc])])
AC_PROG_LEX
AS_IF([test "x`which $LEX`" = x],[AC_MSG_FAILURE([Please install flex])])
AC_PROG_SED
AS_IF([test "x`which $SED`" = x],[AC_MSG_FAILURE([Please install sed])])
AC_PROG_LIBTOOL

LLNL_ENABLE_REGRESSION
LLNL_ENABLE_DOCUMENTATION

# DOXYGEN
AX_WITH_PROG(DOXYGEN, doxygen)
AS_IF([test -n "$DOXYGEN" -a -x "$DOXYGEN"], 
      [AC_SUBST([DOXYGEN_VERSION], [`$DOXYGEN --version`])
       AX_COMPARE_VERSION([$DOXYGEN_VERSION], ge, [1.6.0], 
           [],
           [AC_SUBST([DOXYGEN], [])
	    AM_CONDITIONAL(ENABLE_DOCUMENTATION, false)
            AC_MSG_NOTICE([doxygen < 1.6 is too old])])
      ], 
      [AC_MSG_NOTICE([doxygen is missing])])


# ROSE PATH
AS_IF([test "x`which roseCompiler`" = x],
      [ROSEDIR="/opt/rose"],
      [TMP=`which roseCompiler`
       TMP=`dirname $TMP`
       ROSEDIR=`dirname $TMP`])
AC_ARG_WITH(rosedir,
  [  --with-rosedir=DIR           ROSE install path (default in /opt/rose)],
  [ROSEDIR="$withval"])
AC_SUBST(ROSEDIR)

ROSE_INCLUDE_DIR="$ROSEDIR/include"
AC_ARG_WITH(rose_includedir,
  [  --with-rose-includedir=DIR   ROSE include path (default in /opt/rose/include)],
  [ROSE_INCLUDE_DIR="$withval"])
AC_SUBST(ROSE_INCLUDE_DIR)
AC_DEFINE_UNQUOTED(ROSE_INCLUDE_DIR,["${ROSE_INCLUDE_DIR}"], [Include directory for ROSE headers])

ROSE_LIB_DIR="$ROSEDIR/lib"
AC_ARG_WITH(rose_libdir,
  [  --with-rose-libdir=DIR       ROSE library path (default in /opt/rose/lib)],
  [ROSE_LIB_DIR="$withval"])
AC_SUBST(ROSE_LIB_DIR)

# BOOST PATH
BOOSTDIR='/usr'
AC_ARG_WITH(boostdir,
  [  --with-boostdir=DIR          Boost install path (default in /usr)],
  [BOOSTDIR="$withval"])
AC_SUBST(BOOSTDIR)

BOOST_INCLUDE_DIR="$BOOSTDIR/include"
AC_ARG_WITH(boost_includedir,
  [  --with-boost-includedir=DIR  Boost include path (default in /usr/include)],
  [BOOST_INCLUDE_DIR="$withval"])
AC_SUBST(BOOST_INCLUDE_DIR)

BOOST_LIB_DIR="$BOOSTDIR/lib"
AC_ARG_WITH(boost_libdir,
  [  --with-boost-libdir=DIR      Boost library path (default in /usr/lib)],
  [BOOST_LIB_DIR="$withval"])
AC_SUBST(BOOST_LIB_DIR)

# additional Boost stuff: it encodes the compiler version into its lib names
BOOST_COMPILER_STRING=""
AC_ARG_WITH(boost_compiler_string,
  [  --with-boost-compiler-string=STR    Boost compiler string (default: "")],
  [BOOST_COMPILER_STRING="$withval"])
AC_SUBST(BOOST_COMPILER_STRING)


AC_ARG_WITH([analysis-results],
   [AS_HELP_STRING([--with-analysis-results],
     [generate extra 'analysis_result()' terms for every compound term @<:@default=no@:>@])],
   [with_analysis_results=yes],
   [with_analysis_results=no])
AM_CONDITIONAL(WITH_ANALYSIS_RESULTS, [test "x$with_analysis_results" = xyes])


export PKG_CONFIG_PATH=${PKG_CONFIG_PATH}:${prefix}/lib/pkgconfig

# Check for SWI-Prolog (optional)
#-----------------------------------
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

AC_ARG_WITH([swi-prolog],
   [AS_HELP_STRING([--with-swi-prolog],
     [enable SWI-Prolog in Termite (recommended)  @<:@default=check@:>@])],
   :, [with_swi_prolog=check])
 
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

AM_CONDITIONAL(WITH_SWI_PROLOG, [test "x$with_swi_prolog" = xyes])
AC_SUBST(have_swi_prolog)

# Checks for libraries.
#-----------------------------------
AC_CHECK_FILE(${BOOST_LIB_DIR}/libboost_filesystem${BOOST_COMPILER_STRING}.so,
    AC_MSG_RESULT([found Boost (hopefully)]),
    [echo "Could not find 'libboost_filesystem${BOOST_COMPILER_STRING}.so' in '${BOOST_LIB_DIR}'."
     echo "Please consider using one of the --with-boost* options."
     exit -1 ])

AC_CHECK_LIB([rose], [ROSE_NUMERIC_VERSION], AC_MSG_RESULT([found ROSE]),
    [echo "Could not find '-lrose' in '-L${ROSE_LIB_DIR}'."
     echo "Please consider using one of the --with-rose* options."
     exit -1 ],
    [-Wl,--rpath -Wl,${BOOST_LIB_DIR} -L${ROSE_LIB_DIR}])

AC_CONFIG_FILES([
Makefile
Doxyfile
src/minitermite/minitermite.h
])

AC_OUTPUT

# SUMMARY

SWI_STATUS="no"
if [[ x$with_swi_prolog = xyes ]]; then
    SWI_STATUS="yes ($SWIPL_VERSION in $SWI_PROLOG_HOME_DIR)"
fi

echo
echo "------------------------------------------------------------------------"
echo "  [minitermite] configuration summary:"
echo "    ROSE .................." $ROSEDIR
echo "    SWI-Prolog ............" $SWI_STATUS
echo "------------------------------------------------------------------------"
