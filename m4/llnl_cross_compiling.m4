dnl @synopsis LLNL_CROSS_COMPILING
dnl 
dnl configure for BGL-type machines that need hard wired settings
dnl because the compute nodes running different OSes that the head
dnl node.
dnl
dnl @version
dnl @author Tom Epperly, LLNL
AC_DEFUN([LLNL_CROSS_COMPILING],
[
  case "$target" in
  powerpc64-ibm-bgp*)
    cross_compiling=yes
    llnl_cross_compiling_okay=yes
    enable_pure_static_runtime=no
    enable_shared=yes
    enable_static=no
    enable_java=no
    enable_python=/bgsys/drivers/ppcfloor/gnu-linux/bin/python
    llnl_cv_python_frontend=python
    llnl_cv_python_prefix=/bgsys/drivers/ppcfloor/gnu-linux
    llnl_cv_python_numpy=yes
    llnl_cv_python_numerical=no
    llnl_cv_python_library=$llnl_cv_python_prefix/lib
    llnl_cv_python_version=2.6
    llnl_cv_python_include=$llnl_cv_python_prefix/include/python$llnl_cv_python_version
    llnl_cv_python_numpy_incl=/soft/apps/python/python-2.6-cnk-gcc/numpy-1.3.0/lib/python2.6/site-packages/numpy/core/include/numpy
    llnl_cv_extra_python_build_options="--compiler=mpixlc"
    llnl_python_shared_library=$llnl_cv_python_library/libpython2.6.so
    llnl_python_shared_library_found=yes
    sidl_cv_f77_false=0
    sidl_cv_f77_true=1
    sidl_cv_f90_false=0
    sidl_cv_f90_true=1
    llnl_cv_F77_logical_size=4
    llnl_cv_F90_logical_size=4
    ac_cv_f90_pointer_size=8
    llnl_cv_F77_string_passing="far int32_t"
    llnl_cv_F90_string_passing="far int32_t"
    ac_cv_func_malloc_0_nonnull=yes
    ac_cv_func_realloc_0_nonnull=yes
    ac_cv_func_memcmp_working=yes
    with_sidlx=no
    ;;
  powerpc64-ibm-bgl*)
    cross_compiling=yes
    llnl_cross_compiling_okay=yes
    enable_pure_static_runtime=yes
    enable_shared=no
    enable_static=yes
    enable_java=no
    enable_python=no
    sidl_cv_f77_false=0
    sidl_cv_f77_true=1
    sidl_cv_f90_false=0
    sidl_cv_f90_true=1
    llnl_cv_F77_string_passing="far int32_t"
    llnl_cv_F90_string_passing="far int32_t"
    ac_cv_func_malloc_0_nonnull=yes
    ac_cv_func_realloc_0_nonnull=yes
    ac_cv_func_memcmp_working=yes
    with_sidlx=no
    ;;
  x86_64-cray-catamount*)
    cross_compiling=yes
    llnl_cross_compiling_okay=yes
    enable_pure_static_runtime=yes
    enable_shared=no
    enable_static=yes
    enable_java=no
    enable_python=no
    enable_pthreads=no
    sidl_cv_f77_false=0
    sidl_cv_f77_true=-1
    llnl_cv_F77_logical_size=4
    sidl_cv_f90_false=0
    sidl_cv_f90_true=-1
    llnl_cv_F90_logical_size=4
    chasm_max_descriptor_size=568
    llnl_cv_F77_string_passing="far int32_t"
    llnl_cv_F90_string_passing="far int32_t"
    ac_cv_f90_pointer_size=8
    ac_cv_header_netinet_in_h=no
    ac_cv_func_malloc_0_nonnull=yes
    ac_cv_func_realloc_0_nonnull=yes
    ac_cv_func_memcmp_working=yes
    with_sidlx=no
    ;;  
  x86_64-cray-cnl*)
    cross_compiling=yes
    llnl_cross_compiling_okay=yes
    enable_pure_static_runtime=yes
    enable_shared=no
    enable_static=yes
    enable_java=no
    enable_python=no
    llnl_cv_F77_logical_size=4
    llnl_cv_F90_logical_size=4
    llnl_cv_F77_string_passing="far int32_t"
    llnl_cv_F90_string_passing="far int32_t"
    ac_cv_func_malloc_0_nonnull=yes
    ac_cv_func_realloc_0_nonnull=yes
    ac_cv_func_memcmp_working=yes
    ac_cv_f90_pointer_size=8
    with_sidlx=no
    ;;  
  esac
])
