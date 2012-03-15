/* -*- C++ -*-
Copyright 2009 Adrian Prantl <adrian@complang.tuwien.ac.at>
*/
#ifndef ROSEENUMS_H_
#define ROSEENUMS_H_

#include <map>
#include <string>
#include <vector>

/// This is needed for the SgBitVector translation and should help to
//  keep the information at one location for both directions
class RoseEnums {
 public:
  RoseEnums();

  // ROSE -> TERMITE

#define ROSEENUMS_DECLARE(NAME) \
  std::vector<std::string>   NAME ## s ; /* ROSE -> TERMITE */ \
  std::map<std::string, int> NAME;       /* TERMITE -> ROSE */

  ROSEENUMS_DECLARE(function_modifier)
  ROSEENUMS_DECLARE(special_function_modifier)
  ROSEENUMS_DECLARE(type_modifier)
  ROSEENUMS_DECLARE(elaborated_type_modifier)
  ROSEENUMS_DECLARE(declaration_modifier)
  ROSEENUMS_DECLARE(storage_modifier)
  ROSEENUMS_DECLARE(access_modifier)
  ROSEENUMS_DECLARE(upc_access_modifier)
  ROSEENUMS_DECLARE(cv_modifier)
  ROSEENUMS_DECLARE(class_type)
  ROSEENUMS_DECLARE(throw_kind)
  ROSEENUMS_DECLARE(cast_type)
  ROSEENUMS_DECLARE(static_flag)
  ROSEENUMS_DECLARE(ellipses_flag)
  ROSEENUMS_DECLARE(RelativePositionType)
  ROSEENUMS_DECLARE(DirectiveType)
  ROSEENUMS_DECLARE(attribute_spec)
  ROSEENUMS_DECLARE(subprogram_kind)
  ROSEENUMS_DECLARE(template_instantiation)
  ROSEENUMS_DECLARE(template_argument)
  ROSEENUMS_DECLARE(template_parameter)
};

#endif
