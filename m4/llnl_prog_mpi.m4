#
# LLNL_PROG_MPI
#
# Let user specify if they want MPI or not
#
# Input env vars: MPI_PREFIX
# Configure flags:  --with-mpi
#
#
# lang 	main script	raw compiler	compile flags	link flags
#  C  	MPI_CC 		MPI_CC_CC	MPI_CC_CFLAGS	MPI_CC_LDFLAGS
#  C++  MPI_CXX		MPI_CXX_CXX	MPI_CXX_CFLAGS	MPI_CXX_LDFLAGS
#
# Notes:  sed calls use ! because the usual seperators /,: all show up in flags
#         Also, each language should have CFLAGS, LDFLAGS (-Wl & -L), and LIBS (-l)
#         We had thought there was a bug in AC_LINK_IFELSE that restricted us to 
#         CFLAGS and LIBS but this does not appear to be the case.  Our current code
#         kinda works, but it should be standardized


AC_DEFUN([LLNL_PROG_MPI],
[
  AC_REQUIRE([CCA_DIAGNOSE_INIT])
  AC_MSG_CHECKING([whether to probe for related MPI compilers])
  AC_ARG_VAR([MPI_PREFIX],[Root directory where MPI's bin/ include/ and lib/ dirs are installed.])
  llnl_cv_with_mpi=no
  test "${MPI_PREFIX+set}" = set && llnl_cv_with_mpi=yes
  AC_ARG_WITH([mpi],
    AS_HELP_STRING([--with-mpi@<:@=eprefix@:>@],[(experimental) MPI compiler locations @<:@default=no@:>@]),
    [ case $withval in
         no) llnl_cv_with_mpi=no ;;
         yes) llnl_cv_with_mpi=yes ;;
         *) llnl_cv_with_mpi=yes; mpi_prefix="$withval" ;; 
      esac; ],) #end AC_ARG_WITH
  AC_MSG_RESULT([$llnl_cv_with_mpi])
                       
  # now do all the testing for each configured language
  if test "$llnl_cv_with_mpi" = yes; then 
    if test "${MPI_PREFIX+set}" = set ; then
      mpi_searchpath=${MPI_PREFIX}/bin:${PATH}
    else
      mpi_searchpath=${PATH}
    fi;

    CCA_DIAGNOSE_BEGIN([MPICC])
    LLNL_PROG_MPICC

    if test "$MPI_CC" != skip; then
      AC_MSG_CHECKING([for MPI version])
      cat <<\_ACEOF >conftest.c
#include "mpi.h"
MPI_VERSION AAAAA
MPI_SUBVERSION BBBBB
MPICH_NAME CCCCC
LAM_MPI DDDDD
_ACEOF
      ${MPI_CC} -E conftest.c > conftest.s	
      MPI_VERSION=`grep AAAAA conftest.s | sed -e 's/\ .*$//;'`
      MPI_SUBVERSION=`grep BBBBB conftest.s | sed -e 's/\ .*$//;'`
      AC_MSG_RESULT([$MPI_VERSION.$MPI_SUBVERSION])

      AC_MSG_CHECKING([for MPI vendor])
      if  test "x$MPI_VENDOR" = x; then  
        MPI_VENDOR=unknown
        if grep CCCCC conftest.s | grep 1 > /dev/null; then
           MPI_VENDOR=mpich
        elif grep DDDDD conftest.s | grep 1 > /dev/null; then
           MPI_VENDOR=lam
        fi;
      fi
      AC_MSG_RESULT([$MPI_VENDOR])

      AC_SUBST([MPI_VENDOR])
      AC_SUBST([MPI_VERSION])
      AC_SUBST([MPI_SUBVERSION])
      rm -f conftest.c conftest.s
    fi
    CCA_DIAGNOSE_END([MPICC])
 
    CCA_DIAGNOSE_BEGIN([MPICXX])
    LLNL_PROG_MPICXX
    CCA_DIAGNOSE_END([MPICXX])
    CCA_DIAGNOSE_BEGIN([MPIF77])
    LLNL_PROG_MPIF77
    CCA_DIAGNOSE_END([MPIF77])
    CCA_DIAGNOSE_BEGIN([MPIFC])
    LLNL_PROG_MPIFC
    CCA_DIAGNOSE_END([MPIFC])
  fi
])

#the strategy for all of these is the same
#  if ( the language is enabled ) { 
#     1. Find what MPI_* compiler front-end to use
#     2. Ensure the MPI_* can compile and link a MPI test code
#     3. Figure out what flag gets MPI_* to show its flags
#     4. Capture the underlying compiler, compile flags, and link flags
#     5. if underlying compiler is different from user compiler
#          verify that using underlying compiler, compile flags, and link 
#	   flags by hand will compile and link MPI test code.
#     6. verify that running USER's compiler, MPI's compile flags, and MPI's
#        link flags by hand will compile and link MPI test code.

AC_DEFUN([LLNL_PROG_MPICC],[
  dnl  NOTE:  ac_ct_$1 is set in autoconf standard macros for checking programs 
  dnl         and tools.  It seems sufficient to test if a compiler has been configured for
  if test "x$CC" != "x"; then 

    #
    # 1. Find what MPI_* compiler front-end to use
    #
    AC_ARG_VAR([MPI_CC], [Default MPI-enabled C compiler.])
    if test "x$MPI_CC" = xskip; then
      AC_MSG_NOTICE([Skipping MPI-enabled C compiler.])
    else
    if test "${MPI_CC+set}" != set; then 
      AC_MSG_NOTICE([Scanning for MPI-enabled C compiler.])
      AC_CHECK_PROGS([MPI_CC], [mpi$CC mp$CC MPI$CC MP$CC mpicc hcc mpcc mpcc_r mpxlc cmpicc], [none], [$mpi_searchpath])
    fi  
    AC_SUBST([MPI_CC])
    if test "$MPI_CC" = none; then
      AC_MSG_FAILURE([cannot find a MPI_CC compiler in $mpi_searchpath])
    fi

    #
    # 2. Ensure the MPI_* can compile and link a test MPI code
    #
    AC_CACHE_CHECK([if ($MPI_CC) compiles and links sample MPI code],
	           [llnl_cv_mpi_cc_works],
		   [llnl_cv_mpi_cc_works=no;
		    AC_LANG_PUSH(C)
		    user_CC="$CC"
		    CC="$MPI_CC"
		    AC_LINK_IFELSE([AC_LANG_PROGRAM([[
@%:@include "mpi.h"
int argc2=1;
char *argv2 @<:@ @:>@ = {"test"};
char **argv3=argv2; /*xlC workaround*/
]], [[MPI_Init(&argc2,&argv3)]])],[llnl_cv_mpi_cc_works=yes])
 		   CC="$user_CC"
                   AC_LANG_POP
    ])
    if test "$llnl_cv_mpi_cc_works" = no; then
      AC_MSG_FAILURE([Cannot compile with MPI_CC compiler ($MPI_CC)])
    fi
      
    #
    # 3. Figure out what flag gets MPI_* to show its flags
    # 
    possible_verbose_flags="-compile-info -compile_info -link-info -link_info -show -showme -v"
    if test "$llnl_cv_mpi_cc_works" = yes; then 
      user_CC="$CC"
      user_CFLAGS="$CFLAGS"
      verbose_flag=no
      verbose_flag_works=no
      for flag in $possible_verbose_flags; do 
         if test "$verbose_flag_works" = no; then
           case $flag in 
              -*) AC_MSG_CHECKING([for verbose output with ($MPI_CC $flag)])
	          candidate_verbose_flag="$flag"
		  ;;
  	       *) AC_MSG_CHECKING([for verbose output with $MPI_CC -$flag])
	          candidate_verbose_flag="-$flag"
	  	  ;;
	   esac
           CC="$MPI_CC"
           CFLAGS="$user_CFLAGS $candidate_verbose_flag"
  	   AC_LANG_CONFTEST([AC_LANG_PROGRAM([])])
	   (eval $CC $CFLAGS conftest.$ac_ext) > conf.out 2>&1 
           ac_status=$?
           if test "$ac_status" = 0 ; then
             if grep -- ' -[[IDLl]]' conf.out > /dev/null ; then  
  	       verbose_flag="$candidate_verbose_flag"
	       verbose_flag_works=yes
	     fi
           fi
           AC_MSG_RESULT([$verbose_flag_works])
         fi 
       done
       CC="$user_CC"
       CFLAGS="$user_CFLAGS"
    fi

    #
    # 4. Capture the underlying compiler, compile flags, and link flags
    #
    if test "$verbose_flag_works" = yes; then 
	user_CC="$CC"
	user_CFLAGS="$CFLAGS"
	user_LDFLAGS="$LDFLAGS"
        user_LIBS="$LIBS"
	CC="$MPI_CC"
	if test "$verbose_flag" = "-compile_info"; then 
 	  CFLAGS="-compile_info"
  	  LIBS="-link_info"
        elif test "$verbose_flag" = "-compile-info"; then
	  CFLAGS="-compile-info"
          LIBS="-link-info"
        else
 	  CFLAGS="$CFLAGS $verbose_flag"
          LIBS="$LDFLAGS $verbose_flag"
        fi

	# first the compiler
	AC_MSG_CHECKING([which C compiler ($MPI_CC) invokes])
        llnl_mpi_cc_c_v_output=`$MPI_CC -c $CFLAGS conftest.$ac_ext 2>&1`
        # The compiler should be the first thing that isn't something like "Build Line:"       
        for i in $llnl_mpi_cc_c_v_output; do 
           case $i in 
             Build|Link|Compile|Line:) continue ;;
             *) MPI_CC_CC=$i; break;; 
           esac;
        done;
	AC_MSG_RESULT([$MPI_CC_CC])
	if test "$MPI_CC_CC" != "$user_CC"; then 
 	  AC_MSG_WARN([your CC ($user_CC) may not be the same as $MPI_CC's CC ($MPI_CC_CC)])
 	  AC_MSG_WARN([please make sure these are compatible, or consider changing  your CC])
	fi 

        # now compile flags
        AC_MSG_CHECKING([what compile flags ($MPI_CC) passes to ($MPI_CC_CC)])	  
        if test "x$MPI_CC_CFLAGS" = x; then             
	  AC_LANG_CONFTEST([AC_LANG_PROGRAM([])])
	  MPI_CC_CFLAGS= 
	  for i in $llnl_mpi_cc_c_v_output; do 
            case $i in 
  	      -[[DIUbi]]*)
	         MPI_CC_CFLAGS="$MPI_CC_CFLAGS $i"
                 ;;
            esac
	  done

	  # now prune things in user_CFLAGS out of MPI_CC_CFLAGS
          MPI_CC_CFLAGS=" $MPI_CC_CFLAGS "
	  for i in $user_CFLAGS; do
	    MPI_CC_CFLAGS=`echo "$MPI_CC_CFLAGS" | sed -e "s! $i ! !"`
          done
          #clean up extra whitespace
          MPI_CC_CFLAGS=`echo $MPI_CC_CFLAGS`
        fi
	AC_MSG_RESULT([$MPI_CC_CFLAGS])

	# now the link flags
        AC_MSG_CHECKING([what link flags ($MPI_CC) passes to ($MPI_CC_CC)])
        if test "x$MPI_CC_LDFLAGS" = x; then             
          llnl_mpi_cc_link_v_output=`$MPI_CC -o conftest$ac_exeext $CFLAGS $CPPFLAGS $LDFLAGS conftest.$ac_ext $LIBS 2>&1`
	  MPI_CC_LDFLAGS=
	  for i in $llnl_mpi_cc_link_v_output; do 
            case $i in 
  	       [[\\/]]*.a | ?:[[\\/]]*.a | -[[lLRu]]* | -Wl*)
	          MPI_CC_LDFLAGS="$MPI_CC_LDFLAGS $i"
	       ;;
            esac
	  done

  	  # now prune things in user_LDFLAGS and user_LIBS out of MPI_CC_LDFLAGS
          MPI_CC_LDFLAGS=" $MPI_CC_LDFLAGS " 
	  for i in $user_LIBSS; do
	     MPI_CC_LDFLAGS=`echo "$MPI_CC_LDFLAGS" | sed -e "s! $i ! !"`
          done
	  for i in $LIBS; do
	     MPI_CC_LDFLAGS=`echo "$MPI_CC_LDFLAGS" | sed -e "s! $i ! !"`
          done
          #clean up extra whitespace
          MPI_CC_LDFLAGS=`echo $MPI_CC_LDFLAGS`
        fi      

	AC_MSG_RESULT([$MPI_CC_LDFLAGS])

	#
	#  5. if underlying compiler is different from user compiler
	#     verify that running underlying compiler, compile flags, and link 
	#     flags by hand will compile and link MPI test code.
	#
        other_works=no;
        if test "$MPI_CC_CC" != "$user_CC"; then 
 	  AC_MSG_CHECKING([if ($MPI_CC_CC \$MPI_CC_CFLAGS \$MPI_CC_LDFLAGS) compiles and links same MPI sample code ($MPI_CC) did])
	  CC="$MPI_CC_CC"
	  CFLAGS="$user_CFLAGS $MPI_CC_CFLAGS"
	  LIBS="$user_LDFLAGS $MPI_CC_LDFLAGS"
          AC_LINK_IFELSE([AC_LANG_PROGRAM([[
@%:@include "mpi.h"
int argc2=1;
char *argv2 @<:@ @:>@ = {"test"};
char **argv3=argv2; /*xlC workaround*/
]], [[MPI_Init(&argc2,&argv3)]])],[other_works=yes])
	  AC_MSG_RESULT([$other_works])
	fi

	#
	#     6. verify that running USER's compiler, MPI's compile flags, and MPI's
	#        link flags by hand will compile and link MPI test code.
	#
	AC_MSG_CHECKING([if ($user_CC \$MPI_CC_CFLAGS \$MPI_CC_LDFLAGS) compiles and links same MPI sample code ($MPI_CC) did])
	mpi_flags_work=no
	CC="$user_CC"
	CFLAGS="$user_CFLAGS $MPI_CC_CFLAGS"
	LIBS="$user_LDFLAGS $MPI_CC_LDFLAGS"
        AC_LINK_IFELSE([AC_LANG_PROGRAM([[
@%:@include "mpi.h"
int argc2=1;
char *argv2 @<:@ @:>@ = {"test"};
char **argv3=argv2; /*xlC workaround*/
]], [[MPI_Init(&argc2,&argv3)]])],[mpi_flags_work=yes])
        AC_MSG_RESULT([$mpi_flags_work])

        if test "$mpi_flags_work" = no -a "$other_works" = yes ; then
           AC_MSG_WARN([flags that work with $MPI_CC's compiler ($MPI_CC_CC), do not work with yours ($user_CC)])
           AC_MSG_WARN([recommend either an MPI built with $user_CC, or switch to the $MPI_CC_CC compiler])
 	  AC_MSG_FAILURE([cannot infer a working set of MPI flags for CC=$user_CC.])
	elif test "$mpi_flags_work" = no; then
 	  AC_MSG_FAILURE([cannot infer a working set of MPI flags for CC=$user_CC.])
	fi;

	AC_SUBST([MPI_CC_CFLAGS])
	AC_SUBST([MPI_CC_LDFLAGS])
	CC="$user_CC"
	CFLAGS="$user_CFLAGS"
	LDFLAGS="$user_LDFLAGS"
	LIBS="$user_LIBS"
    fi #test $verbose_flag_works = yes
    fi
  fi #end if ${ac_ct_CC+set}" = set; 
])

############################################################

AC_DEFUN([LLNL_PROG_MPICXX],[
  if test "X$enable_cxx" = "Xno"; then
    AC_DEFINE(CXX_DISABLED, 1, [If defined, Fortran support was disabled at configure time])
    msgs="$msgs
	  Cxx disabled by request";
  elif test "X$enable_cxx" = "Xbroken"; then
    AC_DEFINE(CXX_DISABLED, 1, [If defined, Fortran support was disabled at configure time])
    msgs="$msgs
          Fortran 90 disabled against user request: no viable compiler found.";    
  elif test "x$CXX" != "x" ; then

    #
    # 1. Find what MPI_* compiler front-end to use
    #
    AC_LANG_PUSH(C++)dnl     
    AC_ARG_VAR([MPI_CXX], [Default MPI-enabled C++ compiler.])
    if test "x$MPI_CXX" = xskip; then 
      AC_MSG_NOTICE([Skipping MPI-enabled C++ compiler.])
    else
    if test "${MPI_CXX+set}" != set; then 
      AC_MSG_NOTICE([scanning for MPI-enabled C++ compiler.])
      AC_CHECK_PROGS([MPI_CXX], [mpi$CXX mp$CXX MPI$CXX MP$CXX mpic++ mpc++ mpicxx hcxx mpcxx mpcxx_r mpxlC cmpicxx], [none], $mpi_searchpath)
    fi 
   AC_SUBST([MPI_CXX])
   if test "$MPI_CXX" = none; then
     AC_MSG_FAILURE([cannot find a MPI_CXX compiler in '$mpi_searchpath'])
   fi


    #
    # 2. Ensure the MPI_* can compile and link a test MPI code
    #
    if test "$MPI_VERSION" -eq 2 ; then 

      #
      # 2.a. Ensure the MPI_* can compile and link a test MPI 2.X code
      #
      AC_CACHE_CHECK([if ($MPI_CXX) compiles and links sample MPI-2 code],
  	           [llnl_cv_mpi_cxx_works],
  		   [llnl_cv_mpi_cxx_works=no;
  		    user_CXX="$CXX"
  		    CXX="$MPI_CXX"
  		    AC_LANG_PUSH(C++)
  		    AC_LINK_IFELSE([AC_LANG_PROGRAM([[
@%:@include "mpi.h"
]], [[MPI::Init()]])],[llnl_cv_mpi_cxx_works=yes])
    		    CXX="$user_CXX"
      ])
      if test "$llnl_cv_mpi_cxx_works" = no; then
        AC_MSG_WARN([Cannot compile MPI-2 with MPI_CXX compiler ($MPI_CXX).. trying MPI-1])
      fi
    fi
 
   if test "$MPI_VERSION" -eq 1 -o "$llnl_cv_mpi_cxx_works" == "no" ; then 
     AC_CACHE_CHECK([if ($MPI_CXX) compiles and links sample MPI-1 code],
	           [llnl_cv_mpi_cxx_works],
		   [llnl_cv_mpi_cxx_works=no;
		    user_CXX="$CXX"
		    CXX="$MPI_CXX"
		    AC_LANG_PUSH(C++)
		    AC_LINK_IFELSE([AC_LANG_PROGRAM([[
@%:@include "mpi.h"
int argc2=1;
char *argv2 @<:@ @:>@ = {"test"};
char **argv3=argv2; /*xlC workaround*/
]], [[MPI_Init(&argc2,&argv3)]])],[llnl_cv_mpi_cxx_works=yes])
 		   AC_LANG_POP
 		   CXX="$user_CXX"
      ])
      if test "$llnl_cv_mpi_cxx_works" = no; then
        AC_MSG_FAILURE([Cannot compile MPI-1 with MPI_CXX compiler ($MPI_CXX)])
      fi
    fi

    #
    # 3. Figure out what flag gets MPI_* to show its flags
    # 
    possible_verbose_flags="$candidate_verbose_flag -compile_info -link_info -show -showme -v"
    if test "$llnl_cv_mpi_cxx_works" = yes; then 
      user_CXX="$CXX"
      user_CXXFLAGS="$CXXFLAGS"
      verbose_flag=no
      verbose_flag_works=no
      for flag in $possible_verbose_flags; do 
         if test "$verbose_flag_works" = no; then
           case $flag in 
              -*) AC_MSG_CHECKING([for verbose output with ($MPI_CXX $flag)])
	          candidate_verbose_flag="$flag"
		  ;;
  	       *) AC_MSG_CHECKING([for verbose output with $MPI_CXX -$flag])
	          candidate_verbose_flag="-$flag"
	  	  ;;
	   esac
           CXX="$MPI_CXX"
           CXXFLAGS="$user_CXXFLAGS $candidate_verbose_flag"
  	   AC_LANG_CONFTEST([AC_LANG_PROGRAM([])])
	   (eval $CXX $CXXFLAGS conftest.$ac_ext) > conf.out 2>&1 
           ac_status=$?
           if test "$ac_status" = 0 ; then
             if grep -- ' -[[IDLl]]' conf.out > /dev/null ; then  
  	       verbose_flag="$candidate_verbose_flag"
	       verbose_flag_works=yes
	     fi
           fi
           AC_MSG_RESULT([$verbose_flag_works])
         fi 
       done
       CXX="$user_CXX"
       CXXFLAGS="$user_CXXFLAGS"
    fi

    #
    # 4. Capture the underlying compiler, compile flags, and link flags
    #
    if test "$verbose_flag_works" = yes; then 
	user_CXX="$CXX"
	user_CXXFLAGS="$CXXFLAGS"
        user_CXXLIBS="$LIBS"
	CXX="$MPI_CXX"
	if test "$verbose_flag" = "-compile_info"; then 
 	  CXXFLAGS="-compile_info"
  	  CXXLIBS="-link_info"
        elif test "$verbose_flag" = "-compile-info"; then
	  CXXFLAGS="-compile-info"
          CXXLIBS="-link-info"
         else
 	  CXXFLAGS="$CXXFLAGS $verbose_flag"
          CXXLIBS="$CXXLIBS $verbose_flag"
        fi
        
	# first the compiler
	AC_MSG_CHECKING([which C++ compiler ($MPI_CXX) invokes])
        llnl_mpi_cxx_c_v_output=`$MPI_CXX -c $CXXFLAGS conftest.$ac_ext 2>&1`

        # The compiler should be the first thing that isn't something like "Build Line:"       
        for i in $llnl_mpi_cxx_c_v_output; do 
           case $i in 
             Build|Link|Compile|Line:|"") continue ;;
             *) MPI_CXX_CXX=$i; break;; 
           esac;
        done;
	AC_MSG_RESULT([$MPI_CXX_CXX])
	if test "$MPI_CXX_CXX" != "$user_CXX"; then 
 	  AC_MSG_WARN([your CXX ($user_CXX) may not be the same as $MPI_CXX's CXX ($MPI_CXX_CXX)])
 	  AC_MSG_WARN([please make sure these are compatible, or consider changing  your CXX])
	fi 

        # now compile flags
	AC_MSG_CHECKING([what compile flags ($MPI_CXX) passes to ($user_CXX)])	  
        if test "x$MPI_CXX_CFLAGS" = x; then             
  	  AC_LANG_CONFTEST([AC_LANG_PROGRAM([])])
          llnl_mpi_cxx_c_v_output=`$MPI_CXX -c $CXXFLAGS conftest.$ac_ext 2>&1`
	  MPI_CXX_CFLAGS= 

	  for i in $llnl_mpi_cxx_c_v_output; do 
            case $i in 
  	      -[[DIUbi]]*)
	         MPI_CXX_CFLAGS="$MPI_CXX_CFLAGS $i"
                 ;;
            esac
	  done

	  # now prune things in user_CXXFLAGS out of MPI_CXX_CFLAGS
          MPI_CXX_CFLAGS=" $MPI_CXX_CFLAGS " 
	  for i in $user_CXXFLAGS; do
	    MPI_CXX_CFLAGS=`echo "$MPI_CXX_CFLAGS" | sed -e "s! $i ! !"`
          done
          #clean up whitespace
          MPI_CXX_CFLAGS=`echo $MPI_CXX_CFLAGS`
        fi
	AC_MSG_RESULT([$MPI_CXX_CFLAGS])

        #now the link flags
	AC_MSG_CHECKING([what link flags ($MPI_CXX) passes to ($user_CXX)])
        if test "x$MPI_CXX_LDFLAGS" = x; then             
          llnl_mpi_cxx_link_v_output=`$MPI_CXX -o conftest$ac_exeext $CXXFLAGS $CPPFLAGS conftest.$ac_ext $CXXLIBS 2>&1`
          MPI_CXX_LDFLAGS=
	  for i in $llnl_mpi_cxx_link_v_output; do 
            case $i in 
  	       [[\\/]]*.a | ?:[[\\/]]*.a | -[[lLRu]]* | -Wl* )
	          MPI_CXX_LDFLAGS="$MPI_CXX_LDFLAGS $i"
	         ;;
            esac
 	  done

	  # now prune things in user_CXXLIBS out of MPI_CXX_LDFLAGS
          MPI_CXX_LDFLAGS=" $MPI_CXX_LDFLAGS "
	  for i in $user_CXXLIBS; do
	     MPI_CXX_LDFLAGS=`echo "$MPI_CXX_LDFLAGS" | sed -e "s! $i ! !"`
          done
	  for i in $CXXLIBS; do
	     MPI_CXX_LDFLAGS=`echo "$MPI_CXX_LDFLAGS" | sed -e "s! $i ! !"`
          done
          #clean up whitespace
          MPI_CXX_LDFLAGS=`echo $MPI_CXX_LDFLAGS`
        fi
	AC_MSG_RESULT([$MPI_CXX_LDFLAGS])

	#
	#  5. if underlying compiler is different from user compiler
	#     verify that running underlying compiler, compile flags, and link 
	#     flags by hand will compile and link test app.
	#
        other_works=no;
        if test "$MPI_CXX_CXX" != "$user_CXX"; then 
 	  AC_MSG_CHECKING([if ($MPI_CXX_CXX \$MPI_CXX_CFLAGS \$MPI_CXX_LDFLAGS) compiles and links same MPI code ($MPI_CXX) did])
	  CXX="$MPI_CXX_CXX"
	  CXXFLAGS="$user_CXXFLAGS $MPI_CXX_CFLAGS"
	  LIBS="$user_CXXLIBS $MPI_CXX_LDFLAGS"
          AC_LINK_IFELSE([AC_LANG_PROGRAM([[
@%:@include "mpi.h"
int argc2=1;
char *argv2 @<:@ @:>@ = {"test"};
char **argv3=argv2; /*xlC workaround*/
]], [[MPI_Init(&argc2,&argv3)]])],[other_works=yes])
	  AC_MSG_RESULT([$other_works])
	fi

	#
	#     6. verify that running USER's compiler, MPI's compile flags, and MPI's
	#        link flags by hand will compile and link test app
	#
	AC_MSG_CHECKING([if ($user_CXX \$MPI_CXX_CFLAGS \$MPI_CXX_LDFLAG) compiles and links same MPI code ($MPI_CXX) did])
	mpi_flags_work=no
	CXX="$user_CXX"
	CXXFLAGS="$user_CXXFLAGS $MPI_CXX_CFLAGS"
	LIBS="$user_CXXLIBS $MPI_CXX_LDFLAGS"
        AC_LINK_IFELSE([AC_LANG_PROGRAM([[
@%:@include "mpi.h"
int argc2=1;
char *argv2 @<:@ @:>@ = {"test"};
char **argv3=argv2; /*xlC workaround*/
]], [[MPI_Init(&argc2,&argv3)]])],[mpi_flags_work=yes])
        AC_MSG_RESULT([$mpi_flags_work])


        if test "$mpi_flags_work" = no -a "$other_works" = yes ; then
           AC_MSG_WARN([flags that work with $MPI_CXX's compiler ($MPI_CXX_CXX), do not work with yours ($user_CXX)])
           AC_MSG_WARN([recommend either an MPI built with $user_CXX, or switch to the $MPI_CXX_CXX compiler])
 	  AC_MSG_FAILURE([cannot infer a working set of MPI flags for CXX=$user_CXX.])
	elif test "$mpi_flags_work" = no; then
 	  AC_MSG_FAILURE([cannot infer a working set of MPI flags for CXX=$user_CXX.])
	fi;

	AC_SUBST([MPI_CXX_CFLAGS])
        AC_SUBST([MPI_CXX_LDFLAGS])
	CXX="$user_CXX"
	CXXFLAGS="$user_CXXFLAGS"
        LIBS="$user_CXXLIBS"
    fi #test $verbose_flag_works = yes
    fi
    AC_LANG_POP
  fi #end if ${ac_ct_CXX+set}" = set 
])

############################################################

AC_DEFUN([LLNL_PROG_MPIF77],[
  if test "X$enable_fortran77" = "Xno"; then
    AC_DEFINE(FORTRAN77_DISABLED, 1, [If defined, Fortran support was disabled at configure time])
    msgs="$msgs
	  Fortran77 disabled by request";
  elif test "X$enable_fortran77" = "Xbroken"; then
    AC_DEFINE(FORTRAN77_DISABLED, 1, [If defined, Fortran support was disabled at configure time])
    msgs="$msgs
          Fortran 77 disabled against user request: no viable compiler found.";    
  elif test "x$F77" != "x" ; then

    #
    # 1. Find what MPI_* compiler front-end to use
    #
    AC_LANG_PUSH(Fortran 77)dnl     
    AC_ARG_VAR([MPI_F77], [Default MPI-enabled Fortran 77 compiler.])
    if test "x$MPI_F77" = xskip; then 
      AC_MSG_NOTICE([Skipping MPI-enabled Fortran 77 compiler.])
    else
    if test "${MPI_F77+set}" != set; then 
      AC_MSG_NOTICE([scanning for MPI-enabled F77 compiler.])
      AC_CHECK_PROGS([MPI_F77], [mpi$F77 mp$F77 MPI$F77 MP$F77 mpif77 mpf77 mpif77 hf77 mpf77 mpf77_r mpxlf77 cmpif77 mpxlf77_r mpxlf mpxlf_r], [none], $mpi_searchpath)
    fi 
   AC_SUBST([MPI_F77])
   if test "$MPI_F77" = none; then
     AC_MSG_FAILURE([cannot find a MPI_F77 compiler in '$mpi_searchpath'])
   fi


    #
    # 2. Ensure the MPI_* can compile and link a test MPI code
    #
    if test "$MPI_VERSION" -eq 2 ; then 

      #
      # 2.a. Ensure the MPI_* can compile and link a test MPI 2.X code
      #
      AC_CACHE_CHECK([if ($MPI_F77) compiles and links sample MPI-2 code],
  	           [llnl_cv_mpi_f77_works],
  		   [llnl_cv_mpi_f77_works=no;
  		    user_F77="$F77"
  		    F77="$MPI_F77"
  		    AC_LANG_PUSH(Fortran 77)
  		    AC_LINK_IFELSE([AC_LANG_PROGRAM([],[[
      include 'mpif.h'
      integer numtasks, rank, ierr, rc
      call MPI_INIT(ierr)
      if (ierr .ne. MPI_SUCCESS) then
      print *,'Error starting MPI program. Terminating.'
      call MPI_ABORT(MPI_COMM_WORLD, rc, ierr)
      end if
      call MPI_COMM_RANK(MPI_COMM_WORLD, rank, ierr)
      call MPI_COMM_SIZE(MPI_COMM_WORLD, numtasks, ierr)
      call MPI_FINALIZE(ierr)
]])],[llnl_cv_mpi_f77_works=yes])
    		    F77="$user_F77"
      ])
      if test "$llnl_cv_mpi_f77_works" = no; then
        AC_MSG_WARN([Cannot compile MPI-2 with MPI_F77 compiler ($MPI_F77).. trying MPI-1])
      fi
    fi
 
   if test "$MPI_VERSION" -eq 1 -o "$llnl_cv_mpi_f77_works" == "no" ; then 
     AC_CACHE_CHECK([if ($MPI_F77) compiles and links sample MPI-1 code],
	           [llnl_cv_mpi_f77_works],
		   [llnl_cv_mpi_f77_works=no;
		    user_F77="$F77"
		    F77="$MPI_F77"
		    AC_LANG_PUSH(Fortran 77)
		    AC_LINK_IFELSE([AC_LANG_PROGRAM([], [[
      include 'mpif.h'
      integer numtasks, rank, ierr, rc
      call MPI_INIT(ierr)
      if (ierr .ne. MPI_SUCCESS) then
      print *,'Error starting MPI program. Terminating.'
      call MPI_ABORT(MPI_COMM_WORLD, rc, ierr)
      end if
      call MPI_COMM_RANK(MPI_COMM_WORLD, rank, ierr)
      call MPI_COMM_SIZE(MPI_COMM_WORLD, numtasks, ierr)
      call MPI_FINALIZE(ierr)
]])],[llnl_cv_mpi_f77_works=yes])
 		   AC_LANG_POP
 		   F77="$user_F77"
      ])
      if test "$llnl_cv_mpi_f77_works" = no; then
        AC_MSG_FAILURE([Cannot compile MPI-1 with MPI_F77 compiler ($MPI_F77)])
      fi
    fi

    #
    # 3. Figure out what flag gets MPI_* to show its flags
    # 
    possible_verbose_flags="$candidate_verbose_flag -compile_info -link_info -show -showme -v"
    if test "$llnl_cv_mpi_f77_works" = yes; then 
      user_F77="$F77"
      user_FFLAGS="$FFLAGS"
      verbose_flag=no
      verbose_flag_works=no
      for flag in $possible_verbose_flags; do 
         if test "$verbose_flag_works" = no; then
           case $flag in 
              -*) AC_MSG_CHECKING([for verbose output with ($MPI_F77 $flag)])
	          candidate_verbose_flag="$flag"
		  ;;
  	       *) AC_MSG_CHECKING([for verbose output with $MPI_F77 -$flag])
	          candidate_verbose_flag="-$flag"
	  	  ;;
	   esac
           F77="$MPI_F77"
           FFLAGS="$user_FFLAGS $candidate_verbose_flag"
  	   AC_LANG_CONFTEST([AC_LANG_PROGRAM([])])
	   (eval $F77 $FFLAGS conftest.$ac_ext) > conf.out 2>&1 
           ac_status=$?
           if test "$ac_status" = 0 ; then
             if grep -- ' -[[IDLl]]' conf.out > /dev/null ; then  
  	       verbose_flag="$candidate_verbose_flag"
	       verbose_flag_works=yes
	     fi
           fi
           AC_MSG_RESULT([$verbose_flag_works])
         fi 
       done
       F77="$user_F77"
       FFLAGS="$user_FFLAGS"
    fi

    #
    # 4. Capture the underlying compiler, compile flags, and link flags
    #
    if test "$verbose_flag_works" = yes; then 
	user_F77="$F77"
	user_FFLAGS="$FFLAGS"
        user_F77LIBS="$LIBS"
	F77="$MPI_F77"
	if test "$verbose_flag" = "-compile_info"; then 
 	  FFLAGS="-compile_info"
  	  F77LIBS="-link_info"
        elif test "$verbose_flag" = "-compile-info"; then
	  FFLAGS="-compile-info"
          F77LIBS="-link-info"
         else
 	  FFLAGS="$FFLAGS $verbose_flag"
          F77LIBS="$F77LIBS $verbose_flag"
        fi
        
	# first the compiler
	AC_MSG_CHECKING([which F77 compiler ($MPI_F77) invokes])
        llnl_mpi_f77_c_v_output=`$MPI_F77 -c $FFLAGS conftest.$ac_ext 2>&1`

        # The compiler should be the first thing that isn't something like "Build Line:"       
        for i in $llnl_mpi_f77_c_v_output; do 
           case $i in 
             Build|Link|Compile|Line:|" ") continue ;;
             *) MPI_F77_F77=$i; break;; 
           esac;
        done;

	AC_MSG_RESULT([$MPI_F77_F77])
	if test "$MPI_F77_F77" != "$user_F77"; then 
 	  AC_MSG_WARN([your F77 ($user_F77) may not be the same as $MPI_F77's F77 ($MPI_F77_F77)])
 	  AC_MSG_WARN([please make sure these are compatible, or consider changing  your F77])
	fi 

        # now compile flags
	AC_MSG_CHECKING([what compile flags ($MPI_F77) passes to ($user_F77)])	  
        if test "x$MPI_F77_CFLAGS" = x; then             
  	  AC_LANG_CONFTEST([AC_LANG_PROGRAM([])])
          llnl_mpi_f77_c_v_output=`$MPI_F77 -c $FFLAGS conftest.$ac_ext 2>&1`
	  MPI_F77_CFLAGS= 
	  for i in $llnl_mpi_f77_c_v_output; do 
            case $i in 
            #I had to include f here to pick up -fno-second-underscore for g77
            #Probably really not the best place to pick this up.  Maybe it should
            #be in FFLAGS when we figure out the underscore nubmer earlier?
  	      -[[DIUbif]]*)
	         MPI_F77_CFLAGS="$MPI_F77_CFLAGS $i"
                 ;;
            esac
	  done

	  # now prune things in user_FFLAGS out of MPI_F77_CFLAGS
          MPI_F77_CFLAGS=" $MPI_F77_CFLAGS " 
	  for i in $user_FFLAGS; do
	    MPI_F77_CFLAGS=`echo "$MPI_F77_CFLAGS" | sed -e "s! $i ! !"`
          done
          #clean up whitespace
          MPI_F77_CFLAGS=`echo $MPI_F77_CFLAGS`
        fi
	AC_MSG_RESULT([$MPI_F77_CFLAGS])

        # now link flags
	AC_MSG_CHECKING([what link flags ($MPI_F77) passes to ($user_F77)])
        if test "x$MPI_F77_LDFLAGS" = x; then             
          llnl_mpi_f77_link_v_output=`$MPI_F77 -o conftest$ac_exeext $FFLAGS  conftest.$ac_ext $F77LIBS 2>&1`
          MPI_F77_LDFLAGS=
	  for i in $llnl_mpi_f77_link_v_output; do 
            case $i in 
  	       [[\\/]]*.a | ?:[[\\/]]*.a | -[[lLRu]]* | -Wl* )
	          MPI_F77_LDFLAGS="$MPI_F77_LDFLAGS $i"
	       ;;
            esac
	  done

 	  # now prune things in user_F77LIBS out of MPI_F77_LDFLAGS
          MPI_F77_LDFLAGS=" $MPI_F77_LDFLAGS " 
	  for i in $user_F77LIBS; do
	     MPI_F77_LDFLAGS=`echo "$MPI_F77_LDFLAGS" | sed -e "s! $i ! !"`
          done
	  for i in $F77LIBSS; do
	     MPI_F77_LDFLAGS=`echo "$MPI_F77_LDFLAGS" | sed -e "s! $i ! !"`
          done

          #clean up whitespace
          MPI_F77_LDFLAGS=`echo $MPI_F77_LDFLAGS`
        fi

	AC_MSG_RESULT([$MPI_F77_LDFLAGS])

	#
	#  5. if underlying compiler is different from user compiler
	#     verify that running underlying compiler, compile flags, and link 
	#     flags by hand will compile and link test app.
	#
        other_works=no;
        if test "$MPI_F77_F77" != "$user_F77"; then 
 	  AC_MSG_CHECKING([if ($MPI_F77_F77 \$MPI_F77_CFLAGS \$MPI_F77_LDFLAGS) compiles and links same MPI code ($MPI_F77) did])
	  F77="$MPI_F77_F77"
	  FFLAGS="$user_FFLAGS $MPI_F77_CFLAGS"
	  LIBS="$user_F77LIBS $MPI_F77_LDFLAGS"
          AC_LINK_IFELSE([AC_LANG_PROGRAM([], [[
      include 'mpif.h'
      integer numtasks, rank, ierr, rc
      call MPI_INIT(ierr)
      if (ierr .ne. MPI_SUCCESS) then
      print *,'Error starting MPI program. Terminating.'
      call MPI_ABORT(MPI_COMM_WORLD, rc, ierr)
      end if
      call MPI_COMM_RANK(MPI_COMM_WORLD, rank, ierr)
      call MPI_COMM_SIZE(MPI_COMM_WORLD, numtasks, ierr)
      call MPI_FINALIZE(ierr)
]])],[other_works=yes])
	  AC_MSG_RESULT([$other_works])
	fi

	#
	#     6. verify that running USER's compiler, MPI's compile flags, and MPI's
	#        link flags by hand will compile and link test app
	#
	AC_MSG_CHECKING([if ($user_F77 \$MPI_F77_CFLAGS \$MPI_F77_LDFLAG) compiles and links same MPI code ($MPI_F77) did])
	mpi_flags_work=no
	F77="$user_F77"
	FFLAGS="$user_FFLAGS $MPI_F77_CFLAGS"
	LIBS="$user_F77LIBS $MPI_F77_LDFLAGS"
        AC_LINK_IFELSE([AC_LANG_PROGRAM([], [[
      include 'mpif.h'
      integer numtasks, rank, ierr, rc
      call MPI_INIT(ierr)
      if (ierr .ne. MPI_SUCCESS) then
      print *,'Error starting MPI program. Terminating.'
      call MPI_ABORT(MPI_COMM_WORLD, rc, ierr)
      end if
      call MPI_COMM_RANK(MPI_COMM_WORLD, rank, ierr)
      call MPI_COMM_SIZE(MPI_COMM_WORLD, numtasks, ierr)
      call MPI_FINALIZE(ierr)
]])],[mpi_flags_work=yes])
        AC_MSG_RESULT([$mpi_flags_work])


        if test "$mpi_flags_work" = no -a "$other_works" = yes ; then
           AC_MSG_WARN([flags that work with $MPI_F77's compiler ($MPI_F77_F77), do not work with yours ($user_F77)])
           AC_MSG_WARN([recommend either an MPI built with $user_F77, or switch to the $MPI_F77_F77 compiler])
 	  AC_MSG_FAILURE([cannot infer a working set of MPI flags for F77=$user_F77.])
	elif test "$mpi_flags_work" = no; then
 	  AC_MSG_FAILURE([cannot infer a working set of MPI flags for F77=$user_F77.])
	fi;

	AC_SUBST([MPI_F77_CFLAGS])
        AC_SUBST([MPI_F77_LDFLAGS])
	F77="$user_F77"
	FFLAGS="$user_FFLAGS"
        LIBS="$user_F77LIBS"
    fi #test $verbose_flag_works = yes
    fi
    AC_LANG_POP
  fi #end if ${ac_ct_F77+set}" = set 
])



############################################################

AC_DEFUN([LLNL_PROG_MPIFC],[
  if test "X$enable_fortran90" = "Xno"; then
    AC_DEFINE(FORTRAN90_DISABLED, 1, [If defined, Fortran support was disabled at configure time])
    msgs="$msgs
	  Fortran90 disabled by request";
  elif test "X$enable_fortran90" = "Xbroken"; then
    AC_DEFINE(FORTRAN90_DISABLED, 1, [If defined, Fortran support was disabled at configure time])
    msgs="$msgs
          Fortran 90 disabled against user request: no viable compiler found.";    
  elif test "x$FC" != "x" ; then

    #
    # 1. Find what MPI_* compiler front-end to use
    #
    AC_LANG_PUSH(Fortran)dnl     
    AC_ARG_VAR([MPI_FC], [Default MPI-enabled Fortran 90 compiler.])
    if test "x$MPI_FC" = xskip; then 
      AC_MSG_NOTICE([Skipping MPI-enabled Fortran 90 compiler.])
    else
    if test "${MPI_FC+set}" != set; then 
      AC_MSG_NOTICE([scanning for MPI-enabled F90 compiler.])
      AC_CHECK_PROGS([MPI_FC], [mpi$FC mp$FC MPI$FC MP$FC mpif90 mpf90 mpif90 hf90 mpf90 mpf90_r mpxlf90 cmpif90 mpxlf90_r mpif95 mpf95 mpif95 hf95 mpf95 mpf95_r mpxlf95 cmpif95 mpxlf95_r], [none], $mpi_searchpath)
    fi 
   AC_SUBST([MPI_FC])
   if test "$MPI_FC" = none; then
     AC_MSG_FAILURE([cannot find a MPI_FC compiler in '$mpi_searchpath'])
   fi


    #
    # 2. Ensure the MPI_* can compile and link a test MPI code
    #
    if test "$MPI_VERSION" -eq 2 ; then 

      #
      # 2.a. Ensure the MPI_* can compile and link a test MPI 2.X code
      #
      AC_CACHE_CHECK([if ($MPI_FC) compiles and links sample MPI-2 code],
  	           [llnl_cv_mpi_fc_works],
  		   [llnl_cv_mpi_fc_works=no;
  		    user_FC="$FC"
  		    FC="$MPI_FC"
  		    AC_LANG_PUSH(Fortran)
  		    AC_LINK_IFELSE([AC_LANG_PROGRAM([],[[
        include 'mpif.h'
        integer numtasks, rank, ierr, rc
        call MPI_INIT(ierr)
        if (ierr .ne. MPI_SUCCESS) then
        print *,'Error starting MPI program. Terminating.'
        call MPI_ABORT(MPI_COMM_WORLD, rc, ierr)
        end if
        call MPI_COMM_RANK(MPI_COMM_WORLD, rank, ierr)
        call MPI_COMM_SIZE(MPI_COMM_WORLD, numtasks, ierr)
        call MPI_FINALIZE(ierr)
]])],[llnl_cv_mpi_fc_works=yes])
    		    FC="$user_FC"
      ])
      if test "$llnl_cv_mpi_fc_works" = no; then
        AC_MSG_WARN([Cannot compile MPI-2 with MPI_FC compiler ($MPI_FC).. trying MPI-1])
      fi
    fi
 
   if test "$MPI_VERSION" -eq 1 -o "$llnl_cv_mpi_fc_works" == "no" ; then 
     AC_CACHE_CHECK([if ($MPI_FC) compiles and links sample MPI-1 code],
	           [llnl_cv_mpi_fc_works],
		   [llnl_cv_mpi_fc_works=no;
		    user_FC="$FC"
		    FC="$MPI_FC"
		    AC_LANG_PUSH(Fortran)
		    AC_LINK_IFELSE([AC_LANG_PROGRAM([], [[
        include 'mpif.h'
        integer numtasks, rank, ierr, rc
        call MPI_INIT(ierr)
        if (ierr .ne. MPI_SUCCESS) then
        print *,'Error starting MPI program. Terminating.'
        call MPI_ABORT(MPI_COMM_WORLD, rc, ierr)
        end if
        call MPI_COMM_RANK(MPI_COMM_WORLD, rank, ierr)
        call MPI_COMM_SIZE(MPI_COMM_WORLD, numtasks, ierr)
        call MPI_FINALIZE(ierr)
]])],[llnl_cv_mpi_fc_works=yes])
 		   AC_LANG_POP
 		   FC="$user_FC"
      ])
      if test "$llnl_cv_mpi_fc_works" = no; then
        AC_MSG_FAILURE([Cannot compile MPI-1 with MPI_FC compiler ($MPI_FC)])
      fi
    fi

    #
    # 3. Figure out what flag gets MPI_* to show its flags
    # 
    possible_verbose_flags="$candidate_verbose_flag -compile_info -link_info -show -showme -v"
    if test "$llnl_cv_mpi_fc_works" = yes; then 
      user_FC="$FC"
      user_FCFLAGS="$FCFLAGS"
      verbose_flag=no
      verbose_flag_works=no
      for flag in $possible_verbose_flags; do 
         if test "$verbose_flag_works" = no; then
           case $flag in 
              -*) AC_MSG_CHECKING([for verbose output with ($MPI_FC $flag)])
	          candidate_verbose_flag="$flag"
		  ;;
  	       *) AC_MSG_CHECKING([for verbose output with $MPI_FC -$flag])
	          candidate_verbose_flag="-$flag"
	  	  ;;
	   esac
           FC="$MPI_FC"
           FCFLAGS="$user_FCFLAGS $candidate_verbose_flag"
  	   AC_LANG_CONFTEST([AC_LANG_PROGRAM([])])
	   (eval $FC $FCFLAGS conftest.$ac_ext) > conf.out 2>&1 
           ac_status=$?
           if test "$ac_status" = 0 ; then
             if grep -- ' -[[IDLl]]' conf.out > /dev/null ; then  
  	       verbose_flag="$candidate_verbose_flag"
	       verbose_flag_works=yes
	     fi
           fi
           AC_MSG_RESULT([$verbose_flag_works])
         fi 
       done
       FC="$user_FC"
       FCFLAGS="$user_FCFLAGS"
    fi

    #
    # 4. Capture the underlying compiler, compile flags, and link flags
    #
    if test "$verbose_flag_works" = yes; then 
	user_FC="$FC"
	user_FCFLAGS="$FCFLAGS"
        user_FCLIBS="$LIBS"
	FC="$MPI_FC"
	if test "$verbose_flag" = "-compile_info"; then 
 	  FCFLAGS="-compile_info"
  	  FCLIBS="-link_info"
        elif test "$verbose_flag" = "-compile-info"; then
	  FCFLAGS="-compile-info"
          FCLIBS="-link-info"
         else
 	  FCFLAGS="$FCFLAGS $verbose_flag"
          FCLIBS="$FCLIBS $verbose_flag"
        fi
        
	# first the compiler
	AC_MSG_CHECKING([which F90 compiler ($MPI_FC) invokes])
        llnl_mpi_fc_c_v_output=`$MPI_FC -c $FCFLAGS conftest.$ac_ext 2>&1`

        # The compiler should be the first thing that isn't something like "Build Line:"       
        for i in $llnl_mpi_fc_c_v_output; do 
           case $i in 
             Build|Link|Compile|Line:|"") continue ;;
             *) MPI_FC_FC=$i; break;; 
           esac;
        done;

	AC_MSG_RESULT([$MPI_FC_FC])
	if test "$MPI_FC_FC" != "$user_FC"; then 
 	  AC_MSG_WARN([your FC ($user_FC) may not be the same as $MPI_FC's FC ($MPI_FC_FC)])
 	  AC_MSG_WARN([please make sure these are compatible, or consider changing  your FC])
	fi 

        # now compile flags
	AC_MSG_CHECKING([what compile flags ($MPI_FC) passes to ($user_FC)])	  
        if test "x$MPI_FC_CFLAGS" = x; then           
	  AC_LANG_CONFTEST([AC_LANG_PROGRAM([])])
          llnl_mpi_fc_c_v_output=`$MPI_FC -c $FCFLAGS conftest.$ac_ext 2>&1`
	  MPI_FC_CFLAGS= 
	  for i in $llnl_mpi_fc_c_v_output; do 
            case $i in 
  	      -[[DIUbif]]*)
	         MPI_FC_CFLAGS="$MPI_FC_CFLAGS $i"
                 ;;
            esac
	  done

	  # now prune things in user_FCFLAGS out of MPI_FC_CFLAGS
          MPI_FC_CFLAGS=" $MPI_FC_CFLAGS "  
	  for i in $user_FCFLAGS; do
	    MPI_FC_CFLAGS=`echo "$MPI_FC_CFLAGS" | sed -e "s! $i ! !"`
          done
          #clean up whitespace
          MPI_FC_CFLAGS=`echo $MPI_FC_CFLAGS`
        fi
	AC_MSG_RESULT([$MPI_FC_CFLAGS])

        # now link flags
	AC_MSG_CHECKING([what link flags ($MPI_FC) passes to ($user_FC)])
        if test "x$MPI_FC_LDFLAGS" = x; then 
          llnl_mpi_fc_link_v_output=`$MPI_FC -o conftest$ac_exeext $FCFLAGS  conftest.$ac_ext $FCLIBS 2>&1`
          MPI_FC_LDFLAGS=
	  for i in $llnl_mpi_fc_link_v_output; do 
            case $i in 
  	       [[\\/]]*.a | ?:[[\\/]]*.a | -[[lLRu]]* | -Wl* )
	          MPI_FC_LDFLAGS="$MPI_FC_LDFLAGS $i"
	       ;;
            esac
	  done
        

  	  # now prune things in user_FCLIBS and FCLIBS out of MPI_FC_LDFLAGS
          MPI_FC_LDFLAGS=" $MPI_FC_LDFLAGS "
	  for i in $user_FCLIBS; do
	     MPI_FC_LDFLAGS=`echo "$MPI_FC_LDFLAGS" | sed -e "s! $i ! !"`
          done
	  for i in $FCLIBS; do
	    MPI_FC_LDFLAGS=`echo "$MPI_FC_LDFLAGS" | sed -e "s! $i ! !"`
          done

          #clean up whitespace
          MPI_FC_LDFLAGS=`echo $MPI_FC_LDFLAGS`
        fi
	AC_MSG_RESULT([$MPI_FC_LDFLAGS])

	#
	#  5. if underlying compiler is different from user compiler
	#     verify that running underlying compiler, compile flags, and link 
	#     flags by hand will compile and link test app.
	#
        other_works=no;
        if test "$MPI_FC_FC" != "$user_FC"; then 
 	  AC_MSG_CHECKING([if ($MPI_FC_FC \$MPI_FC_CFLAGS \$MPI_FC_LDFLAGS) compiles and links same MPI code ($MPI_FC) did])
	  FC="$MPI_FC_FC"
	  FCFLAGS="$user_FCFLAGS $MPI_FC_CFLAGS"
	  LIBS="$user_FCLIBS $MPI_FC_LDFLAGS"
          AC_LINK_IFELSE([AC_LANG_PROGRAM([], [[
        include 'mpif.h'
        integer numtasks, rank, ierr, rc
        call MPI_INIT(ierr)
        if (ierr .ne. MPI_SUCCESS) then
        print *,'Error starting MPI program. Terminating.'
        call MPI_ABORT(MPI_COMM_WORLD, rc, ierr)
        end if
        call MPI_COMM_RANK(MPI_COMM_WORLD, rank, ierr)
        call MPI_COMM_SIZE(MPI_COMM_WORLD, numtasks, ierr)
        call MPI_FINALIZE(ierr)
]])],[other_works=yes])
	  AC_MSG_RESULT([$other_works])
	fi

	#
	#     6. verify that running USER's compiler, MPI's compile flags, and MPI's
	#        link flags by hand will compile and link test app
	#
	AC_MSG_CHECKING([if ($user_FC \$MPI_FC_CFLAGS \$MPI_FC_LDFLAG) compiles and links same MPI code ($MPI_FC) did])
	mpi_flags_work=no
	FC="$user_FC"
	FCFLAGS="$user_FCFLAGS $MPI_FC_CFLAGS"
	LIBS="$user_FCLIBS $MPI_FC_LDFLAGS"
        AC_LINK_IFELSE([AC_LANG_PROGRAM([], [[
        include 'mpif.h'
        integer numtasks, rank, ierr, rc
        call MPI_INIT(ierr)
        if (ierr .ne. MPI_SUCCESS) then
        print *,'Error starting MPI program. Terminating.'
        call MPI_ABORT(MPI_COMM_WORLD, rc, ierr)
        end if
        call MPI_COMM_RANK(MPI_COMM_WORLD, rank, ierr)
        call MPI_COMM_SIZE(MPI_COMM_WORLD, numtasks, ierr)
        call MPI_FINALIZE(ierr)
]])],[mpi_flags_work=yes])
        AC_MSG_RESULT([$mpi_flags_work])


        if test "$mpi_flags_work" = no -a "$other_works" = yes ; then
           AC_MSG_WARN([flags that work with $MPI_FC's compiler ($MPI_FC_FC), do not work with yours ($user_FC)])
           AC_MSG_WARN([recommend either an MPI built with $user_FC, or switch to the $MPI_FC_FC compiler])
 	  AC_MSG_FAILURE([cannot infer a working set of MPI flags for FC=$user_FC.])
	elif test "$mpi_flags_work" = no; then
 	  AC_MSG_FAILURE([cannot infer a working set of MPI flags for FC=$user_FC.])
	fi;

	AC_SUBST([MPI_FC_CFLAGS])
        AC_SUBST([MPI_FC_LDFLAGS])
	FC="$user_FC"
	FCFLAGS="$user_FCFLAGS"
        LIBS="$user_FCLIBS"
    fi #test $verbose_flag_works = yes
    fi
    AC_LANG_POP
  fi #end if ${ac_ct_FC+set}" = set 
])


#AC_DEFUN([LLNL_PROG_MPIFC],[
# This is a very simple test to allow the user to set up MPI for FC if the really want to.
#  AC_MSG_CHECKING([Checking if we can pull MPI_FC flags from the environment...])

#  if test "${MPI_FC+set}" = set -a "${MPI_FC_CFLAGS+set}" = set -a "${MPI_FC_LDFLAGS+set}" = set; then 
#    AC_SUBST([MPI_FC])
#    AC_SUBST([MPI_FC_CFLAGS])
#    AC_SUBST([MPI_FC_LDFLAGS])
#    AC_MSG_RESULT([yes])
#  elif test "${MPI_FC+set}" != set -a "${MPI_FC_CFLAGS+set}" != set -a "${MPI_FC_LDFLAGS+set}" != set; then
#    AC_MSG_RESULT([no, none defined.]);
#    AC_MSG_NOTICE([Sorry, test for MPI-enabled FC compiler not yet implemented.])	
#  else
#    AC_MSG_RESULT([no, some undefined.]);
#    AC_MSG_FAILURE([Sorry, test for MPI-enabled FC compiler not yet implemented.  Either define MPI_FC, MPI_FC_CFLAGS, and MPI_FC_LDFLAGS, or none of them.])	
#  fi;

#])
