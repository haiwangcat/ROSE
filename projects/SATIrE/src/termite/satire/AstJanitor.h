/* -*- C++ -*-
  Copyright 2009 Adrian Prantl <adrian@complang.tuwien.ac.at>
*/
#ifndef _AST_JANITOR_H
#define _AST_JANITOR_H
#include "satire_rose.h"
#include "TermToRose.h"

/**
 * Perform various tasks to generate a valid AST
 * including the setting of parent scopes an pointers
 */
#define FI Sg_File_Info::generateDefaultFileInfoForTransformationNode()

class InheritedAttribute
{
public:
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

class AstJanitor : public AstTopDownProcessing<InheritedAttribute>
{
public:
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
      if (!isSgVariableDeclaration(decl) 
	  && !isSgFunctionParameterList(decl)
	  && !isSgPragmaDeclaration(decl)
	  ) {
	ROSE_ASSERT(scope != NULL);
	decl->set_scope(scope);
      }
      TermToRose::addSymbol(scope, decl);
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
