AC_PREREQ(2.64)
AC_INIT([braid],[0.2.1],[adrian@llnl.gov])
AC_CONFIG_SRCDIR([COPYRIGHT])
AC_CONFIG_MACRO_DIR([m4])
CCA_DIAGNOSE_INIT(toolcheck.log)
AC_CONFIG_AUX_DIR([config])
AC_CANONICAL_TARGET

AM_INIT_AUTOMAKE([foreign no-dependencies no-installinfo no-installman no-texinfo.tex 1.11 dist-bzip2 parallel-tests color-tests silent-rules])
dnl To regenerate configure and .in files, configure with --enable-maintainer-mode
AM_MAINTAINER_MODE

dnl AC_CONFIG_HEADERS(runtime/sidl/ignore_me.h)
AC_DEFINE([BABEL_VERSION_HEX],[0x01099000],
	[Hexified form of release number: 2 hex digits each for major, minor, bugfix, and alpha/beta/candidate/distributed ])

LLNL_CHECK_AUTOMAKE([1.11])
LLNL_CHECK_AUTOCONF([2.64])

############################################################
#
# Additional configure options.
#
LLNL_CROSS_COMPILING
LLNL_AUTO_DISABLE
LLNL_ENABLE_REGRESSION
LLNL_ENABLE_DOCUMENTATION

AM_PATH_PYTHON([2.6])

############################################################
#
# Python Support.
#
CCA_DIAGNOSE_BEGIN([PYTHON])
LLNL_CONFIRM_BABEL_PYTHON_SUPPORT
CCA_DIAGNOSE_END([PYTHON])

############################################################
#
# Critical Applications.
#
AC_PROG_CC
AC_PROG_LEX
AC_PROG_INSTALL
AC_PROG_CPP
AC_PROG_AWK
AC_PROG_LN_S
AC_PROG_INSTALL
AC_PROG_MAKE_SET
AC_PROG_LIBTOOL


AC_CONFIG_FILES([Makefile compiler/Makefile Doxyfile])

AC_OUTPUT

