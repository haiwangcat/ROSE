// We include all of these header files in this "dummy" source file
// simply so the $ROSE/scripts/policies/UnusedHeaders.pl policy
// check won't report these header files as being "unused" (i.e.
// it is not included in a source compilation file).

#include "bupc_extensions.h"
#include "preinclude-cuda.h"
#include "preinclude-opencl.h"
#include "rose-g++-headerfilefixup.h"
#include "rose_specific_ammintrin.h"
#include "rose_specific_avxintrin.h"
#include "rose_specific_cdefs.h"
#include "rose_specific_complex.h"
#include "rose_specific_emmintrin.h"
#include "rose_specific_nmmintrin.h"
#include "rose_specific_pmmintrin.h"
#include "rose_specific_smmintrin.h"
#include "rose_specific_tmmintrin.h"
#include "rose_specific_xmmintrin.h"
#include "rose_stdarg.h"
#include "rose_varargs.h"
#include "upc.h"
#include "upc_collective.h"
#include "upc_io.h"
#include "upc_relaxed.h"
#include "upc_strict.h"
