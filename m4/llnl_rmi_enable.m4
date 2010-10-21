dnl
dnl @synopsis LLNL_RMI_ENABLE
dnl
dnl  This is sort of a half baked start to allowing lock-free reference 
dnl  counting in babel generally.  It should be possible on all major 
dnl  processor achitectures.  Right now it only works on x86.  
dnl
dnl  If Babel support for Fast Refcount is enabled:
dnl     the C macro BABEL_PROCESSOR_X86 is defined
dnl
dnl  If Babel support for F77 is disabled:
dnl     the C macro BABEL_PROCESSOR_X86 is undefined
dnl
dnl  @author Jim Leek

AC_DEFUN([LLNL_RMI_ENABLE],
[AC_LANG_PUSH(C)dnl
  AC_REQUIRE([AC_CANONICAL_HOST])	

  AC_MSG_CHECKING([Remote Method Invocation Enabled])

  AC_ARG_ENABLE([rmi],
        AS_HELP_STRING(--enable-rmi@<:@=yes@:>@, enables Babel's Remote Method Invocation capabilities @<:@default=yes@:>@),
               [enable_rmi="$enableval"],
               [enable_rmi=yes])

  if test x"$enable_rmi" = xyes; then	
     AC_DEFINE(WITH_RMI,,[Enable RMI])
     AC_MSG_RESULT([yes]);
  else
     AC_MSG_RESULT([no]);
  fi

])#LLNL_RMI_ENABLE
