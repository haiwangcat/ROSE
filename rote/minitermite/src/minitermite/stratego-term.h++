#ifndef __STRATEGO_TERM_HPP__
#define __STRATEGO_TERM_HPP__
#include <term.h++>

namespace term {

  class StrategoTerm : public STLTerm {};
  class StrategoAtom : public STLAtom {};
  class StrategoInt : public STLInt {};
  class StrategoFloat : public STLFloat {};
  class StrategoList : public STLList {};
  class StrategoCompTerm : public STLCompTerm {};
  class StrategoVariable : public STLVariable {};


  class StrategoTermFactory : public STLTermFactory {
  };
}
#endif
