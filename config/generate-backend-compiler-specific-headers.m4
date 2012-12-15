AC_DEFUN([GENERATE_BACKEND_CXX_COMPILER_SPECIFIC_HEADERS],
dnl DQ 12/17/2001 build from what Bobby put into configure.in directly 11/25/2001
dnl This builds the directories required for the back-end compiler specific header files.
dnl it depends upon the CHOOSE BACKEND COMPILER macro to have already been called.
[
 # BP : 11/20/2001, create a directory to store header files which are compiler specific
   compilerName="`basename $BACKEND_CXX_COMPILER`"
   chmod u+x "${srcdir}/config/create_system_headers"
   if test "$ROSE_CXX_HEADERS_DIR" = ""; then
      dnl AC_MSG_NOTICE([ROSE_CXX_HEADERS_DIR not set ...])
      ROSE_CXX_HEADERS_DIR="${prefix}/include/${compilerName}_HEADERS"
   else
      AC_MSG_NOTICE([ROSE_CXX_HEADERS_DIR set to: $ROSE_CXX_HEADERS_DIR])
   fi

   saveCurrentDirectory="`pwd`"
   cd "$srcdir"
   absolutePath_srcdir="`pwd`"
   cd "$saveCurrentDirectory"

 # DQ (9/1/2009): Output the absolute path
   echo "absolutePath_srcdir = ${absolutePath_srcdir}"

 # Use the full path name to generate the header from the correctly specified version of the backend compiler
   mkdir -p "./include-staging/${compilerName}_HEADERS"
   "${srcdir}/config/create_system_headers" "${BACKEND_CXX_COMPILER}" "./include-staging/${compilerName}_HEADERS" "${absolutePath_srcdir}"

   echo "BACKEND_CXX_COMPILER_MAJOR_VERSION_NUMBER = $BACKEND_CXX_COMPILER_MAJOR_VERSION_NUMBER"
   echo "BACKEND_CXX_COMPILER_MINOR_VERSION_NUMBER = $BACKEND_CXX_COMPILER_MINOR_VERSION_NUMBER"

 # DQ (8/14/2010): GNU 4.5 includes some code that will not compile and appears to not be valid C++ code.
 # We fixup a specific GNU 4.5 issues use of "return { __mask };"
   if test x$BACKEND_CXX_COMPILER_MAJOR_VERSION_NUMBER == x4; then
      if test x$BACKEND_CXX_COMPILER_MINOR_VERSION_NUMBER == x5; then
         echo "Note: we have identified version 4.5 of GNU C/C++ which triggers use of a modified copy of iomanip header file."
         cp ${srcdir}/config/iomanip-gnu-4.5 ./include-staging/iomanip-gnu-4.5
         echo "remove the links..."
         rm ./include-staging/gcc_HEADERS/hdrs4/c++/4.5.0/iomanip;
         rm ./include-staging/g++_HEADERS/hdrs7/c++/4.5.0/iomanip;
         rm ./include-staging/g++_HEADERS/hdrs3/iomanip;
         echo "rebuild links to the modified file..."
         ln -s ./include-staging/iomanip-gnu-4.5 ./include-staging/gcc_HEADERS/hdrs4/c++/4.5.0/iomanip
         ln -s ./include-staging/iomanip-gnu-4.5 ./include-staging/g++_HEADERS/hdrs7/c++/4.5.0/iomanip
         ln -s ./include-staging/iomanip-gnu-4.5 ./include-staging/g++_HEADERS/hdrs3/iomanip
      fi
   fi

 # DQ (9/19/2010): Copy the upc.h header file from the config directory to our include-staging/${BACKEND_CXX_COMPILER}_HEADERS directory.
 # It might be that these should be put into a UPC specific subdirectory (so that the C compiler can't accedentally find them), but this should be discussed.
   echo "Copying UPC++ header files into ./include-staging/${compilerName}_HEADERS directory ..."
   cp ${srcdir}/config/include-staging/upc.h ./include-staging/${compilerName}_HEADERS
   cp ${srcdir}/config/include-staging/upc_io.h ./include-staging/${compilerName}_HEADERS
   cp ${srcdir}/config/include-staging/upc_relaxed.h ./include-staging/${compilerName}_HEADERS
   cp ${srcdir}/config/include-staging/upc_strict.h ./include-staging/${compilerName}_HEADERS
   cp ${srcdir}/config/include-staging/upc_collective.h ./include-staging/${compilerName}_HEADERS
   cp ${srcdir}/config/include-staging/bupc_extensions.h ./include-staging/${compilerName}_HEADERS

 # DQ (8/22/2011): Added support for SSE.
 # Copy alternative SSE and MMX headers to be seen by ROSE ahead of the originals.
   cp ${srcdir}/config/include-staging/rose_specific_emmintrin.h ./include-staging/${compilerName}_HEADERS/emmintrin.h
   cp ${srcdir}/config/include-staging/rose_specific_xmmintrin.h ./include-staging/${compilerName}_HEADERS/xmmintrin.h

# Phlin (6/18/2012): Added support for SSE4.2.
   cp ${srcdir}/config/include-staging/rose_specific_ammintrin.h ./include-staging/${compilerName}_HEADERS/ammintrin.h
   cp ${srcdir}/config/include-staging/rose_specific_nmmintrin.h ./include-staging/${compilerName}_HEADERS/nmmintrin.h
   cp ${srcdir}/config/include-staging/rose_specific_pmmintrin.h ./include-staging/${compilerName}_HEADERS/pmmintrin.h
   cp ${srcdir}/config/include-staging/rose_specific_smmintrin.h ./include-staging/${compilerName}_HEADERS/smmintrin.h
   cp ${srcdir}/config/include-staging/rose_specific_tmmintrin.h ./include-staging/${compilerName}_HEADERS/tmmintrin.h

# Phlin (6/18/2012): Added support for AVX.
# Only GCC 4.6+ supports AVX instructions.
   if test x$BACKEND_CXX_COMPILER_MAJOR_VERSION_NUMBER == x4; then
      if test "$BACKEND_CXX_COMPILER_MINOR_VERSION_NUMBER" -ge "6"; then
   cp ${srcdir}/config/include-staging/rose_specific_avxintrin.h ./include-staging/${compilerName}_HEADERS/avxintrin.h
      fi
   fi



   error_code=$?
   echo "error_code = $error_code"
   if test $error_code != 0; then
        echo "Error in copying of upc.h header file: nonzero exit code returned to caller error_code = $error_code"
        exit 1
   fi

 # echo "Exiting as a test in GENERATE BACKEND CXX COMPILER SPECIFIC HEADERS"
 # exit 1
])


AC_DEFUN([SETUP_BACKEND_CXX_COMPILER_SPECIFIC_REFERENCES],
dnl DQ 12/17/2001 build from what Bobby put into configure.in directly 11/25/2001
dnl This builds the directories required for the back-end compiler specific header files.
dnl it depends upon the CHOOSE BACKEND COMPILER macro to have already been called.
[
 # Now setup the include path that we will prepend to any user -I<dir> options so that the 
 # required compiler-specific header files can be found (these are often relocated versions 
 # of the compiler specific header files that have been processed so that EDG can read them)
 # It is unfortunate, but many compiler-specific files include compiler-specific code which
 # will not compile with a standard C++ compiler or can not be processed using a standard
 # C preprocessor (cpp) (an ugly fact of common compilers).

   chmod u+x "${srcdir}/$ROSE_HOME/config/dirincludes"


 #Mac OS X (and possibly other BSD-distros) does not support the echo -n option.
 #We need to detect this special case and use a "\c" in the end of the echo to not print a
 #newline.
   er=`echo -n ""`
   if test "X$er" = "X-n "
   then
     EC="\c"
     EO=""
   else
     EC=""
     EO="-n"
   fi

compilerNameCxx="`basename ${BACKEND_CXX_COMPILER}`"

 # DQ (11/1/2011): We need this same mechanism for C++'s use of EDG 4.x as we did for EDG 3.3 (but for C code this was not required; and was simpler).
 # Include the directory with the subdirectories of header files
 # if test "x$enable_new_edg_interface" = "xyes"; then
 #   includeString="{`${srcdir}/config/get_compiler_header_dirs ${BACKEND_CXX_COMPILER} | while read dir; do echo -n \\\"$dir\\\",\ ; done` \"/usr/include\"}"
 # else
 #   includeString="{\"${compilerNameCxx}_HEADERS\"`${srcdir}/$ROSE_HOME/config/dirincludes "./include-staging/" "${compilerNameCxx}_HEADERS"`, `${srcdir}/config/get_compiler_header_dirs ${BACKEND_CXX_COMPILER} | while read dir; do echo $EO \\\"$dir\\\",$EC\ ; done` \"/usr/include\"}"
 # fi
 # includeString="{\"${compilerNameCxx}_HEADERS\"`${srcdir}/$ROSE_HOME/config/dirincludes "./include-staging/" "${compilerNameCxx}_HEADERS"`, `${srcdir}/config/get_compiler_header_dirs ${BACKEND_CXX_COMPILER} | while read dir; do echo $EO \\\"$dir\\\",$EC\ ; done` \"/usr/include\"}"

   if ! compilerHeaderDirs="$(${srcdir}/config/get_compiler_header_dirs ${BACKEND_CXX_COMPILER} | while read dir; do echo $EO \"$dir\",$EC\ ; done; exit ${PIPESTATUS[0]})"; then
      AC_MSG_FAILURE([$compilerHeaderDirs])
   fi
   includeString="{\"${compilerNameCxx}_HEADERS\"`${srcdir}/$ROSE_HOME/config/dirincludes "./include-staging/" "${compilerNameCxx}_HEADERS"`, $compilerHeaderDirs"
   includeString="$includeString \"/usr/include\"}"

   echo "includeString = $includeString"
   AC_DEFINE_UNQUOTED([CXX_INCLUDE_STRING],$includeString,[Include path for backend C++ compiler.])
])

AC_DEFUN([GENERATE_BACKEND_C_COMPILER_SPECIFIC_HEADERS],
[
   compilerName="`basename $BACKEND_C_COMPILER`"

   echo "C compilerName = ${compilerName}"

   chmod u+x "${srcdir}/config/create_system_headers"

   if test "$ROSE_C_HEADERS_DIR" = ""; then
      dnl AC_MSG_NOTICE([ROSE_C_HEADERS_DIR not set ...])
      ROSE_C_HEADERS_DIR="${compilerName}_HEADERS"
   else
      AC_MSG_NOTICE([ROSE_C_HEADERS_DIR set to: $ROSE_C_HEADERS_DIR])
   fi

   saveCurrentDirectory="`pwd`"
   cd "$srcdir"
   absolutePath_srcdir="`pwd`"
   cd "$saveCurrentDirectory"

 # DQ (9/1/2009): Output the absolute path
   echo "absolutePath_srcdir = ${absolutePath_srcdir}"

 # Use the full path name to generate the header from the correctly specified version of the backend compiler
   mkdir -p "./include-staging/${compilerName}_HEADERS"
   "${srcdir}/config/create_system_headers" "${BACKEND_C_COMPILER}" "./include-staging/${compilerName}_HEADERS" "${absolutePath_srcdir}"

   error_code=$?
   echo "error_code = $error_code"
   if test $error_code != 0; then
        echo "Error in ${srcdir}/config/create_system_headers: nonzero exit code returned to caller error_code = $error_code"
        exit 1
   fi

 # DQ (9/15/2010): Copy the upc.h header file from the config directory to our include-staging/${compilerName}_HEADERS directory.
 # It might be that these should be put into a UPC specific subdirectory (so that the C compiler can't accedentally find them), but this should be discussed.
   echo "Copying UPC header files into ./include-staging/${compilerName}_HEADERS directory ..."
   cp ${srcdir}/config/include-staging//upc.h ./include-staging/${compilerName}_HEADERS
   cp ${srcdir}/config/include-staging//upc_io.h ./include-staging/${compilerName}_HEADERS
   cp ${srcdir}/config/include-staging//upc_relaxed.h ./include-staging/${compilerName}_HEADERS
   cp ${srcdir}/config/include-staging//upc_strict.h ./include-staging/${compilerName}_HEADERS
   cp ${srcdir}/config/include-staging//upc_collective.h ./include-staging/${compilerName}_HEADERS
   cp ${srcdir}/config/include-staging//bupc_extensions.h ./include-staging/${compilerName}_HEADERS

 # DQ (8/22/2011): Added support for SSE.
 # Copy alternative SSE and MMX headers to be seen by ROSE ahead of the originals.
   cp ${srcdir}/config/include-staging/rose_specific_emmintrin.h ./include-staging/${compilerName}_HEADERS/emmintrin.h
   cp ${srcdir}/config/include-staging/rose_specific_xmmintrin.h ./include-staging/${compilerName}_HEADERS/xmmintrin.h

 # Phlin (6/18/2012): Added support for SSE4.2.
   cp ${srcdir}/config/include-staging/rose_specific_ammintrin.h ./include-staging/${compilerName}_HEADERS/ammintrin.h
   cp ${srcdir}/config/include-staging/rose_specific_nmmintrin.h ./include-staging/${compilerName}_HEADERS/nmmintrin.h
   cp ${srcdir}/config/include-staging/rose_specific_pmmintrin.h ./include-staging/${compilerName}_HEADERS/pmmintrin.h
   cp ${srcdir}/config/include-staging/rose_specific_smmintrin.h ./include-staging/${compilerName}_HEADERS/smmintrin.h
   cp ${srcdir}/config/include-staging/rose_specific_tmmintrin.h ./include-staging/${compilerName}_HEADERS/tmmintrin.h

# Phlin (6/18/2012): Added support for AVX.
# Only GCC 4.6+ supports AVX instructions.
   if test x$BACKEND_CXX_COMPILER_MAJOR_VERSION_NUMBER == x4; then
      if test "$BACKEND_CXX_COMPILER_MINOR_VERSION_NUMBER" -ge "6"; then
   cp ${srcdir}/config/include-staging/rose_specific_avxintrin.h ./include-staging/${compilerName}_HEADERS/avxintrin.h
      fi
   fi

   error_code=$?
   echo "error_code = $error_code"
   if test $error_code != 0; then
        echo "Error in copying of upc.h header file: nonzero exit code returned to caller error_code = $error_code"
        exit 1
   fi
])


AC_DEFUN([SETUP_BACKEND_C_COMPILER_SPECIFIC_REFERENCES],
dnl DQ 12/17/2001 build from what Bobby put into configure.in directly 11/25/2001
dnl This builds the directories required for the back-end compiler specific header files.
dnl it depends upon the CHOOSE BACKEND COMPILER macro to have already been called.
[
 # Now setup the include path that we will prepend to any user -I<dir> options so that the 
 # required compiler-specific header files can be found (these are often relocated versions 
 # of the compiler specific header files that have been processed so that EDG can read them)
 # It is unfortunate, but many compiler-specific files include compiler-specific code which
 # will not compile with a standard C++ compiler or can not be processed using a standard
 # C preprocessor (cpp) (an ugly fact of common compilers).

   chmod u+x ${srcdir}/$ROSE_HOME/config/dirincludes

 #Mac OS X (and possibly other BSD-distros) does not support the echo -n option.
 #We need to detect this special case and use a "\c" in the end of the echo to not print a
 #newline.
   er=`echo -n ""`
   if test "X$er" = "X-n "
   then
     EC="\c"
     EO=""
   else
     EC=""
     EO="-n"
   fi

compilerNameC="`basename $BACKEND_C_COMPILER`"

 # DQ (11/1/2011): We need this same mechanism for C++'s use of EDG 4.x as we did for EDG 3.3 (but for C code this was not required; and was simpler).
 # Include the directory with the subdirectories of header files
 # if test "x$enable_new_edg_interface" = "xyes"; then
 #   includeString="{`${srcdir}/config/get_compiler_header_dirs ${BACKEND_C_COMPILER} | while read dir; do echo -n \\\"$dir\\\",\ ; done` \"/usr/include\"}"
 # else
 #   includeString="{\"${compilerNameC}_HEADERS\"`${srcdir}/$ROSE_HOME/config/dirincludes "./include-staging/" "${compilerNameC}_HEADERS"`, `${srcdir}/config/get_compiler_header_dirs ${BACKEND_C_COMPILER} | while read dir; do echo $EO \\\"$dir\\\",$EC\ ; done` \"/usr/include\"}"
 # fi
 #  includeString="{\"${compilerNameC}_HEADERS\"`${srcdir}/$ROSE_HOME/config/dirincludes "./include-staging/" "${compilerNameC}_HEADERS"`, `${srcdir}/config/get_compiler_header_dirs ${BACKEND_C_COMPILER} | while read dir; do echo $EO \\\"$dir\\\",$EC\ ; done` \"/usr/include\"}"

   if ! compilerHeaderDirs="$(${srcdir}/config/get_compiler_header_dirs ${BACKEND_C_COMPILER} | while read dir; do echo $EO \"$dir\",$EC\ ; done; exit ${PIPESTATUS[0]})"; then
      AC_MSG_FAILURE([$compilerHeaderDirs])
   fi
   includeString="{\"${compilerNameC}_HEADERS\"`${srcdir}/$ROSE_HOME/config/dirincludes "./include-staging/" "${compilerNameC}_HEADERS"`, $compilerHeaderDirs"
   includeString="$includeString \"/usr/include\"}"

   echo "includeString = $includeString"
   AC_DEFINE_UNQUOTED([C_INCLUDE_STRING],$includeString,[Include path for backend C compiler.])
])

