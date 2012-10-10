#ifndef __STRATEGO_TERM_HPP__
#define __STRATEGO_TERM_HPP__
#include <term.h++>

namespace term {

  class StrategoTerm : virtual public STLTerm {
   /// Properly quote and escape an atom if necessary
  public:
    static void quote(std::ostream& r, const std::string atom) {
     //std::cerr<<"@@@@"<<std::endl;
     if (atom.length() == 0) {
       r << "\"\"";
     } else if (((atom.length() > 0) && (!islower(atom[0])) && (!isdigit(atom[0])))
		|| needs_quotes(atom)) {
       r << "\"";
       escape(r, atom);
       r << "\"";
     } else if (is_reserved_operator(atom)) {
       r << "(";
       escape(r, atom);
       r << ")";
     } else {
       escape(r, atom);
     }
   }
  };
  class StrategoAtom : virtual public STLAtom {
  public:
    StrategoAtom(const std::string name = "#ERROR", bool escapedRepresentation = true) :
      STLAtom(name, escapedRepresentation) { };
    virtual void quote(std::ostream& r, const std::string atom) const {
      STLTerm::quote(r, atom);
    }
    /// return the string
    std::string getRepresentation() const {
      std::ostringstream oss;
      dump(oss);
      return oss.str();
    }
    /// dump term representation to an ostream
    virtual void dump(std::ostream& s) const {
      s << "\"";
      escape(s, mName);
      s << "\"";
    }

  protected:
    // Escape non-printable characters
      static void escape(std::ostream& r, std::string s) {
      for (unsigned int i = 0; i < s.length(); ++i) {
	unsigned char c = s[i];
	switch (c) {
	case '\\': r << "\\\\"; break; // Literal backslash
	case '\"': r << "\\\""; break; // Double quote
	case '\'': r << "\\'"; break;  // Single quote
	case '\n': r << "\\n"; break;  // Newline (line feed)
	case '\r': r << "\\r"; break;  // Carriage return
	case '\b': r << "\\b"; break;  // Backspace
	case '\t': r << "\\t"; break;  // Horizontal tab
	case '\f': r << "\\f"; break;  // Form feed
	case '\a': r << "\\a"; break;  // Alert (bell)
	case '\v': r << "\\v"; break;  // Vertical tab
	case '!' : r << "MINITERMITE-STRATEGO-BANG";	   break;
	case '#' : r << "MINITERMITE-STRATEGO-OCTOTHORPE"; break;
	default:
	  if (c < 32 || c > 127) {
	    r << '\\' 
	      << std::oct 
	      << std::setfill('0') 
	      << std::setw(3) 
	      << (unsigned int)c // \nnn Character with octal value nnn
	      << '\\'; // Prolog expects this weird syntax with a trailing backslash
	  } else {
	    r << c;
	  }
	}
      }
      //cerr<<"escape("<<s<<") = "<< r <<endl;
    }

  };

  /// Representation of a compound prolog term.
  class StrategoCompTerm : public STLCompTerm {
  public:
    virtual void quote1(std::ostream& r, const std::string atom) const {
      // get around diamond inheritance woes
      StrategoTerm::quote(r, atom);
    }
    /// Creates a compound term with the given name. no subterms added yet.
    StrategoCompTerm(const std::string name = "#ERROR") : STLCompTerm(name) {};

    StrategoCompTerm(const std::string name, Term* t1)
      : STLCompTerm(name,t1)
    { }

    StrategoCompTerm(const std::string name, Term* t1, Term* t2) 
      : STLCompTerm(name,t1,t2)
    { }

    StrategoCompTerm(const std::string name, 
		Term* t1, Term* t2, Term* t3) 
      : STLCompTerm(name,t1,t2,t3)
    { }

    StrategoCompTerm(const std::string name, 
		Term* t1, Term* t2, Term* t3, 
		Term* t4) 
      : STLCompTerm(name,t1,t2,t3,t4)
    { }

    StrategoCompTerm(const std::string name, 
		Term* t1, Term* t2, Term* t3, 
		Term* t4, Term* t5) 
      : STLCompTerm(name,t1,t2,t3,t4,t5)
    { }

    StrategoCompTerm(const std::string name, 
		Term* t1, Term* t2, Term* t3,
		Term* t4, Term* t5, Term* t6) 
      : STLCompTerm(name,t1,t2,t3,t4,t5,t6)
    { }

    StrategoCompTerm(const std::string name, 
		Term* t1, Term* t2, Term* t3, 
		Term* t4, Term* t5, Term* t6, 
		Term* t7)
      : STLCompTerm(name,t1,t2,t3,t4,t5,t6,t7)
    { }

    StrategoCompTerm(const std::string name, 
		Term* t1, Term* t2, Term* t3, 
		Term* t4, Term* t5, Term* t6, 
		Term* t7, Term* t8)
      : STLCompTerm(name,t1,t2,t3,t4,t5,t6,t7,t8)
    { }

    StrategoCompTerm(const std::string name, 
		Term* t1, Term* t2, Term* t3, 
		Term* t4, Term* t5, Term* t6, 
		Term* t7, Term* t8, Term* t9)
      : STLCompTerm(name,t1,t2,t3,t4,t5,t6,t7,t8,t9)
    { }
  
    StrategoCompTerm(const std::string name, 
		Term* t1, Term* t2, Term* t3, 
		Term* t4, Term* t5, Term* t6, 
		Term* t7, Term* t8, Term* t9,
		Term* t10)
      : STLCompTerm(name,t1,t2,t3,t4,t5,t6,t7,t8,t9,t10)
    { }
  };

  class StrategoTermFactory : public STLTermFactory {
    /// create a new atom
    Atom* makeAtom(const std::string& name, bool escape) const 
    { return new StrategoAtom(name, escape); };

    /// create a new int
    Int* makeInt(const int value) const { return new STLInt(value); }

    /// create a new float
    Float* makeFloat(const float value) const { return new STLFloat(value); }

    /// create a new List
    List* makeList() const { return new STLList(); }
    List* makeList(std::deque<term::Term*>& v) const { return new STLList(v); }
    List* makeList(std::vector<term::Term*>& v) const { return new STLList(v); }

    /// create a new compound term
    //  Yes, I do know about variadic functions.
    CompTerm* makeCompTerm(const std::string& name, 
			   term::Term* t1) const
    { return new StrategoCompTerm(name, t1); }

    CompTerm* makeCompTerm(const std::string& name, 
			   term::Term* t1, term::Term* t2) const
    { return new StrategoCompTerm(name, t1, t2); }

    CompTerm* makeCompTerm(const std::string& name, 
			   term::Term* t1, term::Term* t2, term::Term* t3) const
    { return new StrategoCompTerm(name, t1, t2, t3); }

    CompTerm* makeCompTerm(const std::string& name, 
			   term::Term* t1, term::Term* t2, term::Term* t3,
			   term::Term* t4) const
    { return new StrategoCompTerm(name, t1, t2, t3, t4); }

    CompTerm* makeCompTerm(const std::string& name, 
			   term::Term* t1, term::Term* t2, term::Term* t3,
			   term::Term* t4, term::Term* t5) const
    { return new StrategoCompTerm(name, t1, t2, t3, t4, t5); }

    CompTerm* makeCompTerm(const std::string& name, 
			   term::Term* t1, term::Term* t2, term::Term* t3,
			   term::Term* t4, term::Term* t5, term::Term* t6) const
    { return new StrategoCompTerm(name, t1, t2, t3, t4, t5, t6); }

    CompTerm* makeCompTerm(const std::string& name, 
			   term::Term* t1, term::Term* t2, term::Term* t3,
			   term::Term* t4, term::Term* t5, term::Term* t6,
			   term::Term* t7) const
    { return new StrategoCompTerm(name, t1, t2, t3, t4, t5, t6, t7); }

    CompTerm* makeCompTerm(const std::string& name, 
			   term::Term* t1, term::Term* t2, term::Term* t3,
			   term::Term* t4, term::Term* t5, term::Term* t6,
			   term::Term* t7, term::Term* t8) const
    { return new StrategoCompTerm(name, t1, t2, t3, t4, t5, t6, t7, t8); }

    CompTerm* makeCompTerm(const std::string& name, 
			   term::Term* t1, term::Term* t2, term::Term* t3,
			   term::Term* t4, term::Term* t5, term::Term* t6,
			   term::Term* t7, term::Term* t8, term::Term* t9) const
    { return new StrategoCompTerm(name, t1, t2, t3, t4, t5, t6, t7, t8, t9); }

    CompTerm* makeCompTerm(const std::string& name, 
			   term::Term* t1, term::Term* t2, term::Term* t3,
			   term::Term* t4, term::Term* t5, term::Term* t6,
			   term::Term* t7, term::Term* t8, term::Term* t9,
			   term::Term* t10) const
    { return new StrategoCompTerm(name, t1, t2, t3, t4, t5, t6, t7, t8, t9, t10); }
  };
}
#endif
