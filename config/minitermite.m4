dnl -*- autoconf -*-
AC_DEFUN([ROSE_CONFIGURE_MINITERMITE],
[
AC_ARG_WITH([minitermite-analysis-results],
   [AS_HELP_STRING([--with-minitermite-analysis-results=yes|no],
     [generate extra 'analysis_result()' terms for every compound term @<:@default=no@:>@])],
   [with_minitermite_analysis_results="$withval"],
   [with_minitermite_analysis_results=no])

AS_IF([test "x$with_analysis_results" = xyes],
      [AC_DEFINE(ROSE_HAVE_MINITERMITE_ANALYSIS_RESULTS, 1, [generate extra analysis_result() terms])],
      [AC_DEFINE(ROSE_HAVE_MINITERMITE_ANALYSIS_RESULTS, 0, [generate extra analysis_result() terms])])

AM_CONDITIONAL(ROSE_HAVE_MINITERMITE_ANALYSIS_RESULTS, 
               [test "x$with_minitermite_analysis_results" = xyes])
])
