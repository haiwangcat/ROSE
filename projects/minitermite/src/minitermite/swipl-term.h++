#ifndef __SWI_TERM_HPP__
#define __SWI_TERM_HPP__
#include <term.h++>

#ifndef __TERMITE_H__
#  error "Please do not include this file directly. Use minitermite.h instead."
#endif

#if ROSE_HAVE_SWI_PROLOG

// SWI-Prolog.h includes inttypes.h and ROSE needs the STDC_FORMAT_MACROS to be defined
#ifndef __STDC_FORMAT_MACROS
#define __STDC_FORMAT_MACROS
#endif
#include <SWI-Prolog.h>

// debugging
#include <iostream>
#include <typeinfo>

namespace term {

  class SWIPLTerm;
  class SWIPLAtom;
  class SWIPLInt;
  class SWIPLFloat;
  class SWIPLList;
  class SWIPLCompTerm;
  class SWIPLVariable;

  class SWIPLTerm : virtual public Term {
  public:
    // The way these are implemented right now with the multiple
    // inheritance, we could probably skip everything and just do the
    // dynamic cast
    CompTerm* isCompTerm() { 
      term_t h = PL_new_term_ref();
      if (PL_term_type(term) == PL_TERM && !PL_get_head(term, h))
	return dynamic_cast<CompTerm*>(this);
      else return NULL;
    }
    List* isList()  { 
      term_t h = PL_new_term_ref();
      if ((PL_term_type(term) == PL_ATOM && PL_get_nil(term))
	  || (PL_term_type(term) == PL_TERM && PL_get_head(term, h)))
	return dynamic_cast<List*>(this);
      else return NULL;
    }
    Atom* isAtom() {
      if (PL_term_type(term) == PL_ATOM && !PL_get_nil(term))
	return dynamic_cast<Atom*>(this);
      else return NULL;
    }
    Int* isInt() {
      if (PL_term_type(term) == PL_INTEGER)
	return dynamic_cast<Int*>(this);
      else return NULL;
    }
    Float* isFloat() {
      if (PL_term_type(term) == PL_FLOAT)
	return dynamic_cast<Float*>(this);
      else return NULL;
    }
    Variable* isVariable() {
      if (PL_term_type(term) == PL_VARIABLE)
	return dynamic_cast<Variable*>(this);
      else return NULL;
    }

    SWIPLTerm() :term(PL_new_term_ref()) {
#   if DEBUG_TERMITE
      std::cerr<<"UNINIT"<<std::endl;
#   endif
    }
    SWIPLTerm(term_t t) : term(PL_copy_term_ref(t)) { 
#   if DEBUG_TERMITE
      std::cerr<<"new SWIPLTerm("<<display(t)<<")"<<std::endl;
#   endif
    }

    /// returns the arity of the term
    virtual int getArity() const { 
      int success;
      int arity = 0;
      if (PL_term_type(term) == PL_TERM) {
	term_t name;
	success=PL_get_name_arity(term, &name, &arity);
	if(!success) { /* do someting reasonable */ }
      }
      return arity;
    }
    /// returns whether or not the term is a ground term, i.e. contains
    /// no variables.
    virtual bool isGround() const { return PL_is_ground(term); }

    /// Gets the name (functor/variable/constant) of the term. 
    /* numbers are represented as strings and therefore returned as such */
    virtual std::string getName() const {
      char *s;
      if (PL_get_atom_chars(term, &s))
	return std::string(s);

      int arity;
      atom_t name;
      int success=PL_get_name_arity(term, &name, &arity);
      if(!success) { /* do someting reasonable */ }
      return std::string(PL_atom_chars(name));
    }
    /// the actual prolog term that is represented by this object
    virtual std::string getRepresentation() const { return display(term); }
    /// dump term representation to an ostream
    virtual void dump(std::ostream& s) const { s << getRepresentation(); }
    /// Properly quote an atom if necessary
    static std::string quote(const char* s) {
      return std::string(PL_quote('\'', s));
    }

    // true if the pattern can be unified with the term
    bool matches(std::string pattern);

    /// return the SWI-Prolog term
    term_t getTerm() const { return term; }

    // Create a new SWIPLTerm from a real Prolog Atom
    static SWIPLTerm *wrap_PL_Term(term_t t);

  protected:

    term_t term; // The "real" prolog term

    static std::string display(term_t t)
    { 
      // this should be more efficient than 
      // chars_to_term("with_output_to(string(S),write_term(T,[quoted(true)]))",X)
      fid_t fid = PL_open_foreign_frame();
      term_t T		  = PL_copy_term_ref(t);
      term_t a0 = PL_new_term_refs(7);
      term_t S		  = a0 + 0;
      term_t True		  = a0 + 1;
      term_t quoted	  = a0 + 2;
      term_t list           = a0 + 3;
      term_t write_term	  = a0 + 4;
      term_t string	  = a0 + 5;
      term_t with_output_to = a0 + 6;

      PL_put_variable(S);
      int ignored=PL_cons_functor(string, PL_new_functor(PL_new_atom("string"), 1), S);

      PL_put_atom_chars(True, "true");
      ignored=PL_cons_functor(quoted, PL_new_functor(PL_new_atom("quoted"), 1), True);

      (void)PL_put_nil(list);
      ignored=PL_cons_list(list, quoted, list);
    
      ignored=PL_cons_functor(write_term, 
			      ignored=PL_new_functor(PL_new_atom("write_term"), 2), 
			      T, list);
      ignored=PL_cons_functor(with_output_to, 
			      ignored=PL_new_functor(PL_new_atom("with_output_to"), 2), 
			      string, write_term);
      assert(ignored=PL_call(with_output_to, NULL));
    
      char *s;
      size_t len;
      assert(ignored=PL_get_string_chars(S, &s, &len));

      std::string r = std::string(s);
      PL_discard_foreign_frame(fid);
      return r;
    }

    // Create a new SWIPLTerm from a real Prolog Atom
    // it will automatically be freed at the end of this object's lifetime
    // calls wrap_PL_Term internally
    SWIPLTerm *newSWIPLTerm(term_t t);

    // Create a real Prolog term from a SWIPLTerm
    // it will be garbage-collected by SWI-Prolog
    term_t newTerm_t(SWIPLTerm* pt);

  };

  class SWIPLAtom : public Atom, public SWIPLTerm {
  public:
    SWIPLAtom(term_t t) : SWIPLTerm(t) {};

    ///the destructor
    ~SWIPLAtom() {
      // Decrement the reference count of the atom.
      //PL_unregister(term);
    }
    ///constructor setting the string
    SWIPLAtom(const std::string name = "#ERROR", bool escapedRepresentation = true) {
      term = PL_new_term_ref();
      PL_put_atom_chars(term, name.c_str());
#   if DEBUG_TERMITE
      std::cerr<<"PL_new_atom("<<getRepresentation()<<") = "<<term<<std::endl;
#   endif
      (void) escapedRepresentation;  // unused
    }

    ///return the string
    std::string getName() const {
      char* name;
      int success=PL_get_atom_chars(term, &name);
      if(!success) { /* do someting reasonable */ }
      return std::string(name);
    }
  };


  ///class representing a prolog integer
  class SWIPLInt : public Int, public SWIPLTerm {
  public:
    // CAREFUL: we can't use the default "copy constructor" 
    // because term_t and int64_t are equivalent
    SWIPLInt() : SWIPLTerm() {};
    void createFromTerm(term_t t) { term = PL_copy_term_ref(t); }

    /// constructor sets the value
    SWIPLInt(int64_t value) { 
      //std::stringstream s;
      //s << value;
      //PL_put_atom_chars(term, s.str().c_str());
      //#   if DEBUG_TERMITE
      //  std::cerr<<"SWIPLInt: PL_new_atom("<<s.str()<<") = "<<term<<std::endl;
      //#   endif

      term = PL_new_term_ref();
      int success=PL_put_int64(term, value);
      if(!success) { /* do someting reasonable */ }

#   if DEBUG_TERMITE
      std::cerr<<"SWIPLInt: "<<value<<") = "<<term<<std::endl;
#   endif
    }
    /// return value
    int64_t getValue() const {
      int64_t i;
      assert(PL_get_int64(term, &i));
      return i;
    }
  };

  ///class representing a prolog float
  class SWIPLFloat : public Float, public SWIPLTerm {
  public:
    // CAREFUL: we can't use the default "copy constructor" 
    // because term_t and int64_t are equivalent
    SWIPLFloat() : SWIPLTerm() {};
    void createFromTerm(term_t t) { term = PL_copy_term_ref(t); }

    /// constructor sets the value
    SWIPLFloat(double value) { 
      //std::stringstream s;
      //s << value;
      //PL_put_atom_chars(term, s.str().c_str());
      //#   if DEBUG_TERMITE
      //  std::cerr<<"SWIPLInt: PL_new_atom("<<s.str()<<") = "<<term<<std::endl;
      //#   endif

      term = PL_new_term_ref();
      int success=PL_put_float(term, value);
      if(!success) { /* do someting reasonable */ }

#   if DEBUG_TERMITE
      std::cerr<<"SWIPLFloat: "<<value<<") = "<<term<<std::endl;
#   endif
    }

    /// return value
    double getValue() const {
      double i;
      assert(PL_get_float(term, &i));
      return i;
    }
  };


  // The SWIPL SWIPL implementation generates the term_t delayed, on the
  // first read. Afterwards addSubTerms will fail!
  class SWIPLCompTerm : public CompTerm, public SWIPLTerm {
  public:
    ~SWIPLCompTerm() {
      //PL_unregister_atom(term);
    }

    SWIPLCompTerm(term_t t) : SWIPLTerm(t) {
      term_t name;
      int arity;
      int success=PL_get_name_arity(t, &name, &arity);
      if(!success) { /* do someting reasonable */ }
      while (arity --> 0)
	subterms.push_back(NULL);
    };

#if 0
    // AP (2009-11-10) Deprecated. Use the somewhat less flexible versions below.
    SWIPLCompTerm(std::string name, size_t n, ...) : SWIPLTerm()
    {
      // GB (2009-11-03): More sophisticated construction of composite terms. The
      // "term" member variable is initialized by the default constructor invoked
      // above. We copy the argument terms to a new argument list, create a
      // functor, and hope that everything works out well.
      atom_t functorAtom = PL_new_atom(name.c_str());
      int ignored; 
      if (n > 0) {
	functor_t functor = PL_new_functor(functorAtom, n);
	term_t args = PL_new_term_refs(n);
	ignored=PL_cons_functor_v(term, functor, args);
	va_list params;
	va_start(params, n);
	for (size_t i = 0; i < n; i++) {
	  SWIPLTerm *arg_i = va_arg(params, SWIPLTerm *);
	  assert(arg_i != NULL);
	  PL_unify_arg(i+1, term, arg_i->getTerm());
	  subterms.push_back(arg_i);
	}
	va_end(params);
      } else {
	term = functorAtom;
      }
    }
#endif

# define COMPTERM_CONSTRUCTOR(N)			\
    int ignored;					\
    atom_t functorAtom = PL_new_atom(name.c_str());     \
    functor_t functor = PL_new_functor(functorAtom, N); \
    term_t args = PL_new_term_refs(N);			\
    ignored=PL_cons_functor_v(term, functor, args)

    SWIPLCompTerm(const std::string name, SWIPLTerm* t1) : SWIPLTerm()
    {
      COMPTERM_CONSTRUCTOR(1);
      ignored=PL_unify_arg(1, term, t1->getTerm());
      subterms.push_back(t1);
    }

    SWIPLCompTerm(const std::string name, SWIPLTerm* t1, SWIPLTerm* t2) 
      : SWIPLTerm()
    {
      COMPTERM_CONSTRUCTOR(2);
      ignored=PL_unify_arg(1, term, t1->getTerm());
      ignored=PL_unify_arg(2, term, t2->getTerm());
      subterms.push_back(t1);
      subterms.push_back(t2);
    }

    SWIPLCompTerm(const std::string name, 
		  SWIPLTerm* t1, SWIPLTerm* t2, SWIPLTerm* t3) 
      : SWIPLTerm()
    {
      COMPTERM_CONSTRUCTOR(3);
      ignored=PL_unify_arg(1, term, t1->getTerm());
      ignored=PL_unify_arg(2, term, t2->getTerm());
      ignored=PL_unify_arg(3, term, t3->getTerm());
      subterms.push_back(t1);
      subterms.push_back(t2);
      subterms.push_back(t3);
    }

    SWIPLCompTerm(const std::string name, 
		  SWIPLTerm* t1, SWIPLTerm* t2, SWIPLTerm* t3, 
		  SWIPLTerm* t4) 
      : SWIPLTerm()
    {
      COMPTERM_CONSTRUCTOR(4);
      ignored=PL_unify_arg(1, term, t1->getTerm());
      ignored=PL_unify_arg(2, term, t2->getTerm());
      ignored=PL_unify_arg(3, term, t3->getTerm());
      ignored=PL_unify_arg(4, term, t4->getTerm());
      subterms.push_back(t1);
      subterms.push_back(t2);
      subterms.push_back(t3);
      subterms.push_back(t4);
    }

    SWIPLCompTerm(const std::string name, 
		  SWIPLTerm* t1, SWIPLTerm* t2, SWIPLTerm* t3, 
		  SWIPLTerm* t4, SWIPLTerm* t5) 
      : SWIPLTerm()
    {
      COMPTERM_CONSTRUCTOR(5);
      ignored=PL_unify_arg(1, term, t1->getTerm());
      ignored=PL_unify_arg(2, term, t2->getTerm());
      ignored=PL_unify_arg(3, term, t3->getTerm());
      ignored=PL_unify_arg(4, term, t4->getTerm());
      ignored=PL_unify_arg(5, term, t5->getTerm());
      subterms.push_back(t1);
      subterms.push_back(t2);
      subterms.push_back(t3);
      subterms.push_back(t4);
      subterms.push_back(t5);
    }

    SWIPLCompTerm(const std::string name, 
		  SWIPLTerm* t1, SWIPLTerm* t2, SWIPLTerm* t3,
		  SWIPLTerm* t4, SWIPLTerm* t5, SWIPLTerm* t6) 
      : SWIPLTerm()
    {
      COMPTERM_CONSTRUCTOR(6);
      ignored=PL_unify_arg(1, term, t1->getTerm());
      ignored=PL_unify_arg(2, term, t2->getTerm());
      ignored=PL_unify_arg(3, term, t3->getTerm());
      ignored=PL_unify_arg(4, term, t4->getTerm());
      ignored=PL_unify_arg(5, term, t5->getTerm());
      ignored=PL_unify_arg(6, term, t6->getTerm());
      subterms.push_back(t1);
      subterms.push_back(t2);
      subterms.push_back(t3);
      subterms.push_back(t4);
      subterms.push_back(t5);
      subterms.push_back(t6);
    }

    SWIPLCompTerm(const std::string name, 
		  SWIPLTerm* t1, SWIPLTerm* t2, SWIPLTerm* t3, 
		  SWIPLTerm* t4, SWIPLTerm* t5, SWIPLTerm* t6, 
		  SWIPLTerm* t7)
      : SWIPLTerm()
    {
      COMPTERM_CONSTRUCTOR(7);
      ignored=PL_unify_arg(1, term, t1->getTerm());
      ignored=PL_unify_arg(2, term, t2->getTerm());
      ignored=PL_unify_arg(3, term, t3->getTerm());
      ignored=PL_unify_arg(4, term, t4->getTerm());
      ignored=PL_unify_arg(5, term, t5->getTerm());
      ignored=PL_unify_arg(6, term, t6->getTerm());
      ignored=PL_unify_arg(7, term, t7->getTerm());
      subterms.push_back(t1);
      subterms.push_back(t2);
      subterms.push_back(t3);
      subterms.push_back(t4);
      subterms.push_back(t5);
      subterms.push_back(t6);
      subterms.push_back(t7);
    }

    SWIPLCompTerm(const std::string name, 
		  SWIPLTerm* t1, SWIPLTerm* t2, SWIPLTerm* t3, 
		  SWIPLTerm* t4, SWIPLTerm* t5, SWIPLTerm* t6, 
		  SWIPLTerm* t7, SWIPLTerm* t8)
      : SWIPLTerm()
    {
      COMPTERM_CONSTRUCTOR(8);
      ignored=PL_unify_arg(1, term, t1->getTerm());
      ignored=PL_unify_arg(2, term, t2->getTerm());
      ignored=PL_unify_arg(3, term, t3->getTerm());
      ignored=PL_unify_arg(4, term, t4->getTerm());
      ignored=PL_unify_arg(5, term, t5->getTerm());
      ignored=PL_unify_arg(6, term, t6->getTerm());
      ignored=PL_unify_arg(7, term, t7->getTerm());
      ignored=PL_unify_arg(8, term, t8->getTerm());
      subterms.push_back(t1);
      subterms.push_back(t2);
      subterms.push_back(t3);
      subterms.push_back(t4);
      subterms.push_back(t5);
      subterms.push_back(t6);
      subterms.push_back(t7);
      subterms.push_back(t8);
    }

    SWIPLCompTerm(const std::string name, 
		  SWIPLTerm* t1, SWIPLTerm* t2, SWIPLTerm* t3, 
		  SWIPLTerm* t4, SWIPLTerm* t5, SWIPLTerm* t6, 
		  SWIPLTerm* t7, SWIPLTerm* t8, SWIPLTerm* t9)
      : SWIPLTerm()
    {
      COMPTERM_CONSTRUCTOR(9);
      ignored=PL_unify_arg(1, term, t1->getTerm());
      ignored=PL_unify_arg(2, term, t2->getTerm());
      ignored=PL_unify_arg(3, term, t3->getTerm());
      ignored=PL_unify_arg(4, term, t4->getTerm());
      ignored=PL_unify_arg(5, term, t5->getTerm());
      ignored=PL_unify_arg(6, term, t6->getTerm());
      ignored=PL_unify_arg(7, term, t7->getTerm());
      ignored=PL_unify_arg(8, term, t8->getTerm());
      ignored=PL_unify_arg(9, term, t9->getTerm());
      subterms.push_back(t1);
      subterms.push_back(t2);
      subterms.push_back(t3);
      subterms.push_back(t4);
      subterms.push_back(t5);
      subterms.push_back(t6);
      subterms.push_back(t7);
      subterms.push_back(t8);
      subterms.push_back(t9);
    }

    SWIPLCompTerm(const std::string name, 
		  SWIPLTerm* t1, SWIPLTerm* t2, SWIPLTerm* t3, 
		  SWIPLTerm* t4, SWIPLTerm* t5, SWIPLTerm* t6, 
		  SWIPLTerm* t7, SWIPLTerm* t8, SWIPLTerm* t9,
		  SWIPLTerm* t10)
      : SWIPLTerm()
    {
      COMPTERM_CONSTRUCTOR(10);
      ignored=PL_unify_arg(1, term, t1->getTerm());
      ignored=PL_unify_arg(2, term, t2->getTerm());
      ignored=PL_unify_arg(3, term, t3->getTerm());
      ignored=PL_unify_arg(4, term, t4->getTerm());
      ignored=PL_unify_arg(5, term, t5->getTerm());
      ignored=PL_unify_arg(6, term, t6->getTerm());
      ignored=PL_unify_arg(7, term, t7->getTerm());
      ignored=PL_unify_arg(8, term, t8->getTerm());
      ignored=PL_unify_arg(9, term, t9->getTerm());
      ignored=PL_unify_arg(10, term, t10->getTerm());
      subterms.push_back(t1);
      subterms.push_back(t2);
      subterms.push_back(t3);
      subterms.push_back(t4);
      subterms.push_back(t5);
      subterms.push_back(t6);
      subterms.push_back(t7);
      subterms.push_back(t8);
      subterms.push_back(t9);
      subterms.push_back(t10);
    }


    /// Creates a compound term with the given name. no subterms added yet.
    SWIPLCompTerm(const std::string functor = "#ERROR") {
      term = PL_new_term_ref();
      PL_put_atom_chars(term, functor.c_str());
#   if DEBUG_TERMITE
      std::cerr<<"CompTerm: PL_new_atom('"<<functor<<"') ="<<term<<std::endl;
#   endif
    }

    /// return a list of successors
    std::vector<SWIPLTerm*> getSubTerms() {
      std::vector<SWIPLTerm *> mSubterms;
      int arity = getArity();
      for(int n = 1; n <= arity; n++) { 
	term_t arg = PL_new_term_ref();
	int success=PL_get_arg(n, term, arg);
	if(!success) { /* do someting reasonable */ }
	mSubterms.push_back(newSWIPLTerm(arg));
      }
      return mSubterms;
    }

    /// Add a subterm at the first position
    virtual void addFirstSubTerm(Term* t) {
      int ignored;
#   if DEBUG_TERMITE
      std::cerr<<display(term)<<" . addFirstSubTerm("
	       <<t->getRepresentation()<<");"<<std::endl;
#   endif
      assert(0 && "this function does not exist");

      term_t old_term = term;
      int arity;
      atom_t name;
      if (PL_get_atom(old_term, &name)) { // still arity 0
	arity = 0;
      } else {
	ignored=PL_get_name_arity(old_term, &name, &arity);
      }

      // Construct a new, bigger term
      term_t args = PL_new_term_refs(arity+1);
      (void)PL_put_variable(args);
	
      for(int n = 1; n <= arity; n++)
	assert(ignored=PL_get_arg(n, old_term, args+n));

      term = PL_new_term_ref();
      ignored=PL_cons_functor_v(term, PL_new_functor(name, arity+1), args); 
      assert(ignored=PL_unify_arg(1, term, dynamic_cast<SWIPLTerm*>(t)->getTerm()));

#   if DEBUG_TERMITE
      std::cerr<<" --> "<<display(term)<<" !"<<std::endl;
#   endif
    }

    /// Add a subterm at the last position
    void addSubterm(Term* t) {
      int ignored;
#   if DEBUG_TERMITE
      std::cerr<<display(term)<<"  addSubterm("<<t->getRepresentation()<<");"
	       <<std::endl;
#   endif

      term_t old_term = term;
      int arity;
      term_t name;
      if ((ignored=PL_get_atom(old_term, &name))) { // still arity 0
	arity = 0;
      } else {
	ignored=PL_get_name_arity(old_term, &name, &arity);
      }

      // Construct a new, bigger term
      term_t args = PL_new_term_refs(arity+1);
      for(int n = 0; n < arity; n++)
	assert(ignored=PL_get_arg(n+1, old_term, args+n));
      PL_put_variable(args+arity);

      term = PL_new_term_ref();
      ignored=PL_cons_functor_v(term, PL_new_functor(name, arity+1), args); 

      SWIPLTerm* swi_t = dynamic_cast<SWIPLTerm*>(t);
      assert(PL_unify_arg(arity+1, term, swi_t->getTerm()));

      subterms.push_back(swi_t);

#   if DEBUG_TERMITE
      std::cerr<<" --> "<<display(term)<<" !"<<std::endl;
#   endif
    }

    /// the i-th subterm
    Term* at(int i) {
      int ignored;
      if (subterms[i] != NULL)
	return subterms[i];
      else {
	term_t arg = PL_new_term_ref();
	ignored=PL_get_arg(i+1, term, arg);
	subterms[i] = newSWIPLTerm(arg);
	return subterms[i];
      }
    }

  private:
    std::vector<SWIPLTerm *> subterms;
  };

  class SWIPLInfixOperator : public SWIPLCompTerm {
  public:
    SWIPLInfixOperator(std::string name) : SWIPLCompTerm(name) {};
  };


  /// class representing a prolog list
  class SWIPLList : public List, public SWIPLCompTerm {
  public:
    ///empty list
    SWIPLList() {
      term = PL_new_term_ref();
      (void)PL_put_nil(term);
#   if DEBUG_TERMITE
      std::cerr<<"new SWIPLList: "<<display(term)<<std::endl;
#   endif
    }

    SWIPLList(term_t t) : SWIPLCompTerm(t) {}

    ///construct from vector
    SWIPLList(std::vector<Term*> v) {
      int success;
      term = PL_new_term_ref();
      (void)PL_put_nil(term);
      for (std::vector<Term*>::reverse_iterator i = v.rbegin();
	   i != v.rend(); ++i) { 
	success=PL_cons_list(term, dynamic_cast<SWIPLTerm*>(*i)->getTerm(), term);
	if(!success) { /* do someting reasonable */ }
      }
#   if DEBUG_TERMITE
      std::cerr<<"new SWIPLList: "<<display(term)<<std::endl;
#   endif
    }

    SWIPLList(std::deque<Term*> v) {
      int success;
      term = PL_new_term_ref();
      (void)PL_put_nil(term);
      for (std::deque<Term*>::reverse_iterator i = v.rbegin();
	   i != v.rend(); ++i) { 
	success=PL_cons_list(term, dynamic_cast<SWIPLTerm*>(*i)->getTerm(), term);
	if(!success) { /* do someting reasonable */ }
      }
#   if DEBUG_TERMITE
      std::cerr<<"new SWIPLList: "<<display(term)<<std::endl;
#   endif
    }
  
    /// return size of the list
    int getArity() const { 
      int l = 0;
      fid_t fid = PL_open_foreign_frame();
      // FIXME: cache predicate
      term_t a0 = PL_new_term_refs(3);
      assert(PL_unify(a0, term));
      (void)PL_put_variable(a0+2);
      qid_t qid = PL_open_query(NULL, PL_Q_NORMAL, 
				PL_predicate("length", 2, ""), a0);
      assert(PL_next_solution(qid) && 
	     PL_get_integer(a0+1, &l));
      //PL_close_query(qid);
      PL_cut_query(qid);
      PL_discard_foreign_frame(fid);
      return l;
    }

    /// add a list element
    void addElement(Term* t) {
#   if DEBUG_TERMITE
      std::cerr<<"  addElement("<<display(term)<<" + " 
	       <<t->getRepresentation()<<")"<<std::endl;
#   endif

      term_t a0 = PL_new_term_refs(3);
      assert(PL_unify(a0, term));
      (void)PL_put_nil(a0+1);
      int success=PL_cons_list(a0+1, dynamic_cast<SWIPLTerm*>(t)->getTerm(), a0+1);
      if(!success) { /* do someting reasonable */ }
      (void)PL_put_variable(a0+2);
      // TODO: cache the predicates
      assert(PL_call_predicate(NULL, PL_Q_NORMAL, 
			       PL_predicate("append", 3, "library(lists)"), a0));
      term = a0 + 2;

#   if DEBUG_TERMITE
      for (int i = 0; i < 3; ++i)
	std::cerr<<display(a0+i)<<std::endl;
      std::cerr<<"-> "<<display(term)<<std::endl;
#   endif
    }

    /// add the first list element
    void addFirstElement(Term* t) {
      int success=PL_cons_list(term, dynamic_cast<SWIPLTerm*>(t)->getTerm(), term);
      if(!success) { /* do someting reasonable */ }
    }

    /// get the i-th element
    Term* at(int i) {
      assert(i >= 0);
      if ((unsigned) i < mTerms.size())
	return mTerms[i];

      term_t t = PL_copy_term_ref(term);

      for (int c = 0; c < i; c++)
	assert(PL_get_tail(t, t));
      int success=PL_get_head(t, t);
      if(!success) { /* do someting reasonable */ }
      return newSWIPLTerm(t);
    }

    /// return a list of successors
    std::deque<Term*>* getSuccs() {
      if (mTerms.size() == 0) {
	term_t tail = PL_copy_term_ref(term);
	term_t head = PL_new_term_ref();
	while (PL_get_list(tail, head, tail))
	  mTerms.push_back(newSWIPLTerm(head));
      }

      return &mTerms;
    }

  private:
    /// the successors
    std::deque<Term*> mTerms;
  };


  static inline term::SWIPLTerm* SWIPLTerm_cast(term::Term* t) {
    SWIPLTerm* swi_t = dynamic_cast<SWIPLTerm*>(t);
    assert(swi_t && "expected an SWIPL term");
    return swi_t;
  }

  class SWIPLTermFactory: public TermFactory {
    /// create a new atom
    Atom* makeAtom(const std::string& name, bool escape) const 
    { return new SWIPLAtom(name, escape); };

    /// create a new int
    Int* makeInt(const int value) const { return new SWIPLInt(value); }

    /// create a new float
    Float* makeFloat(const float value) const { return new SWIPLFloat(value); }

    /// create a new List
    List* makeList() const { return new SWIPLList(); }
    List* makeList(std::deque<term::Term*>& v) const { return new SWIPLList(v); }
    List* makeList(std::vector<Term*>& v) const { return new SWIPLList(v); }

    /// create a new compound term
    //  Yes, I do know about variadic functions.
    CompTerm* makeCompTerm(const std::string& name, 
			   Term* t1) const 
    { return new SWIPLCompTerm(name, SWIPLTerm_cast(t1)); }

    CompTerm* makeCompTerm(const std::string& name, 
			   Term* t1, Term* t2) const
    { return new SWIPLCompTerm(name, SWIPLTerm_cast(t1), SWIPLTerm_cast(t2)); }

    CompTerm* makeCompTerm(const std::string& name, 
			   Term* t1, Term* t2, Term* t3) const
    { return new SWIPLCompTerm(name, SWIPLTerm_cast(t1), SWIPLTerm_cast(t2), SWIPLTerm_cast(t3)); }

    CompTerm* makeCompTerm(const std::string& name, 
			   Term* t1, Term* t2, Term* t3,
			   Term* t4) const
    { return new SWIPLCompTerm(name, SWIPLTerm_cast(t1), SWIPLTerm_cast(t2), SWIPLTerm_cast(t3), 
			       SWIPLTerm_cast(t4)); }

    CompTerm* makeCompTerm(const std::string& name, 
			   Term* t1, Term* t2, Term* t3,
			   Term* t4, Term* t5) const
    { return new SWIPLCompTerm(name, SWIPLTerm_cast(t1), SWIPLTerm_cast(t2), SWIPLTerm_cast(t3), 
			       SWIPLTerm_cast(t4), SWIPLTerm_cast(t5)); }

    CompTerm* makeCompTerm(const std::string& name, 
			   Term* t1, Term* t2, Term* t3,
			   Term* t4, Term* t5, Term* t6) const
    { return new SWIPLCompTerm(name, SWIPLTerm_cast(t1), SWIPLTerm_cast(t2), SWIPLTerm_cast(t3), 
			       SWIPLTerm_cast(t4), SWIPLTerm_cast(t5), SWIPLTerm_cast(t6)); }

    CompTerm* makeCompTerm(const std::string& name, 
			   Term* t1, Term* t2, Term* t3,
			   Term* t4, Term* t5, Term* t6,
			   Term* t7) const
    { return new SWIPLCompTerm(name, SWIPLTerm_cast(t1), SWIPLTerm_cast(t2), SWIPLTerm_cast(t3), 
			       SWIPLTerm_cast(t4), SWIPLTerm_cast(t5), SWIPLTerm_cast(t6), 
			       SWIPLTerm_cast(t7)); }

    CompTerm* makeCompTerm(const std::string& name, 
			   Term* t1, Term* t2, Term* t3,
			   Term* t4, Term* t5, Term* t6,
			   Term* t7, Term* t8) const
    { return new SWIPLCompTerm(name, SWIPLTerm_cast(t1), SWIPLTerm_cast(t2), SWIPLTerm_cast(t3), 
			       SWIPLTerm_cast(t4), SWIPLTerm_cast(t5), SWIPLTerm_cast(t6), 
			       SWIPLTerm_cast(t7), SWIPLTerm_cast(t8)); }

    CompTerm* makeCompTerm(const std::string& name, 
			   Term* t1, Term* t2, Term* t3,
			   Term* t4, Term* t5, Term* t6,
			   Term* t7, Term* t8, Term* t9) const
    { return new SWIPLCompTerm(name, SWIPLTerm_cast(t1), SWIPLTerm_cast(t2), SWIPLTerm_cast(t3), 
			       SWIPLTerm_cast(t4), SWIPLTerm_cast(t5), SWIPLTerm_cast(t6), 
			       SWIPLTerm_cast(t7), SWIPLTerm_cast(t8), SWIPLTerm_cast(t9)); }

    CompTerm* makeCompTerm(const std::string& name, 
			   Term* t1, Term* t2, Term* t3,
			   Term* t4, Term* t5, Term* t6,
			   Term* t7, Term* t8, Term* t9,
			   Term* t10) const
    { return new SWIPLCompTerm(name, SWIPLTerm_cast(t1), SWIPLTerm_cast(t2), SWIPLTerm_cast(t3), 
			       SWIPLTerm_cast(t4), SWIPLTerm_cast(t5), SWIPLTerm_cast(t6), 
			       SWIPLTerm_cast(t7), SWIPLTerm_cast(t8), SWIPLTerm_cast(t9), 
			       SWIPLTerm_cast(t10)); }
  };






}
#endif
#endif
