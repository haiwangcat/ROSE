/* -*- C++ -*-
Copyright 2006 Christoph Bonitz <christoph.bonitz@gmail.com>
          2008-2009 Adrian Prantl <adrian@complang.tuwien.ac.at>
*/
#ifndef PROLOGTOROSE_H_
#define PROLOGTOROSE_H_
#include <rose.h>
#include "minitermite.h"
#include "RoseEnums.h"
#include "RoseToTerm.h"
#include <iostream>
#include <deque>
#include <string>
#include <map>
#include <vector>

/// Class for creating a ROSE-IR (made for unparsing) from its PROLOG term-representation
class TermToRose {
public:
  TermToRose(term::TermFactory& termFactory_) : termFactory(termFactory_) {};
  ~TermToRose() {};
  void unparse(std::string, std::string, std::string, SgNode*);
  SgNode* toRose(term::Term*);
  SgNode* toRose(const char* filename);

  static void addSymbol(SgScopeStatement*, SgDeclarationStatement*);
private:
  term::TermFactory& termFactory;
  /* enum <-> atom conversion */
  RoseEnums re;

  bool createFlag(term::Term*);
  template < typename enumType  >
  SgBitVector* createBitVector(term::Term*, std::map<std::string, enumType>);
  
  /* fixups */
  std::vector<SgDeclarationStatement*> declarationStatementsWithoutScope;
  std::vector<SgLabelStatement*> labelStatementsWithoutScope;
  std::multimap<std::string,SgGotoStatement*> gotoStatementsWithoutLabel;
  std::map<std::string,SgClassDefinition*> classDefinitionMap;
  /* our own little symbol tables */
  std::deque<term::Term*>* globalDecls;
  std::map<std::string,SgType*> typeMap;
  std::map<std::string,SgType*> fortranFunctionTypeMap;
  std::map<std::string,SgDeclarationStatement*> declarationMap;
  std::map<std::string,SgInitializedName*> initializedNameMap;
  std::map<SgInitializedName*, SgVariableSymbol*> variableSymbolMap;
  std::multimap<std::string,SgMemberFunctionDeclaration*> memberFunctionDeclarationMap;
  std::map<std::string,SgTemplateDeclaration*> templateDeclMap;

  /* arity specific node generation*/
  SgNode* leafToRose(term::CompTerm*, std::string);
  SgNode* unaryToRose(term::CompTerm*, std::string);
  SgNode* binaryToRose(term::CompTerm*, std::string);
  SgNode* ternaryToRose(term::CompTerm*, std::string);
  SgNode* quaternaryToRose(term::CompTerm*, std::string);
  SgNode* listToRose(term::CompTerm*, std::string);
  /*helpers*/
  term::Term* canonical_type(term::Term*);
  void unparseFile(SgSourceFile&, std::string, std::string, SgUnparse_Info*);
  void warn_msg(std::string);
  Sg_File_Info* createFileInfo(term::Term*);
  SgType* createType(term::Term*);
  SgFunctionType* createFunctionType(term::Term*);
  SgMemberFunctionType* createMemberFunctionType(term::Term*);
  SgClassType* createClassType(term::Term*);
  SgPointerType* createPointerType(term::Term*);
  SgEnumType* createEnumType(term::Term*);
  SgReferenceType* createReferenceType(term::Term*);
  SgArrayType* createArrayType(term::Term*);
  term::CompTerm* retrieveAnnotation(term::CompTerm*);
  void abort_unless(bool, std::string);
  void debug(std::string);
  bool isValueExp(std::string);
  bool isUnaryOp(std::string);
  bool isBinaryOp(std::string);
  SgInitializedName* inameFromAnnot(term::CompTerm*);
  void testFileInfo(Sg_File_Info*);
  SgClassDeclaration* createDummyClassDeclaration(std::string, int);
  SgMemberFunctionDeclaration* createDummyMemberFunctionDeclaration(std::string s,int c_type); /* TODO */
  SgFunctionDeclaration* setFunctionDeclarationBody(SgFunctionDeclaration*, SgNode*);
  SgClassDeclaration* setClassDeclarationBody(SgClassDeclaration*, SgNode*);
  void setSpecialFunctionModifier(term::Term*, SgSpecialFunctionModifier*);

  SgLabelStatement* makeLabel(Sg_File_Info*, std::string);
  std::string* toStringP(term::Term*);
  int toInt(term::Term*);
  void pciDeclarationStatement(SgDeclarationStatement*,term::Term*);
  void fakeParentScope(SgDeclarationStatement*);
  void fakeClassScope(std::string, int, SgDeclarationStatement*);
  SgAccessModifier* createAccessModifier(term::Term*);
  SgBaseClassModifier* createBaseClassModifier(term::Term*);
  SgFunctionModifier* createFunctionModifier(term::Term*);
  SgSpecialFunctionModifier* createSpecialFunctionModifier(term::Term*);

  SgStorageModifier* createStorageModifier(term::Term*);
  SgLinkageModifier* createLinkageModifier(term::Term*);
  SgElaboratedTypeModifier* createElaboratedTypeModifier(term::Term*);
  SgConstVolatileModifier* createConstVolatileModifier(term::Term*);
  SgUPC_AccessModifier* createUPC_AccessModifier(term::Term*);
  SgTypeModifier* createTypeModifier(term::Term*);
  void setTypeModifier(term::Term*, SgTypeModifier*);
  SgDeclarationModifier* createDeclarationModifier(term::Term*);
  void setDeclarationModifier(term::Term*, SgDeclarationModifier*);
  SgModifierType* createModifierType(term::Term*);
  SgFunctionDeclaration* createDummyFunctionDeclaration(std::string*, term::Term*, SgProcedureHeaderStatement::subprogram_kind_enum);
  SgFunctionSymbol* createDummyFunctionSymbol(std::string*, term::Term*, SgProcedureHeaderStatement::subprogram_kind_enum);
  SgMemberFunctionSymbol* createDummyMemberFunctionSymbol(term::Term*);
  SgVariableSymbol* createVariableSymbol(SgInitializedName*);
  void storeVariableSymbolFromDeclaration(SgScopeStatement*,
                                          SgDeclarationStatement*);
  void fakeNamespaceScope(std::string, int, SgDeclarationStatement*);
  SgTypedefType* createTypedefType(term::Term*);
  /* type specific node generation */
  /*unary nodes*/
  SgExpression* createValueExp(Sg_File_Info*, SgNode*, term::CompTerm*);
  SgUnaryOp* createUnaryOp(Sg_File_Info*, SgNode*, term::CompTerm*);
  SgSourceFile* createFile(Sg_File_Info*, SgNode*, term::CompTerm*);
  SgReturnStmt* createReturnStmt(Sg_File_Info*, SgNode*, term::CompTerm*);
  SgFunctionDefinition* createFunctionDefinition(Sg_File_Info*, SgNode*, term::CompTerm*);
  SgInitializedName* createInitializedName(Sg_File_Info*, SgNode*, term::CompTerm*);
  SgAssignInitializer* createAssignInitializer(Sg_File_Info*, SgNode*, term::CompTerm*);
  SgExprStatement* createExprStatement(Sg_File_Info*, SgNode*, term::CompTerm*);
  SgDefaultOptionStmt* createDefaultOptionStmt(Sg_File_Info*, SgNode*, term::CompTerm*);
  SgClassDeclaration* createClassDeclaration(Sg_File_Info*, SgNode*, term::CompTerm*);
  SgDeleteExp* createDeleteExp(Sg_File_Info*, SgNode*, term::CompTerm*);
  SgVarArgOp* createVarArgOp(Sg_File_Info*, SgNode*, term::CompTerm*);
  SgVarArgStartOneOperandOp* createVarArgStartOneOperandOp(Sg_File_Info*, SgNode*, term::CompTerm*);
  SgVarArgEndOp* createVarArgEndOp(Sg_File_Info*, SgNode*, term::CompTerm*);
  SgAggregateInitializer* createAggregateInitializer(Sg_File_Info*, SgNode*, term::CompTerm*);
  SgNamespaceDeclarationStatement* createNamespaceDeclarationStatement(Sg_File_Info*, SgNode*, term::CompTerm*);
  SgSizeOfOp* createSizeOfOp(Sg_File_Info*, SgNode*, term::CompTerm*);
  SgConstructorInitializer* createConstructorInitializer(Sg_File_Info*, SgNode*, term::CompTerm*);
  SgPragmaDeclaration* createPragmaDeclaration(Sg_File_Info*, SgNode*, term::CompTerm*);

  /*binary nodes*/
  SgFunctionDeclaration* createFunctionDeclaration(Sg_File_Info*, SgNode*, term::CompTerm*);
  SgBinaryOp* createBinaryOp(Sg_File_Info*, SgNode*, SgNode*, term::CompTerm*);
  SgSwitchStatement* createSwitchStatement(Sg_File_Info*, SgNode*, SgNode*, term::CompTerm*);
  SgDoWhileStmt* createDoWhileStmt(Sg_File_Info*, SgNode*, SgNode*, term::CompTerm*);
  SgWhileStmt* createWhileStmt(Sg_File_Info*, SgNode*, SgNode*, term::CompTerm*);
  SgVarArgCopyOp* createVarArgCopyOp(Sg_File_Info*, SgNode*, SgNode*, term::CompTerm*);
  SgVarArgStartOp* createVarArgStartOp(Sg_File_Info*, SgNode*, SgNode*, term::CompTerm*);
  SgFunctionCallExp* createFunctionCallExp(Sg_File_Info*, SgNode*, SgNode*, term::CompTerm*);
  SgTryStmt* createTryStmt(Sg_File_Info*, SgNode*, SgNode*, term::CompTerm*);
  SgCatchOptionStmt* createCatchOptionStmt(Sg_File_Info*, SgNode*, SgNode*, term::CompTerm*);
  /*ternary nodes*/
  SgIfStmt* createIfStmt(Sg_File_Info*,  SgNode*,  SgNode*,  SgNode*,  term::CompTerm*);
  SgCaseOptionStmt* createCaseOptionStmt(Sg_File_Info*, SgNode*, SgNode*, SgNode*, term::CompTerm*);
  SgMemberFunctionDeclaration* createMemberFunctionDeclaration(Sg_File_Info*, SgNode*, SgNode*, SgNode*, term::CompTerm*);
  SgNewExp* createNewExp(Sg_File_Info*, SgNode*, SgNode*, SgNode*, term::CompTerm*);
  SgConditionalExp* createConditionalExp(Sg_File_Info*, SgNode*, SgNode*, SgNode*, term::CompTerm*);
  SgProgramHeaderStatement* createProgramHeaderStatement(Sg_File_Info*, SgNode*, SgNode*, SgNode*, term::CompTerm*);
  /*quaternary nodes*/
  SgForStatement* createForStatement(Sg_File_Info*, SgNode*, SgNode*, SgNode*, SgNode*, term::CompTerm*);
  /*list nodes*/
  SgFunctionParameterList* createFunctionParameterList(Sg_File_Info*,  std::deque<SgNode*>*);
  SgBasicBlock* createBasicBlock(Sg_File_Info*, std::deque<SgNode*>*);
  SgGlobal* createGlobal(Sg_File_Info*, std::deque<SgNode*>*);
  SgProject* createProject(Sg_File_Info*, std::deque<SgNode*>*);
  SgVariableDeclaration* createVariableDeclaration(Sg_File_Info*, std::deque<SgNode*>*, term::CompTerm*, SgDeclarationStatement*);
  SgForInitStatement* createForInitStatement(Sg_File_Info*, std::deque<SgNode*>*);
  SgClassDefinition* createClassDefinition(Sg_File_Info*, std::deque<SgNode*>*, term::CompTerm* t);
  SgCtorInitializerList* createCtorInitializerList(Sg_File_Info*, std::deque<SgNode*>*);
  SgEnumDeclaration* createEnumDeclaration(Sg_File_Info*, std::deque<SgNode*>*, term::CompTerm*);
  SgExprListExp* createExprListExp(Sg_File_Info*, std::deque<SgNode*>*);
  SgNamespaceDefinitionStatement* createNamespaceDefinitionStatement(Sg_File_Info*, std::deque<SgNode*>*);
  SgCatchStatementSeq* createCatchStatementSeq(Sg_File_Info*, std::deque<SgNode*>*);
  /*leaf nodes*/
  SgVarRefExp* createVarRefExp(Sg_File_Info*, term::CompTerm*);
  SgBreakStmt* createBreakStmt(Sg_File_Info*, term::CompTerm*);
  SgContinueStmt* createContinueStmt(Sg_File_Info*, term::CompTerm*);
  SgLabelStatement* createLabelStatement(Sg_File_Info*, term::CompTerm*);
  SgGotoStatement* createGotoStatement(Sg_File_Info*, term::CompTerm*);
  SgRefExp* createRefExp(Sg_File_Info*, term::CompTerm*);
  SgFunctionRefExp* createFunctionRefExp(Sg_File_Info*, term::CompTerm*);
  SgMemberFunctionRefExp* createMemberFunctionRefExp(Sg_File_Info*, term::CompTerm*);
  SgThisExp* createThisExp(Sg_File_Info*, term::CompTerm*);
  SgTypedefDeclaration* createTypedefDeclaration(Sg_File_Info*, term::CompTerm*);
  SgPragma* createPragma(Sg_File_Info*, term::CompTerm*);
  SgImplicitStatement* createImplicitStatement(Sg_File_Info* fi, term::CompTerm* t);
  SgAttributeSpecificationStatement* 
  createAttributeSpecificationStatement(Sg_File_Info*, term::CompTerm*);
  SgProcedureHeaderStatement* 
  createProcedureHeaderStatement(Sg_File_Info*, SgNode*, SgNode*, SgNode*, SgNode*, term::CompTerm*);
  SgFunctionDeclaration* 
  createTemplateInstantiationFunctionDecl(Sg_File_Info*, SgNode*, term::CompTerm*);
  SgTemplateArgument* createTemplateArgument(term::CompTerm*);
  SgTemplateParameter* createTemplateParameter(Sg_File_Info*, term::CompTerm*);
  SgTemplateDeclaration* createTemplateDeclaration(Sg_File_Info*, term::CompTerm*);
  SgTypedefSeq* createTypedefSeq(Sg_File_Info*, term::CompTerm*);
  SgCommonBlockObject* createCommonBlockObject(Sg_File_Info*, SgNode*, term::CompTerm*);
  SgCommonBlock* createCommonBlock(Sg_File_Info*, std::deque<SgNode*>*);
  SgFortranDo* createFortranDo(Sg_File_Info*, SgNode*, SgNode*, SgNode*, SgNode*, term::CompTerm*);
  SgFortranIncludeLine* createFortranIncludeLine(Sg_File_Info*, term::CompTerm*);
  SgAsteriskShapeExp* createAsteriskShapeExp(Sg_File_Info*, term::CompTerm*);
  SgWriteStatement* createWriteStatement(Sg_File_Info*, std::deque<SgNode*>*, term::CompTerm*);
  SgPrintStatement* createPrintStatement(Sg_File_Info*, std::deque<SgNode*>*, term::CompTerm*);
  SgFormatStatement* createFormatStatement(Sg_File_Info*, term::CompTerm*);
  SgFormatItem* createFormatItem(Sg_File_Info*, term::CompTerm*);
  SgLabelRefExp* createLabelRefExp(Sg_File_Info*, term::CompTerm*);
  SgLabelSymbol* createLabelSymbol(Sg_File_Info*, SgNode*, term::CompTerm*);
  SgAsmOp* createAsmOp(Sg_File_Info*, SgNode*, term::CompTerm*);
  SgAsmStmt* createAsmStmt(Sg_File_Info*, std::deque<SgNode*>*, term::CompTerm*);
  SgAsmx86Instruction* createAsmx86Instruction(std::deque<SgNode*>*, term::CompTerm*);

  void register_func_decl(SgName, SgFunctionDeclaration*, term::Term*);
  char unescape_char(std::string s);

public:
  // This is a helper function to create the necessary unique first
  // nondefining definition
  template< class DeclType, typename A, typename B, typename C >
  DeclType* createDummyNondefDecl(DeclType* decl, Sg_File_Info* fi, 
			     A a, B b, C c) 
  {
    decl->set_forward(0);
    //decl->set_definingDeclaration(decl);
    
    DeclType* ndd = new DeclType(fi,a,b,c);
    ndd->set_endOfConstruct(fi);
    ndd->set_parent(NULL);
    
    /* Set the internal reference to the non-defining declaration */  
    ndd->set_firstNondefiningDeclaration(ndd);
    //ndd->set_definingDeclaration(decl);
    ndd->setForward();
    decl->set_firstNondefiningDeclaration(ndd);
    declarationStatementsWithoutScope.push_back(ndd);
    return ndd;
  }

  template< class DeclType >
  DeclType* lookupDecl(DeclType** decl, std::string id, bool fail=true) 
  {
    if (declarationMap.find(id) != declarationMap.end()) {
      *decl = dynamic_cast<DeclType*>(declarationMap[id]);
      ROSE_ASSERT(*decl != NULL);
    } else if (fail) {
      //std::cerr << "**ERROR: Symbol lookup failed: (";
      //if (*decl != NULL) std::cerr << ((SgNode*)*decl)->class_name() <<"*) ";
      //std::cerr << id << std::endl;
      //std::cerr << "FIXME: forward-referencing function references\n" 
      // 		<< "       are not yet implemented. See lookaheadDecl()." 
      // 		<< std::endl;
      //ROSE_ASSERT(false);
      *decl = NULL;
    }
    return *decl;
  }

  template< class TypeType >
  TypeType* lookupType(TypeType** type, std::string id, bool fail=true) 
  {   
    if (typeMap.find(id) != typeMap.end()) {
      SgType* t = typeMap[id];
      *type = dynamic_cast<TypeType*>(t);
      ROSE_ASSERT(*type != NULL || t == NULL); // allow NULL pointer
    } else if (fail) {
      std::cerr<<"**ERROR: Symbol lookup failed: (";
      if (*type != NULL) std::cerr << ((SgNode*)*type)->class_name() <<"*)";
      std::cerr << id << std::endl;
      ROSE_ASSERT(false);
      *type = NULL;
    }
    return *type;
  }

  template< class DeclType >
  DeclType* lookaheadDecl(DeclType** decl, std::string pattern) 
  {
    *decl = NULL;
    if (globalDecls) {
      for (std::deque<term::Term*>::iterator it = globalDecls->begin();
	   it != globalDecls->end(); ++it) {
	if ((*it)->matches(pattern)) {
	  //std::cerr<<pattern<<std::endl;
	  *decl = dynamic_cast<DeclType*>(toRose(*it));
	  //std::cerr<<d->class_name()<<std::endl;
	  ROSE_ASSERT(*decl != NULL);
	}
      }
    }
    return *decl;
  }

  SgTemplateDeclaration* lookupTemplateDecl(std::string name)
  {
    if (templateDeclMap.find(name) == templateDeclMap.end())
      return NULL;
    else return templateDeclMap[name];
  }



};
#endif
