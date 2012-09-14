#include "RoseEnums.h"

/* This is needed for the SgBitVector translation
 *
 * see "rose/src/ROSETTA/Grammar/Support.code"
 * and "rose/src/ROSETTA/Grammar/Statement.code"
 *
 * 2009 Adrian Prantl <adrian@complang.tuwien.ac.at>
 */


// CAVEAT: this assumes that all enum values are contiguous!
#define INIT(TYPE, NAME)				   \
  for (i = 0; i < sizeof(e_ ## NAME)/sizeof(char*); ++i) { \
    ROSE_ASSERT(sizeof(e_ ## NAME)/sizeof(const char*)>i); \
    enum_ ## NAME[e_ ## NAME[i]] = (TYPE)i;		   \
    vec_  ## NAME.push_back(e_ ## NAME[i]);		   \
  }

#define ROSEENUM_DEFS 1
#include <RoseEnumNames.h>
#undef ROSE_ENUM_DEFS
