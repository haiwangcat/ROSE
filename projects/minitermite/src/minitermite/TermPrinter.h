/* -*- C++ -*-
   Copyright 2006 Christoph Bonitz <christoph.bonitz@gmail.com>
   2007-2009 Adrian Prantl <adrian@complang.tuwien.ac.at>
   2009 Gergö Barany <gergo@complang.tuwien.ac.at>
*/
#ifndef PROLOGTRAVERSAL_H_
#define  PROLOGTRAVERSAL_H_
#include <iostream>
#include <string>
#include <time.h>
#include <ctype.h>
#include <cstdio>
#include <cstdlib>
#include <rose.h>
#include "minitermite.h"
#include <climits>

// GB (2009-02-25): Want to build with ICFG support unless explicitly told
// (by c2term.C) not to.
#ifndef HAVE_SATIRE_ICFG
#  define HAVE_SATIRE_ICFG 1
#endif

#if HAVE_SATIRE_ICFG
#  include <cfg_support.h>
#  include <satire_program_representation.h>
#endif

#if HAVE_PAG && !defined(DO_NOT_USE_DFIPRINTER)
#  include <config.h>
// GB (2008-10-03): The declaration (and definition) of PagDfiTextPrinter is
// now provided in a special header.
#  include <PagDfiTextPrinter.h>
#endif

#include "RoseToTerm.h"
#include <sstream>
#include <iostream>

#if HAVE_ASL
#  include <aslanalysis.h>
#  include <aslattribute.h>
#endif

/* See main.C-template and toProlog.C for examples how to use this */

/// Class implementing a traversal to create a PROLOG term
// representing a ROSE-IR
//
// Additionally, this template can be instatiated with the DFI_STORE type
// in the case the Terms should contain PAG analysis results.
// This feature is only enabled if Termite was configured with PAG support
// (i.e., HAVE_PAG is defined).
template<typename DFI_STORE_TYPE>
class TermPrinter: public AstBottomUpProcessing<term::Term*>
{
public:
  TermPrinter(term::TermFactory& termFactory_ = term::STLTermFactory(),
              DFI_STORE_TYPE analysis_info = 0
              , std::string analysisname_ = ""
#if HAVE_SATIRE_ICFG
              , CFG *cfg = 0
              , SATIrE::Program *program = 0
#endif
              )
    :
    termFactory(termFactory_),
    termConv(termFactory_),
#if HAVE_PAG && !defined(DO_NOT_USE_DFIPRINTER)
    pagDfiTextPrinter(analysis_info),
#endif
    analysisname(analysisname_ != "" ? analysisname_ : "unknown")
#if HAVE_SATIRE_ICFG
    , cfg(cfg)
    , program(program)
#else
    , cfg(NULL)
    , program(NULL)
#endif
  {
#if ROSE_HAVE_SWI_PROLOG
    int argc;
    char **argv;
    assert(PL_is_initialised(&argc, &argv)
           && "please run init_termite(argc, argv) first.");
#endif
    withPagAnalysisResults = (analysis_info != 0);
    rootTerm = termFactory.makeAtom("error");
  }


  /** return the term*/
  term::Term* getTerm() {return rootTerm;};

protected:
  /** reimplemented from AstBottomUpProcessing*/
  virtual term::Term*
  evaluateSynthesizedAttribute(SgNode* astNode, SynthesizedAttributesList synList);
  /** reimplemented from AstBottomUpProcessing*/
  virtual term::Term*
  defaultSynthesizedAttribute() {return termFactory.makeAtom("null");};

  bool withPagAnalysisResults;
#if HAVE_PAG && !defined(DO_NOT_USE_DFIPRINTER)
  PagDfiTextPrinter<DFI_STORE_TYPE> pagDfiTextPrinter;
#endif

private:
  /** should generate list instead of tuple? */
  bool isContainer(SgNode* astNode);
  void padArity(SynthesizedAttributesList synList, int arity);
  void ensureArity(SgNode* astNode, SynthesizedAttributesList synList);
  /** return the number of successors */
  int getArity(SgNode* astNode);

  /** create leaf nodes*/
  term::CompTerm* leafTerm(SgNode* astNode, SynthesizedAttributesList synList,
			   term::Term* specific, term::Term* ar, term::Term* fiTerm);
  /** create unary nodes*/
  term::CompTerm* unaryTerm(SgNode* astNode, SynthesizedAttributesList synList,
			    term::Term* specific, term::Term* ar, term::Term* fiTerm);
  /** create binary nodes*/
  term::CompTerm* binaryTerm(SgNode* astNode, SynthesizedAttributesList synList,
			     term::Term* specific, term::Term* ar, term::Term* fiTerm);
  /** create ternary nodes*/
  term::CompTerm* ternaryTerm(SgNode* astNode, SynthesizedAttributesList synList,
			      term::Term* specific, term::Term* ar, term::Term* fiTerm);
  /** create quaternary nodes*/
  term::CompTerm* quaternaryTerm(SgNode* astNode, SynthesizedAttributesList synList,
				 term::Term* specific, term::Term* ar, term::Term* fiTerm);
  /** create list nodes*/
  term::CompTerm* listTerm(SgNode* astNode, SynthesizedAttributesList synList,
			   term::Term* specific, term::Term* ar, term::Term* fiTerm);

  /** the current term */
  term::Term* rootTerm;

  /** the converter */
  RoseToTerm termConv;
  term::TermFactory& termFactory;

  /** the name of the analysis, if available */
  std::string analysisname;

#if HAVE_SATIRE_ICFG
  /** the CFG */
  CFG *cfg;
  SATIrE::Program *program;

  /** create integer term with variable ID or "null" atom */
  term::Term* varidTerm(SgVariableSymbol *symbol);
  /** create a term containing the procnum for the given procedure, when
   * looked up in a certain file (the file matters for static functions);
   * and a term containing a pair Entry-Exit of ICFG labels; plus a helper
   * function */
  term::CompTerm* functionIdAnnotation(std::string funcname, SgFile *file);
  term::CompTerm* functionEntryExitAnnotation(std::string funcname,
					      SgFile *file);
  Procedure* procedureNode(std::string funcname, SgFile *file);
#else
  /** dummy member */
  void *cfg;
  void *program;
#endif

  term::List* getAnalysisResultList(SgStatement* stmt);
  term::CompTerm* pagToProlog(std::string name, std::string analysis,
			      std::string dfi);
};

typedef TermPrinter<void*> BasicTermPrinter;

/***********************************************************************
 * TermPrinter (Implementation)
 ***********************************************************************/
/**
 *  AP 2.2.2008 new rose (hotel) compatibility
 *  GB (2008-12-11): AstTests::numSuccContainers does not report container
 *  nodes that happen to be empty at the moment. This is a clear design
 *  problem in the way it is implemented (in theory, a correct
 *  implementation could be generated for each node by using ROSETTA). This
 *  is really problematic for empty SgFunctionParameterLists! However,
 *  other than patching ROSE, which is not really an option, I can't see
 *  how to implement this correctly. In any case, I added the parameter
 *  lists as a special case here, and this should be done for any other
 *  maybe-empty list nodes we stumble upon.
 *  FIXME: Revisit this issue, and think of a real fix!
 *  GB (2009-JAN): Added SgBasicBlock and SgExprListExp as maybe-emtpy
 *  containers. Added SgForInitStatement.
 */
template<typename DFI_STORE_TYPE>
bool
TermPrinter<DFI_STORE_TYPE>::isContainer(SgNode* astNode)
{
  return AstTests::numSuccContainers(astNode) ||
    isSgFunctionParameterList(astNode) ||
    isSgExprListExp(astNode) ||
    isSgBasicBlock(astNode) ||
    isSgForInitStatement(astNode) ||
    isSgClassDefinition(astNode) ||
    isSgVariableDeclaration(astNode);
}

template<typename DFI_STORE_TYPE>
void
TermPrinter<DFI_STORE_TYPE>::padArity(SynthesizedAttributesList synList, int arity)
{
  size_t l = synList.size();
  ROSE_ASSERT(l <= arity);
  while (l < arity) {
    //    std::cerr<< l<<std::endl;
    //    synList.debugDump(std::cerr);
    synList.push(termFactory.makeAtom("null"));
  }
}
/**
 * ensure that certain node types always have as consistent arity,
 * even though they may or may not have children by padding them with
 * extra "null" children
 */
template<typename DFI_STORE_TYPE>
void
TermPrinter<DFI_STORE_TYPE>::ensureArity(SgNode* astNode, SynthesizedAttributesList synList)
{
  switch (astNode->variantT()) {
  case V_SgFunctionDeclaration: padArity(synList, 3); break;
  default: return;
  }
}

template<typename DFI_STORE_TYPE>
int
TermPrinter<DFI_STORE_TYPE>::getArity(SgNode* astNode)
{
  int n = AstTests::numSingleSuccs(astNode);
  switch (astNode->variantT()) {
    /* Since ~2011, ROSE adds additional 'else' children to these
       nodes that do not make sense in C/C++.
       We remove them here. */
  case V_SgWhileStmt:
  case V_SgForStatement:
    // We also don't need the decorator list
  case V_SgClassDeclaration:
    // case V_SgFunctionDeclaration: FIXME: middle arg
    // case V_SgMemberFunctionDeclaration:
    return n - 1;
  default: return n;
  }
}

/**
 * Compute the PROLOG representation of a node using
 * the successors' synthesized attributes.
 *
 * o nodes with a fixed number of at most 4 successors will be
 *   represented by a term in which the successor nodes have fixed
 *   positions
 *
 * o nodes with more successors or a variable # of succ. will be
 *   represented by a term that contains a list of successor nodes.
 */
template<typename DFI_STORE_TYPE>
term::Term* TermPrinter<DFI_STORE_TYPE>::
evaluateSynthesizedAttribute(SgNode* astNode, SynthesizedAttributesList synList) {

  term::Term* t;

#if HAVE_SATIRE_ICFG
  if (cfg == NULL)
    cfg = get_global_cfg();
  assert(cfg != NULL);
  if (program == NULL)
    program = cfg->program;
  assert(program != NULL);
#endif

  /* Backwards-compatability and related stuff */
  if (isSgProject(astNode)) {
    /* Newer versions of Rose wrap SgFiles inside an unnecessary
       SgFileList node */
    term::CompTerm* fileList = dynamic_cast<term::CompTerm*>(synList.at(0));
    if (fileList != NULL && fileList->getName() == "file_list") {
      ROSE_ASSERT (synList.size() == 1);
      synList[0] = fileList->at(0);
    }
  }

  else if (SgCastExp* cst = dynamic_cast<SgCastExp*>(astNode)) {
    // Use the original expression tree instead of what EDG generates for
    // the case  (cast) &foo.member . This has a doubly nested cast!
#if 0
    // Dump the structure of the cast expression.
    std::cerr << "- " << cst->unparseToString() << std::endl;
    std::cerr << "cst";
    SgExpression *p = cst;
    while (p != NULL) {
      std::cerr << " -> " << p->class_name();
      p = (isSgUnaryOp(p) ? isSgUnaryOp(p)->get_operand() : NULL);
    }
    std::cerr << std::endl;
#endif

    SgCastExp *nestedCast = isSgCastExp(cst->get_operand());
    SgCastExp *originalCast = isSgCastExp(cst->get_originalExpressionTree());
    SgAddressOfOp *addressOp = isSgAddressOfOp(
                                               originalCast ? originalCast->get_operand() : NULL);
    if (nestedCast != NULL && addressOp != NULL &&
        isSgDotExp(addressOp->get_operand())) {
#if 0
      std::cerr << "** DEBUG: cst = " << cst->unparseToString() << std::endl
                << "** original: " << (originalCast == NULL ? "NULL"
                                       : originalCast->unparseToString())
                << std::endl;
      std::cerr << "** original type: " << originalCast->class_name()
                << std::endl;
#endif
      //std::cerr << "** DEBUG: replacing\n" << astNode->unparseToString()
      //        << "\n with \n" << original->unparseToString() << std::endl;

      astNode = originalCast;

      // Rebuild the  term for the original expression
      // and substitute as our synthesized attribute
      synList[0] = termConv.traverseSingleNode(originalCast);
    }
  }

  /* See if this node is intended to be unparsed */
  /*  -> decls inserted by EDG will be stripped */
  Sg_File_Info* fi = astNode->get_file_info();
  if (fi == NULL) {
    fi = Sg_File_Info::generateDefaultFileInfoForTransformationNode();
    if (isSgLocatedNode(astNode)) {
      std::cerr << "** WARNING: FileInfo for Node " << astNode->class_name()
                << " \"" << astNode->unparseToString()
                << "\" was not set." << std::endl;
    }
  }

  if (fi->isCompilerGenerated() && isSgBasicBlock(astNode)) {
    /* Adrian 2009/10/27:
       ROSE insists on wrapping loop bodies inside a second SgBasicBlock now.
       We don't need that */
    // GB (2009-11-05): We can't assert his here because it fails sometimes.
    // (Don't know when.) If the condition is true, take the way out;
    // otherwise, continue and maybe risk duplicated basic blocks.
    // assert(synList.size() == 1);
    if (synList.size() == 1) {
      t = synList.at(0);
      return t;
    }
  }

  ensureArity(astNode, synList);

  if (!fi->isFrontendSpecific()) {
    /* add node specific information to the term*/
    term::Term* specific = termConv.getSpecific(astNode);

    /* analysis results */
    term::Term* ar = NULL;

    /* add analysis information to the term*/
    if (SgStatement* n = isSgStatement(astNode)) {
      /* analysis result */
      term::List *results = getAnalysisResultList(n);

      /* function IDs, if appropriate */
#if HAVE_SATIRE_ICFG
      std::string funcname = "";
      SgFunctionDeclaration *d = isSgFunctionDeclaration(astNode);
      if (d != NULL)
        funcname = d->get_name().str();
      if (funcname != "" && cfg != NULL) {
        SgNode *p = d->get_parent();
        while (p != NULL && !isSgFile(p))
          p = p->get_parent();
        results->addFirstElement(functionIdAnnotation(funcname, isSgFile(p)));
        Term* entryExit
          = functionEntryExitAnnotation(funcname, isSgFile(p));
        if (entryExit != NULL) {
          results->addFirstElement(entryExit);
        }
      }
#endif

      ar = termFactory.makeCompTerm("analysis_info", /*1,*/ results);
    } else {
      /* default: empty analysis result */
      term::List *results = termFactory.makeList();

      /* variable IDs, if appropriate */
#if HAVE_SATIRE_ICFG
      SgVariableSymbol *sym = NULL;
      if (SgVarRefExp *v = isSgVarRefExp(astNode))
        sym = program->get_symbol(v);
      if (SgInitializedName *in = isSgInitializedName(astNode)) {
        sym = program->get_symbol(in);
        if (sym == NULL) {
          /* ROSE has NULL symbols for some unused things; for example,
           * argument names in forward function declarations. But also for
           * global variables that are declared more than once (which is
           * totally allowed). Look up this variable in the special little
           * table for global variable IDs; if it's not there, we invent a
           * number for these and hope that nothing breaks. */
          /* GB (2009-11-11): Since we now use SATIrE's own global symbol
           * table, the branch below is probably dead code. */
          CompTerm *varid_annot = NULL;
          SgVariableDeclaration *d = isSgVariableDeclaration(in->get_parent());
          if (d != NULL && isSgGlobal(d->get_parent())
              && !d->get_declarationModifier().get_storageModifier().isStatic()) {
            /* If there is no symbol, ROSE does not give a variable name
             * either. But we can hack one out of the mangled name, where
             * the variable name comes right after the substring
             * "variable_name_". */
            std::string mname = d->get_mangled_name().str();
            const char *key = "variable_name_";
            std::string::size_type pos = mname.find(key);
            if (pos != std::string::npos && cfg != NULL) {
              std::string varname = mname.substr(pos + strlen(key));
              std::map<std::string, unsigned long>::iterator idi;
              idi = cfg->globalvarnames_ids.find(varname);
              if (idi != cfg->globalvarnames_ids.end()) {
                varid_annot = termFactory.makeCompTerm("variable_id", //1,
                                                       termFactory.makeInt(idi->second));
              }
            }
          }
          if (varid_annot == NULL) {
            varid_annot = termFactory.makeCompTerm("variable_id", //1,
                                                   termFactory.makeInt(INT_MAX));
          }
          results->addFirstElement(varid_annot);
        }
      }
      if (sym != NULL) {
        if (cfg != NULL && !cfg->varsyms_ids.empty()) {
          CompTerm *varid_annot = termFactory.makeCompTerm("variable_id", //1,
                                                           varidTerm(sym));
          results->addFirstElement(varid_annot);
        }
      }
#endif

      /* function IDs, if appropriate */
#if HAVE_SATIRE_ICFG
      std::string funcname = "";
      SgFunctionRefExp *f = isSgFunctionRefExp(astNode);
      if (f != NULL)
        funcname = f->get_symbol()->get_name().str();
      if (funcname != "" && cfg != NULL) {
        SgNode *p = f->get_parent();
        while (p != NULL && !isSgFile(p))
          p = p->get_parent();
        results->addFirstElement(functionIdAnnotation(funcname, isSgFile(p)));
      }
#endif

      /* function call sites, if appropriate */
#if HAVE_SATIRE_ICFG
      if (SgFunctionCallExp *fc = isSgFunctionCallExp(astNode)) {
        SgExpression *function = fc->get_function();
        if (cfg != NULL) {
          CallSiteAttribute *csa = (CallSiteAttribute *)
            fc->getAttribute("SATIrE ICFG call block");
          Int *callsite = termFactory.makeInt(csa->bb->id);
          CompTerm *callsite_annot = termFactory.makeCompTerm("call_site", //1,
                                                              callsite);
          results->addFirstElement(callsite_annot);
          /* add information on possible call targets */
          if (!isSgFunctionRefExp(function)) {
            using SATIrE::Analyses::PointsToAnalysis;
            PointsToAnalysis *cspta = cfg->contextSensitivePointsToAnalysis;
            List *callsite_locs = NULL;
#if HAVE_PAG
            /* output context-sensitive callsite-target location mapping;
             * but only for the contexts that are actually relevant for the
             * calling function */
            SgNode *p = fc->get_parent();
            while (p != NULL && !isSgFunctionDeclaration(p))
              p = p->get_parent();
            assert(isSgFunctionDeclaration(p));
            std::string funcname =
              isSgFunctionDeclaration(p)->get_name().str();
            while (p != NULL && !isSgFile(p))
              p = p->get_parent();
            assert(isSgFile(p));
            Procedure *proc = procedureNode(funcname, isSgFile(p));
            if (cspta != NULL) {
              const std::vector<ContextInformation::Context> &ctxs
                = cfg->contextInformation->allContexts();
              std::vector<ContextInformation::Context>::const_iterator ctx;
              for (ctx = ctxs.begin(); ctx != ctxs.end(); ++ctx) {
                if (ctx->procnum != proc->procnum)
                  continue;
                PointsToAnalysis::Location *loc =
                  cspta->expressionLocation(function, *ctx);
                Int *pLocation =
                  termFactory.makeInt(cspta->location_id(cspta->base_location(loc)));
                CompTerm *ccl =
                  termFactory.makeCompTerm("context_location", //2,
                                           ctx->toPrologTerm(),
                                           pLocation);
                if (callsite_locs == NULL)
                  callsite_locs = termFactory.makeList();
                callsite_locs->addFirstElement(ccl);
              }
              PointsToAnalysis::Location *loc =
                cspta->expressionLocation(function);
              Int *pLocation =
                termFactory.makeInt(cspta->location_id(cspta->base_location(loc)));
              if (callsite_locs == NULL)
                callsite_locs = termFactory.makeList();
              callsite_locs->addFirstElement(pLocation);
            }
#else
            PointsToAnalysis *pto = cfg->pointsToAnalysis;
            if (pto != NULL) {
              PointsToAnalysis::Location *loc =
                pto->expressionLocation(function);
              Int *pLocation =
                termFactory.makeInt(pto->location_id(pto->base_location(loc)));
              if (callsite_locs == NULL)
                callsite_locs = termFactory.makeList();
              callsite_locs->addFirstElement(pLocation);
            }
#endif
            if (callsite_locs != NULL) {
              CompTerm *callsite_locations =
                termFactory.makeCompTerm("callsite_locations", //2,
                                         callsite,
                                         callsite_locs);
              results->addFirstElement(callsite_locations);
            }
          }
        }
        if (function->attributeExists(ASL_ATTRIBUTE_ID)) {
          ASLAttribute *attribute =
            (ASLAttribute *) function->getAttribute(ASL_ATTRIBUTE_ID);
          std::string str = attribute->toString();
          CompTerm *asl_annot = termFactory.makeCompTerm("asl_annot", //1,
                                                         termFactory.makeAtom(str));
          results->addFirstElement(asl_annot);
        }
      }
#endif

      /* call strings, if appropriate */
#if HAVE_SATIRE_ICFG && HAVE_PAG
      if (isSgProject(astNode)) {
        if (cfg != NULL && cfg->contextInformation != NULL) {
          Term *callStrings = cfg->contextInformation->toPrologTerm();
          CompTerm *callStringInfo
            = termFactory.makeCompTerm("callstringinfo", /*1,*/ callStrings);
          results->addFirstElement(callStringInfo);
        }
      }
#endif

      /* points-to information, if appropriate */
#if HAVE_SATIRE_ICFG && HAVE_PAG
      if (isSgProject(astNode) && cfg != NULL
          && cfg->contextSensitivePointsToAnalysis != NULL) {
        using SATIrE::Analyses::PointsToAnalysis;
        // PointsToAnalysis *merged_pto = cfg->pointsToAnalysis;
        PointsToAnalysis *pto = cfg->contextSensitivePointsToAnalysis;

        /* mapping: locations to their contents; this automagically defines
         * the set of all locations */
        List *locations = termFactory.makeList();
        std::vector<PointsToAnalysis::Location *> locs;
        pto->interesting_locations(locs);
        std::vector<PointsToAnalysis::Location *>::const_iterator loc;
        for (loc = locs.begin(); loc != locs.end(); ++loc) {
          List *varids = termFactory.makeList();
          List *funcs = termFactory.makeList();
          const std::list<SgSymbol *> &syms = pto->location_symbols(*loc);
          std::list<SgSymbol *>::const_iterator s;
          for (s = syms.begin(); s != syms.end(); ++s) {
            if (SgVariableSymbol *varsym = isSgVariableSymbol(*s)) {
              varids->addFirstElement(varidTerm(varsym));
            } else if (SgFunctionSymbol *funsym = isSgFunctionSymbol(*s)) {
              std::string funcname = funsym->get_name().str();
              Sg_File_Info* fi = funsym->get_declaration()->get_file_info();
              assert(fi != NULL);
              SgNode* p = funsym->get_declaration();
              while (p != NULL && !isSgFile(p))
                p = p->get_parent();
              SgFile* file = isSgFile(p);
              assert(file != NULL);
              Procedure* proc = procedureNode(funcname, file);
              // If a Procedure node for this function exists, i.e., we have a
              // definition for it, then mangle its function number into its
              // name for unique display.
              if (proc != NULL) {
                std::stringstream name;
                name << funcname << "::" << proc->procnum;
                funcname = name.str();
              }
              funcs->addFirstElement(termFactory.makeAtom(funcname));
            } else { // {{{ error handling
              std::cerr
                << "* unexpected symbol type in points-to location: "
                << (*s)->class_name()
                << " <" << (*s)->get_name().str() << ">"
                << std::endl;
              std::abort(); // }}}
            }
          }
          CompTerm *loct
            = termFactory.makeCompTerm("location_varids_funcs", //3,
                                       termFactory.makeInt(pto->location_id(*loc)),
                                       varids,
                                       funcs);
          locations->addFirstElement(loct);
        }
        CompTerm *locationInfo = termFactory.makeCompTerm("locations", //1,
                                                          locations);
        results->addFirstElement(locationInfo);

        /* mapping: variables to locations in each context */
        List *vlocs = termFactory.makeList();
        std::map<SgVariableSymbol *, unsigned long>::const_iterator v;
        for (v = cfg->varsyms_ids.begin(); v != cfg->varsyms_ids.end(); ++v) {
          const std::vector<ContextInformation::Context> &ctxs
            = cfg->contextInformation->allContexts();
          std::vector<ContextInformation::Context>::const_iterator ctx;
          for (ctx = ctxs.begin(); ctx != ctxs.end(); ++ctx) {
            if (pto->symbol_has_location(v->first, *ctx)) {
              Int *pLocation = termFactory.makeInt(
                                                   pto->location_id(pto->symbol_location(v->first, *ctx)));
              CompTerm *vcl
                = termFactory.makeCompTerm("varid_context_location", //3,
                                           varidTerm(v->first),
                                           ctx->toPrologTerm(),
                                           pLocation);
              vlocs->addFirstElement(vcl);
            }
          }
        }
        CompTerm *variable_locations
          = termFactory.makeCompTerm("variable_locations", /*1,*/ vlocs);
        results->addFirstElement(variable_locations);

        /* mapping (or graph...): points-to relationships */
        List *points_tos = termFactory.makeList();
        for (loc = locs.begin(); loc != locs.end(); ++loc) {
          PointsToAnalysis::Location *base = pto->base_location(*loc);
          if (pto->valid_location(base)) {
            CompTerm *points_to
              = termFactory.makeCompTerm("->", //2,
                                         termFactory.makeInt(pto->location_id(*loc)),
                                         termFactory.makeInt(pto->location_id(base)));
            points_tos->addFirstElement(points_to);
          }
        }
        CompTerm *points_to_relations
          = termFactory.makeCompTerm("points_to_relations", /*1,*/ points_tos);
        results->addFirstElement(points_to_relations);

        /* mapping: function nodes to return and argument locations */

        /* mapping: structure locations to named members */
        // "structlocation_member_location" terms
      }
#elif HAVE_SATIRE_ICFG && !HAVE_PAG
      /* context-insensitive points-to information */
      if (isSgProject(astNode) && cfg != NULL
          && cfg->pointsToAnalysis != NULL) {
        using SATIrE::Analyses::PointsToAnalysis;
        PointsToAnalysis *pto = cfg->pointsToAnalysis;

        /* mapping: locations to their contents; this automagically defines
         * the set of all locations */
        List *locations = termFactory.makeList();
        std::vector<PointsToAnalysis::Location *> locs;
        pto->interesting_locations(locs);
        std::vector<PointsToAnalysis::Location *>::const_iterator loc;
        for (loc = locs.begin(); loc != locs.end(); ++loc) {
          List *varids = termFactory.makeList();
          List *funcs = termFactory.makeList();
          const std::list<SgSymbol *> &syms = pto->location_symbols(*loc);
          std::list<SgSymbol *>::const_iterator s;
          for (s = syms.begin(); s != syms.end(); ++s) {
            if (SgVariableSymbol *varsym = isSgVariableSymbol(*s)) {
              varids->addFirstElement(varidTerm(varsym));
            } else if (SgFunctionSymbol *funsym = isSgFunctionSymbol(*s)) {
              std::string funcname = funsym->get_name().str();
              Sg_File_Info* fi = funsym->get_declaration()->get_file_info();
              assert(fi != NULL);
              SgNode* p = funsym->get_declaration();
              while (p != NULL && !isSgFile(p))
                p = p->get_parent();
              SgFile* file = isSgFile(p);
              assert(file != NULL);
              Procedure* proc = procedureNode(funcname, file);
              // If a Procedure node for this function exists, i.e., we have a
              // definition for it, then mangle its function number into its
              // name for unique display.
              if (proc != NULL) {
                std::stringstream name;
                name << funcname << "::" << proc->procnum;
                funcname = name.str();
              }
              funcs->addFirstElement(termFactory.makeAtom(funcname));
            } else { // {{{ error handling
              std::cerr
                << "* unexpected symbol type in points-to location: "
                << (*s)->class_name()
                << " <" << (*s)->get_name().str() << ">"
                << std::endl;
              std::abort(); // }}}
            }
          }
          CompTerm *loct
            = termFactory.makeCompTerm("location_varids_funcs", // 3,
                                       termFactory.makeInt(pto->location_id(*loc)),
                                       varids,
                                       funcs);
          locations->addFirstElement(loct);
        }
        CompTerm *locationInfo = termFactory.makeCompTerm("locations", //1,
                                                          locations);
        results->addFirstElement(locationInfo);

        /* mapping: variables to locations in each context */
        List *vlocs = termFactory.makeList();
        std::map<SgVariableSymbol *, unsigned long>::const_iterator v;
        for (v = cfg->varsyms_ids.begin(); v != cfg->varsyms_ids.end(); ++v) {
          if (pto->symbol_has_location(v->first)) {
            Int *pLocation = termFactory.makeInt(
                                                 pto->location_id(pto->symbol_location(v->first)));
            CompTerm *vcl
              = termFactory.makeCompTerm("varid_location", //2,
                                         varidTerm(v->first),
                                         pLocation);
            vlocs->addFirstElement(vcl);
          }
        }
        CompTerm *variable_locations
          = termFactory.makeCompTerm("variable_locations", /*1,*/ vlocs);
        results->addFirstElement(variable_locations);

        /* mapping (or graph...): points-to relationships */
        List *points_tos = termFactory.makeList();
        for (loc = locs.begin(); loc != locs.end(); ++loc) {
          PointsToAnalysis::Location *base = pto->base_location(*loc);
          if (pto->valid_location(base)) {
            CompTerm *points_to
              = termFactory.makeCompTerm("->", //2,
                                         termFactory.makeInt(pto->location_id(*loc)),
                                         termFactory.makeInt(pto->location_id(base)));
            points_tos->addFirstElement(points_to);
          }
        }
        CompTerm *points_to_relations
          = termFactory.makeCompTerm("points_to_relations", /*1,*/ points_tos);
        results->addFirstElement(points_to_relations);

        /* mapping: function nodes to return and argument locations */

        /* mapping: structure locations to named members */
        // "structlocation_member_location" terms
      }
#endif

      ar = termFactory.makeCompTerm("analysis_info", /*1,*/ results);
    }

    /* add file info term */
    term::Term* fiTerm = termConv.getFileInfo(fi);

    assert(specific != NULL);
    assert(ar != NULL);
    assert(fiTerm != NULL);

    /* depending on the number of successors, use different predicate names*/
    if(isContainer(astNode))
      t = listTerm(astNode, synList, specific, ar, fiTerm);
    else {
      switch (getArity(astNode)) {
      case 0:
        t = leafTerm(astNode, synList, specific, ar, fiTerm);
        break;
      case 1:
        t = unaryTerm(astNode, synList, specific, ar, fiTerm);
        break;
      case 2:
        t = binaryTerm(astNode, synList, specific, ar, fiTerm);
        break;
      case 3:
        t = ternaryTerm(astNode, synList, specific, ar, fiTerm);
        break;
      case 4:
        t = quaternaryTerm(astNode, synList, specific, ar, fiTerm);
        break;
      default:
        t = listTerm(astNode, synList, specific, ar, fiTerm);
        break;
      }
    }
  }
  else {
    t = termFactory.makeAtom("null");
  }

  /* remember the last term */
  rootTerm = t;
  return t;
}

/* Add analysis result */
template<typename DFI_STORE_TYPE>
term::List*
TermPrinter<DFI_STORE_TYPE>::getAnalysisResultList(SgStatement* stmt)
{
  term::List *infos;
  infos = termFactory.makeList();

#if HAVE_PAG && !defined(DO_NOT_USE_DFIPRINTER)
  if (withPagAnalysisResults && stmt->get_attributeMechanism()) {
    Term *preInfo, *postInfo;
    preInfo = pagToProlog("pre_info",  analysisname,
                          pagDfiTextPrinter.getPreInfo(stmt));
    postInfo = pagToProlog("post_info", analysisname,
                           pagDfiTextPrinter.getPostInfo(stmt));
    infos->addFirstElement(postInfo);
    infos->addFirstElement(preInfo);
  }
#endif
#if HAVE_SATIRE_ICFG
  if (cfg != NULL && cfg->statementHasLabels(stmt)) {
    std::pair<int, int> entryExit = cfg->statementEntryExitLabels(stmt);
    CompTerm *pair = termFactory.makeInfixOperator("-");
    pair->addSubterm(termFactory.makeInt(entryExit.first));
    pair->addSubterm(termFactory.makeInt(entryExit.second));
    CompTerm *ee;
    ee = termFactory.makeCompTerm("entry_exit_labels");
    ee->addSubterm(pair);
    infos->addFirstElement(ee);
    /* ICFG node labels identifying branch headers */
    if (stmt->attributeExists("PAG statement head")) {
      StatementAttribute *a =
        (StatementAttribute *) stmt->getAttribute("PAG statement head");
      Int *l = termFactory.makeInt(a->get_bb()->id);
      CompTerm *head = termFactory.makeCompTerm("branch_head_label");
      head->addSubterm(l);
      infos->addFirstElement(head);
    }
  }
#endif

  return infos;
}

/* Convert the PAG analysis result into a  Term */
extern const char* dfi_input;
extern const char* dfi_input_start;
extern const char* dfi_name;
extern const char* dfi_analysisname;
extern int dfiparse (void);
extern void dfirestart(FILE*);
extern term::CompTerm* dfiterm;

template<typename DFI_STORE_TYPE>
term::CompTerm*
TermPrinter<DFI_STORE_TYPE>::pagToProlog(
                                         std::string name, std::string analysis, std::string dfi) {
  // Initialize and call the parser
  dfi_name = name.c_str();
  dfi_analysisname = analysis.c_str();
  dfi_input = dfi_input_start = dfi.c_str();
  dfirestart(0);
  dfiparse();
  return dfiterm;
}

/* Create a prolog term representing a leaf node.*/
template<typename DFI_STORE_TYPE>
term::CompTerm* TermPrinter<DFI_STORE_TYPE>::leafTerm(
						      SgNode* astNode, SynthesizedAttributesList synList,
						      term::Term* specific, term::Term* ar, term::Term* fiTerm)
{
  term::CompTerm* t =
    termFactory.makeCompTerm(termConv.prologize(astNode->class_name()), //0+3,
                             specific,
#if ROSE_HAVE_MINITERMITE_ANALYSIS_RESULTS
                             ar,
#endif
                             fiTerm);
  return t;
}

/* Create a prolog term representing a unary operator.*/
template<typename DFI_STORE_TYPE>
term::CompTerm* TermPrinter<DFI_STORE_TYPE>::unaryTerm(
						       SgNode* astNode, SynthesizedAttributesList synList,
						       term::Term* specific, term::Term* ar, term::Term* fiTerm)
{
  term::CompTerm* t =
    termFactory.makeCompTerm(termConv.prologize(astNode->class_name()), //1+3,
                             synList.at(0),
                             specific,
#if ROSE_HAVE_MINITERMITE_ANALYSIS_RESULTS
                             ar,
#endif
                             fiTerm);
  return t;
}

/* Create a prolog term representing a binary operator.*/
template<typename DFI_STORE_TYPE>
term::CompTerm* TermPrinter<DFI_STORE_TYPE>::binaryTerm(
							SgNode* astNode, SynthesizedAttributesList synList,
							term::Term* specific, term::Term* ar, term::Term* fiTerm)
{
  term::CompTerm* t =
    termFactory.makeCompTerm(termConv.prologize(astNode->class_name()), //2+3,
                             synList.at(0),
                             synList.at(1),
                             specific,
#if ROSE_HAVE_MINITERMITE_ANALYSIS_RESULTS
                             ar,
#endif
                             fiTerm);
  return t;
}

/* Create a prolog term representing a ternary operator.*/
template<typename DFI_STORE_TYPE>
term::CompTerm* TermPrinter<DFI_STORE_TYPE>::ternaryTerm(
							 SgNode* astNode, SynthesizedAttributesList synList,
							 term::Term* specific, term::Term* ar, term::Term* fiTerm)
{
  term::CompTerm* t =
    termFactory.makeCompTerm(termConv.prologize(astNode->class_name()), //3+3,
                             synList.at(0),
                             synList.at(1),
                             synList.at(2),
                             specific,
#if ROSE_HAVE_MINITERMITE_ANALYSIS_RESULTS
                             ar,
#endif
                             fiTerm);
  return t;
}

/* Create a prolog term representing a quaternary operator.*/
template<typename DFI_STORE_TYPE>
term::CompTerm* TermPrinter<DFI_STORE_TYPE>::quaternaryTerm(
							    SgNode* astNode, SynthesizedAttributesList synList,
							    term::Term* specific, term::Term* ar, term::Term* fiTerm)
{
  term::CompTerm* t =
    termFactory.makeCompTerm(termConv.prologize(astNode->class_name()), //4+3,
                             synList.at(0),
                             synList.at(1),
                             synList.at(2),
                             synList.at(3),
                             specific,
#if ROSE_HAVE_MINITERMITE_ANALYSIS_RESULTS
                             ar,
#endif
                             fiTerm);
  return t;
}

/* Create a prolog term representing a node with more than four successors.*/
template<typename DFI_STORE_TYPE>
term::CompTerm* TermPrinter<DFI_STORE_TYPE>::
listTerm(SgNode* astNode, SynthesizedAttributesList synList,
	 term::Term* specific, term::Term* ar, term::Term* fiTerm)
{
  /* add children's subterms to list */
  term::List* l = termFactory.makeList();
  SynthesizedAttributesList::reverse_iterator it;
  it = synList.rbegin();
  SynthesizedAttributesList::reverse_iterator end;
  end = synList.rend();

  /* Special case for variable declarations: The first traversal successor
   * may be a type declaration or definition. In the ROSE AST, it is an
   * argument by itself, not one of the initialized names in the list. This
   * is the only node type that is a mixture of "list node" and "fixed-arity
   * node". In the Termite term, we will add this subterm in the variable
   * declaration's annotation term (variable_declaration_specific). */
  if (isSgVariableDeclaration(astNode)) {
    /* skip the first element in the loop below */
    --end;
  }

  while(it != end) {
    /* strip frontend-specific "null" Atoms (see above) */
    term::Atom* atom = dynamic_cast<term::Atom*>(*it);
    if (!(atom && (atom->getName() == "null")))
      l->addFirstElement(*it);
    it++;
  }
  /* add list to term*/
  term::CompTerm* t =
    termFactory.makeCompTerm(termConv.prologize(astNode->class_name()), //1+3,
                             l,
                             specific,
#if ROSE_HAVE_MINITERMITE_ANALYSIS_RESULTS
                             ar,
#endif
                             fiTerm);
  return t;
}

#if HAVE_SATIRE_ICFG
template<typename DFI_STORE_TYPE>
Term*
TermPrinter<DFI_STORE_TYPE>::varidTerm(SgVariableSymbol *sym)
{
  Term *result = NULL;
  std::map<SgVariableSymbol *, unsigned long>::iterator s;
  if (cfg != NULL
      && (s = cfg->varsyms_ids.find(sym)) != cfg->varsyms_ids.end()) {
    unsigned long id = s->second;
    result = termFactory.makeInt(id);
  } else {
    result = termFactory.makeAtom("null");
  }
  return result;
}

template<typename DFI_STORE_TYPE>
Procedure*
TermPrinter<DFI_STORE_TYPE>::procedureNode(std::string funcname,
                                           SgFile *file) {
  std::multimap<std::string, Procedure *>::iterator mmi, limit;
  mmi = cfg->proc_map.lower_bound(funcname);
  if (mmi != cfg->proc_map.end()) {
    /* If we got here, we found *some* functions with the correct name in
     * the procedure map. To see which one we really want, we prefer a
     * static function in the same file, if there is one; otherwise, a
     * non-static implementation. */
    Procedure *staticCandidate = NULL;
    Procedure *nonStaticCandidate = NULL;
    limit = cfg->proc_map.upper_bound(funcname);
    while (mmi != limit) {
      Procedure *p = mmi++->second;
      if (p->isStatic && p->containingFile == file) {
        staticCandidate = p;
        break;
      } else if (!p->isStatic) {
        nonStaticCandidate = p;
      }
    }
    if (staticCandidate != NULL)
      return staticCandidate;
    else if (nonStaticCandidate != NULL)
      return nonStaticCandidate;
  }
  return NULL;
}

template<typename DFI_STORE_TYPE>
term::CompTerm*
TermPrinter<DFI_STORE_TYPE>::functionIdAnnotation(std::string funcname,
                                                  SgFile *file) {
  Procedure* p = procedureNode(funcname, file);
  Int* funcid_value = NULL;
  if (p != NULL) {
    funcid_value = termFactory.makeInt(p->procnum);
  } else {
    funcid_value = termFactory.makeInt(INT_MAX);
  }
  CompTerm *funcid_annot
    = termFactory.makeCompTerm("function_id", /*1,*/ funcid_value);
  return funcid_annot;
}

template<typename DFI_STORE_TYPE>
term::CompTerm*
TermPrinter<DFI_STORE_TYPE>::functionEntryExitAnnotation(
                                                         std::string funcname, SgFile *file) {
  Procedure* p = procedureNode(funcname, file);
  term::CompTerm* entryExit = NULL;
  if (p != NULL) {
    term::CompTerm* pair = termFactory.makeCompTerm("-", //2,
						    termFactory.makeInt(p->entry->id),
						    termFactory.makeInt(p->exit->id));
    entryExit = termFactory.makeCompTerm("function_entry_exit", /*1,*/ pair);
  }
  return entryExit;
}
#endif

#endif
