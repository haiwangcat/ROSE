// -*- mode: C++ -*-
/* Copyright 2006 Christoph Bonitz <christoph.bonitz@gmail.com>
	2007-2008 Adrian Prantl <adrian@complang.tuwien.ac.at>
*/
#include <rose.h>
#include <list>
#include <cctype>
#include "minitermite.h"
// GB (2009-02-25): Use the term printer without DFI stuff.
#undef HAVE_PAG
#define HAVE_SATIRE_ICFG 0
#include "TermPrinter.h"
#include "RoseToTerm.h"
#include <boost/algorithm/string/predicate.hpp>
#include <rose_config.h>

using namespace std;
using namespace term;

/* Helper Macro to attach the preprocessing information to each node's
   annotation */
#define PPI(NODE) \
  getPreprocessingInfo((NODE)->getAttachedPreprocessingInfo())

/**
 * Create a descriptive name for a boolean flag
 */
#define MAKE_FLAG(node, flag_name) \
  makeFlag((node)->get_ ## flag_name(), #flag_name)
 
Term*
RoseToTerm::makeFlag(bool val, std::string name) {
  ROSE_ASSERT(!boost::starts_with(name, "no_"));
  if (val) return termFactory.makeAtom(name);
  else return termFactory.makeAtom("no_"+name);
}

/** Convert an enum value to an atom */
#define enum_atom(ENUM) \
  termFactory.makeAtom(re.str(ENUM))

/**
 * get node specific info for a term.
 * This function, depending on the type of the node, uses private helper functions.
 * No actual work is done here.
 */

#define CASE_SPECIFIC(SAGETYPE) \
  case V_Sg ## SAGETYPE: return get ## SAGETYPE ## Specific(isSg ## SAGETYPE(astNode));

Term*
RoseToTerm::getSpecific(SgNode* astNode) {
  string cname = astNode->class_name();
  VariantT v = astNode->variantT();

  switch (v) {

  CASE_SPECIFIC(AsmOp)
  CASE_SPECIFIC(AsmStmt)
  CASE_SPECIFIC(Asmx86Instruction)
  CASE_SPECIFIC(AssignInitializer)
  CASE_SPECIFIC(AsteriskShapeExp)
  CASE_SPECIFIC(AttributeSpecificationStatement)
  CASE_SPECIFIC(ClassDeclaration)
  CASE_SPECIFIC(ClassDefinition)
  CASE_SPECIFIC(CommonBlockObject)
  CASE_SPECIFIC(ConditionalExp)
  CASE_SPECIFIC(ConstructorInitializer)
  CASE_SPECIFIC(DeleteExp)
  CASE_SPECIFIC(EnumDeclaration)
  CASE_SPECIFIC(FormatItem)
  CASE_SPECIFIC(FormatStatement)
  CASE_SPECIFIC(FortranDo)
  CASE_SPECIFIC(FortranIncludeLine)
  CASE_SPECIFIC(FunctionCallExp)
  CASE_SPECIFIC(FunctionRefExp)
  CASE_SPECIFIC(GotoStatement)
  CASE_SPECIFIC(IfStmt)
  CASE_SPECIFIC(ImplicitStatement)
  CASE_SPECIFIC(InitializedName)
  CASE_SPECIFIC(LabelStatement)
  CASE_SPECIFIC(LabelRefExp)
  CASE_SPECIFIC(LabelSymbol)
  CASE_SPECIFIC(MemberFunctionDeclaration)
  CASE_SPECIFIC(MemberFunctionRefExp)
  CASE_SPECIFIC(MemberFunctionSymbol)
  CASE_SPECIFIC(NamespaceDeclarationStatement)
  CASE_SPECIFIC(NewExp)
  CASE_SPECIFIC(Pragma)
  CASE_SPECIFIC(PrintStatement)
  CASE_SPECIFIC(ProcedureHeaderStatement)
  CASE_SPECIFIC(RefExp)
  CASE_SPECIFIC(SizeOfOp)
  CASE_SPECIFIC(TemplateArgument)
  CASE_SPECIFIC(TemplateDeclaration)
  CASE_SPECIFIC(TemplateInstantiationFunctionDecl)
  CASE_SPECIFIC(TemplateParameter)
  CASE_SPECIFIC(TypedefDeclaration)
  CASE_SPECIFIC(TypedefSeq)
  CASE_SPECIFIC(VarRefExp)
  CASE_SPECIFIC(WriteStatement)
  CASE_SPECIFIC(VariableDeclaration)

  case V_SgProgramHeaderStatement:
  case V_SgFunctionDeclaration: 
    return getFunctionDeclarationSpecific(isSgFunctionDeclaration(astNode));

  case V_SgVarArgOp:                
  case V_SgVarArgCopyOp:            
  case V_SgVarArgEndOp:             
  case V_SgVarArgStartOp:           
  case V_SgVarArgStartOneOperandOp: 
    return getVarArgSpecific(isSgExpression(astNode));

  default:
    // here we are matching generic base classes
    if (SgValueExp* n = dynamic_cast<SgValueExp*>(astNode)) {
      return getValueExpSpecific(n);
    } else if (SgUnaryOp* n = dynamic_cast<SgUnaryOp*>(astNode)) {
      return getUnaryOpSpecific(n);
    } else if (SgBinaryOp* n = dynamic_cast<SgBinaryOp*>(astNode)) {
      return getBinaryOpSpecific(n);
    } else if (SgLocatedNode* n = dynamic_cast<SgLocatedNode*>(astNode)) {
      // add preprocessing info
      return termFactory.makeCompTerm("default_annotation", //2,
			     termFactory.makeAtom("null"),
			     PPI(n));
    } else {
      return termFactory.makeCompTerm("default_annotation", /*1,*/ termFactory.makeAtom("null"));
    }
  }
  assert(false);
}

CompTerm*
RoseToTerm::getPreprocessingInfo(AttachedPreprocessingInfoType* inf) {
  List* l = termFactory.makeList();
  if (inf != NULL) {
    for (AttachedPreprocessingInfoType::reverse_iterator it = inf->rbegin();
	 it != inf->rend(); ++it) {
      bool escape = (*it)->getTypeOfDirective()
	!= PreprocessingInfo::CpreprocessorIncludeDeclaration;

      CompTerm* ppd = termFactory.makeCompTerm
	(re.str((*it)->getTypeOfDirective()), //3,
	 termFactory.makeAtom((*it)->getString(), escape),
	 enum_atom((*it)->getRelativePosition()),
	 getFileInfo((*it)->get_file_info()));
      l->addFirstElement(ppd);
    }
  }
  return termFactory.makeCompTerm("preprocessing_info", /*1,*/ l);
}

/**
 * class: Sg_File_Info
 * term: file_info(file,line,column)
 * arg file: file name
 * arg line: line name
 * arg col: column name
 */
CompTerm*
RoseToTerm::getFileInfo(Sg_File_Info* inf) {
  ROSE_ASSERT(inf != NULL);
  if (inf->ok()) {
    return termFactory.makeCompTerm("file_info", /*3,*/
			      termFactory.makeAtom(inf->get_filename()),
			      termFactory.makeInt(inf->get_line()),
			      termFactory.makeInt(inf->get_col()));
  } else {
#if 0
    cerr<<"**WARNING file info broken"<<endl;
    return termFactory.makeCompTerm("file_info", /*3,*/
			      termFactory.makeAtom("BROKEN Sg_File_Info"),
			      termFactory.makeInt(0),
			      termFactory.makeInt(0));
#else
    return getFileInfo(Sg_File_Info::Sg_File_Info::generateDefaultFileInfoForCompilerGeneratedNode());
#endif
  }
}

/**
 * convert ZigZagCase to zig_zag_case.
 * (In , strings starting with uppercase letters are free variables)
 */
std::string
RoseToTerm::prologize(std::string s) {
  string t;
  string::iterator it;
  it = s.begin();
  // remove "^Sg"
  if ((s.length() > 2) && (s[0] == 'S') && (s[1] == 'g')) {
    ++it, ++it;
  }
  //lowercase first char (without prepending underscore)
  if(it != s.end()) {
    if(isupper(*it)) {
      t.push_back(tolower(*it));
    } else {
      t.push_back(*it);
    }
    it++;
  }
  //replace an uppercase letter with an underscore
  //and its lowercase equivalent
  while(it != s.end()) {
    if(isupper(*it)) {
      t.push_back('_');
      t.push_back(tolower(*it));
    } else {
      t.push_back(*it);
    }
    it++;
  }
  return t;
}

/** check whether we have seen the type before, and store it for future
 * queries */
bool
RoseToTerm::typeWasDeclaredBefore(std::string type) {
  /* std::set::insert returns a pair where the second component tells us
   * whether the object actually needed to be inserted (i.e., was *not*
   * present before) */
  return !declaredTypes.insert(type).second;
}

/**
 * class: SgProcedureHeaderStatement
 * term: function_declaration_annotation(type,name)
 * arg type: type of the declaration
 * arg name: name of the declaration
 * arg dec_mod: declaration modifier (see getDeclarationModifierSpecific)
 */
CompTerm*
RoseToTerm::getProcedureHeaderStatementSpecific(SgProcedureHeaderStatement* decl) {
  /* create annotation term*/
  return termFactory.makeCompTerm
    ("procedure_header_statement_annotation", /*4,*/
     /* add type and name*/
     getTypeSpecific(decl->get_type()),
     termFactory.makeAtom(decl->get_name().getString()),
     getDeclarationModifierSpecific(&(decl->get_declarationModifier())),
     enum_atom(decl->get_subprogram_kind()),
     termFactory.makeAtom("null"), //FIXME decl->get_end_numeric_label(),
     //termFactory.makeAtom("null"), decl->get_result_name(),
     PPI(decl));
}

#define templateDeclarationName(decl) \
  termFactory.makeAtom(  decl->get_templateDeclaration() ? \
		   decl->get_templateDeclaration()->get_name().getString() : \
                   "")

CompTerm*  
RoseToTerm::getTemplateInstantiationFunctionDeclSpecific(SgTemplateInstantiationFunctionDecl* decl) {
  return termFactory.makeCompTerm
    ("template_instantiation_function_decl_annotation", /*6,*/
     /* add type and name*/
     getTypeSpecific(decl->get_type()),
     termFactory.makeAtom(decl->get_name().getString()),
     getDeclarationModifierSpecific(&(decl->get_declarationModifier())),
     getSpecialFunctionModifierSpecific(&(decl->get_specialFunctionModifier())),
     traverseList(decl->get_templateArguments()),
     templateDeclarationName(decl),
     PPI(decl));

}


CompTerm*  
RoseToTerm::getTemplateArgumentSpecific(SgTemplateArgument* arg) {
  return termFactory.makeCompTerm
    ("template_argument_annotation", 
     enum_atom(arg->get_argumentType()),
     MAKE_FLAG(arg, isArrayBoundUnknownType),
     getTypeSpecific(arg->get_type()),
     traverseSingleNode(arg->get_expression()),     
     templateDeclarationName(arg),
     MAKE_FLAG(arg, explicitlySpecified));
}

CompTerm*  
RoseToTerm::getTemplateDeclarationSpecific(SgTemplateDeclaration* decl) {
  return termFactory.makeCompTerm
    ("template_declaration_annotation", 
     termFactory.makeAtom(decl->get_name().getString()),
     termFactory.makeAtom(decl->get_string().getString()),
     enum_atom(decl->get_template_kind()),
     traverseList(decl->get_templateParameters()));
}

CompTerm*  
RoseToTerm::getTemplateParameterSpecific(SgTemplateParameter *p) {
  return termFactory.makeCompTerm
    ("template_parameter_annotation", 
     enum_atom(p->get_parameterType()),
     getTypeSpecific(p->get_type()),
     getTypeSpecific(p->get_defaultTypeParameter()),
     traverseSingleNode(p->get_expression()),
     traverseSingleNode(p->get_defaultExpressionParameter()),
     termFactory.makeAtom(p->get_templateDeclaration()->get_name().getString()),
     termFactory.makeAtom(p->get_defaultTemplateDeclarationParameter()->get_name().getString()));
}

CompTerm*  
RoseToTerm::getTypedefSeqSpecific(SgTypedefSeq *p) {
  return termFactory.makeCompTerm("typedef_seq_annotation", 
			    traverseList(p->get_typedefs()));
}


/**
 * class: SgFunctionDeclaration
 * term: function_declaration_annotation(type,name)
 * arg type: type of the declaration
 * arg name: name of the declaration
 * arg dec_mod: declaration modifier (see getDeclarationModifierSpecific)
 */
CompTerm*
RoseToTerm::getFunctionDeclarationSpecific(SgFunctionDeclaration* decl) {
  /* create annotation term*/
  return termFactory.makeCompTerm
    ("function_declaration_annotation", /*4,*/
     /* add type and name*/
     getTypeSpecific(decl->get_type()),
     termFactory.makeAtom(decl->get_name().getString()),
     getDeclarationModifierSpecific(&(decl->get_declarationModifier())),
     getSpecialFunctionModifierSpecific(&(decl->get_specialFunctionModifier())),
     termFactory.makeInt(decl->get_name_qualification_length()),
     MAKE_FLAG(decl, type_elaboration_required),
     MAKE_FLAG(decl, global_qualification_required),
     MAKE_FLAG(decl, requiresNameQualificationOnReturnType),
     getScope(decl),
     PPI(decl));
}


/**
 * class: SgFunctionType
 * term: function_type(tpe,he,argl)
 * arg tpe: return type
 * arg he: has_ellipses - flag
 * arg argl: argument type list (List of SgType - Annotations
 * */
CompTerm*
RoseToTerm::getFunctionTypeSpecific(SgType* mytype) {
  /*let ROSE do casting and testing*/
  SgFunctionType* ftype = isSgFunctionType(mytype);
  ROSE_ASSERT(ftype != NULL);
  /*this is a nested type*/
  return termFactory.makeCompTerm
    ("function_type", /*3,*/
     /*recurse with getTypeSpecific*/
     getTypeSpecific(ftype->get_return_type()),
     /*we need to know wether it has ellipses to unparse the constructor*/
     makeFlag(ftype->get_has_ellipses(), "ellipses"),
     /*arguments*/
     getTypePtrListSpecific(ftype->get_arguments()));
}



/**
 * class: SgMemberFunctionType
 * term: member_function_type(tpe,he,argl,mfs)
 * arg tpe: return type
 * arg he: has_ellipses - flag
 * arg argl: argument type list (List of SgType - Annotations
 * arg mfs: mfunc_specifier of type
 * */
CompTerm*
RoseToTerm::getMemberFunctionTypeSpecific(SgType* mytype) {
  /*let ROSE do casting and testing*/
  SgMemberFunctionType* ftype = isSgMemberFunctionType(mytype);
  ROSE_ASSERT(ftype != NULL);
  /*this is a nested type*/
  return termFactory.makeCompTerm
    ("member_function_type", /*4,*/
     /*recurse with getTypeSpecific*/
     getTypeSpecific(ftype->get_return_type()),
    /*we need to know wether it has ellipses for the constructor for unparsing*/
     makeFlag(ftype->get_has_ellipses(), "ellipses"),
     /*arguments*/
     getTypePtrListSpecific(ftype->get_arguments()),
     /* mfunc_specifier*/
     enum_atom((::SgMemberFunctionType::mfunc_specifier_enum)ftype->get_mfunc_specifier()));
}


/**
 * class: SgPointerType
 * term: pointer_type(type)
 * arg type: base type
 */
CompTerm*
RoseToTerm::getPointerTypeSpecific(SgType* mytype) {
  /* let rose do type testing and casting*/
  SgPointerType* ptype = isSgPointerType(mytype);
  ROSE_ASSERT(ptype != NULL);
  /* nested type */
  return termFactory.makeCompTerm
    ("pointer_type", /*1,*/
     /* get base type with recursion*/
     getTypeSpecific(ptype->get_base_type()));
}


/**
 * class: SgEnumType
 * term: enum_type(declaration)
 * arg declaration: the term representation of the declaration
 */
CompTerm*
RoseToTerm::getEnumTypeSpecific(SgType* mtype) {
  /*make sure we are actually dealing with a class type*/
  SgEnumType* ctype = isSgEnumType(mtype);
  ROSE_ASSERT(ctype != NULL);
  /*add base type*/
  string id = ctype->get_name().str();
  if (id == "") {
    /* nameless enum declarations can occur in typedefs */
    SgTypedefDeclaration *td;
    if (td = isSgTypedefDeclaration(ctype->get_declaration()->get_parent())) {
      id = td->get_mangled_name().str();
    }
  }
  ROSE_ASSERT(id != "" && id != "''");

  /*nested type -> nested term*/
  return termFactory.makeCompTerm("enum_type", /*1,*/ termFactory.makeAtom(id));
}


/**
 * class: SgClassType
 * term: class_type(name,type,scope)
 * arg name: name of the class
 * arg type: type enum of the class (class/struct/union)
 * arg scope: name of the scope
 */
CompTerm*
RoseToTerm::getClassTypeSpecific(SgType* mtype) {
  /*make sure we are actually dealing with a class type*/
  SgClassType* ctype = isSgClassType(mtype);
  ROSE_ASSERT(ctype != NULL);

  SgClassDeclaration* d = isSgClassDeclaration(ctype->get_declaration());
  ROSE_ASSERT(d != NULL);

  return termFactory.makeCompTerm
    ("class_type", //3,
     /*add base type*/
     termFactory.makeAtom(ctype->get_name().str()),
     /* what kind of class is this?*/
     enum_atom(d->get_class_type()),
     /* add qualified name of scope*/
     termFactory.makeAtom
     (d->get_scope()->get_scope()->get_qualified_name().getString()));
}

/**
 * class: SgTypedefType
 * term: typedef_type(name, base)
 * arg name: name of the new type
 * arg base: basetype
 */
CompTerm*
RoseToTerm::getTypedefTypeSpecific(SgType* mtype) {
  /* make sure this is actually a SgTypedefType*/
  SgTypedefType* tp = isSgTypedefType(mtype);
  ROSE_ASSERT(tp != NULL);

  /* create term and add name*/
  return termFactory.makeCompTerm
    ("typedef_type", //2,
     termFactory.makeAtom(tp->get_name().getString()),
     (tp->get_base_type() != NULL /* add base type */
      ? getTypeSpecific(tp->get_base_type())
      : termFactory.makeAtom("null")));
}

/**
 * class: SgConstructorInitializer
 * term: constructor_initializer_annotiation(name)
 * arg name: qualified class name
 */
CompTerm*
RoseToTerm::getConstructorInitializerSpecific(SgConstructorInitializer* ci) {
  ROSE_ASSERT(ci != NULL);
  /* get name from class declaration*/
  SgClassDeclaration* dec = ci->get_class_decl();
  return termFactory.makeCompTerm
    ("constructor_initializer_annotation",
     dec ? termFactory.makeAtom(dec->get_qualified_name().getString()): termFactory.makeAtom("null"),
     getTypeSpecific(ci->get_expression_type()),
     MAKE_FLAG(ci, need_name),
     MAKE_FLAG(ci, need_qualifier),
     MAKE_FLAG(ci, need_parenthesis_after_name),
     MAKE_FLAG(ci, associated_class_unknown),
     PPI(ci));
}

/**
 * class: SgNewExp
 * term: new_exp_annotation(type)
 * arg type: type of the expression
 */
CompTerm*
RoseToTerm::getNewExpSpecific(SgNewExp* ne) {
  ROSE_ASSERT(ne != NULL);
  /*create annot term*/
  return termFactory.makeCompTerm
    ("new_exp_annotation", //2,
     getTypeSpecific(ne->get_specified_type()), /* add type term*/
     PPI(ne));
}



/**
 * class: SgArrayType
 * term: array_type(nested,index)
 * arg nested: nested type
 * arg index: index (a SgExpression)
 * arg rank
 * arg dim_info
 */
CompTerm*
RoseToTerm::getArrayTypeSpecific(SgType* mtype) {
  /*make sure we are actually dealing with an array type*/
  SgArrayType* a = isSgArrayType(mtype);
  ROSE_ASSERT(a != NULL);
  return termFactory.makeCompTerm
    ("array_type", //2,
     getTypeSpecific(a->get_base_type()), /* get nested type*/
     traverseSingleNode(a->get_index()), /* get expression*/
     termFactory.makeInt(a->get_rank()),
     traverseSingleNode(a->get_dim_info()));
}

/**
 * class: SgModifierType
 * term: modifier_type(nested,tmod)
 * arg nested: nested type
 * tmod: term representation of type modifier
 */
CompTerm*
RoseToTerm::getModifierTypeSpecific(SgType* stype) {
  /*make sure we are actually dealing with a modifier type*/
  SgModifierType* m = isSgModifierType(stype);
  ROSE_ASSERT(m != NULL);
  return termFactory.makeCompTerm
    ("modifier_type", //2,
     /* base type*/ getTypeSpecific(m->get_base_type()),
     /* type modifier*/ getTypeModifierSpecific(&(m->get_typeModifier())));
}


/**
 * create representation for a type.
 * Result is an atom for the primitive types and a nested
 * term for the complex types.
 * */
Term*
RoseToTerm::getTypeSpecific(SgType* stype) {
  VariantT v = stype->variantT();
  /*type is represented by a prolog term*/
  Term*  t = NULL;
  /* composite types implemented in different functions*/
  switch (v) {
  case V_SgFunctionType:       t = getFunctionTypeSpecific(stype);       break;
  case V_SgPointerType:        t = getPointerTypeSpecific(stype);        break; 
  case V_SgClassType:          t = getClassTypeSpecific(stype);		 break; 
  case V_SgTypedefType:        t = getTypedefTypeSpecific(stype);	 break; 
  case V_SgEnumType:	       t = getEnumTypeSpecific(stype);		 break; 
  case V_SgArrayType:          t = getArrayTypeSpecific(stype);		 break; 
  case V_SgModifierType:       t = getModifierTypeSpecific(stype);	 break; 
  case V_SgMemberFunctionType: t = getMemberFunctionTypeSpecific(stype); break; 
  case V_SgTypeComplex:        
    t = getTypeComplexSpecific(isSgTypeComplex(stype));        
    break;
  case V_SgTypeString:
    t = getTypeStringSpecific(isSgTypeString(stype));
    break;
  /* simple types */
  case V_SgTypeBool:
  case V_SgTypeChar:
  case V_SgTypeDefault:
  case V_SgTypeDouble:
  case V_SgTypeEllipse:
  case V_SgTypeFloat:
  case V_SgTypeGlobalVoid:
  case V_SgTypeInt:
  case V_SgTypeLong:
  case V_SgTypeLongDouble:
  case V_SgTypeLongLong:
  case V_SgTypeShort:
  case V_SgTypeSignedChar:
  case V_SgTypeSignedInt:
  case V_SgTypeSignedLong:
  case V_SgTypeSignedShort:
  case V_SgTypeUnknown:
  case V_SgTypeUnsignedChar:
  case V_SgTypeUnsignedInt:
  case V_SgTypeUnsignedLong:
  case V_SgTypeUnsignedLongLong:
  case V_SgTypeUnsignedShort:
  case V_SgTypeVoid:
  case V_SgTypeWchar: {
    // I haven't decided what the best way to include the fortran type kind is yet
    SgExpression *kind = stype->get_type_kind();
    if (kind) {
      t = termFactory.makeCompTerm("fortran_type_with_kind",
			     termFactory.makeAtom(prologize(stype->class_name())),
			     traverseSingleNode(kind));
    } t = termFactory.makeAtom(prologize(stype->class_name()));
    break;
  }
  default: {
    CompTerm* ct  = termFactory.makeCompTerm
      ("not_yet_implemented", /*1,*/ termFactory.makeAtom(stype->class_name()));
    t = ct;
    }
  }
  /*we should have created some type info here*/
  ROSE_ASSERT(t != NULL);
  return t;
}


/**
 * class: SgUnaryOp
 * term: unary_op_annotation(mode,type,throw_kind)
 * arg mode: prefix or postfix
 * arg type: type of the expression
 * arg throw_kind: an integer flag of throw ops
 */
CompTerm*
RoseToTerm::getUnaryOpSpecific(SgUnaryOp* op) {
  Term *e3, *e4;
  if(SgThrowOp* thrw = dynamic_cast<SgThrowOp*>(op)) {
    /*Throw Ops also have a 'throw kind'*/
    // GB (2008-08-23): As of ROSE 0.9.3.a-1593, throw ops no longer have a
    // type list. Or was it only removed temporarily? TODO: Check again
    // sometime.
    e3 = enum_atom(thrw->get_throwKind());
#if 0
    SgTypePtrListPtr types = thrw->get_typeList ();
    SgTypePtrList::iterator it = types->begin();
    List* l = List();
    while (it != types->end()) {
      l->addElement(getTypeSpecific(*it));
      it++;
    }
#else
    e4 = termFactory.makeAtom("null");
#endif
  } else if (SgCastExp* cst = dynamic_cast<SgCastExp*>(op)) {
    /*Casts have a cast type*/
    e3 = enum_atom(cst->get_cast_type());
    /*assure that arity = 4*/
    e4 = termFactory.makeAtom("null");
  } else {
    /*assure that arity = 4*/
    e3 = termFactory.makeAtom("null");
    e4 = termFactory.makeAtom("null");
  }
  return termFactory.makeCompTerm
    ("unary_op_annotation", //5,
     termFactory.makeAtom(op->get_mode() == SgUnaryOp::prefix ? "prefix" : "postfix"),
     getTypeSpecific(op->get_type()),
     e3,
     e4,
     PPI(op));
}

/**
 * class: SgBinaryOp
 * term: binary_op_annotation(type)
 * arg type: the type of the expression
 */
CompTerm*
RoseToTerm::getBinaryOpSpecific(SgBinaryOp* op) {
  return termFactory.makeCompTerm
    ("binary_op_annotation", //2,
     getTypeSpecific(op->get_type()),
     PPI(op));
}

/**
 * class: SgValueExp
 * term: value_annotation(val)
 * arg val: value of the SgValueExp. The possibilities are integers
 * (for booleans and the smaller integer types) or quoted strings
 * using << on ostringstreams for alll other types
 */
CompTerm*
RoseToTerm::getValueExpSpecific(SgValueExp* astNode) {
  Term *val;
  /* int and enum types */
  if(SgIntVal* n = dynamic_cast<SgIntVal*>(astNode)) {
    val = termFactory.makeInt(n->get_value());
  } else if(SgUnsignedIntVal* n = dynamic_cast<SgUnsignedIntVal*>(astNode)) {
    val = termFactory.makeInt(n->get_value());
  } else if(SgShortVal* n = dynamic_cast<SgShortVal*>(astNode)) {
    val = termFactory.makeInt(n->get_value());
  } else if(SgUnsignedShortVal* n = dynamic_cast<SgUnsignedShortVal*>(astNode)) {
    val = termFactory.makeInt(n->get_value());
  } else if (SgLongIntVal* n = dynamic_cast<SgLongIntVal*>(astNode)) {
    val = termFactory.makeInt(n->get_value());
  } else if (SgUnsignedLongVal* n = dynamic_cast<SgUnsignedLongVal*>(astNode)) {
    val = termFactory.makeInt(n->get_value());
  } else if (SgLongLongIntVal* n = dynamic_cast<SgLongLongIntVal*>(astNode)) {
    val = termFactory.makeInt(n->get_value());
  } else if (SgUnsignedLongLongIntVal* n = dynamic_cast<SgUnsignedLongLongIntVal*>(astNode)) {
    val = termFactory.makeInt(n->get_value());
  } else if(SgEnumVal* n = dynamic_cast<SgEnumVal*>(astNode)) {
    /* value*/
    // val = termFactory.makeInt(n->get_value());
    /* name of value*/
    // val = termFactory.makeAtom(n->get_name().getString());
    /* name of declaration*/
    SgEnumType *type = isSgEnumDeclaration(n->get_declaration())->get_type();
    ROSE_ASSERT(type != NULL);
    // val = getEnumTypeSpecific(type);
    return termFactory.makeCompTerm("value_annotation",
			      termFactory.makeInt(n->get_value()),
			      termFactory.makeAtom(n->get_name().getString()),
			      getEnumTypeSpecific(type),
			      PPI(astNode));
  }
  /* float types */
  else if (SgFloatVal* n = dynamic_cast<SgFloatVal*>(astNode)) {
    val = termFactory.makeAtom(n->get_valueString());
  } else if (SgDoubleVal* n = dynamic_cast<SgDoubleVal*>(astNode)) {
    val = termFactory.makeAtom(n->get_valueString());
  } else if (SgLongDoubleVal* n = dynamic_cast<SgLongDoubleVal*>(astNode)) {
    val = termFactory.makeAtom(n->get_valueString());
  }
  /* boolean type */
  else if (SgBoolValExp* n = dynamic_cast<SgBoolValExp*>(astNode)) {
    ostringstream o;
    o << n->get_value();
    string s = o.str();
    val = termFactory.makeAtom(s);
  }
  /* char and string types */
  else if (SgCharVal* n = dynamic_cast<SgCharVal*>(astNode)) {
    val = termFactory.makeInt((int)n->get_value());
  } else if (SgUnsignedCharVal* n = dynamic_cast<SgUnsignedCharVal*>(astNode)) {
    val = termFactory.makeInt((unsigned)n->get_value());
  } else if (SgWcharVal* n = dynamic_cast<SgWcharVal*>(astNode)) {
    ostringstream o;
    o << n->get_valueUL();
    string s = o.str();
    val = termFactory.makeAtom(s);
  } else if (SgStringVal* n = dynamic_cast<SgStringVal*>(astNode)) {
    return termFactory.makeCompTerm
      ("value_annotation", 
       termFactory.makeAtom(n->get_value()),
       MAKE_FLAG(n, usesSingleQuotes),
       MAKE_FLAG(n, usesDoubleQuotes),
       PPI(astNode));
  } else {
    val = termFactory.makeAtom("null");
  }
  return termFactory.makeCompTerm("value_annotation", /*2,*/ val, PPI(astNode));
}
/**
 * class: SgAssignInitializer
 * term: assign_initializer_annotation(tpe)
 * arg tpe: type of the initializer
 */
CompTerm*
RoseToTerm::getAssignInitializerSpecific(SgAssignInitializer* ai) {
  return termFactory.makeCompTerm("assign_initializer_annotation", //2,
			    getTypeSpecific(ai->get_type()),
			    PPI(ai));
}
/**
 * class: SgVarRefExp
 * term: var_ref_exp_annotation(tpe,name,static,scope)
 * arg tpe: type
 * arg name: name
 * arg static: wether the declaration was static
 * arg scope: scope name (either from a namespace, a class or "null")
 */
CompTerm*
RoseToTerm::getVarRefExpSpecific(SgVarRefExp* vr) {
  SgInitializedName* n = vr->get_symbol()->get_declaration();
  /* type: in general, this can be taken "as is" from the ROSE AST. However,
   * ROSE (up to 0.9.4a-8xxx at least) gets a detail wrong: a declaration
   * like "int arr[]" as a function parameter declares a *pointer*, not an
   * array. Thus we check whether the variable might be of this sort, and if
   * yes, we must make a pointer type for it. */
  Term* typeSpecific = NULL;
  SgInitializedName* vardecl = vr->get_symbol()->get_declaration();
  SgType* t = vr->get_type()->stripType(SgType::STRIP_MODIFIER_TYPE
				      | SgType::STRIP_REFERENCE_TYPE
				      | SgType::STRIP_TYPEDEF_TYPE);
  if (isSgFunctionParameterList(vardecl->get_parent()) && isSgArrayType(t)) {
    SgType* baseType = isSgArrayType(t)->get_base_type();
    Term* baseTypeSpecific = getTypeSpecific(baseType);
    typeSpecific = termFactory.makeCompTerm("pointer_type", /*1,*/ baseTypeSpecific);
  } else {
    typeSpecific = getTypeSpecific(n->get_typeptr());
  }
  /* static? (relevant for unparsing if scope is a class)*/
  Term *isStatic;
  SgDeclarationStatement* vdec = n->get_declaration();
  if (vdec != NULL) {
    isStatic =
      makeFlag(vdec->get_declarationModifier().get_storageModifier().isStatic(), "static");
  } else {
    isStatic = makeFlag(false, "static");
  }
  Term* scope;
  if (vdec != NULL) {
    /* named scope or irrelevant?*/
    if (SgNamespaceDefinitionStatement* scn =
	isSgNamespaceDefinitionStatement(vdec->get_parent())) {
      scope = getNamespaceScopeName(scn);
    } else if (SgClassDefinition* scn =
	       isSgClassDefinition(vdec->get_parent())) {
      scope = getClassScopeName(scn);
    } else {
      scope = termFactory.makeAtom("null");
    }
  } else {
    scope = termFactory.makeAtom("null");
  }

  return termFactory.makeCompTerm
    ("var_ref_exp_annotation", //5,
     typeSpecific,
     /* name*/ termFactory.makeAtom(n->get_name().getString()),
     isStatic,
     scope,
     PPI(vr));
}

/**
 * class: SgInitializedName
 * term: initialized_name_annotation(tpe,name,static,scope)
 * arg tpe: type
 * arg name: name
 * arg static: wether the declaration was static
 * arg scope: scope name (either from a namespace, a class or "null")
 */
CompTerm*
RoseToTerm::getInitializedNameSpecific(SgInitializedName* n) {
  /* named scope or irrelevant?*/
  return termFactory.makeCompTerm
    ("initialized_name_annotation", //4,
     getTypeSpecific(n->get_typeptr()),
     termFactory.makeAtom(n->get_name().getString()),
     /* static? (relevant for unparsing if scope is a class)*/
     makeFlag(n->get_storageModifier().isStatic(), "static"),
     getScope(n),
     PPI(n));
}

/**
 * class: SgClassDeclaration
 * term: class_declaration_annotation(name,class_type,type)
 * arg name: class name
 * arg class_type: class type as required by ROSE
 * arg type: SgClassType of the class declaration.
 * */
CompTerm*
RoseToTerm::getClassDeclarationSpecific(SgClassDeclaration* cd) {
  Term *typet = getTypeSpecific(cd->get_type());
  typeWasDeclaredBefore(typet->getRepresentation());
  return termFactory.makeCompTerm
    ("class_declaration_annotation", //4,
     /* add name and type*/
     termFactory.makeAtom(cd->get_name().str()),
     enum_atom(cd->get_class_type()),
     getTypeSpecific(cd->get_type()),
     PPI(cd));
}

/**
 * class: SgClassDefinition
 * term: class_definition_annotation(fileinfo)
 * arg fileinfo: file info information for end of construct
 * */
CompTerm*
RoseToTerm::getClassDefinitionSpecific(SgClassDefinition* def) {
  List *inhs = termFactory.makeList();
  SgBaseClassPtrList& is = def->get_inheritances();
  if (&is != NULL) {
    for (SgBaseClassPtrList::iterator it = is.begin();
	 it != is.end(); ++it)
      inhs->addElement(termFactory.makeCompTerm
		       ("base_class", 
			traverseSingleNode((*it)->get_base_class()),
			MAKE_FLAG(*it, isDirectBaseClass),
			termFactory.makeCompTerm("default_annotation", /*1,*/ termFactory.makeAtom("null"))));
  }

  return termFactory.makeCompTerm
    ("class_definition_annotation",
     inhs,
     /* add end of construct*/
     getFileInfo(def->get_endOfConstruct()),
     PPI(def));
}

/**
 * class: SgNamespaceDeclarationStatement
 * term: namespace_declaration_statement(name,unnamed)
 * arg name: name of the namespace
 * arg unnamed: unnamed namespace
 */
CompTerm*
RoseToTerm::getNamespaceDeclarationStatementSpecific
(SgNamespaceDeclarationStatement* dec) {
  return termFactory.makeCompTerm
    ("namespace_declaration_statement_annotation", //3,
     /* name*/ termFactory.makeAtom(dec->get_name().getString()),
     /* unnamed?*/ termFactory.makeInt((int) dec->get_isUnnamedNamespace()),
     PPI(dec));
}

/** create a list of atoms from a bit vector*/
Term*
RoseToTerm::getBitVector(const SgBitVector &v, const std::vector<std::string> &names) {
  List* l = termFactory.makeList();
  reverse_iterator<SgBitVector::const_iterator> it = v.rbegin();
  reverse_iterator<vector<string>::const_iterator> name = names.rbegin();

  name++; // skip over e_last_xxx
  ROSE_ASSERT(v.size()+1 <= names.size());
  while(it != v.rend()) {
    ROSE_ASSERT(name != names.rend());
    if (*it == true)
      l->addFirstElement(termFactory.makeAtom(*name));
    it++;
    name++;
  }
  return l;
}

/**
 * class: SgConditionalExp
 * term: conditional_exp_annotation(type)
 * arg type: type of the expression
 * */
CompTerm*
RoseToTerm::getConditionalExpSpecific(SgConditionalExp* c) {
  return termFactory.makeCompTerm
    ("conditional_exp_annotation", //2,
     getTypeSpecific(c->get_type()),
     PPI(c));
}

/**
 * class: SgLabelStatement
 * term: label_annotation(label)
 * arg label: name of the label
 * */
CompTerm*
RoseToTerm::getLabelStatementSpecific(SgLabelStatement* label) {
  //get name of the label
  string s = *(new string(label->get_label().getString()));
  // create a term containing the name;
  return termFactory.makeCompTerm("label_annotation", //2,
			    termFactory.makeAtom(s),
			    PPI(label));
}

/**
 * class: SgGotoStatement
 * term: label_annotation(label)
 * arg label: name of the label associated with the goto
 * */
CompTerm*
RoseToTerm::getGotoStatementSpecific(SgGotoStatement* sgoto) {
  SgLabelStatement* l = sgoto->get_label();
  ROSE_ASSERT(l != NULL);
  /* we need the information to create the label*/
  return getLabelStatementSpecific(l);
}

/**
 * class SgEnumDeclaration
 * term: enum_declaration_annotation(name,decl_att)
 * arg name: name of the enum
 * arg decl_att: declaration attributes (see SgDeclarationStatement
 */
CompTerm*
RoseToTerm::getEnumDeclarationSpecific(SgEnumDeclaration* d) {
  ROSE_ASSERT(d != NULL);
  //get Enum name
  string ename = d->get_name().getString();
  if (ename == "") {
    /* nameless enum declarations can occur in typedefs */
    SgTypedefDeclaration *td;
    if (td = isSgTypedefDeclaration(d->get_parent())) {
      ename = td->get_mangled_name().str();
    }
  }
  ROSE_ASSERT(ename != "");
  Term *typet = getTypeSpecific(d->get_type());
  typeWasDeclaredBefore(typet->getRepresentation());

  //create term
  return termFactory.makeCompTerm
    ("enum_declaration_annotation", //4,
     termFactory.makeAtom(ename),
     getDeclarationAttributes(d),
     termFactory.makeInt(d->get_embedded()),
     PPI(d));
}

/**
 * class SgDeclarationStatement
 * term decl_attributes(nameonly,forward,externbrace,skipelaboratetype,neednamequalifier
 * arg all: boolean flags common to all declaration statements
 */
CompTerm*
RoseToTerm::getDeclarationAttributes(SgDeclarationStatement* s) {
  ROSE_ASSERT(s != NULL);
  return termFactory.makeCompTerm
    ("decl_attributes", //5,
     termFactory.makeInt(s->get_nameOnly()),
     termFactory.makeInt(s->get_forward()),
     termFactory.makeInt(s->get_externBrace()),
     termFactory.makeInt(s->get_skipElaborateType()),
     // ROSE 0.8.8a: termFactory.makeInt(s->get_need_name_qualifier()),
     termFactory.makeInt(0)); // set dummy value
}


/**
 * class: SgDeleteExp
 * term: delete_exp_annotation(is_array,need_global_specifier)
 * arg all: short "flags"
 */
CompTerm*
RoseToTerm::getDeleteExpSpecific(SgDeleteExp* de) {
  return termFactory.makeCompTerm("delete_exp_annotation", //3,
			    MAKE_FLAG(de, is_array),
			    MAKE_FLAG(de, need_global_specifier),
			    PPI(de));
}

/**
 * class: SgRefExp
 * term: ref_exp_annotation(type)
 * arg type: type of the expression
 */
CompTerm*
RoseToTerm::getRefExpSpecific(SgRefExp* re) {
  return termFactory.makeCompTerm("ref_exp_annotation", //2,
			    getTypeSpecific(re->get_type()),
			    PPI(re));
}

/**
 * class: SgVariableDeclaration
 * term: variable_declaration_specific(dm)
 * arg dm: declaration modifier information (see annotation of SgDeclarationModifier)
 */

CompTerm*
RoseToTerm::getVariableDeclarationSpecific(SgVariableDeclaration* d) {
  ROSE_ASSERT(d != NULL);
  /* add base type forward declaration */
  SgNode *baseTypeDecl = NULL;
  if (d->get_variableDeclarationContainsBaseTypeDefiningDeclaration()) {
    baseTypeDecl = d->get_baseTypeDefiningDeclaration();
  } else {
    /* The complication is that in the AST, the type declaration member is
     * only set if it is a type definition, not if it is a forward
     * declaration. So we need to check whether the base type (possibly
     * below layers of pointers) is a class type, and whether its first
     * declaration appears to be hidden here in the variable declaration. */
    SgClassType *ctype = isSgClassType(d->get_variables().front()
				       ->get_type()->findBaseType());
    if (ctype) {
      /* See if the type is declared in the scope where it belongs. If no,
       * then the declaration is apparently inside this variable
       * declaration, so we add it as a subterm. */
      SgDeclarationStatement *cdecl = ctype->get_declaration();
      SgSymbol *symbol = cdecl->get_symbol_from_symbol_table();
      if (!typeWasDeclaredBefore(
	   getTypeSpecific(symbol->get_type())->getRepresentation())) {
	baseTypeDecl = cdecl;
      }
    }
  }

  return termFactory.makeCompTerm
    ("variable_declaration_specific", //3,
     getDeclarationModifierSpecific(&(d->get_declarationModifier())),
     (baseTypeDecl != NULL
      ? traverseSingleNode(baseTypeDecl)
      : termFactory.makeAtom("null")),
     PPI(d));
}

/**
 * class: SgVarArgCopyOp, SgVarArgEndOp, SgVarArgOp, SgVarArgStartOp, SgVarArgStartOneOperatorOp
 * term: vararg_annotation(type)
 * arg type: type of the expression
 */
CompTerm*
RoseToTerm::getVarArgSpecific(SgExpression* e) {
  return termFactory.makeCompTerm("vararg_annotation", //2,
			    getTypeSpecific(e->get_type()),
			    PPI(e));
}

/**
 * traverse single node
 */
Term*
RoseToTerm::traverseSingleNode(SgNode* astNode) {
  if (astNode == NULL) 
    return termFactory.makeAtom("null");

  BasicTermPrinter tempt(termFactory);
  tempt.traverse(astNode);
  Term*  rep = tempt.getTerm();
  ROSE_ASSERT(rep != NULL);
  return rep;
}

/**
 * class: SgAccessModifier
 * term: access_modifier(a)
 * arg a: enum value of SgAccessModifier (see ROSE docs!)
 */
// CompTerm*
// RoseToTerm::getAccessModifierSpecific(SgAccessModifier* a) {
//   CompTerm* t = CompTerm("access_modifier");
//   t->addSubterm(Int((int) a->get_modifier()));
//   return t;
// }

/**
 * class: SgBaseClassModifier
 * term: base_class_modifier(b,a)
 * arg b: enum value of SgBaseClassModifier (see ROSE docs!)
 * arg a: enum value of SgAccessModifier
 */
CompTerm*
RoseToTerm::getBaseClassModifierSpecific(SgBaseClassModifier* b) {
  return termFactory.makeCompTerm
    ("base_class_modifier", //2,
     termFactory.makeInt((int) b->get_modifier()),
     termFactory.makeInt((int) b->get_accessModifier().get_modifier()));
}

/**
 * class: SgFunctionModifier
 * term: function_modifier(b)
 * arg b: bit vector of SgFunctionModifier as List (true = 1)
 */
CompTerm*
RoseToTerm::getFunctionModifierSpecific(SgFunctionModifier* f) {
  return termFactory.makeCompTerm
    ("function_modifier", //1,
     /* get bit vector and convert to PROLOG*/
     getBitVector(f->get_modifierVector(), re.vec_function_modifier_enum));
}

/**
 * class: SgSpecialFunctionModifier
 * term: special_function_modifier(b)
 * arg b: bit vector of SgFunctionModifier as List (true = 1)
 */
CompTerm*
RoseToTerm::getSpecialFunctionModifierSpecific(SgSpecialFunctionModifier* f) {
  return termFactory.makeCompTerm
    ("special_function_modifier", //1,
     /* get bit vector and convert to PROLOG*/
     getBitVector(f->get_modifierVector(),re.vec_special_function_modifier_enum));
}

/**
 * class: SgLinkageModifier
 * term: linkage_modifier(a)
 * arg a: enum value of SgLinkageModifier (see ROSE docs!)
 */
CompTerm*
RoseToTerm::getLinkageModifierSpecific(SgLinkageModifier* a) {
  return termFactory.makeCompTerm("linkage_modifier", //1,
			    termFactory.makeInt((int) a->get_modifier()));
}
/**
 * class: SgStorageModifier
 * term: storage_modifier(a)
 * arg a: enum value of SgStorageModifier (see ROSE docs!)
 */
CompTerm*
RoseToTerm::getStorageModifierSpecific(SgStorageModifier* a) {
  return termFactory.makeCompTerm("storage_modifier", //1,
				  enum_atom(a->get_modifier()));
}
/**
 * class: SgElaboratedTypeModifier
 * term: elaborated_type_modifier(a)
 * arg a: enum value of SgElaboratedTypeModifier (see ROSE docs!)
 */
CompTerm*
RoseToTerm::getElaboratedTypeModifierSpecific(SgElaboratedTypeModifier* a) {
  return termFactory.makeCompTerm("elaborated_type_modifier", //1,
			    termFactory.makeInt((int) a->get_modifier()));
}
/**
 * class: SgConstVolatileModifier
 * term: const_volatile_modifier(a)
 * arg a: enum value of SgConstVolatileModifier (see ROSE docs!)
 */
CompTerm*
RoseToTerm::getConstVolatileModifierSpecific(SgConstVolatileModifier* a) {
  return termFactory.makeCompTerm("const_volatile_modifier", //1,
				  enum_atom(a->get_modifier()));
}
/**
 * class: SgUPC_AccessModifier
 * term: upc_access_modifier(a)
 * arg a: enum value of SgUPC_AccessModifier (see ROSE docs!)
 */
CompTerm*
RoseToTerm::getUPC_AccessModifierSpecific(SgUPC_AccessModifier* a) {
  return termFactory.makeCompTerm
    ("upc_access_modifier", //1,
     enum_atom(a->get_modifier()));
}

/**
 * class: SgTypeModifier
 * term: type_modifier(b,u,c,e)
 * arg b: bit vector of SgTypeModifier
 * arg u: enum of SgUPC_AccessModifier
 * arg c: enum of SgConstVolatileModifier
 * arg e: enum of SgElaboratedTypeModifier
 */
CompTerm*
RoseToTerm::getTypeModifierSpecific(SgTypeModifier* a) {
  return termFactory.makeCompTerm
    ("type_modifier", //4,
     /* get bit vector and convert to PROLOG*/
     getBitVector(a->get_modifierVector(), re.vec_type_modifier_enum),
     /* add enums*/
     enum_atom(a->get_upcModifier().get_modifier()),
     enum_atom(a->get_constVolatileModifier().get_modifier()),
     enum_atom(a->get_elaboratedTypeModifier().get_modifier()));
}

/**
 * class: SgDeclarationModifier
 * term: declaration_modifier(e,t,a,s)
 * arg e: enum of SgDeclarationModifier
 * arg t: term representation of SgTypeModifier
 * arg a: enum of SgAccessModifier
 * arg s: enum of SgStorageModifier
 */
CompTerm*
RoseToTerm::getDeclarationModifierSpecific(SgDeclarationModifier* dm) {
  return termFactory.makeCompTerm
    ("declaration_modifier", //4,
     getBitVector(dm->get_modifierVector(), re.vec_declaration_modifier_enum),
     getTypeModifierSpecific(&(dm->get_typeModifier())),
     enum_atom(dm->get_accessModifier().get_modifier()),
     enum_atom(dm->get_storageModifier().get_modifier()));
}

/**
 * class: SgFunctionRefExp
 * term: function_ref_exp_annotation(n,ft)
 * arg n: name of the function
 * arg ft: type of the function (via getTypeSpecific)
 */
CompTerm*
RoseToTerm::getFunctionRefExpSpecific(SgFunctionRefExp* r) {
  ROSE_ASSERT(r != NULL);
  /* get name and type from SgFunctionSymbol that is linked from this node*/
  SgFunctionSymbol* s = r->get_symbol();
  ROSE_ASSERT(s != NULL);
  SgType* tpe = s->get_type();
  ROSE_ASSERT(tpe != NULL);

  // Fortran-specific: store subprogram kind (subroutine or procedure)
  // cf. TermToRose::createDummyFunctionDeclaration()
  // Note that the function declaration is explicitly marked and I think this is better than
  // getting the return type.
  SgFunctionSymbol* functionSymbol = r->get_symbol();
  ROSE_ASSERT(functionSymbol != NULL);
  SgFunctionDeclaration* functionDeclaration = functionSymbol->get_declaration();
  ROSE_ASSERT(functionDeclaration != NULL);
  SgProcedureHeaderStatement* procedureHeaderStatement = 
    isSgProcedureHeaderStatement(functionDeclaration);
  SgProcedureHeaderStatement::subprogram_kind_enum subprogram_kind = 
    SgProcedureHeaderStatement::e_unknown_kind;
  if (procedureHeaderStatement)
    subprogram_kind = procedureHeaderStatement->get_subprogram_kind();

  /*create  Term*/
  return termFactory.makeCompTerm("function_ref_exp_annotation", //3,
			    termFactory.makeAtom(s->get_name().getString()),
			    getTypeSpecific(tpe),
			    enum_atom(subprogram_kind),
			    PPI(r));

}
/**
 * class: SgMemberFunctionRefExp
 * term: member_function_ref_exp_annotation(sym,vc,ft,nq)
 * arg sym: member function symbol annotation
 * arg vc: wether this is a virtual call
 * arg ft: type of the function (via getTypeSpecific)
 * arg nq: wether a qualifier is needed
 */
CompTerm*
RoseToTerm::getMemberFunctionRefExpSpecific(SgMemberFunctionRefExp* r) {
  ROSE_ASSERT(r != NULL);
  ///* get member function symbol information*/
  SgMemberFunctionSymbol* s = r->get_symbol();
  ROSE_ASSERT(s != NULL);

  return termFactory.makeCompTerm
    ("member_function_ref_exp_annotation", //5,
     //getMemberFunctionSymbolSpecific(s),
     termFactory.makeAtom(r->get_symbol()->get_name()),
     termFactory.makeInt(r->get_virtual_call()), // virtual call?
     getTypeSpecific(s->get_type()),   // type
     termFactory.makeInt(r->get_need_qualifier()),   // need qualifier?
     PPI(r));
}

/**
 * class: SgFunctionCallExp
 * term: function_call_exp_annotation(rt)
 * arg rt: return type (via getTypeSpecific)
 */
CompTerm*
RoseToTerm::getFunctionCallExpSpecific(SgFunctionCallExp* c) {
  ROSE_ASSERT(c != NULL);
  /* create  Term*/
  return termFactory.makeCompTerm("function_call_exp_annotation", //2,
			    getTypeSpecific(c->get_type()),
			    PPI(c));
}


/**
 * class: SgMemberFunctionDeclaration
 * term: member_function_declaration_annotation(t,name,scope,mod)
 * term t: type
 * term name: name
 * term scope: class scope
 * arg mod: declaration modifier representation
 */

CompTerm*
RoseToTerm::getMemberFunctionDeclarationSpecific(SgMemberFunctionDeclaration* decl) {
  /* add scope */
  SgClassDefinition* def = decl->get_class_scope();

  /* create term and append type and name */
  return termFactory.makeCompTerm
    ("member_function_declaration_annotation", //5,
     getTypeSpecific(decl->get_type()),
     termFactory.makeAtom(decl->get_name().getString()), /* add the node's name*/
     /* we add the complete class scope name here */
     getClassScopeName(def),
     /* add declaration modifier specific*/
     getDeclarationModifierSpecific(&(decl->get_declarationModifier())),
     getSpecialFunctionModifierSpecific(&(decl->get_specialFunctionModifier())),
     PPI(decl));
}

/**
 * class: SgClassDefinition
 * term: class_scope(name,type)
 * arg name: qualified name of class scope
 * arg type: class type enum
 */
CompTerm*
RoseToTerm::getClassScopeName(SgClassDefinition* def) {
  ROSE_ASSERT(def != NULL);
  /* get qualified name of scope and type of class declaration*/
  SgClassDeclaration* decl = def->get_declaration();
  ROSE_ASSERT(decl != NULL);
  string qname = decl->get_qualified_name().getString();
  /* create a CompTerm*/
  return termFactory.makeCompTerm("class_scope", //3,
			    termFactory.makeAtom(qname),
			    enum_atom(decl->get_class_type()),
			    PPI(def));
}

/**
 * class: SgNamespaceDefinition
 * term: namespace_scope(name,unnamed)
 * arg name: qualified name of the namespace
 * arg unnamed: wether the namespace is unnamed
 */

CompTerm*
RoseToTerm::getNamespaceScopeName(SgNamespaceDefinitionStatement* def) {
  ROSE_ASSERT(def != NULL);
  /* get declaration*/
  SgNamespaceDeclarationStatement* decl = def->get_namespaceDeclaration();
  ROSE_ASSERT(decl != NULL);
  /* create annotation term*/
  return termFactory.makeCompTerm
    ("namespace_scope", 
     termFactory.makeAtom(decl->get_qualified_name().getString()),
     MAKE_FLAG(decl, isUnnamedNamespace),
     PPI(def));
}


/**
 * class: SgMemberFunctionSymbol
 * term: member_function_symbol_annotation(mf,scope)
 * arg mf: complete PROLOG-Representation of member function declaration without definition
 * arg scope: class scope (see getClassScopeName)
 */
CompTerm*
RoseToTerm::getMemberFunctionSymbolSpecific(SgMemberFunctionSymbol* sym) {
  SgMemberFunctionDeclaration* orig_decl = sym->get_declaration();
  ROSE_ASSERT(orig_decl != NULL);
  /* save wether original node had declaration*/
  bool orig_decl_has_def = (orig_decl->get_definition() == NULL);
  /* clone node (deep copy) */
  // ROSE 0.8.8a SgMemberFunctionDeclaration* cop_decl = isSgMemberFunctionDeclaration(orig_decl->copy(SgTreeCopy()));
  // GB (2008-03-05): This copy statement produces interesting warnings like:
  // WARNING: Scopes do NOT match! variable = 0x2aaaadaa2760 = n (could this
  // be a static variable, or has the symbol table been setup before the
  // scopes have been set?)
  // Error: Symbol not found for initializedName_copy = 0x2aaaadaa2760 = n
  SgMemberFunctionDeclaration* cop_decl = isSgMemberFunctionDeclaration(orig_decl->copy(*new SgTreeCopy()));
  ROSE_ASSERT(cop_decl != NULL);
  /* make sure we didn't change the orginal node*/
  ROSE_ASSERT(orig_decl_has_def == (orig_decl->get_definition() == NULL));
  cop_decl->set_definition(NULL);
  // GB (2008-03-05): For some reason, cop_decl has a null parent. This
  // causes problems within the nested traversal. Therefore: Copy the parent
  // pointer manually. (It took me two days to find this bug, BTW.)
  cop_decl->set_parent(orig_decl->get_parent());
  /* add scope*/
  SgClassDefinition* cdef = orig_decl->get_class_scope();
  ROSE_ASSERT(cdef != NULL);

  CompTerm* t = termFactory.makeCompTerm
    ("member_function_symbol_annotation", //2,
     traverseSingleNode(cop_decl),
     getClassScopeName(cdef));

  delete cop_decl;
  return t;
}

/**
 * class: SgSizeOfOp
 * term: size_of_op_annotation(otype,etype)
 * term otype: operand type
 * term etype: expression type
 */
CompTerm*
RoseToTerm::getSizeOfOpSpecific(SgSizeOfOp* o) {
  Term* e1, *e2;
  ROSE_ASSERT(o != NULL);
  /* create type info if types are present*/
  SgType* otype = o->get_operand_type();
  if (otype != NULL) {
    e1 = getTypeSpecific(otype);
  } else {
    e1 = termFactory.makeAtom("null");
  }
  SgType* etype = o->get_type();
  if (etype != NULL) {
    e2 = getTypeSpecific(etype);
  } else {
    e2 = termFactory.makeAtom("null");
  }
  return termFactory.makeCompTerm("size_of_op_annotation", /*3,*/ e1, e2, PPI(o));
}


/**
 * class: SgTypedefDeclaration
 * term: typedef_annotation(name,base_type,decl)
 * arg name: qualified name of the typedef
 * arg base_type: base type of the typedef
 * arg decl: declaration statement (unparsed), null if none exists
 */
CompTerm*
RoseToTerm::getTypedefDeclarationSpecific(SgTypedefDeclaration* d) {
  ROSE_ASSERT(d != NULL);
  /*get name*/
  // FIXME :: t->addSubterm(Atom(d->get_qualified_name().getString()));

  return termFactory.makeCompTerm
    ("typedef_annotation", //3,
     termFactory.makeAtom(d->get_name().getString()),
     /*get base type*/
     getTypeSpecific(d->get_base_type()),
     /* the base type declaration is no longer in the typedef
      * annotation; it is now a child of the typedef declaration
      * itself */
     PPI(d));
}



/**
 *class: SgTypePtrList
 *term: [T|Ts]
 *arg [T|Ts]: List of SgTypes
 */
Term*
RoseToTerm::getTypePtrListSpecific(SgTypePtrList& tl) {
  List* alist = termFactory.makeList();
  if (&tl != NULL) {
    SgTypePtrList::iterator it = tl.begin();
    while(it != tl.end()) {
      alist->addElement(getTypeSpecific(*it));
      it++;
    }
  }
  return alist;
}

/**
 * class: SgPragma
 * term: pragma(name)
 * arg name: name
 */
CompTerm*
RoseToTerm::getPragmaSpecific(SgPragma* n) {
  // Adrian 2007-11-27:
  // This is to work around a bug in ROSE?/EDG? that inserts whitespaces
  // Hopefully I can remove it in a later revision
  string s = n->get_pragma();
  s.erase(remove_if( s.begin(), s.end(),
		     bind1st(equal_to<char>(), ' ')),
	  s.end());
  return termFactory.makeCompTerm("pragma_annotation", /*1,*/ termFactory.makeAtom(s));
}

/**
 * class: SgImplicitStatement
 * term: implicit_statement(name)
 */
CompTerm*
RoseToTerm::getImplicitStatementSpecific(SgImplicitStatement* is) {
  return termFactory.makeCompTerm("implicit_statement_annotation", 
			    MAKE_FLAG(is, implicit_none), 
			    PPI(is));
}

/**
 * class: SgAttributeSpecificationStatement
 */
CompTerm*
RoseToTerm::getAttributeSpecificationStatementSpecific(SgAttributeSpecificationStatement* ass) {
  return termFactory.makeCompTerm
    ("attribute_specification_statement_annotation",
     enum_atom(ass->get_attribute_kind()),
     traverseSingleNode( ass->get_parameter_list() ),
     traverseSingleNode( ass->get_bind_list() ),
     PPI(ass));
}


CompTerm*
RoseToTerm::getCommonBlockObjectSpecific(SgCommonBlockObject* cbo) {
  return termFactory.makeCompTerm("common_block_object_annotation", 
			    termFactory.makeAtom(cbo->get_block_name()),
			    PPI(cbo));
}


CompTerm* 
RoseToTerm::getTypeComplexSpecific(SgTypeComplex *tc) {
  return termFactory.makeCompTerm("type_complex", getTypeSpecific(tc->get_base_type()));
}

Term* 
RoseToTerm::getTypeStringSpecific(SgTypeString *ts) {
  SgExpression* length = ts->get_lengthExpression();
  if (length)
    return termFactory.makeCompTerm("type_fortran_string", traverseSingleNode(length));
  else return termFactory.makeAtom("type_string");
}

CompTerm*
RoseToTerm::getIfStmtSpecific(SgIfStmt* ifstmt) {
  return termFactory.makeCompTerm
    ("if_stmt_annotation",
     MAKE_FLAG(ifstmt, has_end_statement),
     MAKE_FLAG(ifstmt, use_then_keyword),
     MAKE_FLAG(ifstmt, is_else_if_statement),
     PPI(ifstmt));
}

CompTerm*
RoseToTerm::getFortranDoSpecific(SgFortranDo* dostmt) {
  return termFactory.makeCompTerm
    ("fortran_do_annotation",
     MAKE_FLAG(dostmt, old_style),
     MAKE_FLAG(dostmt, has_end_statement),
     PPI(dostmt));
}

CompTerm*
RoseToTerm::getFortranIncludeLineSpecific(SgFortranIncludeLine* includeline) {
  return termFactory.makeCompTerm
    ("fortran_include_line_annotation",
     termFactory.makeAtom(includeline->get_filename()),
     PPI(includeline));
}

CompTerm*
RoseToTerm::getAsteriskShapeExpSpecific(SgAsteriskShapeExp* e) {
  return termFactory.makeCompTerm
    ("asterisk_shape_exp_annotation",
     getTypeSpecific(e->get_type()),
     PPI(e));
}

CompTerm*
RoseToTerm::getWriteStatementSpecific(SgWriteStatement* n) {
  return termFactory.makeCompTerm
    ("write_statement_annotation",
     // from IOStatement
     //get_io_stmt_list() traversal successor
     traverseSingleNode( n->get_unit()         ),
     traverseSingleNode( n->get_iostat()       ),
     traverseSingleNode( n->get_err()          ),
     traverseSingleNode( n->get_iomsg()        ),
     // from WriteStatement
     traverseSingleNode( n->get_format()       ),
     traverseSingleNode( n->get_rec()          ),
     traverseSingleNode( n->get_namelist()     ),
     traverseSingleNode( n->get_advance()      ),
     traverseSingleNode( n->get_asynchronous() ),
     PPI(n));
}

CompTerm*
RoseToTerm::getPrintStatementSpecific(SgPrintStatement* n) {
  return termFactory.makeCompTerm
    ("print_statement_annotation",
     // from IOStatement
     //get_io_stmt_list() traversal successor
     traverseSingleNode( n->get_unit()         ),
     traverseSingleNode( n->get_iostat()       ),
     traverseSingleNode( n->get_err()          ),
     traverseSingleNode( n->get_iomsg()        ),
     // from PrintStatement
     traverseSingleNode( n->get_format()       ),
     PPI(n));
}


List* 
RoseToTerm::getFormatItemList(SgFormatItemList* itemlist) {
  if (itemlist == NULL) 
    return termFactory.makeList();

  SgFormatItemPtrList& items = itemlist->get_format_item_list();
  SgFormatItemPtrList::iterator it;
  List* l = termFactory.makeList();
  for (it = items.begin(); it != items.end(); ++it) {
    l->addElement(RoseToTerm::traverseSingleNode(*it));
  }
  return l;
}

CompTerm*
RoseToTerm::getFormatItemSpecific(SgFormatItem* n) {
  return termFactory.makeCompTerm
    ("format_item_annotation",
     termFactory.makeInt(n->get_repeat_specification()),
     traverseSingleNode(n->get_data()),
     getFormatItemList(n->get_format_item_list()));
}

CompTerm*
RoseToTerm::getFormatStatementSpecific(SgFormatStatement* n) {
  return termFactory.makeCompTerm
    ("format_statement_annotation", 
     getFormatItemList(n->get_format_item_list()),
     // From DeclarationStmt
     termFactory.makeAtom(n->get_binding_label()),
     // From Statement
     // FIXME: we should probably add numeric labels to the file_info
     traverseSingleNode(n->get_numeric_label()),
     PPI(n));
}

CompTerm*
RoseToTerm::getLabelRefExpSpecific(SgLabelRefExp* n) {
  return termFactory.makeCompTerm
    ("label_ref_exp_annotation",
     traverseSingleNode(n->get_symbol()));
}

CompTerm*
RoseToTerm::getLabelSymbolSpecific(SgLabelSymbol* n) {
  return termFactory.makeCompTerm
    ("label_symbol_annotation",
     termFactory.makeInt(n->get_numeric_label_value()),
     enum_atom(n->get_label_type())
     );
}

CompTerm*
RoseToTerm::getAsmOpSpecific(SgAsmOp* op) {
  return termFactory.makeCompTerm("asm_op_annotation",
				  enum_atom(op->get_constraint()),
				  // there can be multiple or'ed values
				  termFactory.makeInt(op->get_modifiers()),
				  MAKE_FLAG(op, recordRawAsmOperandDescriptions),
				  MAKE_FLAG(op, isOutputOperand),
				  termFactory.makeAtom(op->get_constraintString()),
				  termFactory.makeAtom(op->get_name()),
				  PPI(op));
}

CompTerm*
RoseToTerm::getAsmStmtSpecific(SgAsmStmt* stmt) {
  return termFactory.makeCompTerm("asm_stmt_annotation",
				  termFactory.makeAtom(stmt->get_assemblyCode()),
				  MAKE_FLAG(stmt, useGnuExtendedFormat),
				  MAKE_FLAG(stmt, isVolatile),
				  PPI(stmt));
}

CompTerm*
RoseToTerm::getAsmx86InstructionSpecific(SgAsmx86Instruction* i) {
  return termFactory.makeCompTerm("asm_x64instruction_annotation",
				  enum_atom(i->get_kind()),
				  enum_atom(i->get_baseSize()),
				  enum_atom(i->get_operandSize()),
				  enum_atom(i->get_addressSize()),
				  MAKE_FLAG(i, lockPrefix),
				  enum_atom(i->get_repeatPrefix()),
				  enum_atom(i->get_branchPrediction()),
				  enum_atom(i->get_segmentOverride()),
				  /* From SgAsmInstruction */
				  termFactory.makeAtom(i->get_mnemonic()),
				  //get_raw_bytes(),
				  /* From SgAsmStatement */
				  //get_address()
				  termFactory.makeAtom(i->get_comment())
				 );
}
