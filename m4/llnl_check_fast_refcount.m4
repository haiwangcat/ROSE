dnl
dnl @synopsis LLNL_CHECK_FAST_REFCOUNT
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

AC_DEFUN([LLNL_CHECK_FAST_REFCOUNT],
[AC_LANG_PUSH(C)dnl
  AC_REQUIRE([AC_CANONICAL_HOST])	

  AC_ARG_ENABLE([fast-refcount],
        AS_HELP_STRING(--enable-fast-refcount@<:@=yes@:>@, lock-free reference counting @<:@default=yes@:>@),
               [enable_fast_refcount="$enableval"],
               [enable_fast_refcount=yes])
    

#  test -z "$enable_fast_recount" && enable_fast_refcount=yes
#  if test x"$enable_fast_refcount" != xno; then
#    if test x"$enable_fast_refcount" != xyes; then 
#      FAST_REFCOUNT=$enable_fast_refcount
#      enable_fast_refcount=yes
#    fi
#  fi
#  if test x"$enable_fast_refcount" != xno; then

  if test x"$enable_fast_refcount" = xyes; then	
    AC_MSG_CHECKING([processor architecture])
    case "${host}" in
      i[[567]]86-*) BABEL_PROCESSOR_ARCHITECTURE=["X86"];;
      x86_64*) BABEL_PROCESSOR_ARCHITECTURE=["X86"];;
      ia64*) BABEL_PROCESSOR_ARCHITECTURE=["IA64"];;
      sparc*) BABEL_PROCESSOR_ARCHITECTURE=["SPARC"];;
      mips*) BABEL_PROCESSOR_ARCHITECTURE=["MIPS"];;
      powerpc*) BABEL_PROCESSOR_ARCHITECTURE=["POWERPC"];;
      *) BABEL_PROCESSOR_ARCHITECTURE=["UNKNOWN"];;
    esac
    AC_MSG_RESULT([$BABEL_PROCESSOR_ARCHITECTURE]);

    AC_MSG_CHECKING([if Babel supports fast reference counting for $BABEL_PROCESSOR_ARCHITECTURE])
    AC_LINK_IFELSE([AC_LANG_PROGRAM(,[int x=0; __sync_val_compare_and_swap(&x,0,1);])],
                   [BABEL_PROCESSOR_ARCHITECTURE=["GNU"]],
                   [])
    if test x"$BABEL_PROCESSOR_ARCHITECTURE" = xX86; then
      # double check that we actually have an x86 architecture
      # Try compiling and linking a program that used x86 assembler
      AC_LINK_IFELSE([AC_LANG_PROGRAM(,[
        #define CAS(_a, _o, _n)                                    \
          ({ __typeof__(_o) __o = _o;                              \
            __asm__ __volatile__(                                  \
            "lock cmpxchg %3,%1"                                   \
            : "=a" (__o), "=m" (*(volatile unsigned int *)(_a))    \
            :  "0" (__o), "r" (_n) );                              \
            __o;                                                   \
          })],
        [int x = 0;
         CAS(&x,0,1)])],
      [], #true
      [BABEL_PROCESSOR_ARCHITECTURE=["UNKNOWN"];]) #false

      if test x"$BABEL_PROCESSOR_ARCHITECTURE" = xX86; then
        AC_DEFINE(BABEL_PROCESSOR_X86,,[Define processor type to be x86.])
        AC_MSG_RESULT([yes]); #Babel supports fast refcount on this processor 
      else
        AC_MSG_RESULT([no]); #no fast refcount on this processor
      fi
    else
      if test x"$BABEL_PROCESSOR_ARCHITECTURE" = xGNU; then
	AC_MSG_RESULT([yes])
        AC_DEFINE(BABEL_PROCESSOR_GNU,,[Define processor type to be GNU GCC.])
	AC_MSG_NOTICE([Using GCC built-in atomic memory access functions])
      else
        AC_MSG_RESULT([no]); #no fast refcount on this processor	
      fi
    fi
  fi
])#LLNL_CHECK_FAST_REFCOUNT
