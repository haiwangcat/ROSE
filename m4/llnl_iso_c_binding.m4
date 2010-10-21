dnl
dnl @synopsis LLNL_ISO_C_BINDING
dnl
dnl
dnl @author muszala
dnl
dnl Note:  Define a configuraion macro to see if bindC is requested and then
dnl if the Fortran compiler actually has the iso_c_binding module.
AC_DEFUN([LLNL_ISO_C_BINDING], 
[ 
  AC_MSG_CHECKING([if BindC is requested])
    ac_arg_with_bindc=no
    AC_ARG_WITH([bindc],
      AS_HELP_STRING(--with-bindc@<:@=bindc@:>@,F2003 iso_c_binding support @<:@default=no@:>@),
      [ case $withval in
          no) ac_arg_with_bindc=no ;; 
          yes)
           ac_arg_with_bindc=yes 
          ;; 
          *) ac_arg_with_bindc=no;
        esac]) # end AC_ARG_WITH
  AC_MSG_RESULT([$ac_arg_with_bindc])
  if test $ac_arg_with_bindc = yes; then
    AC_CACHE_CHECK([if this Fortran compiler actually has iso_c_binding],
    llnl_cv_enable_bindc,
    [AC_LANG_PUSH(Fortran)dnl
    AC_COMPILE_IFELSE([
      program main  
          use, intrinsic :: iso_c_binding
          type, bind(c) :: ftest
            real(c_double)         :: d_dbl
            real(c_float)          :: d_flt
            complex(c_float_complex)  :: d_fcmplx
	    complex(c_double_complex) :: d_dcmplx
            integer(c_int32_t)     :: d_int
            integer(c_int64_t)     :: d_long
            type(c_ptr)            :: d_opaque
          end type ftest
      end
      ],
      [llnl_cv_enable_bindc="yes"],
      [llnl_cv_enable_bindc="no"])
    AC_LANG_POP(Fortran)dnl
    ])
    if test "$llnl_cv_enable_bindc" = yes; then
      AC_CACHE_CHECK([if this Fortran compiler has working c_associated],
        llnl_cv_working_c_associated,
        [AC_LANG_PUSH(Fortran)dnl
         AC_COMPILE_IFELSE([
         program main
           use, intrinsic :: iso_c_binding
           type(c_ptr) :: voidstar
           voidstar = C_NULL_PTR
           if (c_associated(voidstar)) then
             write(*,*) 'Not NULL'
           else
             write(*,*) 'NULL'
           endif
         end
	],[llnl_cv_working_c_associated="yes"],
	[llnl_cv_working_c_associated="no"])
         AC_LANG_POP(Fortran)dnl
        ])
    fi
    if test "$llnl_cv_enable_bindc" != no; then
      AC_DEFINE(SIDL_HAS_ISO_C_BINDING,1,
	    [Define to 1 if the Fortran compiler supports iso_c_binding.])
      msgs="$msgs
          BindC requested and available."
    else 
      msgs="$msgs
          BindC request disabled against user request--iso_c_binding not supported."
    fi
    if test "$llnl_cv_working_c_associated" = yes; then
      AC_DEFINE(SIDL_HAS_FORTRAN_C_ASSOC,1,
             [Define to 1 if Fortran has C_ASSOCIATED in ISO_C_BINDING.])
    fi
  fi
  AM_CONDITIONAL(SUPPORT_FORTRAN03, test "X$llnl_cv_enable_bindc" = "Xyes")
])
