#####################################
#
# LLNL_LIB_CHASM
#
# Check for CHASM_PREFIX (if set) and commandline.
# 

AC_DEFUN([LLNL_GUESS_VENDOR],
[
  CHASM_FORTRAN_VENDOR=$1
  AC_MSG_WARN([Guessing Fortran 90/95 vendor as $1 based on the compiler name $FC])
])

AC_DEFUN([LLNL_LIB_CHASM], 
[ 
  AC_ARG_WITH(F90-vendor,
    [AS_HELP_STRING([--with-F90-vendor@<:@=name@:>@],[Fortran compiler (Absoft,Alpha,Cray,GNU,G95,IBMXL,Intel,Intel_7,Lahey,MIPSpro,NAG,PathScale,PGI,SUNWspro)])],
    [CHASM_FORTRAN_VENDOR=$withval],
    [CHASM_FORTRAN_VENDOR='unknown'])
  AC_ARG_WITH(arch,
    AS_HELP_STRING(--with-arch@<:@=CHASM_ARCH@:>@,CHASM architecture),
    [CHASM_ARCH=$withval],[CHASM_ARCH=${CHASM_ARCH='unknown'}])
  if test "X$CHASM_FORTRAN_VENDOR" == "Xunknown" ; then
    llnl_fc_basename=`basename $FC`
    case "$llnl_fc_basename" in
      *gfortran*)
	LLNL_GUESS_VENDOR("GNU")
	;;
      *g95*)
	LLNL_GUESS_VENDOR("G95")
	;;
      *xlf*)
	LLNL_GUESS_VENDOR("IBMXL")
	;;
      *ifc*|*ifort*)
	LLNL_GUESS_VENDOR("Intel")
	;;
      *lf95*)
	LLNL_GUESS_VENDOR("Lahey")
	;;
      *pgf90*|*pgf95*)
	LLNL_GUESS_VENDOR("PGI")
	;;
      *pathf90* | *pathf95*)
	LLNL_GUESS_VENDOR("PathScale")
	;;
     esac
  fi
  if test "X$CHASM_FORTRAN_VENDOR" != "Xunknown" ; then
    AC_CACHE_CHECK(for 64-bit bitfield error, llnl_cv_bitfield_error,[
      AC_LANG_PUSH([C])
      AC_COMPILE_IFELSE(AC_LANG_PROGRAM(,[struct {
  long stride_mult :64;   /* distance between successive elements (bytes)  */
  long upper_bound :64;   /* last array index for a given dimension        */
  long lower_bound :64;   /* first array index for a given dimension       */
} dim[7];
  ]),[llnl_cv_bitfield_error=false],[llnl_cv_bitfield_error=true])
      AC_LANG_POP([])
    ])
    if test "X$llnl_cv_bitfield_error" != "Xtrue" ; then
      CHASM_BROKEN_BITFIELD=0
    else
      CHASM_BROKEN_BITFIELD=1
    fi
    AC_SUBST([CHASM_BROKEN_BITFIELD])
    AC_CACHE_CHECK(whether CHASM architecture is 32- or 64-bit,llnl_cv_chasm_arch_64,[
      if test "$CHASM_ARCH" == "unknown" ; then
        if test $ac_cv_sizeof_void_p -ge 8 ; then
	  llnl_cv_chasm_arch_64=64
        else
	  llnl_cv_chasm_arch_64=32
        fi
      else
        case $CHASM_ARCH in
          linux64|aix64|alpha64|ia64)
            llnl_cv_chasm_arch_64=64
            ;;
          *)
            llnl_cv_chasm_arch_64=32
            ;;
        esac
      fi
    ])
    if test $llnl_cv_chasm_arch_64 -eq 64 ; then
      CHASM_ARCH_64=1
    else
      CHASM_ARCH_64=0
    fi
    AC_SUBST([CHASM_ARCH_64])
    AC_MSG_CHECKING([module include flag for $FC])
    CHASM_FORTRAN_MFLAG="-I"
    case "$CHASM_FORTRAN_VENDOR" in
    Absoft | Cray)
       CHASM_FORTRAN_MFLAG="-p"
       ;;
    PathScale)
       CHASM_FORTRAN_MFLAG="-I"
       ;;
    PGI)
       CHASM_FORTRAN_MFLAG="-module "
       ;;
    SUNWspro)
       CHASM_FORTRAN_MFLAG="-M"
       ;;
    Alpha | GNU | G95 | IBMXL | Intel | Intel_7 | MPISpro | NAG | Lahey)
       CHASM_FORTRAN_MFLAG="-I"
       ;;
    *)
       AC_MSG_ERROR(["--with-F90-vendor=NAME" flag needed at configure time (new with chasmlite). "$CHASM_FORTRAN_VENDOR" is insufficient. See choices in --help.])
       ;;
    esac
    AC_MSG_RESULT([$CHASM_FORTRAN_MFLAG])
    AC_SUBST(CHASM_FORTRAN_MFLAG)

    CHASM_CFLAGS='-I../libchasmlite -I${srcdir}/../libchasmlite'
    CHASM_LIBS='${abs_top_builddir}/libchasmlite/libchasmlite.la'
    CHASM_PYSETUP="--extra-library=chasmlite"

    AC_SUBST(CHASM_CFLAGS)
    AC_SUBST(CHASM_LIBS)
    AC_SUBST(CHASM_FORTRAN_VENDOR)
    AC_SUBST(CHASM_PYSETUP)
    AC_DEFINE_UNQUOTED([SIDL_MAX_F90_DESCRIPTOR],256,[Maximum Fortran array descriptor size])
    AC_DEFINE_UNQUOTED([SIDL_MAX_F03_DESCRIPTOR],256,[Maximum Fortran array descriptor size])
    AC_DEFINE_UNQUOTED([CHASM_FORTRAN_VENDOR],"$CHASM_FORTRAN_VENDOR",[Name of the F90 compiler to use with CHASM])
  else
    if echo $enable_auto_disable | egrep -i "yes|f90" 2>&1 > /dev/null; then
      AC_MSG_WARN([Disabling F90 support due to missing --with-F90-vendor=NAME.])
      enable_fortran90="no_chasm"
    else
      AC_MSG_ERROR([The --with-F90-vendor=NAME flag is needed at configure time (new for Babel with chasmlite).  For choices use --help.])
    fi
  fi
]) # end LLNL_LIB_CHASM
