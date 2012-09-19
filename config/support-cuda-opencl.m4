
AC_DEFUN([GENERATE_CUDA_SPECIFIC_HEADERS],
[
   mkdir -p "./include-staging/cuda_HEADERS"
   cp ${srcdir}/config/include-staging/preinclude-cuda.h ./include-staging/cuda_HEADERS
])

AC_DEFUN([GENERATE_OPENCL_SPECIFIC_HEADERS],
[
   mkdir -p "./include-staging/opencl_HEADERS"
   cp ${srcdir}/config/include-staging/preinclude-opencl.h ./include-staging/opencl_HEADERS
])
