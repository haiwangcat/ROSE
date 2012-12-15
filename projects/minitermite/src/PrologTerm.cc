#include <rose_config.h>
#include "minitermite.h"

#include <cstring>

using namespace std;
using namespace term;

CompTerm* STLTerm::isCompTerm() { 
  return dynamic_cast<CompTerm*>(this);
}
List* STLTerm::isList() { 
  return dynamic_cast<List*>(this);
}
Atom* STLTerm::isAtom() { 
  return dynamic_cast<Atom*>(this);
}
Int* STLTerm::isInt() { 
  return dynamic_cast<Int*>(this);
}
Float* STLTerm::isFloat() { 
  return dynamic_cast<Float*>(this);
}
Variable* STLTerm::isVariable() { 
  return dynamic_cast<Variable*>(this);
}

#if ROSE_HAVE_SWI_PROLOG


// true if the pattern can be unified with the term
bool SWIPLTerm::matches(std::string pattern) {
  fid_t fid = PL_open_foreign_frame();
  // FIXME: cache predicate
  term_t a0 = PL_new_term_refs(2);
  assert(PL_unify(a0, term));
  PL_put_variable(a0+1);
  PL_chars_to_term(pattern.c_str(), a0);
  SWIPLTerm t(a0);
  //cerr<<t.getRepresentation()<<endl;
  //cerr<<getRepresentation()<<endl;
  bool b = PL_call_predicate(NULL, PL_Q_NORMAL,
			     PL_predicate("=@=", 2, ""), a0);
  //cerr<<b<<endl;
  PL_discard_foreign_frame(fid);
  return b;
}

// Create a new Term from a real  Atom
SWIPLTerm *SWIPLTerm::wrap_PL_Term(term_t t)
{
  //cerr<< "WRAPPING " << display(t) << endl;

  SWIPLTerm *pt = 0;
  switch( PL_term_type(t) ) {
  case PL_VARIABLE: assert(false && "Encountered Variable!");

  case PL_ATOM:     
    if (PL_get_nil(t)) pt = new SWIPLList(t);
    else               pt = new SWIPLAtom(t); 
    break;

  case PL_INTEGER:  
    // Careful about overloading
    pt = new SWIPLInt(); 
    ((SWIPLInt*)pt)->createFromTerm(t);
    break;

  case PL_FLOAT:    
    pt = new SWIPLFloat(); 
    ((SWIPLFloat*)pt)->createFromTerm(t);
    break;
  case PL_STRING:   assert(false);
  case PL_TERM: {
    term_t h = PL_new_term_ref();
    if (PL_get_head(t, h)) pt = new SWIPLList(t);
    else                   pt = new SWIPLCompTerm(t);
    break;
  }
  default:          assert(false);
  }
  return pt;
}

// Create a new Term from a real  Atom
// it will automatically be freed at the end of this object's lifetime
SWIPLTerm* SWIPLTerm::newSWIPLTerm(term_t t)
{
  SWIPLTerm *pt = wrap_PL_Term(t);
  return pt;
}

// Create a real  term from a Term
// it will be garbage-collected by SWI-
term_t SWIPLTerm::newTerm_t(SWIPLTerm* pt) 
{
  //if (Atom *a = dynamic_cast<Atom *>pt) {
  assert(0 && "do we need this function at all???");
}

void abort_termite() {
  PL_cleanup(0);
}

bool term::init_termite(int argc, char **argv, bool interactive)
{ 
  char *av[10];
  int ac = 0;

  av[ac++] = argv[0];
  av[ac++] = strdup("-q");
  av[ac++] = strdup("-O");
  // Sizes of "0" mean the largest possible limits.
  av[ac++] = strdup("-L0");  // Local stack
  av[ac++] = strdup("-G0");  // Global stack
  av[ac++] = strdup("-A0");  // Argument stack
  av[ac++] = strdup("-T0");  // Trail stack

  if (interactive == false) {
    // At runtime, it is advised to pass the flag -nosignals, which
    // inhibits all default signal handling. This has a few consequences
    // though:
    //
    // It is no longer possible to break into the tracer using an
    // interrupt signal (Control-C).
    //
    // SIGPIPE is normally set to be ignored. Prolog uses return-codes to
    // diagnose broken pipes. Depending on the situation one should take
    // appropriate action if Prolog streams are connected to pipes.
    //
    // Fatal errors normally cause Prolog to call PL_cleanup() and
    // exit(). It is advised to call PL_cleanup() as part of the
    // exit-procedure of your application.
    av[ac++] = strdup("-nosignals");
    atexit(abort_termite);
  }

  av[ac]   = NULL;

  // Make sure SWI always finds... itself. Its home directory is determined
  // by the configure script and must be passed on the command line when
  // this file is compiled. It will then be hardcoded in the library, which
  // is not very nice, but somewhat reasonable.
  // (see http://www.swi-prolog.org/FAQ/FindResources.html for info)
  setenv("SWI_HOME_DIR", SWI_HOME_DIR, /* overwrite = */ 0);

  return PL_initialise(ac, av);
}


#else //////////////////////////////////////////////////////////////////

bool term::init_termite(int argc, char **argv, bool) {
  return true;
}


#endif
