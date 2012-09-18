/* -*- C++ -*-
Copyright 2006 Christoph Bonitz <christoph.bonitz@gmail.com>
          2008 Adrian Prantl <adrian@complang.tuwien.ac.at>
*/

#ifndef PROLOGSUPPORT_H_
#define PROLOGSUPPORT_H_ 
#include <rose.h>
#include "minitermite.h"
#include "RoseEnums.h"
#include <string>
#include <vector>

/// Class supporting generation of PROLOG trees representing ROSE-IR
class RoseToTerm {
public:
  RoseToTerm(term::TermFactory& termFactory_): termFactory(termFactory_) {};
  term::Term* getSpecific(SgNode*);
  term::CompTerm* getFileInfo(Sg_File_Info*);
  static std::string prologize(std::string);
  term::Term* traverseSingleNode(SgNode*);
private:
  term::TermFactory& termFactory;
  term::Term* makeFlag(bool, std::string);
  bool typeWasDeclaredBefore(std::string type);
  std::set<std::string> declaredTypes;
  RoseEnums re;
  term::Term* getBitVector(const SgBitVector&, const std::vector<std::string>&);
  term::CompTerm* getPreprocessingInfo(AttachedPreprocessingInfoType*);
  term::CompTerm* getFunctionDeclarationSpecific(SgFunctionDeclaration*);
  term::CompTerm* getUnaryOpSpecific(SgUnaryOp*);
  term::CompTerm* getBinaryOpSpecific(SgBinaryOp*);
  term::CompTerm* getValueExpSpecific(SgValueExp*);
  term::CompTerm* getInitializedNameSpecific(SgInitializedName*);
  term::CompTerm* getVarRefExpSpecific(SgVarRefExp*);
  term::CompTerm* getAssignInitializerSpecific(SgAssignInitializer*);
  term::Term*     getTypeSpecific(SgType*);
  term::CompTerm* getFunctionTypeSpecific(SgType*);
  term::CompTerm* getPointerTypeSpecific(SgType*);
  term::CompTerm* getClassTypeSpecific(SgType*);
  term::CompTerm* getTypedefTypeSpecific(SgType*);
  term::CompTerm* getEnumTypeSpecific(SgType*);
  term::CompTerm* getClassDeclarationSpecific(SgClassDeclaration*);
  term::CompTerm* getClassDefinitionSpecific(SgClassDefinition*);
  term::CompTerm* getLabelStatementSpecific(SgLabelStatement*);
  term::CompTerm* getGotoStatementSpecific(SgGotoStatement*);
  term::CompTerm* getConditionalExpSpecific(SgConditionalExp*);
  term::CompTerm* getEnumDeclarationSpecific(SgEnumDeclaration*);
  term::CompTerm* getDeclarationAttributes(SgDeclarationStatement*);
  term::CompTerm* getDeleteExpSpecific(SgDeleteExp*);
  term::CompTerm* getRefExpSpecific(SgRefExp*);
  term::CompTerm* getVarArgSpecific(SgExpression*);
  term::CompTerm* getBaseClassModifierSpecific(SgBaseClassModifier*); 
  term::CompTerm* getFunctionModifierSpecific(SgFunctionModifier*);
  term::CompTerm* getSpecialFunctionModifierSpecific(SgSpecialFunctionModifier*);
  term::CompTerm* getLinkageModifierSpecific(SgLinkageModifier*);
  term::Atom*     createStorageModifierAtom(SgStorageModifier&);
  term::Atom*     createAccessModifierAtom(SgAccessModifier&);
  term::CompTerm* getStorageModifierSpecific(SgStorageModifier*);
  term::CompTerm* getElaboratedTypeModifierSpecific(SgElaboratedTypeModifier*);
  term::Atom*     createConstVolatileModifierAtom(SgConstVolatileModifier&);
  term::CompTerm* getConstVolatileModifierSpecific(SgConstVolatileModifier*);
  term::CompTerm* getUPC_AccessModifierSpecific(SgUPC_AccessModifier*);
  term::CompTerm* getTypeModifierSpecific(SgTypeModifier*);
  term::CompTerm* getDeclarationModifierSpecific(SgDeclarationModifier*);
  term::CompTerm* getArrayTypeSpecific(SgType*);
  term::CompTerm* getModifierTypeSpecific(SgType*);
  term::CompTerm* getFunctionRefExpSpecific(SgFunctionRefExp*);
  term::CompTerm* getFunctionCallExpSpecific(SgFunctionCallExp*);
  term::CompTerm* getMemberFunctionDeclarationSpecific(SgMemberFunctionDeclaration*);
  term::CompTerm* getTemplateInstantiationFunctionDeclSpecific(SgTemplateInstantiationFunctionDecl*);
  term::CompTerm* getTemplateArgumentSpecific(SgTemplateArgument*);
  term::CompTerm* getTemplateDeclarationSpecific(SgTemplateDeclaration*);
  term::CompTerm* getTemplateParameterSpecific(SgTemplateParameter *);
  term::Term*     getTypePtrListSpecific(SgTypePtrList&);
  term::CompTerm* getMemberFunctionTypeSpecific(SgType*);
  term::CompTerm* getClassScopeName(SgClassDefinition*);
  term::CompTerm* getMemberFunctionSymbolSpecific(SgMemberFunctionSymbol*);
  term::CompTerm* getMemberFunctionRefExpSpecific(SgMemberFunctionRefExp*);
  term::CompTerm* getNamespaceScopeName(SgNamespaceDefinitionStatement*);
  term::CompTerm* getNamespaceDeclarationStatementSpecific(SgNamespaceDeclarationStatement*);
  term::CompTerm* getSizeOfOpSpecific(SgSizeOfOp*);
  term::CompTerm* getVariableDeclarationSpecific(SgVariableDeclaration*);
  term::CompTerm* getTypedefDeclarationSpecific(SgTypedefDeclaration*);
  term::CompTerm* getConstructorInitializerSpecific(SgConstructorInitializer*);
  term::CompTerm* getNewExpSpecific(SgNewExp*);
  term::CompTerm* getPragmaSpecific(SgPragma*);
  term::CompTerm* getImplicitStatementSpecific(SgImplicitStatement*);
  term::CompTerm* getAttributeSpecificationStatementSpecific(SgAttributeSpecificationStatement*);
  term::CompTerm* getProcedureHeaderStatementSpecific(SgProcedureHeaderStatement*);
  term::CompTerm* getTypedefSeqSpecific(SgTypedefSeq*);
  term::CompTerm* getTypeComplexSpecific(SgTypeComplex*);
  term::Term*     getTypeStringSpecific(SgTypeString*);
  term::CompTerm* getCommonBlockObjectSpecific(SgCommonBlockObject* cbo);
  term::CompTerm* getIfStmtSpecific(SgIfStmt*);
  term::CompTerm* getFortranDoSpecific(SgFortranDo*);
  term::CompTerm* getFortranIncludeLineSpecific(SgFortranIncludeLine*);
  term::CompTerm* getAsteriskShapeExpSpecific(SgAsteriskShapeExp*);
  term::CompTerm* getWriteStatementSpecific(SgWriteStatement*);
  term::CompTerm* getPrintStatementSpecific(SgPrintStatement*);
  term::CompTerm* getFormatStatementSpecific(SgFormatStatement*);
  term::CompTerm* getFormatItemSpecific(SgFormatItem*);
  term::CompTerm* getLabelRefExpSpecific(SgLabelRefExp*);
  term::CompTerm* getLabelSymbolSpecific(SgLabelSymbol*);
  term::List*     getFormatItemList(SgFormatItemList*);
  term::CompTerm* getAsmOpSpecific(SgAsmOp*);
  term::CompTerm* getAsmStmtSpecific(SgAsmStmt*);
  term::CompTerm* getAsmx86InstructionSpecific(SgAsmx86Instruction*);

		
  template <class A> term::List* traverseList(const A& list) {
    term::List* alist = termFactory.makeList();		
    if (&(list) != NULL) {		
      for (int i = 0; i<list.size(); ++i) {
	alist->addElement(traverseSingleNode(list[i]));	
      }						
    }
    return alist;
  }


  template< class NodeType >
  term::Term* getScope(NodeType n) {
    if(SgNamespaceDefinitionStatement* scn =
       isSgNamespaceDefinitionStatement(n->get_scope())) {
      return getNamespaceScopeName(scn);
    } else if (SgClassDefinition* scn = isSgClassDefinition(n->get_scope())) {
      return  getClassScopeName(scn);
    } else {
      return termFactory.makeAtom("null");
    }
  }
		
};

#endif
