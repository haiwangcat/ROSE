/* -*- C++ -*-
  Copyright 2009 Adrian Prantl <adrian@complang.tuwien.ac.at>
*/
#ifndef _AST_JANITOR_H
#define _AST_JANITOR_H
#include <rose.h>
#include "TermToRose.h"

#define FI Sg_File_Info::generateDefaultFileInfoForTransformationNode()

/// Data structure for AstJanitor
struct InheritedAttribute
{
  TermToRose* conv;
  SgScopeStatement* scope;
  SgNode* parent;
  // Specific constructors are required
  InheritedAttribute(TermToRose* c, 
	       SgScopeStatement* s = NULL, 
	       SgNode* p = NULL)
    : conv(c), scope(s), parent(p) 
  {};
  InheritedAttribute(const InheritedAttribute& X)
    : conv(X.conv), scope(X.scope), parent(X.parent) 
  {};
};


/// Perform various tasks to generate a valid AST
//  including the setting of parent scopes an pointers
class AstJanitor : public AstTopDownProcessing<InheritedAttribute>
{
private:
  bool isFortran;

public:
  AstJanitor(bool _isFortran):isFortran(_isFortran) {};
  
  //virtual function must be defined
  virtual InheritedAttribute 
  evaluateInheritedAttribute(SgNode *n, InheritedAttribute attr)
  {
    // Set parent
    n->set_parent(attr.parent);

    // FileInfo
    if (SgLocatedNode* ln = isSgLocatedNode(n)) {
      // Set the CompilerGenerated Flag
      //Sg_File_Info* fi = ln->get_file_info();
      //fi->set_classificationBitField(fi->get_classificationBitField() 
      //				   | Sg_File_Info::e_compiler_generated 
      /*| Sg_File_Info::e_output_in_code_generation*/
      //);
      // Set EndOfConstruct
      ln->set_endOfConstruct(ln->get_startOfConstruct());
    }

    // Scope
    SgScopeStatement* scope = isSgScopeStatement(n);
    if (scope == NULL) scope = attr.scope;

    // These nodes don't have a scope associated
    if (SgDeclarationStatement* decl = isSgDeclarationStatement(n)) {
      VariantT v = decl->variantT();
      if (   v != V_SgAttributeSpecificationStatement
	  && v != V_SgAsmStmt
	  && v != V_SgCommonBlock
	  && v != V_SgContainsStatement
	  && v != V_SgCtorInitializerList
	  && v != V_SgFormatStatement
	     //&& v != V_SgFunctionDeclaration
	  && v != V_SgFunctionParameterList
	  && v != V_SgImplicitStatement
	  && v != V_SgNamespaceDeclarationStatement
	  && v != V_SgMemberFunctionDeclaration
	  && v != V_SgPragmaDeclaration
	  && v != V_SgVariableDeclaration
	  ) {
	ROSE_ASSERT(scope != NULL);
	if (v == V_SgFunctionDeclaration) {
	  if (decl->get_scope() == NULL)
	    decl->set_scope(scope);
	} else decl->set_scope(scope);
      }
      if (isFortran && scope->variantT() == V_SgGlobal) { 
	/* SKIP, Fortran apparently has no global symbol table */
	// I find the condition to be easier to read this way
      }
      else {
	TermToRose::addSymbol(scope, decl);
      }
    }

    if (SgVariableDeclaration *vardecl = isSgVariableDeclaration(n))
      setInitNameScopes(vardecl->get_variables(), vardecl->get_scope());
    if (SgEnumDeclaration *edecl = isSgEnumDeclaration(n)) {
      setInitNameScopes(edecl->get_enumerators(), edecl->get_scope());
    }
    if (SgFunctionParameterList *plist = isSgFunctionParameterList(n)) {
      /* try to ensure that function parameters are entered in the function
       * definition's symbol table -- if this is a function definition */
      SgFunctionDeclaration *fdecl
        = isSgFunctionDeclaration(plist->get_parent());
      SgFunctionDefinition *fdef = fdecl->get_definition();
      if (fdef != NULL) {
        setInitNameScopes(plist->get_args(), fdef);
      } else {
        setInitNameScopes(plist->get_args(), plist->get_scope());
      }
    }
    if (SgClassDeclaration *cdecl = isSgClassDeclaration(n)) {
      if (cdecl->get_scope() == NULL) {
        cdecl->set_scope(scope);
      }
      SgClassDeclaration *fnd
        = isSgClassDeclaration(cdecl->get_firstNondefiningDeclaration());
      if (fnd != NULL && fnd->get_scope() == NULL) {
        fnd->set_scope(cdecl->get_scope());
      }
    }
    if (SgEnumDeclaration *edecl = isSgEnumDeclaration(n)) {
      if (edecl->get_scope() == NULL) {
        edecl->set_scope(scope);
      }
      SgEnumDeclaration *fnd
        = isSgEnumDeclaration(edecl->get_firstNondefiningDeclaration());
      if (fnd != NULL && fnd->get_scope() == NULL) {
        fnd->set_scope(edecl->get_scope());
      }
    }
    if (SgTypedefDeclaration *td = isSgTypedefDeclaration(n)) {
      SgDeclarationStatement *d = td->get_baseTypeDefiningDeclaration();
      if (d != NULL && d->get_scope() == NULL) {
        d->set_scope(scope);
      }
    }

    if (SgInitializedName *iname = isSgInitializedName(n))
    {
      if (iname->get_scope() == NULL)
      {
        std::cout
            << "iname " << iname->get_name().str()
            << " has NULL scope; parent is "
            << iname->get_parent()->class_name()
            << std::endl;
      }
    }


    if (isSgVariableDeclaration(n) && isSgForInitStatement(attr.parent))
      n->set_parent(attr.parent->get_parent());

    return InheritedAttribute(attr.conv, scope, n);
  };

private:
  void setInitNameScopes(SgInitializedNamePtrList &ins, SgScopeStatement *s) {
    SgInitializedNamePtrList::iterator i;
    for (i = ins.begin(); i != ins.end(); ++i)
      (*i)->set_scope(s);
  }
};


#endif
