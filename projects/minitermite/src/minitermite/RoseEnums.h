/* -*- C++ -*-
Copyright 2009 Adrian Prantl <adrian@complang.tuwien.ac.at>
*/
#ifndef ROSEENUMS_H_
#define ROSEENUMS_H_

#include <rose.h>
#include <map>
#include <string>
#include <vector>

/// This is needed for the SgBitVector translation and should help to
//  keep the information at one location for both directions
class RoseEnums {
 public:
  RoseEnums();

#define ROSEENUMS_DECLARE(TYPE, NAME)					\
  std::map<std::string, TYPE> enum_ ## NAME; /* TERMITE -> ROSE */	\
  std::vector<std::string>     vec_ ## NAME;				\
  const std::string& str(TYPE i)            /* ROSE -> TERMITE */	\
    const { return vec_ ## NAME[i]; }					\

#undef ROSEENUM_DEFS
#include <RoseEnumNames.h>
};

#endif
