dnl -*- autoconf -*-
AC_DEFUN([ROSE_CONFIGURE_MINITERMITE],
[
  ROSE_ARG_WITH(
    [minitermite-analysis-results],
    [(minitermite analysis results)],
    [generate extra 'analysis_result()' terms for every compound term @<:@default=no@:>@],
    []
  )

AC_DEFINE(
  ROSE_HAVE_MINITERMITE_ANALYSIS_RESULTS,
  [test "x$CONFIG_HAS_ROSE_WITH_MINITERMITE_ANALYSIS_RESULTS" = xyes],
  [generate extra `analysis_result()` terms])


AM_CONDITIONAL(ROSE_HAVE_MINITERMITE_ANALYSIS_RESULTS, 
               [test "x$CONFIG_HAS_ROSE_WITH_MINITERMITE_ANALYSIS_RESULTS" = xyes])
])
