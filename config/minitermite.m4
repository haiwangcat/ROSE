dnl -*- autoconf -*-
AC_DEFUN([ROSE_CONFIGURE_MINITERMITE],
[
  ROSE_ARG_WITH(
    [minitermite-analysis-results],
    [(minitermite analysis results)],
    [generate extra 'analysis_result()' terms for every compound term @<:@default=no@:>@],
    []
  )

AS_IF([test "x$CONFIG_HAS_ROSE_WITH_MINITERMITE_ANALYSIS_RESULTS" = xyes],
      [AC_DEFINE(ROSE_HAVE_MINITERMITE_ANALYSIS_RESULTS, 1, [generate extra analysis_result() terms])],
      [AC_DEFINE(ROSE_HAVE_MINITERMITE_ANALYSIS_RESULTS, 0, [generate extra analysis_result() terms])])
 
AM_CONDITIONAL(ROSE_HAVE_MINITERMITE_ANALYSIS_RESULTS, 
               [test "x$CONFIG_HAS_ROSE_WITH_MINITERMITE_ANALYSIS_RESULTS" = xyes])
])
