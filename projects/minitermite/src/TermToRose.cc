/* -*- C++ -*-
Copyright 2006 Christoph Bonitz <christoph.bonitz@gmail.com>
          2007-2011 Adrian Prantl <adrian@complang.tuwien.ac.at>
*/

#include <rose.h>
#include <rose_config.h>
#include "minitermite.h"
#include "TermToRose.h"
#include "AstJanitor.h"
#include <iostream>
#include <sstream>
#include <string>
#include <assert.h>
#include <boost/algorithm/string/predicate.hpp>
#include <typeinfo>
#include <sys/types.h>

#include "termparser.tab.h++"
extern int yyparse();
extern FILE* yyin;
extern term::Term* prote;

static SgSourceFile* dummy_to_please_rose = NULL;

using namespace std;
using namespace boost;
using namespace term;

/** issue a warning*/
void
TermToRose::warn_msg(std::string msg) {
  /* since this is only a warning, i think stdout is okay*/
  cerr << "/*" << msg << "*/\n";
}

/** output a debug message, unless
 * compiled with NDEBUG*/
#define debug(message) {                        \
    /*cerr << "TERMITE>>" << message << "\n";*/ \
}

Term* TermToRose::canonical_type(Term* term) {
  CompTerm *t = term->isCompTerm();
  if (!t) return term;
  string n = t->getName();

  if (n == "pointer_type")
    // For iname lookup purposes, we treat array_type(X,null) and
    // pointer_type(X) as equivalent
    return termFactory.makeCompTerm("array_type", 
                                    canonical_type(t->at(0)), 
                                    termFactory.makeAtom("null"));

  if (n == "array_type") // remove initializer
    return termFactory.makeCompTerm(n, canonical_type(t->at(0)), 
                                    termFactory.makeAtom("null"));

  if (n == "typedef_type")      // actual type instead of typedef type
    return canonical_type(t->at(1));

  return term;
}

/* Hash Keys */
static inline string makeFunctionID(const string& func_name,
                                    const string& func_type) {
  return func_name+'-'+func_type;
}
#define makeInameID(annot) \
  (annot->at(1)->getRepresentation() + \
   '-' + canonical_type(annot->at(0))->getRepresentation())

/* Error handling. Macros are used to keep a useful line number. */
#define TERM_ASSERT(t, assertion) do { \
    if (!(assertion)) \
      cerr << "** ERROR: In " << t->getArity() << "-ary Term\n  >>"     \
           << t->getRepresentation() << "<<\n:" << endl;                \
    ROSE_ASSERT(assertion);                                             \
  } while (0)

#define TERM_ASSERT_UPGRADE(t, assertion) do {                          \
    if (!(assertion))                                                   \
      cerr << "** ERROR: Unsupported " << t->getArity() << "-ary Term\n  >>" \
           << t->getRepresentation() << "<<\n\n"                        \
           << "====================================\n"                  \
           << "Did you upgrade ROSE?\n"                                 \
           << "In that case the arity/layout of\n"                      \
           << "certain node types may have changed.\n"                  \
           << "In any case, please report this bug to\n"                \
           << PACKAGE_BUGREPORT << "\n"                                 \
           << "====================================\n"                  \
           << endl;                                                     \
    ROSE_ASSERT(assertion);                                             \
  } while (0)

#define isCompTerm(t) (t)->isCompTerm()
#define isAtom(t)     (t)->isAtom()
#define isList(t)     (t)->isList()
#define isInt(t)      (t)->isInt()
#define isFloat(t)    (t)->isFloat()

#if ROSE_HAVE_MINITERMITE_ANALYSIS_RESULTS
#  define AR 0
#else
#  define AR 1
#endif

#define ARITY_ASSERT(t, arity) do {                                     \
    if ((t)->getArity() != (arity)) {                                   \
      cerr << "** ERROR: " << (t)->getArity() << "-ary Term\n  >>"      \
           << (t)->getRepresentation() << "<<\n"                        \
           << "does not have the expected arity of " << (arity)         \
           << endl;                                                     \
      ROSE_ASSERT(false && "Arity Error");                              \
    }                                                                   \
  } while (0)

/* Expect dynamic_casts. Abort if cast fails. */
template< class NodeType >
void expect_node(SgNode* n, NodeType **r) {
  *r = dynamic_cast<NodeType*>(n);
  if (r == NULL) {
    NodeType t;
    std::cerr << "** ERROR: The node\n  " << n->unparseToString()
              << "\nof type >>"
              << n->class_name() << "<< "
              << " does not have the expected type of >>"
              << t.class_name()
              << "<<" << std::endl;
    ROSE_ASSERT(false && "Type Error");
  }
}

template< class TermType >
void expect_term(Term* n, TermType **r) {
  *r = dynamic_cast<TermType*>(n);
  if (*r == NULL) {
    //TermType t;
    std::cerr << "** ERROR: The term\n  "
              << n->getRepresentation() << "\nof type >>"
              << typeid(n).name() << "<< "
              << " does not have the expected type of >>"
              << typeid(r).name()
              << "<<" << std::endl;
    ROSE_ASSERT(false && "Type Error");
  }
}

/* Special case for  Terms, with check for name  */
template< class TermType >
void expect_term(Term* n, TermType **r,
                 std::string name) {
  expect_term(n, r);
  if ((*r)->getName() != name) {
    std::cerr << "** ERROR: The term\n  "
              << n->getRepresentation() << "\nof type >>"
              << (*r)->getName() << "<< "
              << " does not have the expected type of >>" << name
              << "<<" << std::endl;
    ROSE_ASSERT(false && "Type Error");
  }
}

/* Special case for  Terms, with check for arity and name  */
template< class TermType >
void expect_term(Term* n, TermType **r,
                 std::string name, int arity) {
  expect_term(n, r, name);
  ARITY_ASSERT(*r, arity);
}

#define EXPECT_NODE(type, spec, base)           \
  type spec;                                    \
  expect_node(base, &spec);
#define EXPECT_TERM(type, spec, base)           \
  type spec;                                    \
  expect_term(base, &spec);
#define EXPECT_TERM_NAME(type, spec, base, name)        \
  type spec;                                            \
  expect_term(base, &spec, name);
#define EXPECT_TERM_NAME_ARITY(type, spec, base, name, arity)   \
  type spec;                                                    \
  expect_term(base, &spec, name, arity);
#define EXPECT_ATOM(name, base)                 \
  std::string name;                             \
  {                                             \
     EXPECT_TERM(Atom*, a, base);               \
     name = a->getName();                       \
  }

/** reverse of makeFlag */
bool TermToRose::createFlag(Term *t) {
  EXPECT_TERM(Atom*, atom, t);
  if (starts_with(atom->getName(), "no_"))
    return false;
  else return true;
}

SgNode*
TermToRose::toRose(const char* filename) {
#if ROSE_HAVE_SWI_PROLOG
  if (dynamic_cast<SWIPLInt*>(termFactory.makeInt(0)) == NULL)
#endif
  {
    ROSE_ASSERT(string(filename) != "");
    yyin = fopen( filename, "r" );
    ROSE_ASSERT(yyin);
    yyparse();
#if ROSE_HAVE_SWI_PROLOG
  } else {
    /*open('input.pl',read,_,[alias(rstrm)]),
      read_term(rstrm,X,[double_quotes(string)]),
      close(rstrm),*/

    term_t a0 = PL_new_term_refs(10);
    term_t fn        = a0 + 0;
    term_t read      = a0 + 1;
    term_t var       = a0 + 2;
    term_t alias     = a0 + 3;
    term_t open      = a0 + 4;
    term_t r         = a0 + 5;
    term_t term      = a0 + 6;
    term_t flags     = a0 + 7;
    term_t read_term = a0 + 8;
    term_t close     = a0 + 9;


    PL_put_atom_chars(fn, filename);
    PL_put_atom_chars(read, "read");
    PL_put_variable(var);
    PL_chars_to_term("[alias(r)]", alias);
    int ignored;
    ignored=PL_cons_functor(open, PL_new_functor(PL_new_atom("open"), 4),
                            fn, read, var, alias);

    PL_put_atom_chars(r, "r");
    PL_put_variable(term);
    PL_chars_to_term("[double_quotes(string)]", flags);
    ignored=PL_cons_functor(read_term, PL_new_functor(PL_new_atom("read_term"), 3),
                            r, term, flags);

    PL_chars_to_term("close(r)", close);

    assert(PL_call(open, NULL) &&
           PL_call(read_term, NULL) &&
           PL_call(close, NULL));

    prote = SWIPLTerm::wrap_PL_Term(term);

#endif
  }
  // ROSE (late 2011) now goes through the memory pool to see what
  // source languages we are using when it is unparsing array type
  // expressions, and fails if there are no files yet.  We also use
  // this as temporary parent node to silence a couple of assertions
  // that would temporarily fail, since we are building our ROSE AST
  // bottom-up!
  dummy_to_please_rose = new SgSourceFile();
  Sg_File_Info* fi = FI;
  fi->set_parent(dummy_to_please_rose);
  dummy_to_please_rose->set_file_info(fi);
  SgNode* root = toRose(prote);
  delete dummy_to_please_rose;
  ROSE_ASSERT(declarationStatementsWithoutScope.empty());
  return root;
}

/**
 * create ROSE-IR for valid term representation
 */
SgNode*
TermToRose::toRose(Term* t) {
  SgNode* node;
  if(CompTerm* c = isCompTerm(t)) {

    string tname = c->getName();
    debug("converting " + tname + "\n");
    if (isList(c->at(0))) {
      //cerr << "list"<<endl;
      node = listToRose(c,tname);
    } else {
      switch (c->getArity()) {
      case (3-AR): node = leafToRose(c,tname); break;
      case (4-AR): node = unaryToRose(c,tname); break;
      case (5-AR): node = binaryToRose(c,tname); break;
      case (6-AR): node = ternaryToRose(c,tname); break;
      case (7-AR): node = quaternaryToRose(c,tname); break;
      default: node = (SgNode*) 0;
      }
    }
  } else {
    node = (SgNode*) 0;
  }

  if ((node == NULL) && (t->getRepresentation() != "null")
      && (t->getName() != "source_file")) {
    cerr << "**WARNING: could not translate the term '"
         << t->getRepresentation() << "'"
         << " of arity " << t->getArity() << "." << endl;
    assert(0);
  }

  SgLocatedNode* ln = isSgLocatedNode(node);
  // Create the attached PreprocessingInfo
  CompTerm* ct = isCompTerm(t);
  if (ln != NULL && ct != NULL) {
    CompTerm* annot = isCompTerm(ct->at(ct->getArity()-(3-AR)));
    TERM_ASSERT(t, annot);

    CompTerm* ppil = isCompTerm(annot->at(annot->getArity()-1));
    if (ppil) {
      List* l = isList(ppil->at(0));
      if (l) {
        for (int i = 0; i < l->getArity(); ++i) {

          EXPECT_TERM(CompTerm*, ppi, l->at(i));

          Sg_File_Info* fi = createFileInfo(ppi->at(ppi->getArity()-1));
          PreprocessingInfo::RelativePositionType locationInL =
            re.enum_RelativePositionType[*ppi->at(1)];

          ln->addToAttachedPreprocessingInfo(
	     new PreprocessingInfo(re.enum_DirectiveType[ppi->getName()],
                                   ppi->at(0)->getName(),
                                   fi->get_filenameString(),
                                   fi->get_line(),
                                   fi->get_col(),
                                   1 /* FIXME: nol */,
                                   locationInL));
        }
      } else TERM_ASSERT(t, ppil->at(0)->getName() == "null");
    }
    // Set end of construct info
    Sg_File_Info *endfi = createFileInfo(ct->at(ct->getArity()-1));
    ln->set_endOfConstruct(endfi);
  }
  return node;
}

/** create ROSE-IR for unary node*/
SgNode*
TermToRose::unaryToRose(CompTerm* t,std::string tname) {
  debug("unparsing unary"); debug(t->getRepresentation());
  /* assert correct arity of term*/
  ARITY_ASSERT(t, 4-AR);

  /*node to be created*/
  SgNode* s = NULL;
  /*create file info and check it*/
  Sg_File_Info* fi = createFileInfo(t->at(t->getArity()-1));
  testFileInfo(fi);

  if (tname == "class_declaration") {
    /* class declarations must be handled before their bodies because they
     * can be recursive */
    s = createClassDeclaration(fi,NULL,t);
  }

  /*get child node (prefix traversal step)*/
  SgNode* child1 = toRose(t->at(0));

  /* depending on the node type: create it*/
  if (tname == "class_declaration") {
    /* class declaration: created above, needs fixup here */
    s = setClassDeclarationBody(isSgClassDeclaration(s),child1);
  }
  else if(isValueExp(tname)) s = createValueExp(fi,child1,t);
  else if(isUnaryOp(tname)) s = createUnaryOp(fi,child1,t);
  else if (tname == "aggregate_initializer")        s = createAggregateInitializer(fi,child1,t);
  else if (tname == "assign_initializer")           s = createAssignInitializer(fi,child1,t);
  else if (tname == "asm_op")                       s = createAsmOp(fi,child1,t);
  else if (tname == "common_block_object")          s = createCommonBlockObject(fi,child1,t);
  else if (tname == "constructor_initializer")      s = createConstructorInitializer(fi,child1,t);
  else if (tname == "default_option_stmt")          s = createDefaultOptionStmt(fi,child1,t);
  else if (tname == "delete_exp")                   s = createDeleteExp(fi,child1,t);
  else if (tname == "expr_statement")               s = createExprStatement(fi,child1,t);
  else if (tname == "function_definition")          s = createFunctionDefinition(fi,child1,t);
  else if (tname == "initialized_name")             s = createInitializedName(fi,child1,t);
  else if (tname == "label_symbol")                 s = createLabelSymbol(fi,child1,t);
  else if (tname == "namespace_declaration_statement") 
    s = createNamespaceDeclarationStatement(fi,child1,t);
  else if (tname == "pragma_declaration")           s = createPragmaDeclaration(fi,child1,t);
  else if (tname == "return_stmt")                  s = createReturnStmt(fi,child1,t);
  else if (tname == "size_of_op")                   s = createSizeOfOp(fi,child1,t);
  else if (tname == "source_file")                  s = createFile(fi,child1,t);
  else if (tname == "typedef_declaration")          s = createTypedefDeclaration(fi,t);
  else if (tname == "var_arg_end_op")               s = createVarArgEndOp(fi,child1,t);
  else if (tname == "var_arg_op")                   s = createVarArgOp(fi,child1,t);
  else if (tname == "var_arg_start_one_operand_op") s = createVarArgStartOneOperandOp(fi,child1,t);
  else cerr<<"**WARNING: unhandled Unary Node: "<<tname<<endl;

  TERM_ASSERT_UPGRADE(t, s != NULL);

  /*set s to be the parent of its child node*/
  //cerr<<s->class_name()<<endl;
  if (s != NULL){ //&& !isSgProject(s) && !isSgFile(s) && !isSgGlobal(s)) {
    if(child1 != NULL) {
      child1->set_parent(s);
    }
  }
  return s;
}

/** create ROSE-IR for binary node*/
SgNode*
TermToRose::binaryToRose(CompTerm* t,std::string tname) {
  debug("unparsing binary"); debug(t->getRepresentation());
  /* assert correct arity of term*/
  ARITY_ASSERT(t, 5-AR);
  /*create file info and check it*/
  Sg_File_Info* fi = createFileInfo(t->at(t->getArity()-1));
  testFileInfo(fi);


  /* node to be created*/
  SgNode* s = NULL;
  /*get child node 1 (prefix traversal step)*/
  SgNode* child1 = toRose(t->at(0));
  /*get child node 2 (almost-prefix traversal step)*/
  SgNode* child2 = toRose(t->at(1));

  /* create nodes depending on type */
  if (isBinaryOp(tname)) {
    s = createBinaryOp(fi,child1,child2,t);
  } else if (tname == "cast_exp") {
    s = createUnaryOp(fi,child1,t);
  } else if (tname == "switch_statement") {
    s = createSwitchStatement(fi,child1,child2,t);
  } else if (tname == "do_while_stmt") {
    s = createDoWhileStmt(fi,child1,child2,t);
  } else if (tname == "while_stmt") {
    s = createWhileStmt(fi,child1,child2,t);
  } else if(tname == "var_arg_copy_op") {
    s = createVarArgCopyOp(fi,child1,child2,t);
  } else if(tname == "var_arg_start_op") {
    s = createVarArgStartOp(fi,child1,child2,t);
  } else if(tname == "function_call_exp") {
    s = createFunctionCallExp(fi,child1,child2,t);
  } else if(tname == "try_stmt") {
    s = createTryStmt(fi,child1,child2,t);
  } else if(tname == "catch_option_stmt") {
    s = createCatchOptionStmt(fi,child1,child2,t);
  } else if(tname == "template_argument") {
    s = createTemplateArgument(t);
  } else if (tname == "source_file") {
    TERM_ASSERT(t, false && "a source_file should not be a binary node!");
    s = createFile(fi,child1,t);
  } else cerr<<"**WARNING: unhandled Binary Node: "<<tname<<endl;

  TERM_ASSERT_UPGRADE(t, s != NULL);

  /*set s to be the parent of its child nodes*/
  if (s != NULL) {
    if(child1 != NULL) {
      child1->set_parent(s);
    }
    if(child2 != NULL) {
      child2->set_parent(s);
    }
  }
  return s;
}

/** create ROSE-IR for ternary node*/
SgNode*
TermToRose::ternaryToRose(CompTerm* t,std::string tname) {
  debug("unparsing ternary");
  // assert correct arity of term
  ARITY_ASSERT(t, 6-AR);

  // node to be created 
  SgNode* s = NULL;

  // create file info and check it
  Sg_File_Info* fi = createFileInfo(t->at(t->getArity()-1));
  testFileInfo(fi);

  // get child nodes (prefix traversal step)
  SgNode* child1 = toRose(t->at(0));

  if (tname == "function_declaration") {
    /* function declarations are special: we create an incomplete
     * declaration before traversing the body; this is necessary for
     * recursive functions */
    s = createFunctionDeclaration(fi,child1,t);
  } else if (tname == "template_instantiation_function_decl") {
    /* function declarations are special: we create an incomplete
     * declaration before traversing the body; this is necessary for
     * recursive functions */
    s = createTemplateInstantiationFunctionDecl(fi,child1,t);
  }


  // remaining children (traversals)
  SgNode* child2 = toRose(t->at(1));
  SgNode* child3 = toRose(t->at(2));

  /* create nodes depending on type*/
  if (tname == "if_stmt") {
    s = createIfStmt(fi,child1,child2,child3,t);
  } else if (tname == "function_declaration" || 
             tname == "template_instantiation_function_decl") {
    /* function declaration: created above, needs a fixup here */
    /* child2 is the decorator now */
    s = setFunctionDeclarationBody(isSgFunctionDeclaration(s),child3);
  } else if (tname == "case_option_stmt") {
    s = createCaseOptionStmt(fi,child1,child2,child3,t);
  } else if (tname == "new_exp") {
    s = createNewExp(fi,child1,child2,child3,t);
  } else if (tname == "conditional_exp") {
    s = createConditionalExp(fi,child1,child2,child3,t);
  } else if (tname == "program_header_statement") {
    s = createProgramHeaderStatement(fi,child1,child2,child3,t);
  } else cerr<<"**WARNING: unhandled Ternary Node: "<<tname<<endl;

  TERM_ASSERT_UPGRADE(t, s != NULL);

  /*set s to be the parent of its child nodes*/
  if (s != NULL) {
    if(child1 != NULL) {
      child1->set_parent(s);
    }
    if(child2 != NULL) {
      child2->set_parent(s);
    }
    if(child3 != NULL) {
      child3->set_parent(s);
    }
  }
  return s;
}

/** create ROSE-IR for quaternary node*/
SgNode*
TermToRose::quaternaryToRose(CompTerm* t,std::string tname) {
  debug("unparsing quaternary");
  /* assert correct arity of term*/
  ARITY_ASSERT(t, 7-AR);
  /*create file info and check it*/
  Sg_File_Info* fi = createFileInfo(t->at(t->getArity()-1));
  testFileInfo(fi);
  /* node to be created*/
  SgNode* s = NULL;

  if (tname == "procedure_header_statement") {
    fortranFunctionTypeMap.clear();
  }

  /*get child nodes (prefix traversal step)*/
  SgNode* child1 = toRose(t->at(0));
  SgNode* child2 = toRose(t->at(1));
  SgNode* child4 = toRose(t->at(3));

  if (tname == "member_function_declaration") {
    /* function declarations are special: we create an incomplete
     * declaration before traversing the body; this is necessary for
     * recursive functions */
    s = createMemberFunctionDeclaration(fi,child1,child2,child4,t);
  }

  // now do the body
  SgNode* child3 = toRose(t->at(2));

  if (tname == "member_function_declaration") {
    /* function declaration: created above, needs a fixup here */
    s = setFunctionDeclarationBody(isSgFunctionDeclaration(s),child3);
  }
  else if (tname == "for_statement") s = createForStatement(fi,child1,child2,child3,child4,t);
  else if (tname == "fortran_do")    s = createFortranDo(fi,child1,child2,child3,child4,t);
  else if (tname == "procedure_header_statement") {
    // don't think they can be recursive!?
    s = createProcedureHeaderStatement(fi,child1,child2,child3,child4,t);
  } else cerr<<"**WARNING: unhandled Quarternary Node: "<<tname<<endl;

  TERM_ASSERT(t, s != NULL);

  /*set s to be the parent of its child nodes*/
  if (child1 != NULL) child1->set_parent(s);
  if (child2 != NULL) child2->set_parent(s);
  if (child3 != NULL) child3->set_parent(s);
  if (child4 != NULL) child4->set_parent(s);
  return s;
}

/** create ROSE-IR for list node*/
SgNode*
TermToRose::listToRose(CompTerm* t,std::string tname) {
  debug("unparsing list node");
  ARITY_ASSERT(t, 4-AR);
  EXPECT_TERM(List*, l, t->at(0));
  /*create file info and check it*/
  Sg_File_Info* fi = createFileInfo(t->at(t->getArity()-1));
  testFileInfo(fi);
  /*get child nodes (prefix traversal step)*/
  SgNode* cur = NULL;
  /* recursively, create ROSE-IR for list-members*/
  deque<Term*>* succterms = l->getSuccs();

  /* lookahead hack for variable declarations: the annotation term must be
   * traversed first because it may contain a type declaration */
  SgDeclarationStatement *varDeclBaseTypeDecl = NULL;
  if (tname == "variable_declaration") {
    EXPECT_TERM_NAME_ARITY(CompTerm*, annot, t->at(1),
                 "variable_declaration_specific", 3);
    Term* typeDeclTerm = annot->at(1);
    if (!(isAtom(typeDeclTerm))) {
      varDeclBaseTypeDecl = isSgDeclarationStatement(toRose(typeDeclTerm));
      declarationStatementsWithoutScope.push_back(varDeclBaseTypeDecl);
    }
  }

  /* lookahead hack */
  if (tname == "global")
    globalDecls = succterms;

  deque<SgNode*>* succs = new deque<SgNode*>();
  deque<Term*>::iterator it = succterms->begin();
  while (it != succterms->end()) {
    cur = toRose(*it);
    if(cur != (SgNode*) 0) {
      succs->push_back(cur);
      debug("added successor of type " + (isCompTerm(t))->at(0)->getName());
    } else {
      debug("did not add NULL successor");
    }
    it++;
  }
  /* depending on the type, create node*/
  SgNode* s = NULL;
  if(tname == "global") {
    s = createGlobal(fi,succs);
  } else if (tname == "project") {
    s = createProject(fi,succs);
  } else if (tname == "function_parameter_list") {
    s = createFunctionParameterList(fi,succs);
  } else if (tname == "basic_block") {
    s = createBasicBlock(fi,succs);
  } else if (tname == "common_block") {
    s = createCommonBlock(fi,succs);
  } else if (tname == "variable_declaration") {
    s = createVariableDeclaration(fi,succs,t,varDeclBaseTypeDecl);
  } else if (tname == "for_init_statement") {
    s = createForInitStatement(fi,succs);
  } else if (tname == "class_definition") {
    s = createClassDefinition(fi,succs,t);
  } else if (tname == "enum_declaration") {
    s = createEnumDeclaration(fi,succs,t);
  } else if (tname == "expr_list_exp") {
    s = createExprListExp(fi,succs);
  } else if (tname == "ctor_initializer_list") {
    s = createCtorInitializerList(fi,succs);
  } else if (tname == "namespace_definition_statement") {
    s = createNamespaceDefinitionStatement(fi,succs);
  } else if (tname == "catch_statement_seq") {
    s = createCatchStatementSeq(fi,succs);
  } else if (tname == "print_statement") {
    s = createPrintStatement(fi,succs,t);
  } else if (tname == "write_statement") {
    s = createWriteStatement(fi,succs,t);
  } else if (tname == "asm_stmt") {
    s = createAsmStmt(fi, succs, t);
  } else if (tname == "asmx86_instruction") {
    s = createAsmx86Instruction(succs, t);
  }
  TERM_ASSERT_UPGRADE(t, s != NULL);

  /* note that for the list nodes the set_parent operation takes place
   * inside the methods when necessary since they always require
   * an iteration over the list anyway. */

  return s;
}


/**create ROSE-IR from leaf terms*/
SgNode*
TermToRose::leafToRose(CompTerm* t,std::string tname) {
  debug("unparsing leaf");
  /* assert correct arity of term*/
  ARITY_ASSERT(t, 3-AR);
  /* create file info and check it*/
  Sg_File_Info* fi = createFileInfo(t->at(t->getArity()-1));
  testFileInfo(fi);
  /* node to be created*/
  SgNode* s = NULL;
  /* some list nodes become leaf nodes when the list is empty
   * -> create dummy list and call corresponding factory methods*/
  if (tname == "function_parameter_list")     s = createFunctionParameterList(fi, new deque<SgNode*>);
  else if (tname == "basic_block")            s = createBasicBlock(fi, new deque<SgNode*>);
  else if (tname == "class_definition")       s = createClassDefinition(fi, new deque<SgNode*>,t);
  else if (tname == "for_init_statement")     s = createForInitStatement(fi, new deque<SgNode*>);
  else if (tname == "ctor_initializer_list")  s = createCtorInitializerList(fi, new deque<SgNode*>);
  else if (tname == "expr_list_exp")          s = createExprListExp(fi, new deque<SgNode*>);
  else if (tname == "namespace_definition_statement") 
    s = createNamespaceDefinitionStatement(fi, new deque<SgNode*>);
  
    /* regular leaf nodes*/
  else if (tname == "attribute_specification_statement")  
    s = createAttributeSpecificationStatement(fi,t);

  else if (isValueExp(tname))                  s = createValueExp(fi,NULL,t);
  else if (tname == "asterisk_shape_exp")      s = createAsteriskShapeExp(fi, t);
  else if (tname == "break_stmt")              s = createBreakStmt(fi,t);
  else if (tname == "contains_statement")      s = new SgContainsStatement(fi);
  else if (tname == "continue_stmt")           s = createContinueStmt(fi,t);
  else if (tname == "format_item")             s = createFormatItem(fi,t);
  else if (tname == "format_statement")        s = createFormatStatement(fi,t);
  else if (tname == "fortran_include_line")    s = createFortranIncludeLine(fi, t);
  else if (tname == "function_ref_exp")        s = createFunctionRefExp(fi,t);
  else if (tname == "goto_statement")          s = createGotoStatement(fi,t);
  else if (tname == "implicit_statement")      s = createImplicitStatement(fi,t);
  else if (tname == "label_statement")         s = createLabelStatement(fi,t);
  else if (tname == "label_ref_exp")           s = createLabelRefExp(fi,t);
  else if (tname == "member_function_ref_exp") s = createMemberFunctionRefExp(fi,t);
  else if (tname == "null_expression")         s = new SgNullExpression(fi);
  else if (tname == "null_statement")          s = new SgNullStatement(fi);
  else if (tname == "pragma")                  s = createPragma(fi,t);
  else if (tname == "ref_exp")                 s = createRefExp(fi,t);
  else if (tname == "template_argument")       s = createTemplateArgument(t);
  else if (tname == "template_declaration")    s = createTemplateDeclaration(fi, t);
  else if (tname == "template_parameter")      s = createTemplateParameter(fi, t);
  else if (tname == "this_exp")                s = createThisExp(fi,t);
  else if (tname == "typedef_seq")             s = createTypedefSeq(fi, t);
  else if (tname == "var_ref_exp")             s = createVarRefExp(fi,t);
  TERM_ASSERT_UPGRADE(t, s != NULL);
  return s;
}

/** test file info soundness*/
void
TermToRose::testFileInfo(Sg_File_Info* fi) {
  ROSE_ASSERT(fi != NULL);
  ROSE_ASSERT(fi->get_line() >= 0);
  ROSE_ASSERT(fi->get_col() >= 0);
}

/** create Sg_File_Info from term*/
Sg_File_Info*
TermToRose::createFileInfo(Term* t) {
  debug("unparsing file info");
  Sg_File_Info *fi = NULL;
  if (Atom *a = isAtom(t)) {
    /*node new or file info removed during transformation*/
    /*=> only possible atom: null*/
    assert(a->getName() == "null");
    fi = FI;
  } else {
    /*file info was preserved*/
    /*=> the file info term should be named file_info and have an arity of 3*/
    EXPECT_TERM_NAME_ARITY(CompTerm*, u, t, "file_info", 3);
    debug(u->getRepresentation());
    if ((u->at(0)->getName() == "compilerGenerated") ||
        (u->at(0)->getName() == "<invalid>")) {
      debug("compiler generated node");
      fi = Sg_File_Info::generateDefaultFileInfoForCompilerGeneratedNode();
      // if we do not set the output flag, the unparser will sometimes
      // refuse to output entire basic blocks
      fi->setOutputInCodeGeneration();
    }
    else {
      /* a filename is present => retrieve data from term and generete node*/
      EXPECT_TERM(Atom*, filename, u->at(0));
      EXPECT_TERM(Int*, line, u->at(1));
      EXPECT_TERM(Int*, col, u->at(2));
      /* filename must be a term representing a character string,
       * line and col are integers */
      assert(line->getValue() >= 0);
      assert( col->getValue() >= 0);
      fi = new Sg_File_Info(filename->getName(),
                            line->getValue(), col->getValue());
    }
  }
  TERM_ASSERT(t, fi != NULL);

  return fi;
}

/**create enum type from annotation*/
SgEnumType*
TermToRose::createEnumType(Term* t) {
  /* first subterm is the name of the enum*/
  debug("creating enum type");
  EXPECT_TERM_NAME(CompTerm*, annot, t, "enum_type");
  /*create dummy declaration*/
  string id = annot->at(0)->getRepresentation();
  SgEnumType* type = NULL;
  if (lookupType(&type, id)) {
    // We have a problem since we only use the first definition as a reference
    return type;
  } else {
    cerr<<id<<endl;
    TERM_ASSERT(t, false);
    SgEnumDeclaration* dec = isSgEnumDeclaration(toRose(annot->at(0)));
    TERM_ASSERT(t, dec != NULL);
    /* create type using a factory Method*/
    return SgEnumType::createType(dec);
  }
}

/**create pointer type from annotation*/
SgPointerType*
TermToRose::createPointerType(Term* t) {
  EXPECT_TERM_NAME(CompTerm*, c, t, "pointer_type");
  /* first subterm is the base type*/
  SgType* base_type = TermToRose::createType(c->at(0));
  TERM_ASSERT(t, base_type != NULL);
  /* use SgPointerType's factory method*/
  SgPointerType* pt = SgPointerType::createType(base_type);
  TERM_ASSERT(t, pt != NULL);
  return pt;
}

/**create reference type from annotation*/
SgReferenceType*
TermToRose::createReferenceType(Term* t) {
  EXPECT_TERM_NAME(CompTerm*, c, t, "reference_type");
  /* first subterm is the base type*/
  SgType* base_type = TermToRose::createType(c->at(0));
  TERM_ASSERT(t, base_type != NULL);
  /* use SgPointerType's factory method*/
  SgReferenceType* pt = SgReferenceType::createType(base_type);
  TERM_ASSERT(t, pt != NULL);
  return pt;
}

/** create array type from annotation*/
SgArrayType*
TermToRose::createArrayType(Term* t) {
  EXPECT_TERM_NAME(CompTerm*, c, t, "array_type");
  /*first subterm is base type*/
  //cerr<<c->at(1)->getRepresentation()<<endl;
  SgType* base_type = createType(c->at(0));
  TERM_ASSERT(t, base_type != NULL);
  /* second subterm is an expression*/
  SgExpression* e = isSgExpression(toRose(c->at(1)));
  SgExprListExp* dim = isSgExprListExp(toRose(c->at(3)));
  SgArrayType* at;
  if (dim == NULL) {
    /* use factory method of SgArrayType*/
    at = SgArrayType::createType(base_type,e);
  } else {
    // not for Fortran, because we don't want the array type to be
    // entered into the ROSE type table before we actually know the
    // full type
    at = new SgArrayType(base_type,e);
  }
  TERM_ASSERT(t, at != NULL);

  Int* val = isInt(c->at(2));
  TERM_ASSERT(t, val != NULL);
  int rank = val->getValue();

  at->set_rank( rank );
  //cerr<<c->at(3)->repr()<<endl;
  //cerr<<toRose(c->at(3))->class_name()<<endl;
  at->set_dim_info( dim );

  return at;
}

/**
 * create SgModifierType
 */
SgModifierType*
TermToRose::createModifierType(Term* t) {
  CompTerm* c = isCompTerm(t);
  TERM_ASSERT(t, c != NULL);
  SgModifierType* mt = new SgModifierType(createType(c->at(0)));
  setTypeModifier(c->at(1),&(mt->get_typeModifier()));
  return mt;
}

/**
 * create SgTypedefType
 */
SgTypedefType*
TermToRose::createTypedefType(Term* t) {
  /* extract declaration*/
  CompTerm* annot = isCompTerm(t);
  TERM_ASSERT(t, annot != NULL);
  /*make sure this is supposed to be a typedef type*/
  string tname = annot->getName();
  TERM_ASSERT(t, tname == "typedef_type");

  /*extract name*/
  SgName n = *(toStringP(annot->at(0)));
  SgTypedefDeclaration* decl = NULL;
  SgTypedefType* tpe = NULL;
  string id = t->getRepresentation();
  if (lookupDecl(&decl, id, false)) {
    tpe = decl->get_type(); //new SgTypedefType(decl);
  } else if (lookaheadDecl(&decl,
                           "typedef_declaration(_,typedef_annotation("
                           +annot->at(0)->getRepresentation()+",_,_),"
#if ROSE_HAVE_MINITERMITE_ANALYSIS_RESULTS
                           "_,"
#endif
                           "_)")) {
    tpe = decl->get_type();
  } else {
    SgType* basetype = NULL;
    if (annot->at(1)->getName() != "typedef_type") {
      basetype = TermToRose::createType(annot->at(1));
    } else {
      basetype = TermToRose::createTypedefType(annot->at(1));
    }
    decl = createTypedefDeclaration
      (FI, termFactory.makeCompTerm("typedef_declaration", //4,
                              termFactory.makeAtom("null"),
                              termFactory.makeCompTerm("typedef_annotation", //3,
                                                 annot->at(0), annot->at(1),
                                                 termFactory.makeAtom("null"),
                                                 termFactory.makeAtom("null")),
#if ROSE_HAVE_MINITERMITE_ANALYSIS_RESULTS
                              termFactory.makeAtom("null"),
#endif
                              termFactory.makeAtom("null")));
    TERM_ASSERT(t, decl != NULL);
    tpe = SgTypedefType::createType(decl);
    declarationStatementsWithoutScope.push_back(decl);
  }
  TERM_ASSERT(t, tpe != NULL);
  if (tpe->get_declaration()->get_parent() == NULL) {
    tpe->get_declaration()->set_parent(dummy_to_please_rose);
  }
  return tpe;
}


/**
 * create SgType from term, possibly recursively
 */
SgType*
TermToRose::createType(Term* t) {
  SgType* type = NULL;
  string id = t->getRepresentation();

  //cerr<<id<<endl;
  CompTerm* ct = dynamic_cast<CompTerm*>(t);
  if (ct
      && t->getName() == "array_type"
      && ct->getArity() > 2
      && ct->at(2)->getRepresentation() == "null") {
    // The difference between ArrayType and PointerType is mostly syntactical
    // we therefore treat them as equivalent in the lookup table.
    id = string("pointer_type(")+ct->at(1)->getRepresentation()+")";
    //cerr<<"-->"<<id<<endl;
  }

  if (lookupType(&type, id, false)) {
    return type;
  }

  if (CompTerm* c = isCompTerm(t)) {
    string tname = t->getName();
    if (tname == "enum_type")                 type = createEnumType(t);
    else if (tname == "pointer_type")         type = createPointerType(t);
    else if (tname == "reference_type")       type = createReferenceType(t);
    else if (tname == "class_type")           type = createClassType(t);
    else if (tname == "function_type")        type = createFunctionType(t);
    else if (tname == "member_function_type") type = createMemberFunctionType(t);
    else if (tname == "array_type")           type = createArrayType(t);
    else if (tname == "modifier_type")        type = createModifierType(t);
    else if (tname == "typedef_type")         type = createTypedefType(t);
    else if (tname == "type_complex")         type = new SgTypeComplex(createType(c->at(0)));
    else if (tname == "type_fortran_string") {
      SgExpression* length = dynamic_cast<SgExpression*>(toRose(c->at(0)));
      ROSE_ASSERT(length != NULL);
      type = new SgTypeString(length);
    } else if (tname == "fortrtan_type_with_kind") {
      type = createType(c->at(0));
      SgExpression* kind = dynamic_cast<SgExpression*>(toRose(c->at(1)));
      ROSE_ASSERT(kind != NULL);
      type->set_type_kind(kind);
    } else TERM_ASSERT(t, false && "Unknown type enountered");
  }
  if (Atom* a = isAtom(t)) {
    string tname = a->getName();
    if (tname == "null") {
      warn_msg("warning: no type created");
      type = NULL;
    } else
    if (tname=="type_bool") type = new SgTypeBool();
    else if (tname=="type_char") type = new SgTypeChar();
    else if (tname=="type_default") type = new SgTypeDefault();
    else if (tname=="type_double") type = new SgTypeDouble();
    else if (tname=="type_float") type = new SgTypeFloat();
    else if (tname=="type_global_void") type = new SgTypeGlobalVoid();
    else if (tname=="type_ellipse") {type = new SgTypeEllipse();}
    else if (tname=="type_int") {type = new SgTypeInt();}
    else if (tname=="type_long") type = new SgTypeLong();
    else if (tname=="type_long_double") type = new SgTypeLongDouble();
    else if (tname=="type_long_long") type = new SgTypeLongLong();
    else if (tname=="type_short") type = new SgTypeShort();
    else if (tname=="type_signed_char") type = new SgTypeSignedChar();
    else if (tname=="type_signed_int") type = new SgTypeSignedInt();
    else if (tname=="type_signed_long") type = new SgTypeSignedLong();
    else if (tname=="type_signed_short") type = new SgTypeSignedShort();
    else if (tname=="type_string") type = new SgTypeString();
    else if (tname=="type_unknown") type = new SgTypeUnknown();
    else if (tname=="type_unsigned_char") type = new SgTypeUnsignedChar();
    else if (tname=="type_unsigned_int") type = new SgTypeUnsignedInt();
    else if (tname=="type_unsigned_long") type = new SgTypeUnsignedLong();
    else if (tname=="type_unsigned_long_long") type = new SgTypeUnsignedLongLong();
    else if (tname=="type_unsigned_short") type = new SgTypeUnsignedShort();
    else if (tname=="type_void") type = new SgTypeVoid();
    else if (tname=="type_wchar") type = new SgTypeWchar();
    else TERM_ASSERT(t, false && "Unknown type enountered");
  }
  typeMap[id] = type;
  return type;

}

/**
 * is this string the name of a SgValueExp?*/
bool
TermToRose::isValueExp(std::string tname) {
  if (tname == "bool_val_exp")               return true;
  if (tname == "char_val")                   return true;
  if (tname == "double_val")                 return true;
  if (tname == "enum_val")                   return true;
  if (tname == "float_val")                  return true;
  if (tname == "int_val")                    return true;
  if (tname == "long_double_val")            return true;
  if (tname == "long_int_val")               return true;
  if (tname == "long_long_int_val")          return true;
  if (tname == "short_val")                  return true;
  if (tname == "string_val")                 return true;
  if (tname == "unsigned_char_val")          return true;
  if (tname == "unsigned_int_val")           return true;
  if (tname == "unsigned_long_long_int_val") return true;
  if (tname == "unsigned_long_val")          return true;
  if (tname == "unsigned_short_val")         return true;
  if (tname == "wchar_val")                  return true;
  return false;
}


/**
 *
 * UnEscape non-printable characters
 */
char
TermToRose::unescape_char(std::string s) {
  std::string r;

  switch(s.length()) {
  case 1: return s[0];
  case 2: {
    ROSE_ASSERT(s[0] == '\\');
    switch(s[1]) {
    case '\\': return '\\';
    case '\"': return '\"';
    case '\'': return '\'';
    case 'n': return '\n';
    case 'r': return '\r';
    case 'b': return '\b';
    case 't': return '\t';
    case 'f': return '\f';
    case 'a': return '\a';
    case 'v': return '\v';
    default: ROSE_ASSERT(false);
    }
  }

  case 4: { // Char Val
    ROSE_ASSERT(s[0] == '\\');
    cerr << "**WARNING: Found C-style escaped char \"" << s
         << "\" when expecting \"" << s << "\\\"" << endl;
    int c;
    istringstream instr(s.substr(1, 3));
    instr.setf(ios::oct, ios::basefield);
    instr >> c;
    return c;
  }
  case 5: { // -style Char Val
    ROSE_ASSERT((s[0] == '\\') && (s[4] == '\\'));
    int c;
    istringstream instr(s.substr(1, 3));
    instr.setf(ios::oct, ios::basefield);
    instr >> c;
    return c;
  }
  case 6: { // Unicode
    ROSE_ASSERT((s[0] == '\\') && (s[1] == 'u'));
    unsigned int c;
    istringstream instr(s.substr(2, 5));
    instr.setf(ios::hex, ios::basefield);
    instr >> c;
    if (c > 255) cerr << "** WARNING: truncated 16bit unicode character" << s << endl;
    return c;
  }
  default: ROSE_ASSERT(false);
  }
}


#define createValue(SGTYPE, TYPE, fi, fromTerm)     \
  do {                                              \
    debug("unparsing " + fromTerm->getName());      \
    CompTerm* annot = retrieveAnnotation(fromTerm); \
    TERM_ASSERT(fromTerm, annot != NULL);           \
    TYPE value;                                     \
    if (Atom* a = isAtom(annot->at(0))) {           \
      istringstream instr(a->getName());            \
      instr >> value;                               \
    } else if (Int* i = isInt(annot->at(0)))        \
      value = i->getValue();                        \
    else if (Float* f = isFloat(annot->at(0)))      \
      value = f->getValue();                        \
    else TERM_ASSERT(fromTerm, false);              \
    ve = new SGTYPE(fi, value);                     \
  } while (false)

// float values also have a value string attached to it
#define createFloatValue(SGTYPE, TYPE, fi, fromTerm)            \
  do {                                                          \
    debug("unparsing " + fromTerm->getName());                  \
    EXPECT_ATOM(valueStr, retrieveAnnotation(fromTerm)->at(0));	\
    istringstream instr(valueStr);                              \
    TYPE value;                                                 \
    instr >> value;                                             \
    ve = new SGTYPE(fi, value, valueStr);                       \
  } while (false)


/** create a SgValueExp*/
SgExpression*
TermToRose::createValueExp(Sg_File_Info* fi, SgNode* succ, CompTerm* t) {
  string vtype = t->getName();
  SgValueExp* ve = NULL;
  /*integer types */
  if(vtype == "int_val")
    createValue(SgIntVal, int, fi, t);
  else if (vtype == "unsigned_int_val")
    createValue(SgUnsignedIntVal, unsigned int, fi, t);
  else if (vtype == "short_val")
    createValue(SgShortVal, short, fi,t);
  else if (vtype == "unsigned_short_val")
    createValue(SgUnsignedShortVal, unsigned short, fi, t);
  else if (vtype == "long_int_val")
    createValue(SgLongIntVal, long int, fi, t);
  else if (vtype == "unsigned_long_val")
    createValue(SgUnsignedLongVal, unsigned long int, fi, t);
  else if (vtype == "long_long_int_val")
    createValue(SgLongLongIntVal, long long int, fi, t);
  else if (vtype == "unsigned_long_long_int_val")
    createValue(SgUnsignedLongLongIntVal, unsigned long long int, fi, t);

  else if (vtype == "enum_val") {
    debug("unparsing enum value");
    CompTerm* annot = retrieveAnnotation(t);
    TERM_ASSERT(t, annot != NULL);
    /* get value and name, find the declaration*/
    ARITY_ASSERT(annot, 4);
    int value = toInt(annot->at(0));
    SgName v_name = *toStringP(annot->at(1));

    // Rather than faking a declaration like before, we look it up in the
    // declaration map.
    SgEnumDeclaration* decdummy = NULL;
    Term* dect = isCompTerm(annot->at(2))->at(0);
    TERM_ASSERT(t, declarationMap.find(dect->getRepresentation())
                != declarationMap.end());
    decdummy = isSgEnumDeclaration(declarationMap[dect->getRepresentation()]);
    TERM_ASSERT(t, decdummy != NULL);

    SgEnumVal* valnode = new SgEnumVal(fi,value,decdummy,v_name);
    TERM_ASSERT(t, valnode != NULL);
    TERM_ASSERT(t, valnode->get_declaration() == decdummy);
    ve = valnode;
  }

  /* floating point types*/
  else if (vtype == "float_val")
    createFloatValue(SgFloatVal, float, fi, t);
  else if (vtype == "double_val")
    createFloatValue(SgDoubleVal, double, fi, t);
  else if (vtype == "long_double_val")
    createFloatValue(SgLongDoubleVal, long double, fi, t);

  /* characters */
  else if (vtype == "char_val") {
    //char
    debug("unparsing char");
    CompTerm* annot = retrieveAnnotation(t);
    TERM_ASSERT(t, annot != NULL);
    char number;
    if (Atom* s = isAtom(annot->at(0))) {
      number = unescape_char(s->getName());
    } else if (Int* val = isInt(annot->at(0))) {
      number = val->getValue();
    } else {
      TERM_ASSERT(t, false && "Must be either a string or an int");
    }
    SgCharVal* valnode = new SgCharVal(fi,number);
    ve = valnode;
  } else if (vtype == "unsigned_char_val") {
    //unsigned char
    debug("unparsing unsigned char");
    CompTerm* annot = retrieveAnnotation(t);
    TERM_ASSERT(t, annot != NULL);
    unsigned char number;
    if (Atom* s = isAtom(annot->at(0))) {
      number = unescape_char(s->getName());
    } else if (Int* val = isInt(annot->at(0))) {
      number = val->getValue();
    } else {
      TERM_ASSERT(t, false && "Must be either a string or an int");
    }
    SgUnsignedCharVal* valnode = new SgUnsignedCharVal(fi,number);
    ve = valnode;
  }
  else if (vtype == "wchar_val")
    createValue(SgWcharVal, unsigned long, fi, t);
    /* boolean*/
  else if (vtype == "bool_val_exp")
    createValue(SgBoolValExp, int, fi, t);
  else if (vtype == "string_val") {
    CompTerm* annot = retrieveAnnotation(t);
    TERM_ASSERT(t, annot != NULL);
    EXPECT_TERM(Atom*, s, annot->at(0));
    SgStringVal* sv = new SgStringVal(fi,s->getName());
    sv->set_usesSingleQuotes(createFlag(annot->at(1)));
    sv->set_usesDoubleQuotes(createFlag(annot->at(2)));
    ve = sv;
  }

  if(ve != NULL) {
    /* post construction */

    /* when the value of a SgValueExp can be computed at compile time
     * ROSE computes it and creates a value expression with a child,
     * the original expression tree. In this case we recreate it here
     */
    if(succ != NULL) {
      debug("value expression with child");
      EXPECT_NODE(SgExpression*, ex, succ);
      ve->set_originalExpressionTree(ex);
    }
    ve->set_endOfConstruct(fi);
  } else {
    debug("Value Type " + vtype + " not implemented yet. Returning null pointer for value expression");
  }
  return ve;
}

/**
 * is the string the name of a unary operator?
 */
bool
TermToRose::isUnaryOp(std::string opname) {
  if (opname == "address_of_op" ||
      opname == "bit_complement_op" ||
      opname == "expression_root" ||
      opname == "minus_op" ||
      opname == "not_op" ||
      opname == "pointer_deref_exp" ||
      opname == "unary_add_op" ||
      opname == "minus_minus_op" ||
      opname == "plus_plus_op" ||
      opname == "cast_exp" ||
      opname == "throw_op")
    return true;
  return false;
}




/**
 * create a SgUnaryOp*/
SgUnaryOp*
TermToRose::createUnaryOp(Sg_File_Info* fi, SgNode* succ, CompTerm* t) {
  EXPECT_NODE(SgExpression*,sgexp,succ);
  Term* n = t->at(0);
  string opname = t->getName();
  debug("creating " + opname + "\n");
  //cerr << t->getRepresentation() << endl << succ << endl;
  CompTerm* annot = retrieveAnnotation(t);
  TERM_ASSERT(t, annot != NULL);
  ARITY_ASSERT(annot, 5);
  // GB (2008-12-04): A unary op's mode is now represented by an atom
  // 'prefix' or 'postfix', not by a numerical constant.
  // Int* mode = isInt(annot->at(0));
  EXPECT_TERM(Atom*, mode, annot->at(0));
  SgType* sgtype = createType(annot->at(1));
  ROSE_ASSERT(sgtype != NULL);
  /*nothing special with these*/
  if (opname == "address_of_op")          return new SgAddressOfOp(fi,sgexp,sgtype);
  else if (opname == "bit_complement_op") return new SgBitComplementOp(fi,sgexp,sgtype);
  else if (opname == "minus_op")          return new SgMinusOp(fi,sgexp,sgtype);
  else if (opname == "not_op")            return new SgNotOp(fi,sgexp,sgtype);
  else if (opname == "pointer_deref_exp") return new SgPointerDerefExp(fi,sgexp,sgtype);
  else if (opname == "unary_add_op")      return new SgUnaryAddOp(fi,sgexp,sgtype);
  else if (opname == "expression_root") {
    SgExpressionRoot* er = new SgExpressionRoot(fi,sgexp,sgtype);
    debug("Exp Root: " + er->unparseToString());
    return er;
  }
  /* chose wether to use ++ and -- as prefix or postfix via set_mode*/
  else if (opname == "minus_minus_op") {
    SgMinusMinusOp* m = new SgMinusMinusOp(fi,sgexp,sgtype);
    m->set_mode(mode->getName() == "prefix" ? SgUnaryOp::prefix
                                            : SgUnaryOp::postfix);
    return m;
  }
  else if (opname == "plus_plus_op") {
    SgPlusPlusOp* p = new SgPlusPlusOp(fi,sgexp,sgtype);
    p->set_mode(mode->getName() == "prefix" ? SgUnaryOp::prefix
                                            : SgUnaryOp::postfix);
    return p;
  }
  /* For a cast we need to retrieve cast type (enum)*/
  else if (opname == "cast_exp") {
    //cerr<<"######castexp "<< annot->getRepresentation()<< "bug in ROSE?" <<endl;
    SgCastExp* e = new SgCastExp(fi, sgexp, sgtype,
                                 re.enum_cast_type_enum[*annot->at(2)]);
    //cerr<< e->unparseToString()<< endl;
    return e;
  }
  /* some more initialization necessary for a throw */
  else if (opname == "throw_op") {
    /*need to retrieve throw kind* (enum)*/
    int tkind = re.enum_e_throw_kind[*annot->at(2)];
    // FIXME: use kind!
    /*need to retrieve types */
    EXPECT_TERM(List*, typel, annot->at(3));
    deque<Term*>* succs = typel->getSuccs();
    deque<Term*>::iterator it = succs->begin();
    SgTypePtrListPtr tpl = new SgTypePtrList();
    while (it != succs->end()) {
      tpl->push_back(createType(*it));
      it++;
    }
    return new SgThrowOp(fi,sgexp,sgtype);
  }

  TERM_ASSERT(t, false);
  /*never called*/
  return (SgUnaryOp*) 0;
}




/**
 * create SgProject
 */
SgProject*
TermToRose::createProject(Sg_File_Info* fi, std::deque<SgNode*>* succs) {
  SgProject* project = new SgProject();
  SgFilePtrList &fl = project->get_fileList();

  for (deque<SgNode*>::iterator it = succs->begin();
       it != succs->end(); ++it) {
    SgSourceFile* file = isSgSourceFile(*it);
    if (file != NULL) { // otherwise, it's a binary file, which shouldn't happen
      fl.push_back(file);
      file->set_parent(project);
    }
  }

  /// Make sure all endOfConstruct pointers are set; ROSE includes
  // essentially the same thing, but that prints verbose diagnostics. Also,
  // the AST janitor does this, but apparently it doesn't always visit every
  // node (SgVariableDefinitions, mostly).
  // This traversal also fixes up missing scopes that the AST janitor
  // doesn't catch. This might mean that we create initialized names that
  // are not connected to the AST!
  class MemoryPoolFixer: public ROSE_VisitTraversal {
  protected:
    void visit(SgNode *n) {
      if (SgLocatedNode *ln = isSgLocatedNode(n)) {
        if (ln->get_startOfConstruct() != NULL
            && ln->get_endOfConstruct() == NULL) {
          ln->set_endOfConstruct(ln->get_startOfConstruct());
        }
      }
      if (SgInitializedName *in = isSgInitializedName(n)) {
        SgNode *parent = in->get_parent();
        if (in->get_scope() == NULL || parent == NULL) {
          if (SgVariableDeclaration *v = isSgVariableDeclaration(parent))
            in->set_scope(v->get_scope());
          else if (SgEnumDeclaration *e = isSgEnumDeclaration(parent)) {
            in->set_scope(e->get_scope());
            if (in->get_scope() == NULL) {
              SgScopeStatement *scp = isSgScopeStatement(parent);
              ROSE_ASSERT(false && "enum decl has no parent and no scope?");
              in->set_scope(scp);
            }
          } else {
            // try to make an educated guess by attaching it to the closest parent scope
            SgScopeStatement* scope;
            do {
              scope = isSgScopeStatement(parent);
              parent = parent->get_parent();
              ROSE_ASSERT(parent != NULL && "initialized name without a scope, I'm lost");
            } while (scope == NULL);
            in->set_scope(scope);
          }
        }
      }
      if (SgClassDeclaration *cdecl = isSgClassDeclaration(n)) {
        if (cdecl->get_scope() == NULL) {
          SgTypedefDeclaration *tddecl =
            isSgTypedefDeclaration(cdecl->get_parent());
          if (tddecl != NULL) {
            cdecl->set_scope(tddecl->get_scope());
          }
        }
      }
      if (SgEnumDeclaration *edecl = isSgEnumDeclaration(n)) {
        if (edecl->get_scope() == NULL) {
          SgTypedefDeclaration *tddecl =
            isSgTypedefDeclaration(edecl->get_parent());
          if (tddecl != NULL) {
            edecl->set_scope(tddecl->get_scope());
          }
        }
      }
      if (SgFunctionDeclaration *fdecl = isSgFunctionDeclaration(n)) {
        if (fdecl->get_scope() == NULL) {
          ROSE_ASSERT(fdecl->get_parent() != NULL);
          if (isSgTypedefDeclaration(fdecl->get_parent())) {
            fdecl->set_scope(
                isSgTypedefDeclaration(fdecl->get_parent())->get_scope());
          }
          ROSE_ASSERT(fdecl->get_scope() != NULL);
        }
      }
      if (SgDeclarationStatement *d = isSgDeclarationStatement(n)) {
        SgDeclarationStatement *nondef = d->get_firstNondefiningDeclaration();
        SgDeclarationStatement *def = d->get_definingDeclaration();
        /* ROSE wants defining and nondefining declarations to be different
         * for many kinds of declarations */
        if (nondef == def && def != NULL) {
          d->set_firstNondefiningDeclaration(NULL);
        } else if (nondef == def && def == NULL) {
          d->set_firstNondefiningDeclaration(d);
        }
        ROSE_ASSERT(d->get_firstNondefiningDeclaration()
                 != d->get_definingDeclaration());
      }
    }
  };
  MemoryPoolFixer memoryPoolFixer;
  memoryPoolFixer.traverseMemoryPool();

  AstPostProcessing(project);

  return project;
}

/**
 * Unparse to a file
 */

void TermToRose::unparseFile(SgSourceFile& f, std::string prefix, std::string suffix,
                               SgUnparse_Info* ui)
{
  string fn = f.get_file_info()->get_filenameString();

  int prefix_end = fn.rfind('/');
  if (prefix_end == fn.length()) prefix_end = 0;
  else prefix_end++;
  int suffix_start = fn.rfind('.');

  stringstream name;
  name << prefix << '/' << fn.substr(prefix_end, suffix_start-prefix_end)
       << suffix << fn.substr(suffix_start);
  ofstream ofile(name.str().c_str());
  cerr << "Unparsing " << name.str() << endl;
  f.set_unparse_output_filename(name.str());
  ofile << globalUnparseToString(f.get_globalScope(), ui);
}

void TermToRose::unparse(std::string filename, std::string dir, std::string suffix,
			 SgNode* node)
{
  SgUnparse_Info* unparseInfo = new SgUnparse_Info();
  unparseInfo->unset_SkipComments();    // generate comments
  unparseInfo->unset_SkipWhitespaces(); // generate all whitespaces to
                                        // format the code
  //resetParentPointers(glob, file);

  if (SgProject* project = isSgProject(node)) {
    for (int i = 0; i < project->numberOfFiles(); ++i) {
      SgSourceFile *file = isSgSourceFile((*project)[i]);
      if (file != NULL) {
	// Override the first file's name with what the user supplied
	if (filename != "") {
	  ofstream ofile(filename.c_str());
	  //file->set_unparse_output_filename(filename);
	  ofile << globalUnparseToString(file->get_globalScope(), unparseInfo);
	  //file->unparse();
	  filename = "";		
	} else {
	  unparseFile(*file, dir, suffix, unparseInfo);
	}
      }
    }
  } 
  else if (SgSourceFile* file = isSgSourceFile(node))
    unparseFile(*file, dir, suffix, unparseInfo);
  else cout << node->unparseToString();
}


/**
 * create SgSourceFile
 */
SgSourceFile*
TermToRose::createFile(Sg_File_Info* fi,SgNode* child1,CompTerm*) {
  // GB (2008-10-20): It looks like there is a new SgSourceFile class in
  // ROSE 0.9.3a-2261, and that it is an instance of that class that we
  // need.
  SgSourceFile* file = new SgSourceFile();
  file->set_file_info(fi);
  // ROSE 0.9.4a fixup
  fi->set_parent(file);

  // are we unparsing some sort of Fortran sources?
  bool isFortran = false;
  string name = fi->get_filename();

  if (ends_with(name, ".f") || ends_with(name, ".F") ||
      ends_with(name, ".f77") || ends_with(name, ".F77")) {
    isFortran = true;
    // TODO: this should probably be stored as an attribute
    file->set_outputFormat(SgFile::e_fixed_form_output_format);
    file->set_sourceFileUsesFortran77FileExtension(true);
    file->set_F77_only(true);      
  } else if (ends_with(name, ".f90") || ends_with(name, ".F90")) {
    isFortran = true;
    file->set_outputFormat(SgFile::e_free_form_output_format);
    file->set_sourceFileUsesFortran90FileExtension(true);
    file->set_F90_only(true);
  } else if (ends_with(name, ".f95") || ends_with(name, ".F95")) {
    isFortran = true;
    file->set_outputFormat(SgFile::e_free_form_output_format);
    file->set_sourceFileUsesFortran95FileExtension(true);
    file->set_F95_only(true);
  } else if (ends_with(name, ".f03") || ends_with(name, ".F03")) {
    isFortran = true;
    file->set_sourceFileUsesFortran2003FileExtension(true);
    file->set_F2003_only(true);
  } else if (ends_with(name, ".c") || ends_with(name, ".h")) {
    file->set_C_only(true);    
  } else if (ends_with(name, ".cxx") || ends_with(name, ".C") ||
	     ends_with(name, ".cpp") || ends_with(name, ".c++")) {
    file->set_Cxx_only(true);    
  } else {
    // ???
    assert(false);
  }
  if (isFortran) {
    file->set_Fortran_only(true);
    file->set_outputLanguage(SgFile::e_Fortran_output_language);
  }

  SgGlobal* glob = isSgGlobal(child1);
  ROSE_ASSERT(glob);
  if (isFortran) {
    // This is pure voodoo, but it un-breaks the test with the CONTAINS statement
    glob->set_file_info(FI);
  }

  //ROSE_ASSERT(declarationStatementsWithoutScope.empty());
  ROSE_ASSERT(labelStatementsWithoutScope.empty());

  file->set_globalScope(glob);
  glob->set_parent(file);

  // Do our own fixups
  AstJanitor janitor(isFortran);
  janitor.traverse(file, InheritedAttribute(this));

  // rebuild the symbol table
  if (not isFortran) {
    glob->set_symbol_table(NULL);
    SageInterface::rebuildSymbolTable(glob);
  } else {
    //glob->set_symbol_table(new SgSymbolTable());
  }

  // Memory Pool Fixups
  for (vector<SgDeclarationStatement*>::iterator it =
               declarationStatementsWithoutScope.begin();
         it != declarationStatementsWithoutScope.end(); it++) {
    // cerr<<__FUNCTION__<<": ("<<(*it)->class_name()<<")->set_scope("<<glob->class_name()<<");"<<endl;

    // GB: these nodes are not reachable in the AST, so traverse them
    // explicitly
    // (*it)->set_parent(glob);
    AstJanitor janitor(isFortran);
    janitor.traverse(*it, InheritedAttribute(this, glob, glob));
    if ((*it)->get_scope() == NULL &&
        (*it)->variantT()  != V_SgVariableDeclaration && 
        (*it)->variantT()  != V_SgNamespaceDeclarationStatement) {
      (*it)->set_scope(glob);
    }

    // GB: we may need to add stuff to the symbol table since some of the
    // declarations may be hidden inside typedef/variable declarations, and
    // rebuildSymbolTable will not find them there
    if (SgClassDeclaration *cdecl = isSgClassDeclaration(*it)) {
      SgSymbol *symbol = new SgClassSymbol(cdecl);
      SgName name = cdecl->get_name();
      glob->get_symbol_table()->insert(name, symbol);
    }
    if (SgEnumDeclaration *edecl = isSgEnumDeclaration(*it)) {
      SgSymbol *symbol = new SgEnumSymbol(edecl);
      SgName name = edecl->get_name();
      glob->get_symbol_table()->insert(name, symbol);
    }
   }
  declarationStatementsWithoutScope.clear();

  // Call all kinds of ROSE fixups
  // GB: Moved to createProject because this accesses global information via
  // the memory pools, so *all* files must have been janitorized before we
  // run this.
  // AstPostProcessing(file);

  // Reset local symbol tables
  classDefinitionMap.clear();
  memberFunctionDeclarationMap.clear();
  typeMap.clear();
  declarationMap.clear();
  globalDecls = NULL;
  return file;
}

/**
 * create SgSizeOfOp
 */
SgSizeOfOp*
TermToRose::createSizeOfOp(Sg_File_Info* fi,SgNode* child1,CompTerm* t) {
  /* retrieve anntoation*/
  CompTerm* annot = retrieveAnnotation(t);
  TERM_ASSERT(t, annot != NULL);
  /* get operand type*/
  SgType* otype = NULL;
  if (annot->at(0)->getRepresentation() != "null")
    otype = createType(annot->at(0));
  /* get expression type*/
  SgType* etype = createType(annot->at(1));
  /* cast child to SgExpression* */
  SgExpression* ex = isSgExpression(child1);
  /* create Op */
  SgSizeOfOp* op = new SgSizeOfOp(fi,ex,otype,etype);
  TERM_ASSERT(t, op != NULL);
  return op;
}

/** create a SgReturnStmt*/
SgReturnStmt*
TermToRose::createReturnStmt(Sg_File_Info* fi, SgNode* succ, CompTerm* t) {
  /* get expression*/
  SgExpression* exp = isSgExpression(succ);
  SgReturnStmt* s  = new SgReturnStmt(fi,exp);
  if (exp != NULL) {
    //debug(exp->get_type()->class_name());
    exp->set_parent(s);
  }
  return s;
}

/**
 * create a SgBasicBlock
 */
SgBasicBlock*
TermToRose::createBasicBlock(Sg_File_Info* fi, std::deque<SgNode*>* succs) {
  SgBasicBlock* b = NULL;
  deque<SgNode*>::iterator it = succs->begin();
  /*first statement comes in the constructor*/
  if(it != succs->end()) {
    b = new SgBasicBlock(fi,isSgStatement(*it));
    it++;
    debug("adding nonempty statement");
  } else {
    return new SgBasicBlock(fi,NULL);
  }
  /*append statements*/
  while(it != succs->end()) {
    if ((*it) != (SgStatement*) 0) {
      EXPECT_NODE(SgStatement*, stmt, *it);
      b->append_statement(stmt);
      (*it)->set_parent(b);
      debug("adding nonempty statement");
    } else debug("empty statement not added");
    it++;
  }
  /* manual recreation of symbol tables; the automatic stuff doesn't seem to
   * work here */
  for (it = succs->begin(); it != succs->end(); ++it) {
    storeVariableSymbolFromDeclaration(b, isSgDeclarationStatement(*it));
  }
  return b;
}

/**
 * create a SgFunctionDefinition
 */
SgFunctionDefinition*
TermToRose::createFunctionDefinition(Sg_File_Info* fi,SgNode* succ,CompTerm* t) {
  /* create a basic block*/
  EXPECT_NODE(SgBasicBlock*, b, succ);
  SgFunctionDefinition* fd = new SgFunctionDefinition(fi,b);

  // Various Label fixups
  for (vector<SgLabelStatement*>::iterator label =
               labelStatementsWithoutScope.begin();
         label != labelStatementsWithoutScope.end(); label++) {
      (*label)->set_scope(fd);

      string l = (*label)->get_label().getString();
      multimap<string, SgGotoStatement*>::iterator low, high, goto_;
      low = gotoStatementsWithoutLabel.lower_bound(l);
      high = gotoStatementsWithoutLabel.upper_bound(l);
      for(goto_ = low; goto_ != high; ++goto_) {
        goto_->second->set_label(*label);
      }

      //cerr<<endl<<(*label)->unparseToString()<<endl<<b->unparseToString()<<endl;
  }
  labelStatementsWithoutScope.clear();

  return fd;
}


/**
 * create SgInitializedName
 */
SgInitializedName*
TermToRose::createInitializedName(Sg_File_Info* fi, SgNode* succ, CompTerm* t) {
  /* retrieve annotation*/
  CompTerm* annot = retrieveAnnotation(t);
  /*create the type*/
  SgType* tpe = createType(annot->at(0));
  TERM_ASSERT(t, tpe != NULL);
  /* create the name*/
  SgName sgnm = *toStringP(annot->at(1));
  /* create the initializer and the initialized name*/
  SgInitializer* sgini = isSgInitializer(succ);
  SgInitializedName* siname = new SgInitializedName(sgnm,tpe,sgini,NULL);
  TERM_ASSERT(t, siname != NULL);
  TERM_ASSERT(t, siname->get_parent() == NULL);

  siname->set_file_info(fi);

  //cerr<<"registering iname: "<<makeInameID(annot)<<endl;
  initializedNameMap[makeInameID(annot)] = siname;

  return siname;
}

/**
 * create SgInitializedName from CompTerm
 */
SgInitializedName*
TermToRose::inameFromAnnot(CompTerm* annot) {
  //TERM_ASSERT(annot, false && "deprecated function");
  debug("creating initialized name for sg var ref exp");
  /* get type*/
  SgType* tpe = createType(annot->at(0));
  /* create name*/
  Atom *nstring = isAtom(annot->at(1));
  SgName sgnm = nstring->getName().c_str();
  SgInitializedName* siname = new SgInitializedName(sgnm,tpe,NULL);
  TERM_ASSERT(annot, siname != NULL);

  siname->set_file_info(FI);

  /* static?*/
  bool stat = createFlag(annot->at(2));
  if(stat) {
    debug("setting static");
    siname->get_storageModifier().setStatic();
  }
  return siname;
}


/**
 * create SgFunctionType
 */
SgFunctionType*
TermToRose::createFunctionType(Term* t) {
  EXPECT_TERM_NAME(CompTerm*, tterm, t, "function_type");
  /* create the return type*/
  SgType* ret_type = createType(tterm->at(0));
  /* has ellipses?*/
  bool has_ellipses = createFlag(tterm->at(1));
  /* create type */
  SgFunctionType* func_type = new SgFunctionType(ret_type,has_ellipses);
  TERM_ASSERT(t, func_type != NULL);
  /* add argument list*/
  List* atypes = isList(tterm->at(2));
  TERM_ASSERT(t, atypes != NULL);
  for(int i = 0; i < atypes->getArity(); i++) {
    func_type->append_argument(createType(atypes->at(i)));
  }
  return func_type;
}

/**
 * create SgMemberFunctionType
 */
SgMemberFunctionType*
TermToRose::createMemberFunctionType(Term* t) {
  EXPECT_TERM_NAME(CompTerm*, tterm, t, "member_function_type");
  /* create the reutnr type*/
  SgType* ret_type = createType(tterm->at(0));
  /* has ellipses?*/
  bool has_ellipses = createFlag(tterm->at(1));
  /* mfunc_specifier*/
  int mfuncs = re.enum_declaration_modifier_enum[*tterm->at(3)];
  /*create type
   * note thate no SgMemberFunctionDefinition is given
   * this is because the unparser does not use it!
   */
  SgMemberFunctionType* func_type = new SgMemberFunctionType(ret_type,has_ellipses,NULL,mfuncs);
  TERM_ASSERT(t, func_type != NULL);
  /* add argument list*/
  List* atypes = isList(tterm->at(2));
  TERM_ASSERT(t, atypes != NULL);
  for(int i = 0; i < atypes->getArity(); i++) {
    func_type->append_argument(createType(atypes->at(i)));
  }
  return func_type;
}


/**
 * create a SgFunctionParameterList
 */
SgFunctionParameterList*
TermToRose::createFunctionParameterList(Sg_File_Info* fi, std::deque<SgNode*>* succs) {
  debug("function parameter list");
  /* create list*/
  SgFunctionParameterList* l = new SgFunctionParameterList(fi);
  /*append successors*/
  deque<SgNode*>::iterator it = succs->begin();
  while(it != succs->end()) {
    if((*it) != NULL) {
      l->append_arg(isSgInitializedName(*it));
      (*it)->set_parent(l);
    }
    it++;
  }
  return l;
}

void TermToRose::register_func_decl(SgName func_name, SgFunctionDeclaration* func_decl, 
                                    Term* type_term)
{
  /* register the function declaration with our own symbol table */
  string id = makeFunctionID(func_name, type_term->getRepresentation());
  //cerr << id << endl;
  if (declarationMap.find(id) == declarationMap.end()) {
    declarationMap[id] = func_decl;
  }
  /* make sure every function declaration has a first declaration */
  if (func_decl->get_firstNondefiningDeclaration() == NULL) {
    func_decl->set_firstNondefiningDeclaration(declarationMap[id]);
  }
}

/**
 * create SgFunctionDeclaration
 */
SgFunctionDeclaration*
TermToRose::createFunctionDeclaration(Sg_File_Info* fi, SgNode* par_list_u, CompTerm* t) {
  debug("function declaration:");
  /* cast parameter list */
  SgFunctionParameterList* par_list = isSgFunctionParameterList(par_list_u);
  /* param list must exist*/
  TERM_ASSERT(t, par_list != NULL);
  /* get annotation*/
  CompTerm* annot = retrieveAnnotation(t);
  /* create type*/
  SgFunctionType* func_type = isSgFunctionType(createType(annot->at(0)));
  TERM_ASSERT(t, func_type != NULL);
  /* get function name*/
  EXPECT_TERM(Atom*, func_name_term, annot->at(1));
  SgName func_name = func_name_term->getName();
  //cerr<<"func decl: "<<func_name<<endl;
  /* create declaration*/
  SgFunctionDeclaration* func_decl =
    new SgFunctionDeclaration(fi,func_name,func_type,/*func_def=*/NULL);
  TERM_ASSERT(t, func_decl != NULL);

  // set namespace/scope if any
  CompTerm* scopeTerm = isCompTerm(annot->at(8));
  if (scopeTerm) {
    EXPECT_ATOM(scope_name, scopeTerm->at(0));
    SgNamespaceDeclarationStatement* ns = NULL;
    //cerr<< "@@@@@@ looking up decl " << scope_name << endl;
    lookupDecl(&ns, "namespace,"+scope_name, false);
    cerr<< "ns = " << ns << endl;
    if (ns != NULL) {
      //cerr<< "ns->get_definition() = " << ns->get_definition() << endl;
      SgScopeStatement* scope = ns->get_definition();
      func_decl->set_scope(scope);
    }
  }

  func_decl->set_parameterList(par_list);
  setDeclarationModifier(annot->at(2),&(func_decl->get_declarationModifier()));
  setSpecialFunctionModifier(annot->at(3), &func_decl->get_specialFunctionModifier());

  EXPECT_TERM(Int*, length, annot->at(4));
  func_decl->set_name_qualification_length(length->getValue());
  func_decl->set_type_elaboration_required(createFlag(annot->at(5)));
  func_decl->set_global_qualification_required(createFlag(annot->at(6)));
  func_decl->set_requiresNameQualificationOnReturnType(createFlag(annot->at(7)));

  register_func_decl(func_name, func_decl, annot->at(0));
  return func_decl;
}

SgFunctionDeclaration*
TermToRose::createTemplateInstantiationFunctionDecl(Sg_File_Info* fi, SgNode* par_list_u, CompTerm* t) {
  debug("template function declaration:");
  /* cast parameter list */
  SgFunctionParameterList* par_list = isSgFunctionParameterList(par_list_u);
  /* param list must exist*/
  TERM_ASSERT(t, par_list != NULL);
  /* get annotation*/
  CompTerm* annot = retrieveAnnotation(t);
  /* create type*/
  SgFunctionType* func_type = isSgFunctionType(createType(annot->at(0)));
  TERM_ASSERT(t, func_type != NULL);
  /* get function name*/
  EXPECT_TERM(Atom*, func_name_term, annot->at(1));
  SgName func_name = func_name_term->getName();

  EXPECT_TERM(List*, ptemplateargs, annot->at(4));

  //deque<Term*>* succs = ptemplateargs->getSuccs();
  //deque<Term*>::iterator it = succs->begin();
  SgTemplateArgumentPtrList args;
  //while (it != succs->end()) {
  for (int i = 0; i < ptemplateargs->getArity(); ++i) {
    //args.push_back(static_cast<SgTemplateArgument*>(toRose(*it)));
    args.push_back(static_cast<SgTemplateArgument*>(toRose(ptemplateargs->at(i))));
  }

  EXPECT_ATOM(templ_decl_name, annot->at(5));

  /* create declaration*/
  SgTemplateInstantiationFunctionDecl* func_decl =
    new SgTemplateInstantiationFunctionDecl(fi,func_name,func_type,/*func_def=*/NULL,
                                            lookupTemplateDecl(templ_decl_name), args);
  TERM_ASSERT(t, func_decl != NULL);
  func_decl->set_parameterList(par_list);
  setDeclarationModifier(annot->at(2),&(func_decl->get_declarationModifier()));
  setSpecialFunctionModifier(annot->at(3), &func_decl->get_specialFunctionModifier());
  
  register_func_decl(func_name, func_decl, annot->at(0));

  return func_decl;
}

SgTemplateArgument*
TermToRose::createTemplateArgument(CompTerm* t) {
  debug("template argument:");
  CompTerm* annot = retrieveAnnotation(t);
  EXPECT_ATOM(templ_decl_name, annot->at(4));
  return new SgTemplateArgument(re.enum_template_argument_enum[*annot->at(0)],
     createFlag(annot->at(1)),
     createType(annot->at(2)),
     static_cast<SgExpression*>(toRose(annot->at(3))),
     lookupTemplateDecl(templ_decl_name),
     createFlag(annot->at(5)));
}

SgTemplateParameter*
TermToRose::createTemplateParameter(Sg_File_Info* fi, CompTerm* t) {
  debug("template param:");
  CompTerm* annot = retrieveAnnotation(t);
  EXPECT_ATOM(templ_decl_name, annot->at(4));
  EXPECT_ATOM(default_param, annot->at(5));
  return new SgTemplateParameter(re.enum_template_parameter_enum[*annot->at(0)],
                                 createType(annot->at(1)),
                                 createType(annot->at(2)),
                                 static_cast<SgExpression*>(toRose(annot->at(3))),
                                 static_cast<SgExpression*>(toRose(annot->at(4))),
                                 lookupTemplateDecl(templ_decl_name),
                                 lookupTemplateDecl(default_param));
}

SgTemplateDeclaration*
TermToRose::createTemplateDeclaration(Sg_File_Info* fi, CompTerm* t) {
  debug("template decl:");
  CompTerm* annot = retrieveAnnotation(t);
  EXPECT_ATOM(name, annot->at(0));
  EXPECT_ATOM(strng, annot->at(1));

  EXPECT_TERM(List*, args, annot->at(3));
  deque<Term*>* succs = args->getSuccs();
  deque<Term*>::iterator it = succs->begin();
  SgTemplateParameterPtrList params;
  while (it != succs->end()) {
    params.push_back(static_cast<SgTemplateParameter*>(toRose(*it)));
    it++;
  }

  SgTemplateDeclaration* decl = 
    new SgTemplateDeclaration(fi, name, strng,
                              re.enum_template_type_enum[*annot->at(2)],
                              params);

  // register it in the symbol table
  templateDeclMap[name] = decl;
  return decl;
}


SgFunctionDeclaration*
TermToRose::setFunctionDeclarationBody(SgFunctionDeclaration* func_decl, SgNode* func_def_u) {
  ROSE_ASSERT(func_decl != NULL);
  SgFunctionDefinition* func_def = isSgFunctionDefinition(func_def_u);
  func_decl->set_forward(func_def == NULL);
  func_decl->set_definition(func_def);
  func_decl->set_definingDeclaration(func_decl);
  func_decl->get_firstNondefiningDeclaration()
           ->set_definingDeclaration(func_decl);

  /*post processing*/
  if (func_def != NULL) { /*important: otherwise unparsing fails*/
    func_def->set_declaration(func_decl);
    /* set defining declaration ROSE 0.9.0b */
    func_decl->set_definingDeclaration(func_decl);
    /** fix function argument symbols: the symbols for the function
     * arguments from the decl node must be inserted in the def's symbol
     * table */
    SgInitializedNamePtrList &args = func_decl->get_args();
    SgInitializedNamePtrList::iterator i;
    for (i = args.begin(); i != args.end(); ++i) {
      /* create or look up variable symbol */
      SgVariableSymbol *varSym = createVariableSymbol(*i);
      func_def->insert_symbol(varSym->get_name(), varSym);
#if 0
      std::cout
          << "entering " << varSym->get_name().str()
          << "@" << (void *) varSym
          << " as " << i - args.begin() << "-th argument of "
          << func_decl->get_name().str()
          << std::endl;
#endif
    }
  } else {
  }
  return func_decl;
}

SgTypedefSeq*
TermToRose::createTypedefSeq(Sg_File_Info* fi, CompTerm* t) {
  debug("template decl:");
  CompTerm* annot = retrieveAnnotation(t);
  SgTypedefSeq* seq = new SgTypedefSeq();
  EXPECT_TERM(List*, l, annot->at(0));
  deque<Term*>* succs = l->getSuccs();
  deque<Term*>::iterator it = succs->begin();
  while (it != succs->end()) {
    seq->append_typedef(static_cast<SgType*>(toRose(*it)));
    it++;
  }

  return seq;
}



/**
 * create SgMemberFunctionDeclaration
 */
SgMemberFunctionDeclaration*
TermToRose::createMemberFunctionDeclaration(Sg_File_Info* fi, SgNode* par_list_u,SgNode* func_def_u, SgNode* ctor_list_u, CompTerm* t) {
  debug("member function declaration:");
  /* cast parameter list and function definition (if exists)*/
  EXPECT_NODE(SgFunctionParameterList*, par_list, par_list_u);
  SgFunctionDefinition* func_def = isSgFunctionDefinition(func_def_u);
  EXPECT_NODE(SgCtorInitializerList*, ctor_list, ctor_list_u);
  /* get annotation*/
  CompTerm* annot = retrieveAnnotation(t);
  /* create type*/
  EXPECT_NODE(SgFunctionType*, func_type, createType(annot->at(0)));
  /* get function name*/
  EXPECT_TERM(Atom*, func_name_term, annot->at(1));
  SgName func_name = func_name_term->getName();
  /* create declaration*/
  SgMemberFunctionDeclaration* func_decl =
    new SgMemberFunctionDeclaration(fi,func_name,func_type,func_def);
  TERM_ASSERT(t, func_decl != NULL);
  /** if there's no declaration we're dealing with a forward declaration*/
  func_decl->set_forward(func_def == NULL);
  func_decl->set_parameterList(par_list);
  func_decl->set_CtorInitializerList(ctor_list);

  /*post processing*/
  /* class scope*/
  CompTerm* scopeTerm = isCompTerm(annot->at(2));
  TERM_ASSERT(t, scopeTerm != NULL);
  EXPECT_ATOM(scope_name, scopeTerm->at(0));
  int scope_type  = re.enum_class_types[*scopeTerm->at(1)];

  //func_decl->set_scope(fakeClassScope(scope_name,scope_type,func_decl));

  /*important: otherwise unparsing fails*/
  if (func_def != NULL) {
    func_def->set_declaration(func_decl);
  }
  //TERM_ASSERT(t, isSgClassDefinition(func_decl->get_class_scope()) != NULL);
  //TERM_ASSERT(t, func_decl->get_class_scope()->get_declaration() != NULL);
  //func_decl->set_isModified(false);
  //debug(func_decl->get_qualified_name().getString());

  /*set declaration modifier*/
  setDeclarationModifier(annot->at(3),&func_decl->get_declarationModifier());
  setSpecialFunctionModifier(annot->at(4), &func_decl->get_specialFunctionModifier());

  // Symbol table management
  register_func_decl(func_name, func_decl, annot->at(0));
  // cerr<<__FUNCTION__<<"**** inserting "+scope_name<<":"<<func_decl<<endl;
  memberFunctionDeclarationMap.insert(pair<string,SgMemberFunctionDeclaration*>
                                      (scope_name,func_decl));

  // Is this a definition outside of the main class declaration?
  // ie., parent != scope  
  // In this case we need to do all the fixups here
  // cerr<<__FUNCTION__<<"@@@ looking for "<<scope_name<<endl;
  if (classDefinitionMap.find(scope_name) != classDefinitionMap.end()) {
    // cerr<<__FUNCTION__<<"@@@ found "<<scope_name<<endl;
    SgClassDefinition* class_def = classDefinitionMap[scope_name];
    ROSE_ASSERT(class_def != NULL);
    func_decl->set_scope(class_def);
    //func_decl->set_parent(global);
    ROSE_ASSERT(class_def->get_declaration() != NULL);
    func_decl->set_associatedClassDeclaration(class_def->get_declaration());
  }
  return func_decl;
}

/**
 * create SgProcedureHeaderStatement
 */
SgProcedureHeaderStatement*
TermToRose::createProcedureHeaderStatement(Sg_File_Info* fi, SgNode* par_list_u, 
                                           SgNode* unknown, SgNode* func_def_u, 
                                           SgNode* result_name_u, CompTerm* t) {
  debug("procedure header statement:");
  /* cast parameter list and function definition (if exists)*/
  EXPECT_NODE(SgFunctionParameterList*, par_list, par_list_u);
  SgFunctionDefinition* func_def = isSgFunctionDefinition(func_def_u);
  EXPECT_NODE(SgInitializedName*, result_name, result_name_u);
  /* get annotation*/
  CompTerm* annot = retrieveAnnotation(t);
  /* create type*/
  EXPECT_NODE(SgFunctionType*, func_type, createType(annot->at(0)));
  /* get function name*/
  EXPECT_TERM(Atom*, func_name_term, annot->at(1));
  SgName func_name = func_name_term->getName();
  /* create declaration*/
  SgProcedureHeaderStatement* proc_header_stmt =
    new SgProcedureHeaderStatement(fi,func_name,func_type,func_def);
  TERM_ASSERT(t, proc_header_stmt != NULL);
  /** if there's no declaration we're dealing with a forward declatation*/
  proc_header_stmt->set_forward(func_def == NULL);
  proc_header_stmt->set_parameterList(par_list);
  proc_header_stmt->set_result_name(result_name);

  /*post processing*/

  /*important: otherwise unparsing fails*/
  if (func_def != NULL) {
    func_def->set_declaration(proc_header_stmt);
    result_name->set_scope(func_def);
  }
  proc_header_stmt->set_isModified(false);
  //debug(proc_header_stmt->get_qualified_name().getString());

  /*set declaration modifier*/
  setDeclarationModifier(annot->at(2),&proc_header_stmt->get_declarationModifier());

  /* subprogram kind */
  proc_header_stmt->set_subprogram_kind(re.enum_subprogram_kind_enum[*annot->at(3)]);

  register_func_decl(func_name, proc_header_stmt, annot->at(0));

  return proc_header_stmt;
}


/**
 * Retrieve Annotation Term and cast to CompTerm* from a node term
 */
CompTerm*
TermToRose::retrieveAnnotation(CompTerm* t) {
  /* the position of the annotation depends on the arity of the term*/
  EXPECT_TERM(CompTerm*, a, t->at(t->getArity()-(3-AR)));
  return a;
}

/**
 * create a SgGlobal node
 * and convert content
 */
SgGlobal*
TermToRose::createGlobal(Sg_File_Info* fi,std::deque<SgNode*>* succs) {
  SgGlobal* glob = new SgGlobal(fi);
  glob->set_endOfConstruct(FI);
  debug("in SgGlobal:");
  testFileInfo(fi);
  /*add successors*/
  deque<SgNode*>::iterator it = succs->begin();
  while(it != succs->end()) {
    /* all successors that arent NULL (we don't create SgNullStatements, instead
     * we return NULL ptrs*/
    if((*it) != NULL) {
      EXPECT_NODE(SgDeclarationStatement*, curdec, *it);
      glob->append_declaration(curdec);
      /* set scope if there is none yet
       * as this is essential for unparsing */
      if(curdec->get_scope() == NULL) {
        curdec->set_scope(glob);
      }
      addSymbol(glob, curdec); // ROSE 0.9.0b (Adrian)
      debug ("added declaration of type " + (*it)->class_name());
    }
    it++;
  }
  return glob;
}

/** create SgVarRefExp*/
SgVarRefExp*
TermToRose::createVarRefExp(Sg_File_Info* fi, CompTerm* t) {
  CompTerm* annot = retrieveAnnotation(t);
  TERM_ASSERT(t, annot != NULL);
  /* cast SgInitializedName*/
  bool forward_ref = false;
  SgInitializedName* init_name;
  string id = makeInameID(annot);
  if (initializedNameMap.find(id) != initializedNameMap.end()) {
    // Lookup the closest iname
    init_name = initializedNameMap[id];
  } else {
    cerr<<"**WARNING: forward reference to the initialized name "<<id<<endl;
    // FIXME: We should actually store the iname here and re-use it
    //when we come to the actual declaration.
    //TERM_ASSERT(t, false);
    init_name = inameFromAnnot(annot);
    forward_ref = true;
  }
  TERM_ASSERT(t, init_name != NULL);
  /*cast variable symbol*/
  SgVariableSymbol* var_sym = createVariableSymbol(init_name);
  TERM_ASSERT(t, var_sym != NULL);
  /*create VarRefExp*/
  SgVarRefExp* vre = new SgVarRefExp(fi,var_sym);
  TERM_ASSERT(t, vre != NULL);
  // Set parent pointers
  if (forward_ref) init_name->set_parent(var_sym);    
  var_sym->set_parent(vre);
  return vre;
}

/** create SgVariableSymbol */
SgVariableSymbol*
TermToRose::createVariableSymbol(SgInitializedName *init_name) {
  /** can't create a new variable symbol for each reference to the variable
   * because analyzers expect the symbols to be shared */
  SgVariableSymbol *varsym = NULL;
  if (variableSymbolMap.find(init_name) != variableSymbolMap.end()) {
    varsym = variableSymbolMap[init_name];
  } else {
    varsym = new SgVariableSymbol(init_name);
#if 0
    std::cout
        << "* created varsym " << (void *) varsym << " for init_name "
        << init_name->get_name().str() << "@" << (void *) init_name
        << std::endl;
#endif
    variableSymbolMap[init_name] = varsym;
  }
  return varsym;
}

/**
 * create a SgAssignInitializer
 */
SgAssignInitializer*
TermToRose::createAssignInitializer(Sg_File_Info* fi, SgNode* succ, CompTerm* t) {
  SgExpression* exp = isSgExpression(succ);
  // not true.. TERM_ASSERT(t, exp != NULL);
  SgAssignInitializer* ai = new SgAssignInitializer(fi,exp);
  TERM_ASSERT(t, ai != NULL);
  return ai;
}

/**
 * create a SgBinaryOp
 */
SgBinaryOp*
TermToRose::createBinaryOp(Sg_File_Info* fi,SgNode* lnode,SgNode* rnode,CompTerm* t) {
  debug("creating binary op");
  string op_name = t->getName();
  debug("op type: " + op_name);
  if (op_name == "lshift_assign_op") {
    debug("op type: " + op_name);
  }
  /*get lhs and rhs operand*/
  SgExpression* lhs = isSgExpression(lnode);
  SgExpression* rhs = isSgExpression(rnode);
  abort_unless((lhs != NULL) && (rhs != NULL), "Operands of binary operator must be an expression");
  CompTerm* annot = retrieveAnnotation(t);
  abort_unless(annot != NULL, "Could not retrieve annotation for binary operator");
  /* get type*/
  SgType* op_type = createType(annot->at(0));
  /* depending on the type, call constructor*/
  SgBinaryOp* cur_op = NULL;
  if (op_name == "arrow_exp")                cur_op = new SgArrowExp(fi,lhs,rhs,op_type);
  else if (op_name == "add_op")              cur_op = new SgAddOp(fi,lhs,rhs,op_type);
  else if (op_name == "and_assign_op")       cur_op = new SgAndAssignOp(fi,lhs,rhs,op_type);
  else if (op_name == "and_op")              cur_op = new SgAndOp(fi,lhs,rhs,op_type);
  else if (op_name == "arrow_star_op")       cur_op = new SgArrowStarOp(fi,lhs,rhs,op_type);
  else if (op_name == "assign_op")           cur_op = new SgAssignOp(fi,lhs,rhs,op_type);
  else if (op_name == "bit_and_op")          cur_op = new SgBitAndOp(fi,lhs,rhs,op_type);
  else if (op_name == "bit_or_op")           cur_op = new SgBitOrOp(fi,lhs,rhs,op_type);
  else if (op_name == "bit_xor_op")          cur_op = new SgBitXorOp(fi,lhs,rhs,op_type);
  else if (op_name == "comma_op_exp")        cur_op = new SgCommaOpExp(fi,lhs,rhs,op_type);
  else if (op_name == "div_assign_op")       cur_op = new SgDivAssignOp(fi,lhs,rhs,op_type);
  else if (op_name == "divide_op")           cur_op = new SgDivideOp(fi,lhs,rhs,op_type);
  else if (op_name == "dot_exp")             cur_op = new SgDotExp(fi,lhs,rhs,op_type);
  else if (op_name == "dot_star_op")         cur_op = new SgDotStarOp(fi,lhs,rhs,op_type);
  else if (op_name == "equality_op")         cur_op = new SgEqualityOp(fi,lhs,rhs,op_type);
  else if (op_name == "exponentiation_op")   cur_op = new SgExponentiationOp(fi,lhs,rhs,op_type);
  else if (op_name == "greater_or_equal_op") cur_op = new SgGreaterOrEqualOp(fi,lhs,rhs,op_type);
  else if (op_name == "greater_than_op")     cur_op = new SgGreaterThanOp(fi,lhs,rhs,op_type);
  else if (op_name == "integer_divide_op")   cur_op = new SgIntegerDivideOp(fi,lhs,rhs,op_type);
  else if (op_name == "ior_assign_op")       cur_op = new SgIorAssignOp(fi,lhs,rhs,op_type);
  else if (op_name == "less_or_equal_op")    cur_op = new SgLessOrEqualOp(fi,lhs,rhs,op_type);
  else if (op_name == "less_than_op")        cur_op = new SgLessThanOp(fi,lhs,rhs,op_type);
  else if (op_name == "lshift_assign_op")    cur_op = new SgLshiftAssignOp(fi,lhs,rhs,op_type);
  else if (op_name == "lshift_op")           cur_op = new SgLshiftOp(fi,lhs,rhs,op_type);
  else if (op_name == "minus_assign_op")     cur_op = new SgMinusAssignOp(fi,lhs,rhs,op_type);
  else if (op_name == "mod_assign_op")       cur_op = new SgModAssignOp(fi,lhs,rhs,op_type);
  else if (op_name == "mod_op")              cur_op = new SgModOp(fi,lhs,rhs,op_type);
  else if (op_name == "mult_assign_op")      cur_op = new SgMultAssignOp(fi,lhs,rhs,op_type);
  else if (op_name == "multiply_op")         cur_op = new SgMultiplyOp(fi,lhs,rhs,op_type);
  else if (op_name == "not_equal_op")        cur_op = new SgNotEqualOp(fi,lhs,rhs,op_type);
  else if (op_name == "or_op")               cur_op = new SgOrOp(fi,lhs,rhs,op_type);
  else if (op_name == "plus_assign_op")      cur_op = new SgPlusAssignOp(fi,lhs,rhs,op_type);
  else if (op_name == "pntr_arr_ref_exp")    cur_op = new SgPntrArrRefExp(fi,lhs,rhs,op_type);
  else if (op_name == "rshift_assign_op")    cur_op = new SgRshiftAssignOp(fi,lhs,rhs,op_type);
  else if (op_name == "rshift_op")           cur_op = new SgRshiftOp(fi,lhs,rhs,op_type);
  else if (op_name == "scope_op")            cur_op = new SgScopeOp(fi,lhs,rhs,op_type);
  else if (op_name == "subtract_op")         cur_op = new SgSubtractOp(fi,lhs,rhs,op_type);
  else if (op_name == "xor_assign_op")       cur_op = new SgXorAssignOp(fi,lhs,rhs,op_type);
  TERM_ASSERT(t, cur_op != NULL);
  debug("created binary op");
  return cur_op;
}

/**
 * is this string a binary op name?
 */
bool
TermToRose::isBinaryOp(std::string tname) {
  // FIXME: replace this with a hashmap or a regex
  if (tname == "arrow_exp")                return true;
  else if (tname == "add_op")              return true;
  else if (tname == "and_assign_op")       return true;
  else if (tname == "and_op")              return true;
  else if (tname == "arrow_exp")           return true;
  else if (tname == "arrow_star_op")       return true;
  else if (tname == "assign_op")           return true;
  else if (tname == "bit_and_op")          return true;
  else if (tname == "bit_or_op")           return true;
  else if (tname == "bit_xor_op")          return true;
  else if (tname == "comma_op_exp")        return true;
  else if (tname == "div_assign_op")       return true;
  else if (tname == "divide_op")           return true;
  else if (tname == "dot_exp")             return true;
  else if (tname == "dot_star_op")         return true;
  else if (tname == "equality_op")         return true;
  else if (tname == "exponentiation_op")   return true;
  else if (tname == "greater_or_equal_op") return true;
  else if (tname == "greater_than_op")     return true;
  else if (tname == "integer_divide_op")   return true;
  else if (tname == "ior_assign_op")       return true;
  else if (tname == "less_or_equal_op")    return true;
  else if (tname == "less_than_op")        return true;
  else if (tname == "lshift_assign_op")    return true;
  else if (tname == "lshift_op")           return true;
  else if (tname == "minus_assign_op")     return true;
  else if (tname == "mod_assign_op")       return true;
  else if (tname == "mod_op")              return true;
  else if (tname == "mult_assign_op")      return true;
  else if (tname == "multiply_op")         return true;
  else if (tname == "not_equal_op")        return true;
  else if (tname == "or_op")               return true;
  else if (tname == "plus_assign_op")      return true;
  else if (tname == "pntr_arr_ref_exp")    return true;
  else if (tname == "rshift_assign_op")    return true;
  else if (tname == "rshift_op")           return true;
  else if (tname == "scope_op")            return true;
  else if (tname == "subtract_op")         return true;
  else if (tname == "xor_assign_op")       return true;
  else return false;
}

/**
 * create SgExprStatement
 */
SgExprStatement*
TermToRose::createExprStatement(Sg_File_Info* fi, SgNode* succ, CompTerm* t) {
  /* create statement*/
  SgExprStatement* es = NULL;
  debug("creating expression statenemt");
  if (SgExpressionRoot* er = isSgExpressionRoot(succ)) {
    /*either with an expression statment as successor*/
    es = new SgExprStatement(fi,er);
  } else if (SgExpression* exp = isSgExpression(succ)) {
    /*...or with an expression*/
    es = new SgExprStatement(fi,exp);
  }
  TERM_ASSERT(t, es != NULL);
  debug("created expression statement");
  return es;
}

/**
 * create a SgVariableDeclaration
 */
SgVariableDeclaration*
TermToRose::createVariableDeclaration(Sg_File_Info* fi,std::deque<SgNode*>* succs,CompTerm* t, SgDeclarationStatement *baseTypeDeclaration) {
  /*extract annotation*/
  CompTerm* annot = retrieveAnnotation(t);
  TERM_ASSERT(t, t != NULL);
  /* create declaration*/
  SgVariableDeclaration* dec = new SgVariableDeclaration(fi);
  TERM_ASSERT(t, fi != NULL);
  debug("created variable declaration");

  // Struct declaration and definition in one?
  SgClassDeclaration* class_decl = 0;
  SgEnumDeclaration* enum_decl = 0;
  if (baseTypeDeclaration != NULL
   && baseTypeDeclaration->get_definingDeclaration() == baseTypeDeclaration) {
    baseTypeDeclaration->unsetForward();
    dec->set_baseTypeDefiningDeclaration(baseTypeDeclaration);
    class_decl = isSgClassDeclaration(baseTypeDeclaration);
    enum_decl = isSgEnumDeclaration(baseTypeDeclaration);
  }

  /* add initialized names*/
  SgInitializer* ini_initializer;

  deque<SgNode*>::iterator it = succs->begin();
  TERM_ASSERT(t, it != succs->end());
  for ( ; it != succs->end(); ++it) {
    if (SgInitializedName* ini_name = isSgInitializedName(*it)) {
      debug("added variable");
      ini_name->set_declptr(dec);
      ini_name->set_parent(dec);
      ini_initializer = ini_name->get_initializer();

      if (class_decl) {
        // If this is a Definition as well, insert the pointer to the
        // declaration
        SgClassType* ct = isSgClassType(ini_name->get_typeptr()->findBaseType());
        TERM_ASSERT(t, ct);
        ct->set_declaration(class_decl);
      } else if (enum_decl) {
        // If this is a Definition as well, insert the pointer to the
        // declaration
        SgEnumType* et = isSgEnumType(ini_name->get_typeptr());
        TERM_ASSERT(t, et);
        et->set_declaration(enum_decl);
      }
      dec->append_variable(ini_name,ini_initializer);
      /* fixup for ROSE 0.9.4 */
      SgVariableDefinition* def = dec->get_definition(ini_name);
      if (def != NULL) def->set_endOfConstruct(fi);

      // Add local variable declaration to the Fortran type map --
      // these could be function declarations
      fortranFunctionTypeMap[ini_name->get_name()] = ini_name->get_type();
    } else {
      cerr << (*it)->class_name() << "???" << endl;
      TERM_ASSERT(t, false);
    }
  }
  /* set declaration modifier*/
  setDeclarationModifier(annot->at(0),&(dec->get_declarationModifier()));

  if (dec->isForward())
    dec->set_firstNondefiningDeclaration(dec);
  else {
    dec->set_definingDeclaration(dec);
    dec->set_firstNondefiningDeclaration(NULL);
  }

  /* fixup for ROSE 0.9.4 */
  SgVariableDefinition* def = dec->get_definition();
  if (def != NULL) def->set_endOfConstruct(fi);

  return dec;
}

/**
 * create SgIfStmt
 */
SgIfStmt*
TermToRose::createIfStmt(Sg_File_Info* fi, SgNode* child1, SgNode* child2, SgNode* child3, CompTerm* t) {
  /* condition*/
  /* GB (2008-08-21): True and false bodies are now SgStatements, not
   * SgBasicBlocks anymore; changed dynamic_casts to less verbose and more
   * idiomatic is... calls. */
  SgStatement* test_stmt = isSgStatement(child1);
  TERM_ASSERT(t, test_stmt != NULL);
  /* if-branch*/
  SgStatement* true_branch = isSgStatement(child2);
  TERM_ASSERT(t, true_branch != NULL);
  /* else branch*/
  SgStatement* false_branch = isSgStatement(child3);
  SgIfStmt* if_stmt = NULL;
  /* create statement*/
  if_stmt = new SgIfStmt(fi,test_stmt,true_branch,false_branch);
  TERM_ASSERT(t, if_stmt != NULL);

  CompTerm* annot = retrieveAnnotation(t);
  if_stmt->set_has_end_statement(    createFlag(annot->at(0)) );
  if_stmt->set_use_then_keyword(     createFlag(annot->at(1)) );
  if_stmt->set_is_else_if_statement( createFlag(annot->at(2)) );

  return if_stmt;
}

/** create SgDoWhileStmt*/
SgDoWhileStmt*
TermToRose::createDoWhileStmt(Sg_File_Info* fi, SgNode* child1, SgNode* child2,CompTerm* t) {
  /* retrieve basic block -- there is always one*/
  SgStatement* b = isSgStatement(child1);
  /* retrieve statement */
  SgStatement* s = isSgStatement(child2);
  TERM_ASSERT(t, s != NULL);
  /* create do/while*/
  SgDoWhileStmt* d = new SgDoWhileStmt(fi,b,s);
  TERM_ASSERT(t, d != NULL);
  return d;
}

/** create SgWhileStmt*/
SgWhileStmt*
TermToRose::createWhileStmt(Sg_File_Info* fi, SgNode* child1, SgNode* child2, CompTerm* t) {
  /* retrieve Statemtent*/
  SgStatement* s = isSgStatement(child1);
  TERM_ASSERT(t, s != NULL);
  /* retrieve basic block*/
  SgStatement* b = isSgStatement(child2);
  /*create while statement*/
  SgWhileStmt* w = new SgWhileStmt(fi,s,b);
  TERM_ASSERT(t, w != NULL);
  return w;
}

/** create SgForInitStatement*/
SgForInitStatement*
TermToRose::createForInitStatement(Sg_File_Info* fi,std::deque<SgNode*>* succs) {
  SgForInitStatement* ini = new SgForInitStatement(fi);
  ROSE_ASSERT(ini != NULL);
  /*append initializer statements*/
  deque<SgNode*>::iterator it = succs->begin();
  while(it != succs->end()) {
    EXPECT_NODE(SgStatement*, stmt, *it);
    ini->append_init_stmt(stmt);
    stmt->set_parent(ini);
    it++;
  }
  ini->set_endOfConstruct(fi);
  return ini;
}

/** create SgForStatement*/
SgForStatement*
TermToRose::createForStatement(Sg_File_Info* fi, SgNode* child1, SgNode* child2, SgNode* child3, SgNode* child4,CompTerm* t) {
  SgForInitStatement* ini_stmt = isSgForInitStatement(child1);
  SgStatement* test_stmt = isSgStatement(child2);
  SgStatement* loop_body = isSgStatement(child4);
  SgForStatement* f = NULL;
  //std::cerr<<ini_stmt<<std::endl;
  if (SgExpression* e = isSgExpression(child3)) {
    f = new SgForStatement(fi,test_stmt,e,loop_body);
  } else if (SgExpression* e = isSgExpression(child3)) {
    f = new SgForStatement(fi,test_stmt,e,loop_body);
  } else if (SgExprStatement* s = isSgExprStatement(child3)) {
    f = new SgForStatement(fi,test_stmt,s->get_expression(),loop_body);
  }
  TERM_ASSERT(t, f != NULL);
  SgStatementPtrList::iterator it = ini_stmt->get_init_stmt().begin();
  while(it != ini_stmt->get_init_stmt().end()) {
    f->append_init_stmt(*it);
    storeVariableSymbolFromDeclaration(f, isSgDeclarationStatement(*it));
    it++;
  }
  //f->append_init_stmt(ini_stmt);
  return f;
}

/** create SgFortranDo*/
SgFortranDo*
TermToRose::createFortranDo(Sg_File_Info* fi, SgNode* child1, SgNode* child2, SgNode* child3, SgNode* child4,CompTerm* t) {
  // get annotation
  CompTerm* annot = retrieveAnnotation(t);
  TERM_ASSERT(t, annot != NULL);

  SgFortranDo* fdo = new SgFortranDo(fi,
                                     isSgExpression(child1), 
                                     isSgExpression(child2),
                                     isSgExpression(child3),
                                     isSgBasicBlock(child4));
  fdo->set_old_style(createFlag(annot->at(0)));
  fdo->set_has_end_statement(createFlag(annot->at(1)));
  return fdo;
}

/**
 * create SgSwitchStatement
 */
SgSwitchStatement*
TermToRose::createSwitchStatement(Sg_File_Info* fi, SgNode* child1, SgNode* child2, CompTerm* t) {
  SgStatement* switch_expr = NULL;
  SgBasicBlock* switch_block = NULL;
  SgSwitchStatement* s = NULL;
  /* the first child, the switch selector must be a SgStatement*/
  switch_expr = isSgStatement(child1);
  TERM_ASSERT(t, switch_expr != NULL);
  /* the second child, the switch code, must be a SgBasicBlock*/
  switch_block = isSgBasicBlock(child2);
  TERM_ASSERT(t, switch_block != NULL);
  /* make sure a SgSwitchStatement is created*/
  s = new SgSwitchStatement(fi,switch_expr,switch_block);
  TERM_ASSERT(t, s != NULL);
  TERM_ASSERT(t, s->get_file_info() != NULL);
  return s;
}

/**
 * create SgCaseOptionStmt
 */
SgCaseOptionStmt*
TermToRose::createCaseOptionStmt(Sg_File_Info* fi, SgNode* child1, SgNode* child2, SgNode* child3, CompTerm* t) {
  SgCaseOptionStmt* case_stmt = NULL;
  SgStatement* case_block = NULL;
  /* second child must be a SgStatement*/
  abort_unless(
               case_block = isSgStatement(child2),
               "Could not retrieve body of case statement"
               );
  /* first child must be either a SgExpressionRoot or a SgExpression*/
  if(SgExpressionRoot* er = isSgExpressionRoot(child1)) {
    case_stmt = new SgCaseOptionStmt(fi,er,case_block);
  } else {
    SgExpression *e = NULL;
    abort_unless(
                 e = isSgExpression(child1),
                 "Could not retrieve selector value of case statement"
                 );
    case_stmt = new SgCaseOptionStmt(fi,e,case_block);
  }
  /* make sure a SgCaseOptionStmt has been created*/
  abort_unless(
               case_stmt != NULL,
               "Could not create case option statement"
               );
  TERM_ASSERT(t, case_stmt->get_file_info() != NULL);
  return case_stmt;
}

/**
 * create SgDefaultOptionStmt
 */
SgDefaultOptionStmt*
TermToRose::createDefaultOptionStmt(Sg_File_Info* fi, SgNode* child1, CompTerm* t) {
  SgDefaultOptionStmt* default_stmt = NULL;
  SgStatement* b = NULL;
  /*make sure the body is actually one.*/
  abort_unless(
               b = isSgStatement(child1),
               "Body of default option is not a basic block"
               );
  /* make sure the statement is actually created */
  abort_unless(
               default_stmt = new SgDefaultOptionStmt(fi,b),
               "Failed to create default option statement"
               );
  TERM_ASSERT(t, default_stmt->get_file_info() != NULL);
  return default_stmt;
}

/**create a SgBreakStmt*/
SgBreakStmt*
TermToRose::createBreakStmt(Sg_File_Info* fi, CompTerm* t) {
  SgBreakStmt* b = NULL;
  b = new SgBreakStmt(fi);
  TERM_ASSERT(t, b != NULL);
  return b;
}

/** create a SgContinueStmt*/
SgContinueStmt*
TermToRose::createContinueStmt(Sg_File_Info* fi,CompTerm* t) {
  SgContinueStmt* s = new SgContinueStmt(fi);
  TERM_ASSERT(t, s != NULL);
  return s;
}

/** create a SgLabelStatement for gotos */
SgLabelStatement*
TermToRose::createLabelStatement(Sg_File_Info* fi,CompTerm* t) {
  /* get annotation data*/
  CompTerm* u = retrieveAnnotation(t);
  TERM_ASSERT(t, u != NULL);
  /* extract the label name*/
  EXPECT_TERM(Atom*, s, u->at(0));
  /* create SgLabelStatement with helper function*/
  /* makeLabel alreay asserts a non-NULL return value*/
  return makeLabel(fi,s->getName());
}

/** create a SgGotoStmt */
SgGotoStatement*
TermToRose::createGotoStatement(Sg_File_Info* fi,CompTerm* t) {
  /* get annotation data*/
  CompTerm* u = retrieveAnnotation(t);
  TERM_ASSERT(t, u != NULL);
  /* extract the label name*/
  EXPECT_TERM(Atom*, s, u->at(0));
  /* create dummy SgLabelStatement with helper function*/
  SgLabelStatement* l = NULL; //makeLabel(FI,s->getName());
  /*makeLabel asserts a non-NULL return value*/
  /* create goto using dummy label*/
  SgGotoStatement* sgoto = new SgGotoStatement(fi,l);
  TERM_ASSERT(t, sgoto != NULL);
  gotoStatementsWithoutLabel.insert(pair<string,SgGotoStatement*>(s->getName(), sgoto));
  return sgoto;
}

/** create a SgLabelStatement from a string*/
SgLabelStatement*
TermToRose::makeLabel(Sg_File_Info* fi, std::string s) {
  /* we need a SgName*/
  SgName n = s;
  // FIXME: This is apparently necessary to convince the unparser..
  fi->set_classificationBitField(fi->get_classificationBitField()
                                 | Sg_File_Info::e_compiler_generated
                                 | Sg_File_Info::e_output_in_code_generation);
  SgLabelStatement* l = new SgLabelStatement(fi,n);
  ROSE_ASSERT(l != NULL);
  labelStatementsWithoutScope.push_back(l);
  return l;
}

/** create a class definition*/
SgClassDefinition*
TermToRose::createClassDefinition(Sg_File_Info* fi, std::deque<SgNode*>* succs, CompTerm* t) {
  /*the unparser needs a Sg_File_Info for determining the end of construct
   * hence it is put in the annotation and retrieved here */
  CompTerm* annot = retrieveAnnotation(t);
  TERM_ASSERT(t, annot != NULL);
  EXPECT_TERM(CompTerm*, fi_term, annot->at(1));
  Sg_File_Info* end_of_construct = createFileInfo(fi_term);
  TERM_ASSERT(t, end_of_construct != NULL);

  SgClassDefinition* d = NULL;
  /*create empty class definition*/
  d = new SgClassDefinition(fi);
  TERM_ASSERT(t, d != NULL);
  /* append declarations*/
  deque<SgNode*>::iterator it = succs->begin();
  while(it != succs->end()) {
    SgDeclarationStatement* s = isSgDeclarationStatement(*it);
    TERM_ASSERT(t, s != NULL);
    d->append_member(s);
    s->set_parent(d);
    //s->set_scope(d);
    storeVariableSymbolFromDeclaration(d, s);
    it++;
  }

  EXPECT_TERM(List*, inhs, annot->at(0));
  /* append inheritances */
  for (int i = 0; i < inhs->getArity(); i++) {
    EXPECT_TERM(CompTerm*, base_class_term, inhs->at(i));
    EXPECT_TERM(CompTerm*, class_decl_term, base_class_term->at(0));
    EXPECT_TERM(CompTerm*, class_decl_annot, class_decl_term->at(1));
    SgClassDeclaration* base_decl =
      isSgClassDeclaration(declarationMap[class_decl_annot->at(2)->getRepresentation()]);
    ROSE_ASSERT(base_decl != NULL);
    d->append_inheritance(new SgBaseClass(base_decl));
    // FIXME add directBaseClass flag
  }

  /* set the end of construct*/
  d->set_endOfConstruct(end_of_construct);

  // this is now in setClassDeclarationBody, because we also need to
  // index it by the class name: classDefinitions.push_back(d);
  return d;
}


/**
 * create SgClassDeclaration
 */
SgClassDeclaration*
TermToRose::createClassDeclaration(Sg_File_Info* fi, SgNode* child1, CompTerm* t) {
  //cerr<<t->getRepresentation()<<endl;
  /* retrieve annotation*/
  CompTerm* annot = retrieveAnnotation(t);
  TERM_ASSERT(t, annot != NULL);
  /* if there is a child, it is a definition*/
  SgClassDefinition* class_def = isSgClassDefinition(child1);
  /*retrieve name, class type and type*/
  EXPECT_TERM(Atom*, class_name_s, annot->at(0));
  /* get the class_type-enum (struct,class) -- not the type */
  EXPECT_TERM(Atom*, p_class_type, annot->at(1));
  /* get the type*/
  EXPECT_TERM(CompTerm*, type_s, annot->at(2));
  SgClassDeclaration::class_types e_class_type = re.enum_class_types[*p_class_type];
  //SgClassType* sg_class_type = createClassType(type_s);
  SgName class_name = class_name_s->getName();
  SgClassDeclaration* d =
    new SgClassDeclaration(fi, class_name, e_class_type, NULL/*sg_class_type */,
                           class_def);

  //cerr<<t->getRepresentation()<<endl;
  //cerr<<class_def<<endl;

  // Set the type
  TERM_ASSERT(t, d != NULL);
  SgClassType* sg_class_type = NULL;
  if (!lookupType(&sg_class_type, type_s->getRepresentation(), false)) {
    /* create a hidden forward declaration for this class; otherwise, ROSE's
     * recursive parent-pointer-setting routine dies with infinite recursion
     * on recursive class types
     * also, the AstPostProcessing stuff insists on different nodes for
     * defining and nondefining declaration */
    SgClassDeclaration *forward = NULL;
    forward = new SgClassDeclaration(FI,class_name,e_class_type,NULL,NULL);
    forward->setForward();
    forward->set_firstNondefiningDeclaration(forward);
    d->set_firstNondefiningDeclaration(forward);
    declarationStatementsWithoutScope.push_back(forward);
    sg_class_type = SgClassType::createType(forward);
    typeMap[type_s->getRepresentation()] = sg_class_type;
    /* not present yet */
    TERM_ASSERT(t, declarationMap.find(type_s->getRepresentation())
                == declarationMap.end());
    declarationMap[type_s->getRepresentation()] = forward;
    forward->set_type(sg_class_type);
  }
  d->set_type(sg_class_type);

  /* set declaration or the forward flag*/
  if(class_def != NULL) {
    class_def->set_declaration(d);
  } else {
    d->setForward();
  }

  // Set class declarations of member function declarations
  // cerr<<__FUNCTION__<<"#### looking for ::"+d->get_name()<<endl;
  for (multimap<string,SgMemberFunctionDeclaration*>::iterator it =
               memberFunctionDeclarationMap.find("::"+d->get_name());
         it != memberFunctionDeclarationMap.end(); it++) {
    // cerr<<__FUNCTION__<<"#### found "<<it->second<<endl;
    it->second->set_scope(class_def);
    it->second->set_associatedClassDeclaration(d);
  }

  TERM_ASSERT(t, declarationMap.find(type_s->getRepresentation())
              != declarationMap.end());
  d->set_firstNondefiningDeclaration(declarationMap[type_s->getRepresentation()]);

  return d;
}

SgClassDeclaration *
TermToRose::setClassDeclarationBody(SgClassDeclaration* d, SgNode *body) {
  ROSE_ASSERT(d != NULL);
  SgClassDefinition *class_def = isSgClassDefinition(body);
  if(class_def != NULL) {
    class_def->set_declaration(d);
    class_def->set_parent(d);
    d->set_definition(class_def);
    d->set_definingDeclaration(d);
    d->get_firstNondefiningDeclaration()->set_definingDeclaration(d);
    d->unsetForward();

    // Store the class definition in our own symbol table so we can
    // associate external member function definitions with it
    // cerr<<__FUNCTION__<<"@@@ storign ::"+string(d->get_name())+":"<<class_def<<endl;
    // FIXME: using the global namespace will not be general enough
    classDefinitionMap["::"+d->get_name()] = class_def;


    // Set scope of member function declarations
    // cerr<<__FUNCTION__<<"**** looking for ::"+d->get_name()<<endl;
    for (multimap<string,SgMemberFunctionDeclaration*>::iterator it =
           memberFunctionDeclarationMap.find("::"+d->get_name());
         it != memberFunctionDeclarationMap.end(); it++) {
      // cerr<<__FUNCTION__<<"**** found "<<it->second<<endl;
      //if (it->second->get_scope() == NULL)
      ROSE_ASSERT(class_def != NULL);
      it->second->set_scope(class_def);
      it->second->set_associatedClassDeclaration(d);
    }
  }
  return d;
}

/** create dummy class scope and add a declaration*/
void
TermToRose::fakeClassScope(std::string s, int c_type,SgDeclarationStatement* stat) {
  ROSE_ASSERT(false && "deprecated function");
  // /*create a dummy class declaration*/
  // SgClassDeclaration* d = createDummyClassDeclaration(s,c_type);
  // SgClassDefinition* def = new SgClassDefinition(
  //   FI, d);
  // d->set_parent(def);
  // // FIXME
  // def->set_parent(d);
  // ROSE_ASSERT(def != NULL);
  // /* scope is changed here as a side effect!*/
  // def->append_member(stat);
  // if (SgVariableDeclaration* vd = isSgVariableDeclaration(stat)) {
  //   debug("var ref exp class scope added");
  //   vd->set_parent(def);
  // } else {
  //   stat->set_scope(def);
  // }
}

/** create dummy namespace scope*/
void
TermToRose::fakeNamespaceScope(std::string s, int unnamed, SgDeclarationStatement* stat) {
  ROSE_ASSERT(false && "deprecated function");
  // SgName n = s;
  // bool u_b = (bool) unnamed;
  // SgNamespaceDefinitionStatement* def =
  //   new SgNamespaceDefinitionStatement(FI,0);
  // /* set scope*/
  // def->append_declaration(stat);
  // if (SgVariableDeclaration* vd = isSgVariableDeclaration(stat)) {
  //   debug("var ref exp namespace scope added");
  //   vd->set_parent(def);
  // } else {
  //   stat->set_scope(def);
  // }
  // /* create namespace*/
  // SgNamespaceDeclarationStatement* dec =
  //   new SgNamespaceDeclarationStatement(FI,n,def,u_b);
  // def->set_namespaceDeclaration(dec); // AP 4.2.2008
  // if(def != NULL) {
  //   def->set_namespaceDeclaration(dec);
  //   dec->set_forward(false);
  //   dec->set_definingDeclaration(dec);
  // }
  // ROSE_ASSERT(dec != NULL);
  // SgGlobal* dummy = new SgGlobal(FI);
  // ROSE_ASSERT(dummy != NULL);
  // dec->set_parent(dummy);
}


/** create dummy class declaration from name*/
SgClassDeclaration*
TermToRose::createDummyClassDeclaration(std::string s,int c_type) {
  //ROSE_ASSERT(false && "deprecated function");

  //Sg_File_Info* fi = Sg_File_Info::generateDefaultFileInfo();
  SgName class_name = s;
  SgClassDeclaration* d =
    new SgClassDeclaration(FI,class_name,
                           (SgClassDeclaration::class_types)c_type,NULL,NULL);
  ROSE_ASSERT(d != NULL);
  d->setForward();
  d->set_firstNondefiningDeclaration(d);
  declarationStatementsWithoutScope.push_back(d);
  return d;
}

/** create dummy member function declaration class from name*/
SgMemberFunctionDeclaration*
TermToRose::createDummyMemberFunctionDeclaration(std::string s,int c_type) {
  ROSE_ASSERT(false && "deprecated function");
  /*    TODO
        Sg_File_Info* fi = Sg_File_Info::generateDefaultFileInfo();
        SgName class_name = s;
        SgClassDeclaration* d = new SgClassDeclaration(fi,class_name,c_type,NULL,NULL);
        ROSE_ASSERT(d != NULL);
        fakeParentScope(d);
        return d;
  */
  return 0;
}

/** create SgClassType from annotation */
SgClassType*
TermToRose::createClassType(Term* p) {
  SgClassType* ct = NULL;
  /* must be a composite term*/
  EXPECT_TERM(CompTerm*, t, p);
  /* first term is class name*/
  string s = *toStringP(t->at(0));
  /* lookup class declaration */
  SgClassDeclaration* d = NULL;
  if (declarationMap.find(t->getRepresentation()) != declarationMap.end()) {
    d = isSgClassDeclaration(declarationMap[t->getRepresentation()]);
  } else {
    d = createDummyClassDeclaration(s, re.enum_class_types[*t->at(1)]);
    declarationMap[t->getRepresentation()] = d;
  }

  TERM_ASSERT(t, d != NULL);
  EXPECT_ATOM(scopename, t->at(2));
  if(scopename != "::") {
    fakeNamespaceScope(scopename,0,d);
  } else {
    declarationStatementsWithoutScope.push_back(d);
  }
  /* the unparser wants this*/
  /*SgClassDefinition* classdef = new SgClassDefinition();
    d->set_definition(classdef);*/
  ct = SgClassType::createType(d);
  TERM_ASSERT(t, ct != NULL);
  return ct;
}

/**Create SgCtorInitializerList*/
SgCtorInitializerList*
TermToRose::createCtorInitializerList(Sg_File_Info* fi,std::deque<SgNode*>* succs) {
  //this is a typical list node. only needs file info in constructor
  SgCtorInitializerList* l = new SgCtorInitializerList(fi);
  ROSE_ASSERT(l != NULL);
  //append constructor initializers
  deque<SgNode*>::iterator it = succs->begin();
  while(it != succs->end()) {
    EXPECT_NODE(SgInitializedName*, n, *it);
    l->append_ctor_initializer(n);
    it++;
  }
  return l;
}


/**
 * if condition is not met, output message and exit with failure*/
void
TermToRose::abort_unless(bool condition,std::string message) {
  if (condition) return;
  cerr << "\nFatal error while transforming to ROSE AST:\n"<< message << "\n";
  assert(condition);
}

/** create bit deque from List*/
template < typename enumType  >
SgBitVector*
TermToRose::createBitVector(Term* t, std::map<std::string, enumType> names) {
  /*cast the argument to the list and extract elements*/
  EXPECT_TERM(List*, l, t);
  deque<Term*>* succs = l->getSuccs();
  /*create a bit vector*/
  SgBitVector* bv = new SgBitVector();
  bv->resize(names.size(), false);
  /*extract bits from list*/
  deque<Term*>::iterator it = succs->begin();
  while(it != succs->end()) {
    EXPECT_TERM(Atom*, a, *it);
    //cerr<<"&& setting "<< names[a->getName()] << " $ " << a->getRepresentation()<< endl;
    (*bv)[names[a->getName()]] = true;
    it++;
  }
  return bv;
}

/**
 * create SgEnumDeclaration
 * */
SgEnumDeclaration*
TermToRose::createEnumDeclaration(Sg_File_Info* fi, std::deque<SgNode*>* succs, CompTerm* t) {
  /*retrieve name*/
  CompTerm* annot = retrieveAnnotation(t);
  TERM_ASSERT(t, t != NULL);
  SgName e_name = *toStringP(annot->at(0));
  /* leave type blank for now*/
  SgEnumDeclaration* dec = new SgEnumDeclaration(fi,e_name,NULL);
  TERM_ASSERT(t, dec != NULL);
  /*create a type*/
  dec->set_type(SgEnumType::createType(dec));
  /* append enumerators (name or name/value)*/
  deque<SgNode*>::iterator it = succs->begin();
  SgInitializedName* iname;
  while(it != succs->end()) {
    iname = isSgInitializedName(*it);
    TERM_ASSERT(t, iname != NULL);
    dec->append_enumerator(iname);
    it++;
  }
  /* postprocessing*/
  dec->set_embedded((bool) toInt(annot->at(2)));
  pciDeclarationStatement(dec,annot->at(1));
  dec->set_definingDeclaration(dec);

  string id = annot->at(0)->getRepresentation();
  TERM_ASSERT(t, id != "" && id != "''");
  typeMap[id] = dec->get_type();
  declarationMap[id] = dec;

  return dec;
}

/**
 * Create SgTypedefDeclaration
 */
SgTypedefDeclaration*
TermToRose::createTypedefDeclaration(Sg_File_Info* fi, CompTerm* t) {
  TERM_ASSERT(t, t != NULL);
  debug("typedef declaration");
  /*get annotation*/
  CompTerm* annot = retrieveAnnotation(t);
  TERM_ASSERT(t, annot != NULL);
  /*create name*/
  SgName n = *(toStringP(annot->at(0)));
  SgType* tpe = NULL;
  /*create definition, if there is one*/
  SgDeclarationStatement* decl = NULL;
  /* condition is true when a declaration is at this position*/
  CompTerm* ct = isCompTerm(t->at(0));
  if(ct != NULL) {
    debug("...with declaration");
    string id;
    if (ct->getName() == "class_declaration") {
      ARITY_ASSERT(ct, 4-AR);
      CompTerm* annot = isCompTerm(ct->at(1));
      ARITY_ASSERT(annot, 4);
      id = annot->at(0)->getRepresentation();
    }
    else if (ct->getName() == "enum_declaration")
      id = isCompTerm(ct->at(1))->at(0)->getRepresentation();
    else id = ct->getRepresentation();
    //cerr<<"TDDECKL>>>>"<<id<<endl;
    // Try to look it up
    if (!lookupDecl(&decl, id, false)) {
      // Create it otherwise
      // decl = isSgDeclarationStatement(toRose(annot->at(2)));
      decl = isSgDeclarationStatement(toRose(t->at(0)));
      TERM_ASSERT(t, decl != NULL);
    }
    if (decl->get_definingDeclaration() != NULL) {
      // we are actually interested in defining declarations
      decl = decl->get_definingDeclaration();
    }

    TERM_ASSERT(t, decl != NULL);
    //note that the unparser seems to skip it!
  }

  /*create nested type*/
  if (tpe == NULL)
    tpe = createType(annot->at(1));

  /*create typedef declaration*/
  SgSymbol* smb = NULL;
  SgTypedefDeclaration* d = new SgTypedefDeclaration(fi,n,tpe,NULL,decl);
  SgTypedefType* tdtpe = SgTypedefType::createType(d);
  string tid = "typedef_type("+annot->at(0)->getRepresentation()+", "
    +annot->at(1)->getRepresentation()+")";
  typeMap[tid] = tdtpe;
  if (tdtpe->get_declaration()->get_parent() == NULL) {
    tdtpe->get_declaration()->set_parent(dummy_to_please_rose);
  }
  TERM_ASSERT(t, d != NULL);
  /* if there is a declaration, set flag and make sure it is set*/
  if(decl != NULL && !decl->isForward()) {
    d->set_typedefBaseTypeContainsDefiningDeclaration(true);
 // createDummyNondefDecl(d, FI, n, tpe, tdtpe);
  }
  if (decl != NULL)
    decl->set_parent(d);

  // Fixup the decl in the type if necessary
  //SgNamedType* nt = isSgNamedType(tpe);
  //if (nt && nt->get_declaration() == NULL)
  //  nt->set_declaration(d);

  // Symbol table
  string id = "typedef_type("+annot->at(0)->getRepresentation()+", "
    +annot->at(1)->getRepresentation()+")";
  declarationMap[id] = d;
  //cerr<<id<<endl;
  return d;
}

/**
 * create SgPragma
 */
SgPragma*
TermToRose::createPragma(Sg_File_Info* fi, CompTerm* t) {
  /* retrieve annotation*/
  CompTerm* annot = retrieveAnnotation(t);
  /* create the name*/
  SgName sgnm = *toStringP(annot->at(0));
  /* create the Pragma*/
  SgPragma* p = new SgPragma(strdup(sgnm.str()), fi);
  TERM_ASSERT(t, p != NULL);
  return p;
}


/**
 * Post Creation Initialization of SgDeclarationStatement
 * */
void
TermToRose::pciDeclarationStatement(SgDeclarationStatement* s,Term* t) {
  /* check wether t is a CompTerm*/
  CompTerm* atts = isCompTerm(t);
  TERM_ASSERT(t, atts != NULL);
  TERM_ASSERT(t, s != NULL);
  ARITY_ASSERT(atts, 5);
  /* set flags (subterms are ints, implicit cast to bool)*/
  s->set_nameOnly(toInt(atts->at(0)));
  s->set_forward(toInt(atts->at(1)));
  s->set_externBrace(toInt(atts->at(2)));
  s->set_skipElaborateType(toInt(atts->at(3)));
  //s->set_need_name_qualifier(toInt(atts->at(4)));
}

/**
 * the unparser wants a parent scope for every declaration
 * for dummy declarations we have to fake it.
 */
void
TermToRose::fakeParentScope(SgDeclarationStatement* s) {
  //nothing to do if there is already a parent scope
  ROSE_ASSERT(false && "deprecated function");
  // if(s->get_parent()) return;

  // debug("faking scope");
  // SgGlobal* dummy = new SgGlobal(FI);
  // TERM_ASSERT(t, dummy != NULL);
  // dummy->set_endOfConstruct(FI);
  // // 7.2.2008 ROSE 0.9.0b (Adrian)
  // addSymbol(dummy, s);


  // s->set_parent(dummy);
  // s->set_scope(dummy);
  // TERM_ASSERT(t, s->get_parent());
  // TERM_ASSERT(t, s->get_scope());
}

/**
 * the unparser now wants a symbol table entry, too
 */
void
TermToRose::addSymbol(SgScopeStatement* scope, SgDeclarationStatement* s) {
  if (scope->get_symbol_table() == NULL) {
    cerr<<"OUCH!!"<<endl;
    scope->set_symbol_table(new SgSymbolTable());
  }

  {
    SgFunctionDeclaration *decl = isSgFunctionDeclaration(s);
    if (decl) scope->insert_symbol(decl->get_name(), new SgFunctionSymbol(decl));
  }
  {
    SgClassDeclaration *decl = isSgClassDeclaration(s);
    if (decl) scope->insert_symbol(decl->get_name(), new SgClassSymbol(decl));
  }
}

/**
 * if the declaration refers to a variable, store its symbol in the scope's
 * symbol table; do nothing otherwise
 */
void
TermToRose::storeVariableSymbolFromDeclaration(SgScopeStatement *scope,
                                               SgDeclarationStatement *decl) {
  if (SgVariableDeclaration *varDecl = isSgVariableDeclaration(decl)) {
    assert(!varDecl->get_variables().empty());
    SgInitializedName *init_name = varDecl->get_variables().front();
    assert(init_name != NULL);
    SgVariableSymbol *varSym = createVariableSymbol(init_name);
    assert(varSym != NULL);
    scope->insert_symbol(varSym->get_name(), varSym);
  }
}

/**
 * create std::string* from Atom*
 * including downcast from Term*.
 * If both casts fail, an assertion will fail;
 */
std::string*
TermToRose::toStringP(Term* t) {
  if(Atom* a =isAtom(t)) {
    TERM_ASSERT(t, a != NULL);
    return new string(a->getName());
  }
}

/**
 * create int from Int*
 * including downcast from Term*
 * If cast fails, an assertion will fail
 */
int
TermToRose::toInt(Term* t) {
  Int* i = isInt(t);
  TERM_ASSERT(t, i != NULL);
  return i->getValue();
}

/**
 * create SgDeleteExp
 */
SgDeleteExp*
TermToRose::createDeleteExp(Sg_File_Info* fi, SgNode* child1, CompTerm* t) {
  // get annotation
  CompTerm* annot = retrieveAnnotation(t);
  TERM_ASSERT(t, annot != NULL);
  // cast child fitting constructor
  SgExpression* e = isSgExpression(child1);
  TERM_ASSERT(t, e != NULL);
  // get "flags" Flag
  bool is_array = createFlag(annot->at(0));
  bool need_g = createFlag(annot->at(1));
  // create, test, return
  SgDeleteExp* del = new SgDeleteExp(fi,e,is_array,need_g);
  TERM_ASSERT(t, del != NULL);
  return del;
}

/**
 * create SgExprListExp
 */
SgExprListExp*
TermToRose::createExprListExp(Sg_File_Info* fi, std::deque<SgNode*>* succs) {
  /* just create SgExprListExp* and append expressions*/
  debug("SgExprListExp");
  SgExprListExp* e = new SgExprListExp(fi);
  ROSE_ASSERT(e != NULL);
  deque<SgNode*>::iterator it = succs->begin();
  while (it != succs->end()) {
    EXPECT_NODE(SgExpression*, ex, *it);
    e->append_expression(ex);
    it++;
  }
  return e;
}
/**
 * create SgRefExp*
 */
SgRefExp*
TermToRose::createRefExp(Sg_File_Info* fi, CompTerm* t) {
  /* retrieve type from annotation*/
  CompTerm* annot = retrieveAnnotation(t);
  TERM_ASSERT(t, annot != NULL);
  SgType* tpe = createType(annot->at(0));
  TERM_ASSERT(t, tpe != NULL);
  SgRefExp* re = new SgRefExp(fi,tpe);
  TERM_ASSERT(t, re != NULL);
  return re;
}

/**
 * create SgVarArgOp
 * */
SgVarArgOp*
TermToRose::createVarArgOp(Sg_File_Info* fi, SgNode* child1,CompTerm* t) {
  /* arg is supposed to be an expression*/
  SgExpression* c1 = isSgExpression(child1);
  TERM_ASSERT(t, c1 != NULL);
  /* retrieve type from annotation*/
  CompTerm* annot = retrieveAnnotation(t);
  TERM_ASSERT(t, annot != NULL);
  SgType* tpe = createType(annot->at(0));
  TERM_ASSERT(t, tpe != NULL);
  SgVarArgOp* o = new SgVarArgOp(fi,c1,tpe);
  return o;
}

/**
 * create SgVarArgEndOp
 * */
SgVarArgEndOp*
TermToRose::createVarArgEndOp(Sg_File_Info* fi, SgNode* child1,CompTerm* t) {
  /* arg is supposed to be an expression*/
  SgExpression* c1 = isSgExpression(child1);
  TERM_ASSERT(t, c1 != NULL);
  /* retrieve type from annotation*/
  CompTerm* annot = retrieveAnnotation(t);
  TERM_ASSERT(t, annot != NULL);
  SgType* tpe = createType(annot->at(0));
  TERM_ASSERT(t, tpe != NULL);
  SgVarArgEndOp* o = new SgVarArgEndOp(fi,c1,tpe);
  return o;
}
/**
 * create SgVarArgStartOneOperandOp
 * */
SgVarArgStartOneOperandOp*
TermToRose::createVarArgStartOneOperandOp(Sg_File_Info* fi, SgNode* child1,CompTerm* t) {
  /* arg is supposed to be an expression*/
  SgExpression* c1 = isSgExpression(child1);
  TERM_ASSERT(t, c1 != NULL);
  /* retrieve type from annotation*/
  CompTerm* annot = retrieveAnnotation(t);
  TERM_ASSERT(t, annot != NULL);
  SgType* tpe = createType(annot->at(0));
  TERM_ASSERT(t, tpe != NULL);
  SgVarArgStartOneOperandOp* o = new SgVarArgStartOneOperandOp(fi,c1,tpe);
  return o;
}
/**
 * create SgVarArgStartOp
 * */
SgVarArgStartOp*
TermToRose::createVarArgStartOp(Sg_File_Info* fi, SgNode* child1,SgNode* child2,CompTerm* t) {
  /* args are supposed to be expressions*/
  SgExpression* c1 = isSgExpression(child1);
  TERM_ASSERT(t, c1 != NULL);
  SgExpression* c2 = isSgExpression(child2);
  TERM_ASSERT(t, c2 != NULL);
  /* retrieve type from annotation*/
  CompTerm* annot = retrieveAnnotation(t);
  TERM_ASSERT(t, annot != NULL);
  SgType* tpe = createType(annot->at(0));
  TERM_ASSERT(t, tpe != NULL);
  SgVarArgStartOp* o = new SgVarArgStartOp(fi,c1,c2,tpe);
  return o;
}

/**
 * create SgVarArgCopyOp
 * */
SgVarArgCopyOp*
TermToRose::createVarArgCopyOp(Sg_File_Info* fi, SgNode* child1,SgNode* child2,CompTerm* t) {
  /* args are supposed to be expressions*/
  SgExpression* c1 = isSgExpression(child1);
  TERM_ASSERT(t, c1 != NULL);
  SgExpression* c2 = isSgExpression(child2);
  TERM_ASSERT(t, c2 != NULL);
  /* retrieve type from annotation*/
  CompTerm* annot = retrieveAnnotation(t);
  TERM_ASSERT(t, annot != NULL);
  SgType* tpe = createType(annot->at(0));
  TERM_ASSERT(t, tpe != NULL);
  SgVarArgCopyOp* o = new SgVarArgCopyOp(fi,c1,c2,tpe);
  return o;
}

/**
 * create SgAccessModifier
 */
SgAccessModifier*
TermToRose::createAccessModifier(Term* t) {
  CompTerm* c = isCompTerm(t);
  TERM_ASSERT(t, c != NULL);
  SgAccessModifier* a = new SgAccessModifier();
  TERM_ASSERT(t, a != NULL);
  a->set_modifier(re.enum_access_modifier_enum[*c->at(0)]);
  return a;
}
/**
 * create SgBaseClassModifier
 */
SgBaseClassModifier*
TermToRose::createBaseClassModifier(Term* t) {
  CompTerm* c = isCompTerm(t);
  TERM_ASSERT(t, c != NULL);
  SgBaseClassModifier* b = new SgBaseClassModifier();
  TERM_ASSERT(t, b != NULL);
  b->set_modifier((SgBaseClassModifier::baseclass_modifier_enum)
    toInt(c->at(0)));

  b->get_accessModifier().set_modifier(re.enum_access_modifier_enum[*c->at(1)]);
  return b;
}
/**
 * create SgFunctionModifier
 */
SgFunctionModifier*
TermToRose::createFunctionModifier(Term* t) {
  CompTerm* c = isCompTerm(t);
  TERM_ASSERT(t, c != NULL);
  //extract bit vector list and create bit vector
  // ( cast done in createBitVector)
  SgBitVector b = *(createBitVector(c->at(0), re.enum_function_modifier_enum));
  SgFunctionModifier* m = new SgFunctionModifier();
  TERM_ASSERT(t, m != NULL);
  m->set_modifierVector(b);
  return m;
}
/**
 * create SgSpecialFunctionModifier
 */
void
TermToRose::setSpecialFunctionModifier(Term* t, SgSpecialFunctionModifier* m) {
  CompTerm* c = isCompTerm(t);
  TERM_ASSERT(t, c != NULL);
  ROSE_ASSERT(m != NULL);
  //extract bit vector list and create bit vector
  // ( cast done in createBitVector)
  SgBitVector b = *(createBitVector(c->at(0),
                                    re.enum_special_function_modifier_enum));
  m->set_modifierVector(b);
}

/**
 * create SgStorageModifier
 */
SgStorageModifier*
TermToRose::createStorageModifier(Term* t) {
  CompTerm* c = isCompTerm(t);
  TERM_ASSERT(t, c != NULL);
  SgStorageModifier* a = new SgStorageModifier();
  TERM_ASSERT(t, a != NULL);
  a->set_modifier(re.enum_storage_modifier_enum[*c->at(0)]);
  return a;
}
/**
 * create SgLinkageModifier
 */
SgLinkageModifier*
TermToRose::createLinkageModifier(Term* t) {
  CompTerm* c = isCompTerm(t);
  TERM_ASSERT(t, c != NULL);
  SgLinkageModifier* a = new SgLinkageModifier();
  TERM_ASSERT(t, a != NULL);
  a->set_modifier((SgLinkageModifier::linkage_modifier_enum) toInt(c->at(0)));
  return a;
}
/**
 * create SgElaboratedTypeModifier
 */
SgElaboratedTypeModifier*
TermToRose::createElaboratedTypeModifier(Term* t) {
  CompTerm* c = isCompTerm(t);
  TERM_ASSERT(t, c != NULL);
  SgElaboratedTypeModifier* a = new SgElaboratedTypeModifier();
  TERM_ASSERT(t, a != NULL);
  a->set_modifier((SgElaboratedTypeModifier::elaborated_type_modifier_enum) toInt(c->at(0)));
  return a;
}

/**
 * create SgConstVolatileModifier
 */
SgConstVolatileModifier*
TermToRose::createConstVolatileModifier(Term* t) {
  CompTerm* c = isCompTerm(t);
  TERM_ASSERT(t, c != NULL);
  SgConstVolatileModifier* a = new SgConstVolatileModifier();
  TERM_ASSERT(t, a != NULL);
  a->set_modifier(re.enum_cv_modifier_enum[*c->at(0)]);
  return a;
}
/**
 * create SgUPC_AccessModifier
 */
SgUPC_AccessModifier*
TermToRose::createUPC_AccessModifier(Term* t) {
  CompTerm* c = isCompTerm(t);
  TERM_ASSERT(t, c != NULL);
  SgUPC_AccessModifier* a = new SgUPC_AccessModifier();
  TERM_ASSERT(t, a != NULL);
  a->set_modifier(re.enum_upc_access_modifier_enum[*c->at(0)]);
  return a;
}

/**
 * create SgTypeModifier
 */
SgTypeModifier*
TermToRose::createTypeModifier(Term* t) {
  /* create modifier*/
  SgTypeModifier* m = new SgTypeModifier();
  TERM_ASSERT(t, m != NULL);
  /* set modifier*/
  setTypeModifier(t,m);
  return m;
}


/**
 * set SgTypeModifier's values
 */
void
TermToRose::setTypeModifier(Term* t, SgTypeModifier* tm) {
  /* cast*/
  CompTerm* c = isCompTerm(t);
  TERM_ASSERT(t, c != NULL);
  TERM_ASSERT(t, tm != NULL);
  /* set bit vector and internal modifiers*/
  SgBitVector b = *(createBitVector(c->at(0), re.enum_type_modifier_enum));
  tm->set_modifierVector(b);
  tm->get_upcModifier().set_modifier( re.enum_upc_access_modifier_enum[*c->at(1)] );
  tm->get_constVolatileModifier().set_modifier( re.enum_cv_modifier_enum[*c->at(2)] );
  tm->get_elaboratedTypeModifier().set_modifier( re.enum_elaborated_type_modifier_enum[*c->at(3)] );
}

/**
 * create SgDeclarationModifier
 */
SgDeclarationModifier*
TermToRose::createDeclarationModifier(Term* t) {
  SgDeclarationModifier* d = new SgDeclarationModifier();
  TERM_ASSERT(t, d != NULL);
  /* set values*/
  setDeclarationModifier(t,d);
  return d;
}

/**
 * set SgDeclarationModifier's values
 */
void
TermToRose::setDeclarationModifier(Term* t, SgDeclarationModifier* d) {
  debug("setting modifier");
  TERM_ASSERT(t, d != NULL);
  /* cast*/
  CompTerm* c = isCompTerm(t);
  TERM_ASSERT(t, c != NULL);
  /* create and set bit vector*/
  SgBitVector b = *(createBitVector(c->at(0), re.enum_declaration_modifier_enum));
  d->set_modifierVector(b);
  /* set type modifier values*/
  setTypeModifier(c->at(1),&(d->get_typeModifier()));
  /* set access modifier value*/
  d->get_accessModifier().set_modifier(re.enum_access_modifier_enum[*c->at(2)]);
  d->get_storageModifier().set_modifier(re.enum_storage_modifier_enum[*c->at(3)]);
}

/**
 * create SgAggregateInitializer
 */
SgAggregateInitializer*
TermToRose::createAggregateInitializer(Sg_File_Info* fi,SgNode* child1,CompTerm* t) {
  //Child must be a SgExprListExp
  SgExprListExp* e = isSgExprListExp(child1);
  TERM_ASSERT(t, e != NULL);
  // create node
  SgAggregateInitializer* i = new SgAggregateInitializer(fi,e);
  TERM_ASSERT(t, i != NULL);
  return i;
}


/**
 * create dummy SgFunctionDeclaration
 * Use this function only if there really is no other way (ie. forward declarations)
 */
SgFunctionDeclaration*
TermToRose::createDummyFunctionDeclaration(std::string* namestr, Term* type_term,
                                           SgProcedureHeaderStatement::subprogram_kind_enum kind) {
  //cerr<<"**WARNING: deprecated function "<<__FUNCTION__<<endl;
  ROSE_ASSERT(namestr != NULL);
  ROSE_ASSERT(type_term != NULL);
  /* create SgName and SgFunctionType from arguments*/
  SgName n = *(namestr);
  EXPECT_NODE(SgFunctionType*, tpe, createType(type_term));

  // create SgFunctionDeclaration
  // We ALWAYS create a SgProcedureHeaderStatement instead of an
  // SgFunctionDeclaration. Fortran expects it, and C/C++ will use
  // only the Funcdecl base class.
  SgProcedureHeaderStatement* d = new SgProcedureHeaderStatement(FI,n,tpe);
  ROSE_ASSERT(d != NULL);
  // cerr<<tpe->get_return_type()->class_name()<< endl;

# if 0 // this does not work because ROSE assumes that all external functions are of type_int
  if (tpe->get_return_type()->variantT() == V_SgTypeVoid)
    if (fortranFunctionTypeMap.find(*namestr) != fortranFunctionTypeMap.end())
      d->set_subprogram_kind(SgProcedureHeaderStatement::e_function_subprogram_kind);
    else 
      d->set_subprogram_kind(SgProcedureHeaderStatement::e_subroutine_subprogram_kind);
  else
    d->set_subprogram_kind(SgProcedureHeaderStatement::e_function_subprogram_kind);
#else
  d->set_subprogram_kind(kind);
#endif

  /* postprocessing to satisfy unparser*/
  d->setForward();
  register_func_decl(namestr->c_str(), d, type_term);
  d->set_parent(dummy_to_please_rose);
  declarationStatementsWithoutScope.push_back(d);
  return d;
}

/**
 * create dummy SgFunctionSymbol
 * Use this function only if there really is no other way (ie. forward declarations)
 */
SgFunctionSymbol*
TermToRose::createDummyFunctionSymbol(std::string* namestr, Term* type_term,     
                                      SgProcedureHeaderStatement::subprogram_kind_enum kind) {
  //cerr<<"**WARNING: deprecated function "<<__FUNCTION__<<endl;
  ROSE_ASSERT(namestr != NULL);
  ROSE_ASSERT(type_term != NULL);
  /* create dummy declaration*/
  SgFunctionDeclaration* decl = createDummyFunctionDeclaration(namestr, type_term, kind);
  ROSE_ASSERT(decl != NULL);
  /* use declaration to create SgFunctionSymbol*/
  SgFunctionSymbol* sym = new SgFunctionSymbol(decl);
  //cerr<<"create2:"<<decl->get_name()<< endl;
  sym->set_parent(new SgSymbolTable());
  return sym;
}

/**
 * create dummy SgMemberFunctionSymbol
 */
SgMemberFunctionSymbol*
TermToRose::createDummyMemberFunctionSymbol(Term* annot_term) {
  /* retrieve representation of member function from annotation*/
  debug("mfs");
  TERM_ASSERT(annot_term, annot_term != NULL);
  CompTerm* annot = isCompTerm(annot_term);
  /* use generic term to rose function for creating a SgNode and try to cast*/
  SgNode* mfunc_uncast = toRose(annot->at(0));
  TERM_ASSERT(annot_term, mfunc_uncast != NULL);
  SgMemberFunctionDeclaration* mfunc =
    isSgMemberFunctionDeclaration(mfunc_uncast);
  TERM_ASSERT(annot_term, mfunc != NULL);
  /*add class scope*/
  CompTerm* scope_term = isCompTerm(annot->at(1));
  /*scope name and type*/
  debug("creating scope for member function declaration for symbol ");
  EXPECT_ATOM(scope_name, scope_term->at(0));
  int scope_type  = re.enum_class_types[*scope_term->at(1)];
  fakeClassScope(scope_name,scope_type,mfunc);
  TERM_ASSERT(annot_term, mfunc->get_class_scope() != NULL);
  /* create symbol */
  SgMemberFunctionSymbol* s = new SgMemberFunctionSymbol(mfunc);
  TERM_ASSERT(annot_term, s != NULL);
  return s;
}


/**
 * create SgFunctionRefExp
 */
SgFunctionRefExp*
TermToRose::createFunctionRefExp(Sg_File_Info* fi, CompTerm* ct) {
  /* extract pointer to string containing the name
   * and a Term* with the type info from annotation*/
  TERM_ASSERT(ct, ct != NULL);
  CompTerm* annot = retrieveAnnotation(ct);
  TERM_ASSERT(ct, annot != NULL);
  ARITY_ASSERT(annot, 4);
  string* s = toStringP(annot->at(0));
  TERM_ASSERT(ct, s != NULL);

  SgFunctionSymbol* sym;
  string id = makeFunctionID(*s, annot->at(1)->getRepresentation());
  SgFunctionDeclaration* decl = NULL;
  if (lookupDecl(&decl, id)) {
    /* get the real symbol */
    sym = new SgFunctionSymbol(decl);
  } else {
    debug("**WARNING: no symbol found for "+id);

    /* create function symbol*/
    debug("symbol");

    sym = createDummyFunctionSymbol(s,annot->at(1), 
                                    re.enum_subprogram_kind_enum[*annot->at(2)]);
  }
  TERM_ASSERT(ct, sym != NULL);

  /* get type from function symbol*/
  SgFunctionType* ft = isSgFunctionType(sym->get_type());
  TERM_ASSERT(ct, ft != NULL);
  /* create SgFunctionRefExp*/
  SgFunctionRefExp* re = new SgFunctionRefExp(fi,sym,ft);
  TERM_ASSERT(ct, re != NULL);
  return re;
}

/**
 * create SgMemberFunctionRefExp
 */
SgMemberFunctionRefExp*
TermToRose::createMemberFunctionRefExp(Sg_File_Info* fi, CompTerm* ct) {
  /* extract pointer to string containing the name
   * and a Term* with the type info from annotation*/
  TERM_ASSERT(ct, ct != NULL);
  CompTerm* annot = retrieveAnnotation(ct);
  ARITY_ASSERT(annot, 5);
  /* create member function symbol*/
  SgMemberFunctionSymbol* sym;
  string id = makeFunctionID(annot->at(0)->getRepresentation(), 
                             annot->at(2)->getRepresentation());
  SgFunctionDeclaration* decl = NULL;
  if (lookupDecl(&decl, id)) {
    /* get the real symbol */
    SgMemberFunctionDeclaration* mdecl = isSgMemberFunctionDeclaration(decl);
    ROSE_ASSERT(mdecl != NULL);
    sym = new SgMemberFunctionSymbol(mdecl);
  } else {
    cerr<<"**WARNING: no symbol found for "<<id<<endl;
    ROSE_ASSERT(false);
    /* create function symbol*/
    debug("symbol");
    sym = createDummyMemberFunctionSymbol(annot->at(2));
  }
  TERM_ASSERT(ct, sym!= NULL);
  /* virtual call?*/
  int vc = toInt(annot->at(1));
  /* create type*/
  SgFunctionType* tpe = isSgFunctionType(sym->get_type());
  TERM_ASSERT(ct, tpe != NULL);
  /* need qualifier?*/
  int nc = toInt(annot->at(3));
  
  SgMemberFunctionRefExp* ref = new SgMemberFunctionRefExp(fi,sym,vc,tpe,nc);
  TERM_ASSERT(ct, ref != NULL);
  return ref;
}

/**
 * create SgNamespaceDefinitionStatement
 */
SgNamespaceDefinitionStatement*
TermToRose::createNamespaceDefinitionStatement(Sg_File_Info* fi, std::deque<SgNode*>* succs) {
  debug("now creating namespace definition");
  /* create definition (declaration is set later)*/
  SgNamespaceDefinitionStatement* d = new SgNamespaceDefinitionStatement(fi,NULL);
  ROSE_ASSERT(d != NULL);
  /* append declarations*/
  deque<SgNode*>::iterator it = succs->begin();
  while(it != succs->end()) {
    EXPECT_NODE(SgDeclarationStatement*, s, *it);
    d->append_declaration(s);
    s->set_parent(d);
    it++;
  }
  return d;
}

/**
 * create SgNamespaceDeclarationStatement
 */
SgNamespaceDeclarationStatement*
TermToRose::createNamespaceDeclarationStatement(Sg_File_Info* fi, SgNode* child1, CompTerm* t) {
  CompTerm* annot = retrieveAnnotation(t);
  TERM_ASSERT(t, annot != NULL);
  SgNamespaceDefinitionStatement* def = isSgNamespaceDefinitionStatement(child1);
  if (def == NULL) {
    debug("namespace definition is NULL");
  }
  SgName n = *(toStringP(annot->at(0)));
  bool unnamed = (bool) toInt(annot->at(1));
  SgNamespaceDeclarationStatement* dec = new SgNamespaceDeclarationStatement(fi,n,def,unnamed);
  TERM_ASSERT(t, dec != NULL);
  if(def != NULL) {
    def->set_namespaceDeclaration(dec);
    createDummyNondefDecl(dec, FI, n, (SgNamespaceDefinitionStatement*)NULL,
                          unnamed);
  } else {
    dec->setForward();
    dec->set_firstNondefiningDeclaration(dec);
  }

  //cerr<<"registering ::"<<n<<" = "<<dec<<endl;
  declarationMap["namespace,::"+n] = dec;
  return dec;
}


/**
 * create SgFunctionCallExp
 */
SgFunctionCallExp*
TermToRose::createFunctionCallExp(Sg_File_Info* fi, SgNode* child1, SgNode* child2, CompTerm* ct) {
  /* cast children*/
  EXPECT_NODE(SgExpression*, re, child1);
  EXPECT_NODE(SgExprListExp*, el, child2);
  /*create return type*/
  CompTerm* annot = retrieveAnnotation(ct);
  ROSE_ASSERT(annot != NULL);
  SgType* rt = createType(annot->at(0));
  ROSE_ASSERT(rt != NULL);
  /* create SgFunctionCallExp*/
  SgFunctionCallExp* fce = new SgFunctionCallExp(fi,re,el,rt);
  ROSE_ASSERT(fce != NULL);
  return fce;
}

/**
 * create SgTryStmt
 */
SgTryStmt*
TermToRose::createTryStmt(Sg_File_Info* fi, SgNode* child1, SgNode* child2, CompTerm* ct) {
  /* first child is a SgStatement*/
  EXPECT_NODE(SgStatement*,b,child1);
  /*second child is a SgCatchStatementSeq*/
  SgCatchStatementSeq* s = isSgCatchStatementSeq(child2);
  /* create try statement*/
  SgTryStmt* t = new SgTryStmt(fi,b);
  /* if catch seq statement exists, set it*/
  if (s != NULL) {
    t->set_catch_statement_seq_root(s);
  }
  return t;

}
/**
 * create SgCatchOptionStmt
 */
SgCatchOptionStmt*
TermToRose::createCatchOptionStmt(Sg_File_Info* fi, SgNode* child1, SgNode* child2, CompTerm* ct) {
  EXPECT_NODE(SgVariableDeclaration*, dec, child1);
  EXPECT_NODE(SgStatement*, bl, child2);
  SgCatchOptionStmt* s = new SgCatchOptionStmt(fi,dec,bl,NULL);
  ROSE_ASSERT(s != NULL);
  return s;
}
/**
 * create SgCatchStatementSeq
 */
SgCatchStatementSeq*
TermToRose::createCatchStatementSeq(Sg_File_Info* fi, std::deque<SgNode*>* succs) {
  SgCatchStatementSeq* seq = new SgCatchStatementSeq(fi);
  ROSE_ASSERT(seq != NULL);
  deque<SgNode*>::iterator it = succs->begin();
  while(it != succs->end()) {
    SgStatement* s = isSgStatement(*it);
    if (s != NULL) {
      seq->append_catch_statement(s);
    }
    it++;
  }
  return seq;
}
/**
 * create a SgThisExp
 */
SgThisExp*
TermToRose::createThisExp(Sg_File_Info* fi, CompTerm* ct) {
  /*the unparser does not use the class name*/
  SgThisExp* t = new SgThisExp(fi,NULL);
  ROSE_ASSERT(t != NULL);
  return t;
}

/**
 * create a SgConstructorInitializer
 */
SgConstructorInitializer*
TermToRose::createConstructorInitializer(Sg_File_Info* fi, SgNode* child1,CompTerm* t) {
  /*retrieve annotation*/
  CompTerm* annot = retrieveAnnotation(t);
  TERM_ASSERT(t, t != NULL);
  /* get class name*/
  string s = *toStringP(annot->at(0));
  /* create a class for unparsing the name*/
  SgMemberFunctionDeclaration* decl = NULL;//createDummyMemberFunctionDeclaration(s,0);
  //TERM_ASSERT(t, decl != NULL);
  /* get expression type */
  SgType* expr_type = createType(annot->at(1));
  TERM_ASSERT(t, expr_type != NULL);
  /* cast the SgExprListExp*/
  SgExprListExp* el = isSgExprListExp(child1);
  /* create constructor initializer, need_name = true*/
  SgConstructorInitializer* ci = new SgConstructorInitializer
    (fi,decl,el,expr_type,
     createFlag(annot->at(2)),
     createFlag(annot->at(3)),
     createFlag(annot->at(4)),
     createFlag(annot->at(5)));
  TERM_ASSERT(t, ci != NULL);
  ci->set_is_explicit_cast(1);
  return ci;
}

/**
 * create a SgPragmaDeclaration
 */
SgPragmaDeclaration*
TermToRose::createPragmaDeclaration(Sg_File_Info* fi, SgNode* child1,CompTerm* t) {
  /*retrieve annotation*/
  CompTerm* annot = retrieveAnnotation(t);
  TERM_ASSERT(t, t != NULL);
  /* cast the SgPragma*/
  SgPragma* p = isSgPragma(child1);
  /* create constructor initializer, need_name = true*/
  SgPragmaDeclaration* pd = new SgPragmaDeclaration(fi,p);
  TERM_ASSERT(t, pd != NULL);
  return pd;
}

/**
 * create a SgNewExp
 */
SgNewExp*
TermToRose::createNewExp(Sg_File_Info* fi,SgNode* child1,SgNode* child2, SgNode* child3,CompTerm* t) {
  /*retrieve annotation*/
  CompTerm* annot = retrieveAnnotation(t);
  TERM_ASSERT(t, annot != NULL);
  /* retrieve type*/
  SgType* tpe = createType(annot->at(0));
  TERM_ASSERT(t, tpe != NULL);
  // get expression list expression
  SgExprListExp* ele = isSgExprListExp(child1);
  // get constructor initializer
  SgConstructorInitializer* ci = isSgConstructorInitializer(child2);
  // get expression
  SgExpression* ex = isSgExpression(child3);
  // create SgNewExp
  SgNewExp* ne = new SgNewExp(fi,tpe,ele,ci,ex,0);
  TERM_ASSERT(t, ne != NULL);
  return ne;
}

/**
 * create a SgConditionalExp
 */
SgConditionalExp*
TermToRose::createConditionalExp(Sg_File_Info* fi,SgNode* child1,SgNode* child2, SgNode* child3,CompTerm* t) {
  /*retrieve annotation*/
  CompTerm* annot = retrieveAnnotation(t);
  TERM_ASSERT(t, annot != NULL);
  /* retrieve type*/
  SgType* tpe = createType(annot->at(0));
  TERM_ASSERT(t, tpe != NULL);
  SgExpression* exp1 = isSgExpression(child1);
  TERM_ASSERT(t, exp1 != NULL);
  SgExpression* exp2 = isSgExpression(child2);
  TERM_ASSERT(t, exp2 != NULL);
  SgExpression* exp3 = isSgExpression(child3);
  TERM_ASSERT(t, exp3 != NULL);

  SgConditionalExp* exp = new SgConditionalExp(fi, exp1, exp2, exp3, tpe);
  TERM_ASSERT(t, exp != NULL);
  return exp;
}


/**
 * create a createProgramHeaderStatement
 */
SgProgramHeaderStatement*
TermToRose::createProgramHeaderStatement(Sg_File_Info* fi,SgNode* child1,SgNode* child2, SgNode* child3,CompTerm* t) {
  debug("function declaration:");
  /* cast parameter list */
  SgFunctionParameterList* par_list = isSgFunctionParameterList(child1);
  /* param list must exist*/
  TERM_ASSERT(t, par_list != NULL);
  /* get annotation*/
  CompTerm* annot = retrieveAnnotation(t);
  /* create type*/
  SgFunctionType* func_type = isSgFunctionType(createType(annot->at(0)));
  TERM_ASSERT(t, func_type != NULL);
  /* get function name*/
  EXPECT_TERM(Atom*, func_name_term, annot->at(1));
  SgName func_name = func_name_term->getName();
  /* create definition*/
  SgFunctionDefinition* func_def = isSgFunctionDefinition(child3);
  SgProgramHeaderStatement* stmt = new SgProgramHeaderStatement(fi, func_name, func_type, func_def);
  TERM_ASSERT(t, stmt != NULL);
  stmt->set_parameterList(par_list);
  setDeclarationModifier(annot->at(2),&(stmt->get_declarationModifier()));

  register_func_decl(func_name, stmt, annot);

  return stmt;
}

/**
 * create SgImplicitStatement
 */
SgImplicitStatement*
TermToRose::createImplicitStatement(Sg_File_Info* fi, CompTerm* t) {
  /* retrieve annotation */
  CompTerm* annot = retrieveAnnotation(t);
  /* create the SgImplicitStatement */
  SgImplicitStatement* s = new SgImplicitStatement(fi, createFlag(annot->at(0)));
  TERM_ASSERT(t, s != NULL);
  s->setForward();
  s->set_firstNondefiningDeclaration(s);
  return s;
}

/**
 * create SgAttributeSpecificationStatement
 */
SgAttributeSpecificationStatement*
TermToRose::createAttributeSpecificationStatement(Sg_File_Info* fi, CompTerm* t) {
  /* retrieve annotation */
  CompTerm* annot = retrieveAnnotation(t);
  /* create the SgAttributeSpecificationStatement */
  SgAttributeSpecificationStatement* ass = 
    new SgAttributeSpecificationStatement(fi);
  TERM_ASSERT(t, ass != NULL);
  ass->set_attribute_kind( re.enum_attribute_spec_enum[*annot->at(0)]);
  ass->set_parameter_list( isSgExprListExp(toRose(annot->at(1))) );
  ass->set_bind_list(      isSgExprListExp(toRose(annot->at(2))) );
  return ass;
}


/**
 * create SgCommonBlockObject
 */
SgCommonBlockObject*
TermToRose::createCommonBlockObject(Sg_File_Info* fi, SgNode* child, CompTerm* t) {
  /* retrieve annotation */
  CompTerm* annot = retrieveAnnotation(t);
  /* create the SgCommonBlockObject */
  SgExprListExp* le = isSgExprListExp(child);
  ROSE_ASSERT(le);
  SgCommonBlockObject* cbo = new SgCommonBlockObject(fi);
  TERM_ASSERT(t, cbo != NULL);
  EXPECT_ATOM(block_name, annot->at(0));
  cbo->set_block_name(block_name);
  cbo->set_variable_reference_list(le);
  return cbo;
}

/**
 * create SgCommonBlock
 */
SgCommonBlock*
TermToRose::createCommonBlock(Sg_File_Info* fi, std::deque<SgNode*>* succs)
{
  /* create the SgCommonBlock */
  SgCommonBlock* cb = new SgCommonBlock(fi);
  ROSE_ASSERT(cb);
  SgCommonBlockObjectPtrList& l = cb->get_block_list();

  deque<SgNode*>::iterator it = succs->begin();
  while(it != succs->end()) {
    if (*it != NULL) {
      EXPECT_NODE(SgStatement*, stmt, *it);
      SgCommonBlockObject* cbo = isSgCommonBlockObject(*it);
      ROSE_ASSERT(cbo);
      l.push_back(cbo);
      cbo->set_parent(cb);
    }
    it++;
  }
  return cb;
}

/**
 * create SgFortranIncludeLine
 */
SgFortranIncludeLine*
TermToRose::createFortranIncludeLine(Sg_File_Info* fi, CompTerm* t) {
  /* retrieve annotation */
  CompTerm* annot = retrieveAnnotation(t);
  /* create the SgFortranIncludeLine */
  SgFortranIncludeLine* fil = new SgFortranIncludeLine(fi);
  EXPECT_ATOM(filename, annot->at(0));
  fil->set_filename(filename);
  return fil;
}

/**
 * create SgAsteriskShapeExp
 */
SgAsteriskShapeExp*
TermToRose::createAsteriskShapeExp(Sg_File_Info* fi, CompTerm* t) {
  //CompTerm* annot = retrieveAnnotation(t);
  SgAsteriskShapeExp* n = new SgAsteriskShapeExp(fi);
  //n->set_type(createType(annot->at(0)));
  return n;
}

/**
 * create SgWriteStatement
 */
SgWriteStatement*
TermToRose::createWriteStatement(Sg_File_Info* fi, std::deque<SgNode*>* succs, CompTerm* t) {
  /* retrieve annotation */
  CompTerm* annot = retrieveAnnotation(t);
  ARITY_ASSERT(annot, 10);
  /* create the SgWriteStatement */
  SgWriteStatement* n = new SgWriteStatement(fi);
  // from IOStatement
  assert(succs->size() > 0);
  n->set_io_stmt_list(  isSgExprListExp(succs->at(0)) ); //FIXME: createExprListExp(fi, succs ));
  n->set_unit(          isSgExpression(toRose(annot->at(0))) );
  n->set_iostat(        isSgExpression(toRose(annot->at(1))) );
  n->set_err(           isSgExpression(toRose(annot->at(2))) );
  n->set_iomsg(         isSgExpression(toRose(annot->at(3))) );
  // from WriteStatement
  n->set_format(        isSgExpression(toRose(annot->at(4))) );
  n->set_rec(           isSgExpression(toRose(annot->at(5))) );
  n->set_namelist(      isSgExpression(toRose(annot->at(6))) );
  n->set_advance(       isSgExpression(toRose(annot->at(7))) );
  n->set_asynchronous(  isSgExpression(toRose(annot->at(8))) );

  n->set_io_statement(SgIOStatement::e_write);
  return n;
}

/**
 * create SgPrintStatement
 */
SgPrintStatement*
TermToRose::createPrintStatement(Sg_File_Info* fi, std::deque<SgNode*>* succs, CompTerm* t) {
  /* retrieve annotation */
  CompTerm* annot = retrieveAnnotation(t);
  ARITY_ASSERT(annot, 6);
  /* create the SgPrintStatement */
  SgPrintStatement* n = new SgPrintStatement(fi);
  // from IOStatement
  assert(succs->size() > 0);
  n->set_io_stmt_list(  isSgExprListExp(succs->at(0)) ); //FIXME: createExprListExp(fi, succs ));
  n->set_unit(          isSgExpression(toRose(annot->at(0))) );
  n->set_iostat(        isSgExpression(toRose(annot->at(1))) );
  n->set_err(           isSgExpression(toRose(annot->at(2))) );
  n->set_iomsg(         isSgExpression(toRose(annot->at(3))) );
  // from PrintStatement
  n->set_format(        isSgExpression(toRose(annot->at(4))) );

  n->set_io_statement(SgIOStatement::e_print);
  return n;
}


/**
 * create SgFormatItem
 */
SgFormatItem*
TermToRose::createFormatItem(Sg_File_Info* fi, CompTerm* t) {
  CompTerm* annot = retrieveAnnotation(t);
  SgFormatItem* n = new SgFormatItem();

  EXPECT_TERM(List*, items, annot->at(2));

  SgFormatItemList* sgitems = new SgFormatItemList();
  for (int i = 0; i < items->getArity(); ++i) {
    sgitems->get_format_item_list().push_back(isSgFormatItem(toRose(items->at(i))));
  }

  EXPECT_TERM(Int*, rs, annot->at(0));
  n->set_repeat_specification( rs->getValue() );
  n->set_data( isSgExpression(toRose(annot->at(1))) );
  n->set_format_item_list(sgitems);
  return n;
}


/**
 * create SgFormatStatement
 */
SgFormatStatement*
TermToRose::createFormatStatement(Sg_File_Info* fi, CompTerm* t) {
  CompTerm* annot = retrieveAnnotation(t);
  SgFormatStatement* n = new SgFormatStatement(fi);

  EXPECT_TERM(List*, items, annot->at(0));
  SgFormatItemList* sgitems = new SgFormatItemList();
  deque<Term*>* succs = items->getSuccs();
  deque<Term*>::iterator it;
  for (it = succs->begin(); it != succs->end(); ++it) {
    sgitems->get_format_item_list().push_back(isSgFormatItem(toRose(*it)));
  }

  n->set_format_item_list(sgitems);

  EXPECT_ATOM(label, annot->at(1));
  n->set_binding_label(label);

  SgLabelRefExp* label_refexp = isSgLabelRefExp(toRose(annot->at(2)));
  if (label_refexp) {
    label_refexp->get_symbol()->set_fortran_statement(n);
    label_refexp->get_symbol()->set_parent(n);
  }
  n->set_numeric_label(label_refexp);
  return n;
}

/**
 * create SgLabelRefExp
 */
SgLabelRefExp*
TermToRose::createLabelRefExp(Sg_File_Info* fi, CompTerm* t) {
  CompTerm* annot = retrieveAnnotation(t);
  SgLabelRefExp* n = new SgLabelRefExp(fi, isSgLabelSymbol(toRose(annot->at(0))));
  return n;
}

/**
 * create SgLabelSymbol
 */
SgLabelSymbol*
TermToRose::createLabelSymbol(Sg_File_Info* fi, SgNode* child1, CompTerm* t) {
  CompTerm* annot = retrieveAnnotation(t);
  SgLabelSymbol* n = new SgLabelSymbol(isSgLabelStatement(child1));

  EXPECT_TERM(Int*, val, annot->at(0));
  n->set_numeric_label_value(val->getValue());
  n->set_label_type(re.enum_label_type_enum[*annot->at(1)]);
  return n;
}

/**
 * create SgAsmOp
 */
SgAsmOp*
TermToRose::createAsmOp(Sg_File_Info* fi, SgNode* child1, CompTerm* t) {
  CompTerm* annot = retrieveAnnotation(t);
  EXPECT_TERM(Int*, val, annot->at(1));
  SgAsmOp* op = 
    new SgAsmOp(fi, 
		re.enum_asm_operand_constraint_enum[*annot->at(0)],
		(SgAsmOp::asm_operand_modifier_enum)val->getValue(),
		isSgExpression(child1));

  op->set_recordRawAsmOperandDescriptions(createFlag(annot->at(2)));
  op->set_isOutputOperand(createFlag(annot->at(3)));
  EXPECT_ATOM(cs, annot->at(4));
  op->set_constraintString(cs);
  EXPECT_ATOM(name, annot->at(5));
  op->set_name(name);
  return op;
}

/**
 * create SgAsmStmt
 */
SgAsmStmt*
TermToRose::createAsmStmt(Sg_File_Info* fi, std::deque<SgNode*>* succs, CompTerm *t) {
  SgAsmStmt* stmt = new SgAsmStmt(fi);

  SgExpressionPtrList &el = stmt->get_operands();
  for (deque<SgNode*>::iterator it = succs->begin(); it != succs->end(); ++it) {
    SgExpression* e = isSgExpression(*it);
    ROSE_ASSERT(e != NULL);
    el.push_back(e);
    e->set_parent(stmt);
  }

  CompTerm* annot = retrieveAnnotation(t);
  EXPECT_ATOM(code, annot->at(0));
  stmt->set_assemblyCode(code);
  stmt->set_useGnuExtendedFormat(createFlag(annot->at(1)));
  stmt->set_isVolatile(createFlag(annot->at(2)));
  return stmt;
}

/**
 * create SgAsmx86Instruction
 */
SgAsmx86Instruction*
TermToRose::createAsmx86Instruction(std::deque<SgNode*>* succs, CompTerm *t) {
  SgAsmx86Instruction* i = new SgAsmx86Instruction();

  /*append successors*/
  deque<SgNode*>::iterator it = succs->begin();
  while(it != succs->end()) {
    if((*it) != NULL) {
      //i->append_sources(isSgAsmStatement(*it));
      (*it)->set_parent(i);
    }
    it++;
  }

  CompTerm* annot = retrieveAnnotation(t);
         i->set_kind(re.enum_X86InstructionKind[*annot->at(0)]);
     i->set_baseSize(re.enum_X86InstructionSize[*annot->at(1)]);
  i->set_operandSize(re.enum_X86InstructionSize[*annot->at(2)]);
  i->set_addressSize(re.enum_X86InstructionSize[*annot->at(3)]);
  i->set_lockPrefix(createFlag(annot->at(4)));
  i->set_repeatPrefix(re.enum_X86RepeatPrefix[*annot->at(5)]);
  i->set_branchPrediction(re.enum_X86BranchPrediction[*annot->at(6)]);
  i->set_segmentOverride(re.enum_X86SegmentRegister[*annot->at(7)]);

  EXPECT_ATOM(mn, annot->at(8));
  i->set_mnemonic(mn);

  EXPECT_ATOM(comment, annot->at(9));
  i->set_comment(comment);
  return i;
}
