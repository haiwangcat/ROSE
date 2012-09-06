#ifndef __TERM_HXX__
#define __TERM_HXX__

#include <assert.h>
#include <deque>
#include <vector>
#include <stdint.h>
#include <string>
#include <ostream>

namespace term {


  /// global initialization function (mostly used to initialize SWI-Prolog)
  bool init_termite(int argc, char **argv, bool interactive=false);


  class Term;
  class Atom;
  class Int;
  class Float;
  class List;
  class CompTerm;
  class Variable;

  class TermFactory {
  public:
    /// create a new atom
    virtual Atom* makeAtom(const std::string& name, bool escape=true) const = 0;

    /// create a new int
    virtual Int* makeInt(const int value) const = 0;

    /// create a new float
    virtual Float* makeFloat(const float value) const = 0;

    /// create a new List
    virtual List* makeList() const = 0;
    virtual List* makeList(std::deque<Term*>& v) const = 0;
    virtual List* makeList(std::vector<Term*>& v) const = 0;

    /// create a new compound term
    //  Yes, I do know about variadic functions.
    virtual CompTerm* makeCompTerm(const std::string& name, Term*) const = 0;
    virtual CompTerm* makeCompTerm(const std::string& name, 
				   Term*, Term*) const = 0;
    virtual CompTerm* makeCompTerm(const std::string& name, 
				   Term*, Term*, Term*) const = 0;
    virtual CompTerm* makeCompTerm(const std::string& name, 
				   Term*, Term*, Term*,
				   Term*) const = 0;
    virtual CompTerm* makeCompTerm(const std::string& name,
				   Term*, Term*, Term*,
				   Term*, Term*) const = 0;
    virtual CompTerm* makeCompTerm(const std::string& name, 
				   Term*, Term*, Term*,
				   Term*, Term*, Term*) const = 0;
    virtual CompTerm* makeCompTerm(const std::string& name, 
				   Term*, Term*, Term*,
				   Term*, Term*, Term*,
				   Term*) const = 0;
    virtual CompTerm* makeCompTerm(const std::string& name, 
				   Term*, Term*, Term*,
				   Term*, Term*, Term*,
				   Term*, Term*) const = 0;
    virtual CompTerm* makeCompTerm(const std::string& name, 
				   Term*, Term*, Term*,
				   Term*, Term*, Term*,
				   Term*, Term*, Term*) const = 0;
    virtual CompTerm* makeCompTerm(const std::string& name, 
				   Term*, Term*, Term*,
				   Term*, Term*, Term*,
				   Term*, Term*, Term*, 
				   Term*) const = 0;
  };

   
  /// Representation of a prolog term
  class Term {
  public:
    virtual ~Term() {};
    /// returns the arity of the term
    virtual int getArity() const = 0;
    /// returns whether or not the term is a ground term, i.e. contains
    /// no variables.
    /// Note that this is the case iff all the subterms are ground.
    virtual bool isGround() const = 0;
    /// Gets the name (functor/variable/constant) of the term. 
    /// numbers are represented as strings and therefore returned as such
    virtual std::string getName() const = 0;
    /// the actual prolog term that is represented by this object
    virtual std::string getRepresentation() const = 0;
    /// shorthand for getRepresenation()
    std::string repr() const { return getRepresentation(); }
    /// conversion to string
    operator std::string () { return getRepresentation(); }
    /// dump term representation to an ostream
    virtual void dump(std::ostream& s) const = 0;
   
    // true if the pattern can be unified with the term
    virtual bool matches(std::string pattern) = 0;

    virtual CompTerm* isCompTerm() = 0;
    virtual List* isList() = 0;
    virtual Atom* isAtom() = 0;
    virtual Int* isInt() = 0;
    virtual Float* isFloat() = 0;
    virtual Variable* isVariable() = 0;
  };
   
  /// class representing a prolog atom
  class Atom : virtual public Term {
  public:
  };
   
   
  ///class representing a prolog integer
  class Int : virtual public Term {
  public:
    /// return value
    virtual int64_t getValue() const = 0;
  };
   
   
  ///class representing a prolog float
  class Float : virtual public Term {
  public:
    /// return value
    virtual double getValue() const = 0;
  };
   
   
  /// Representation of a compound prolog term.
  class CompTerm : virtual public Term {
  public:   
    /// Add a subterm at the first position
    virtual void addFirstSubTerm(Term* t) = 0;
   
    /// Add a subterm at the last position
    virtual void addSubterm(Term* t) = 0;
   
    /// the i-th subterm
    virtual Term* at(int i) = 0;
  };


  ///class representing a prolog list
  class List : virtual public Term {
  public:
    /// add a list element
    virtual void addElement(Term* t) = 0;
   
    /// add a list element at the beginning
    virtual void addFirstElement(Term* t) = 0;
   
    /// get the i-th element
    virtual Term* at(int i) = 0;

    /// get a list of all successors
    virtual std::deque<Term*>* getSuccs() = 0;

  };
   
   
  ///class representing a prolog variable
  class Variable : virtual public Term {
  public:
    /// arity is always zero
    virtual int getArity() const {return 0;};
    /// a variable isn't ground
    virtual bool isGround() const {return false;};
  };
   
     
  /// Representation of an infix operator.
  class InfixOperator : virtual public CompTerm {
  };

}

#endif
