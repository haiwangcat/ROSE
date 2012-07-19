#include "valueGraphNode.h"
#include <utilities/utilities.h>
#include <staticSingleAssignment.h>
#include <sageBuilder.h>
#include <boost/assign/list_inserter.hpp>
#include <boost/lexical_cast.hpp>
#include <boost/foreach.hpp>


namespace Backstroke
{
	
using namespace std;
using namespace boost;
using namespace SageBuilder;
using namespace SageInterface;

#define foreach BOOST_FOREACH

namespace
{
    //! An internal function to return a cost for state saving depending on the type.
    int getCostFromType_(SgType* t)
    {
        ROSE_ASSERT(t);

        t = t->stripTypedefsAndModifiers();
        if (SgReferenceType* refType = isSgReferenceType(t))
        {
            t = refType->get_base_type();
        }

        switch (t->variantT())
        {
            case V_SgTypeBool:
                return sizeof(bool);
            case V_SgTypeInt:
                return sizeof(int);
            case V_SgTypeChar:
                return sizeof(char);
            case V_SgTypeShort:
                return sizeof(short);
            case V_SgTypeLong:
                return sizeof(long);
            case V_SgTypeLongLong:
                return sizeof(long long);
            case V_SgTypeUnsignedChar:
                return sizeof(unsigned char);
            case V_SgTypeUnsignedInt:
                return sizeof(unsigned int);
            case V_SgTypeUnsignedShort:
                return sizeof(unsigned short);
            case V_SgTypeUnsignedLongLong:
                return sizeof(unsigned long long);
            case V_SgTypeUnsignedLong:
                return sizeof(unsigned long);
            case V_SgTypeFloat:
                return sizeof(float);
            case V_SgTypeDouble:
                return sizeof(double);
            case V_SgClassType:
                //ROSE_ASSERT(false);
                return 1000;
            case V_SgPointerType:
            {
                //SgPointerType* pType = isSgPointerType(t);
                //return getCostFromType(pType->get_base_type());
                return sizeof(void*);
            }
            case V_SgTypedefType:
                return getCostFromType_(t->stripTypedefsAndModifiers());
            case V_SgEnumType:
                return sizeof(int);
            default:
                cout << t->class_name() << ' ' << t->unparseToString() << endl;
                //ROSE_ASSERT(!"Unknow type.");
                return 100;
        }

        ROSE_ASSERT(false);
        return 0;
    }
    
    int getCostFromType(SgType* t)
    {
        // Enlarge the cost to offset the side effect of trivail costs.
        return getCostFromType_(t) * 100;
    }
}


std::string ScalarValueNode::toString() const
{
	ostringstream os;
	if (SgValueExp* valueExp = isSgValueExp(astNode))
    {
        if (!isSgStringVal(astNode))
            os << valueExp->unparseToString() + "\\n";
    }

    if (isSgThisExp(astNode))
        os << "THIS";
    else if (isTemp())
		os << "TEMP";
    else
        os << var << " ";
	return os.str();
}


VectorElementNode::VectorElementNode(const VersionedVariable& vec, 
    const VersionedVariable& index, SgFunctionCallExp* funcCallExp)
: ValueNode(funcCallExp), vecVar(vec), indexVar(index), indexVal(NULL)
{
    SgBinaryOp* binExp = isSgBinaryOp(funcCallExp->get_function());
    ROSE_ASSERT(binExp);
    vecExp = binExp->get_lhs_operand();
    indexExp = funcCallExp->get_args()->get_expressions()[0];
    if (SgCastExp* castExp = isSgCastExp(indexExp))
        indexVal = isSgValueExp(castExp->get_operand());
    else
        indexVal = isSgValueExp(indexExp);
}


std::string VectorElementNode::toString() const
{
	ostringstream os;
    os << vecVar << '[';
    if (indexVal)
        os << indexVal->unparseToString();
    else 
        os << indexVar;
    os << "]\\n";

	return os.str();
}

SgExpression* VectorElementNode::buildExpression() const
{
    SgExpression* var = vecVar.getVarRefExp();
    SgType* varType = var->get_type();
    if (SgPointerType* pt = isSgPointerType(varType))
    {
        varType = pt->get_base_type();
        var = SageBuilder::buildPointerDerefExp(var);
    }

    SgClassType* vecType = isSgClassType(varType);
    SgMemberFunctionSymbol* funcSymbol = getMemFuncSymbol(vecType, "operator[]");
    return SageBuilder::buildFunctionCallExp(
            SageBuilder::buildDotExp(
                var, 
                SageBuilder::buildMemberFunctionRefExp(funcSymbol, false, false)),
            SageBuilder::buildExprListExp(indexVar.getVarRefExp()));
}

//void ValueNode::addVariable(const VersionedVariable& newVar)
//{
//    // If this value node has a value, its cost is zero.
//    if (isSgValueExp(astNode_))
//    {
//        vars_.push_back(newVar);
//        return;
//    }
//
//    int costOfNewVar = getCostFromType(newVar.name.back()->get_type());
//    if (vars_.empty() || costOfNewVar < cost)
//    {
//        cost = costOfNewVar;
//        vars_.push_back(newVar);
//    }
//    else
//    {
//        vars_.insert(vars_.end() - 1, newVar);
//    }
//}

int PhiNode::getCost() const
{
    return getCostFromType(getType());
}

SgType* ScalarValueNode::getType() const
{
    SgType* type;
    if (!var.isNull())
        type = var.name.back()->get_type();
    else if (SgExpression* expr = isSgExpression(astNode))
        type = expr->get_type();
    else if (SgInitializedName* initName = isSgInitializedName(astNode))
        type = initName->get_type();

    // Remove reference.
    if (SgReferenceType* refType = isSgReferenceType(type))
        type = refType->get_base_type();

    return type;
}

int ScalarValueNode::getCost() const
{
    if (isAvailable())
        return 0;
    return getCostFromType(getType());
}

std::map<VariantT, std::string> OperatorNode::typeStringTable;

void OperatorNode::buildTypeStringTable()
{
    boost::assign::insert(typeStringTable)
    (V_SgAddOp,             "+" )
    (V_SgSubtractOp,        "-" )
    (V_SgPlusPlusOp,        "++")
    (V_SgMinusMinusOp,      "--")
    (V_SgMultiplyOp,        "x" )
    (V_SgDivideOp,          "/" )
    (V_SgGreaterThanOp,     ">" )
    (V_SgLessThanOp,        "<" )
    (V_SgEqualityOp,        "==")
    (V_SgNotEqualOp,        "!=")
    (V_SgGreaterOrEqualOp,  ">=")
    (V_SgLessOrEqualOp,     "<=")
    (V_SgModOp,             "%" );
}

OperatorNode::OperatorNode(VariantT t, SgNode* node)
    : ValueGraphNode(node), type(t)
{
    switch (t)
    {
	case V_SgPlusAssignOp:
		type = V_SgAddOp;
        break;

	case V_SgSubtractOp:
	case V_SgMinusAssignOp:
        type = V_SgSubtractOp;
        break;

    default:
        break;
    }
    buildTypeStringTable();
}

std::string OperatorNode::toString() const
{
    if (typeStringTable.count(type) > 0)
        return typeStringTable[type];
    return "OP";
}


std::set<SgMemberFunctionDeclaration*> FunctionCallNode::functionsToReverse;
std::ofstream FunctionCallNode::os("fileList.txt");
std::set<std::pair<std::string, std::string> > FunctionCallNode::reversibleStlFunctions;


FunctionCallNode::FunctionCallNode(SgFunctionCallExp* funcCall, bool isRvs)
:   ValueGraphNode(funcCall), isReverse(isRvs), isVirtual(false), 
    isConst(false), isMemberFunction(false), isStd(false), canBeReversed(false), 
    caller(NULL), isReversibleSTLFunction(false)
{
    if (reversibleStlFunctions.empty())
    {
        reversibleStlFunctions.insert(make_pair("priority_queue", "push"));
        reversibleStlFunctions.insert(make_pair("priority_queue", "pop"));
        
        reversibleStlFunctions.insert(make_pair("vector", "begin"));
        reversibleStlFunctions.insert(make_pair("vector", "end"));
        reversibleStlFunctions.insert(make_pair("vector", "erase"));
        reversibleStlFunctions.insert(make_pair("vector", "insert"));
        reversibleStlFunctions.insert(make_pair("vector", "push_back"));
        reversibleStlFunctions.insert(make_pair("vector", "pop_back"));
        
        
        reversibleStlFunctions.insert(make_pair("deque", "begin"));
        reversibleStlFunctions.insert(make_pair("deque", "end"));
        reversibleStlFunctions.insert(make_pair("deque", "erase"));
        reversibleStlFunctions.insert(make_pair("deque", "insert"));
        reversibleStlFunctions.insert(make_pair("deque", "push_back"));
        reversibleStlFunctions.insert(make_pair("deque", "pop_back"));
        reversibleStlFunctions.insert(make_pair("deque", "push_front"));
        reversibleStlFunctions.insert(make_pair("deque", "pop_front"));
        
        reversibleStlFunctions.insert(make_pair("list", "begin"));
        reversibleStlFunctions.insert(make_pair("list", "end"));
        reversibleStlFunctions.insert(make_pair("list", "erase"));
        reversibleStlFunctions.insert(make_pair("list", "insert"));
        reversibleStlFunctions.insert(make_pair("list", "push_back"));
        reversibleStlFunctions.insert(make_pair("list", "pop_back"));
        reversibleStlFunctions.insert(make_pair("list", "push_front"));
        reversibleStlFunctions.insert(make_pair("list", "pop_front"));
        
        reversibleStlFunctions.insert(make_pair("multiset", "begin"));
        reversibleStlFunctions.insert(make_pair("multiset", "end"));
        reversibleStlFunctions.insert(make_pair("multiset", "erase"));
        reversibleStlFunctions.insert(make_pair("multiset", "insert"));
    }
    
    // If this function is declared as const.
    //bool isConst = false;
    bool isInline = false;
    //bool isMemberFunc = false;
    bool isOperator = false;
    bool isCtorOrDtor = false;
 
    // 6/7/2012
    // Set canBeReversed to false then we don't reverse function calls.
#if 1
            
    funcDecl = funcCall->getAssociatedFunctionDeclaration();
    // In some cases, such as function pointers and virtual functions, the function 
    // called cannot be resolved statically; for those cases this function returns NULL.
    if (funcDecl == NULL)
    {
        SgMemberFunctionRefExp* funcRef = NULL;
        
        //isVirtual = true;
        if (SgBinaryOp* binExp = isSgBinaryOp(funcCall->get_function()))
        {
            caller = binExp->get_lhs_operand();
            funcRef = isSgMemberFunctionRefExp(binExp->get_rhs_operand());
        }
        
            //if (isSgThisExp(arrowExp->get_lhs_operand()))
        if (funcRef)
        {
            SgMemberFunctionDeclaration* memFuncDecl = funcRef->getAssociatedMemberFunctionDeclaration();
            const SgFunctionModifier& modifier = memFuncDecl->get_functionModifier();
            const SgSpecialFunctionModifier& specialModifier = memFuncDecl->get_specialFunctionModifier();
            
            //cout << funcDecl->get_name().str() << funcDecl->get_functionModifier().isVirtual() << endl;
            
            isVirtual = modifier.isVirtual();
            isConst = SageInterface::isConstType(memFuncDecl->get_type());
            isInline = modifier.isInline();
            isOperator = specialModifier.isOperator() || specialModifier.isConversion();
            isCtorOrDtor = specialModifier.isDestructor() || specialModifier.isConstructor();

            funcDecl = memFuncDecl;
            //if (isVirtual)
            //cout << funcDecl->get_name().str() << "\t: VIRTUAL1\n\n";
            
            functionsToReverse.insert(memFuncDecl);
        }

        else 
        {
            canBeReversed = false;
            return;
            
            cout << funcCall->unparseToString() << endl;
            funcCall->get_file_info()->display();
            ROSE_ASSERT(0);
            //isVirtual = true;
            //cout << "UNKNOWN" << "\t: VIRTUAL2\n\n";
        }
        
        // TEMP
        //isVirtual = true;
        isMemberFunction =true;
    }
    
    else
    {
        SgMemberFunctionRefExp* funcRef = NULL;
        if (SgBinaryOp* binExp = isSgBinaryOp(funcCall->get_function()))
        {
            caller = binExp->get_lhs_operand();
            funcRef = isSgMemberFunctionRefExp(binExp->get_rhs_operand());
        }
        
        if (funcRef)
        {
            //SgMemberFunctionRefExp* funcRef = isSgMemberFunctionRefExp(arrowExp->get_rhs_operand());
            SgMemberFunctionDeclaration* memFuncDecl = funcRef->getAssociatedMemberFunctionDeclaration();
            const SgFunctionModifier& modifier = memFuncDecl->get_functionModifier();
            const SgSpecialFunctionModifier& specialModifier = memFuncDecl->get_specialFunctionModifier();
            
            
            //cout << funcDecl->get_name().str() << funcDecl->get_functionModifier().isVirtual() << endl;
            isVirtual = modifier.isVirtual();
            isConst = SageInterface::isConstType(memFuncDecl->get_type());
            isInline = modifier.isInline();
            isOperator = specialModifier.isOperator() || specialModifier.isConversion();
            isCtorOrDtor = specialModifier.isDestructor() || specialModifier.isConstructor();

            SgNamespaceDefinitionStatement* nsDef = SageInterface::enclosingNamespaceScope(memFuncDecl);
            SgNamespaceDeclarationStatement* nsDecl = nsDef ? nsDef->get_namespaceDeclaration() : NULL;
            if (nsDecl && nsDecl->get_name() == "std")
            {
                //cout << "\nFound a STD function: " << memFuncDecl->get_name() << "\n\n";
                isStd = true;
            }
            else if (isOperator)
            {
                //cout << "\nFound a overloaded operator: " << memFuncDecl->get_name() << "\n\n";
            }
            else
            {
                //isVirtual = true;
                
                functionsToReverse.insert(memFuncDecl);
            }
            
            //if (isVirtual)
            //cout << funcDecl->get_name().str() << "\t: VIRTUAL3\n\n";
            //funcRef->get_file_info()->display();
            
            isMemberFunction = true;
        }
        //isVirtual = true;
    }
    
    
    ROSE_ASSERT(funcDecl);
    funcName = funcDecl->get_name();
    
    // A work-around to detect operators. Sometimes an operator does not have a operator flag in its
    // function modifier. For example, default assignment operator.
    if (string(funcName.begin(), funcName.begin() + 8) == "operator")
        isOperator = true;
    
    // Currently we don't reverse virtual destructor. We will reverse it in the future.
    if (isVirtual && !isCtorOrDtor)
        canBeReversed = true;
    else if (isConst || isInline || isOperator || isCtorOrDtor || isStd)
        canBeReversed = false;
    else if (isMemberFunction)
        canBeReversed = true;


    os << funcDecl->get_name() << ":\n";
    os << funcDecl->get_functionModifier() << "\n";
    os << isMemberFunction << canBeReversed << "\n";
    os << funcDecl->get_specialFunctionModifier() << "\n\n";
    
    
    // Check if this function is a STL one that can be reversed.
    if (!canBeReversed && caller != NULL)
    {
        typedef pair<string, string> StrPairT;
        foreach (const StrPairT& strPair, reversibleStlFunctions)
        {
            if (BackstrokeUtility::isSTLContainer(caller->get_type(), strPair.first.c_str()))
            {
                if (funcDecl && funcDecl->get_name() == strPair.second)
                {
                    canBeReversed = true;
                    
                    isReversibleSTLFunction = true;
                    STLContainerName = strPair.first;
                    funcName = strPair.second;
                    
                    break;
                }
            }
        }
    }
    
#endif
}

FunctionCallNode::FunctionNamesT FunctionCallNode::getFunctionNames() const
{
    string fwdName, rvsName, cmtName;
    if (isStd)
    {
        if (funcName == "push_back")
        {
            fwdName = "push_back";
            rvsName = "pop_back";
            cmtName = "";
        }
        
    }
    else
    {
        fwdName = funcName + "_forward";
        rvsName = funcName + "_reverse";
        cmtName = funcName + "_commit";
    }
    
    return FunctionNamesT(fwdName, rvsName, cmtName);
}



std::pair<SgExpression*, SgExpression*> FunctionCallNode::buildFwdAndRvsFuncCallsForSTL() const
{
    string fwdFuncName = "bs_" + STLContainerName + "_" + funcName + "_forward";
    string rvsFuncName = "bs_" + STLContainerName + "_" + funcName + "_reverse";
    
    SgFunctionCallExp* funcCall = isSgFunctionCallExp(astNode);
    ROSE_ASSERT(funcCall);
    ROSE_ASSERT(caller);
    
    SgExprListExp* fwdFuncParaList = buildExprListExp(copyExpression(caller));
    SgExprListExp* rvsFuncParaList = buildExprListExp(copyExpression(caller));
    
    foreach (SgExpression* exp, funcCall->get_args()->get_expressions())
        fwdFuncParaList->append_expression(copyExpression(exp));
    
#ifdef ROSS
    fwdFuncParaList->append_expression(buildVarRefExp("lp"));
    rvsFuncParaList->append_expression(buildVarRefExp("lp"));
#endif
    
    SgExpression* fwdFuncCall = buildFunctionCallExp(
            fwdFuncName, buildVoidType(), fwdFuncParaList);
    SgExpression* rvsFuncCall = buildFunctionCallExp(
            rvsFuncName, buildVoidType(), rvsFuncParaList);
    
    return make_pair(fwdFuncCall, rvsFuncCall);
}



std::pair<SgExpression*, SgExpression*> FunctionCallNode::buildFwdAndRvsFuncCalls() const
{
    if (isReversibleSTLFunction)
        return buildFwdAndRvsFuncCallsForSTL();
    
    
    SgFunctionCallExp* funcCallExp = isSgFunctionCallExp(astNode);
    ROSE_ASSERT(funcCallExp);
    //ROSE_ASSERT(funcDecl);
    
    
    SgMemberFunctionRefExp* funcRef = NULL;
    if (SgBinaryOp* binExp = isSgBinaryOp(funcCallExp->get_function()))
        funcRef = isSgMemberFunctionRefExp(binExp->get_rhs_operand());
    ROSE_ASSERT(funcRef);

    SgMemberFunctionDeclaration* memFunDecl = funcRef->getAssociatedMemberFunctionDeclaration();
    //SgType* returnType = funcCallExp->get_type();

    string funcName = memFunDecl->get_name().str();
    string fwdFuncName = funcName + "_forward";
    string rvsFuncName = funcName + "_reverse";
    //string cmtFuncName = funcName + "_commit";
    
    SgFunctionCallExp* fwdFuncCall = NULL;
    SgFunctionCallExp* rvsFuncCall = NULL;

    if (SgClassDefinition* classDef = memFunDecl->get_class_scope())
    {
        SgMemberFunctionSymbol* fwdFuncSymbol = NULL;
        SgMemberFunctionSymbol* rvsFuncSymbol = NULL;
        SgMemberFunctionSymbol* cmtFuncSymbol = NULL;

        ROSE_ASSERT(classDef);

        foreach (SgDeclarationStatement* decl, classDef->get_members())
        {
            SgMemberFunctionDeclaration* memFuncDecl = 
                    isSgMemberFunctionDeclaration(decl);
            if (memFuncDecl == NULL)
                continue;

            SgName funcName = memFuncDecl->get_name();

            if (funcName == fwdFuncName)
            {
                fwdFuncSymbol = isSgMemberFunctionSymbol(
                        memFuncDecl->get_symbol_from_symbol_table());
            }
            else if (funcName == rvsFuncName)
            {
                rvsFuncSymbol = isSgMemberFunctionSymbol(
                        memFuncDecl->get_symbol_from_symbol_table());
            }
#if 0
            else if (funcName == cmtFuncName)
            {
                cmtFuncSymbol = isSgMemberFunctionSymbol(
                        memFuncDecl->get_symbol_from_symbol_table());
            }
#endif
        }

        //cout << "Processing Function Call:\t" << funcName << " : " <<
        //        funcDecl->get_functionModifier() << " " << 
        //        funcDecl->get_specialFunctionModifier() << endl;

        if (!(fwdFuncSymbol && rvsFuncSymbol && cmtFuncSymbol))
        {
            boost::tie(fwdFuncSymbol, rvsFuncSymbol, cmtFuncSymbol) = 
                    buildThreeFuncDecl(classDef, memFunDecl);
        }
        ROSE_ASSERT(fwdFuncSymbol && rvsFuncSymbol && cmtFuncSymbol);



        //SgThisExp* thisExp = isSgThisExp(arrowExp->get_lhs_operand());
        //ROSE_ASSERT(thisExp);
        //ROSE_ASSERT(copyExpression(thisExp));

        //SgMemberFunctionRefExp* fwdFuncRef = NULL;
        //SgMemberFunctionRefExp* rvsFuncRef = NULL;
        //SgMemberFunctionRefExp* cmtFuncRef = NULL;

        // Since the same VG node can be traversed more than once, this 
        // flag indicate if the replacement of this function call is built
        // or not.
        //bool isFwdFuncCallBuilt = replaceTable_.count(funcCallExp);

        //if (!isFwdFuncCallBuilt)
        //{
        fwdFuncCall = isSgFunctionCallExp(copyExpression(funcCallExp));
        if (SgBinaryOp* binExp = isSgBinaryOp(fwdFuncCall->get_function()))
            funcRef = isSgMemberFunctionRefExp(binExp->get_rhs_operand());
        funcRef->set_symbol(fwdFuncSymbol);
        //    replaceTable_[funcCallExp] = fwdFuncCall;
        //}
        // FIXME The following method does not work!!
        //replaceExpression(arrowExp->get_rhs_operand(), fwdFuncRef);

        rvsFuncCall = isSgFunctionCallExp(copyExpression(funcCallExp));
        //replaceExpression(rvsFuncCall->get_args(), buildExprListExp());
        if (SgBinaryOp* binExp = isSgBinaryOp(rvsFuncCall->get_function()))
            funcRef = isSgMemberFunctionRefExp(binExp->get_rhs_operand());
        funcRef->set_symbol(rvsFuncSymbol);

        // Remove all args from the reverse function call.
#ifdef ROSS
        rvsFuncCall->set_args(buildExprListExp(buildVarRefExp("lp")));
#else
        rvsFuncCall->set_args(buildExprListExp());
#endif

        //replaceExpression(arrowExp->get_rhs_operand(), rvsFuncRef);

#if 0
        SgFunctionCallExp* cmtFuncCall = isSgFunctionCallExp(copyExpression(funcCallExp));
        replaceExpression(cmtFuncCall->get_args(), buildExprListExp());
        if (SgBinaryOp* binExp = isSgBinaryOp(cmtFuncCall->get_function()))
            funcRef = isSgMemberFunctionRefExp(binExp->get_rhs_operand());
        funcRef->set_symbol(cmtFuncSymbol);
#endif
        //replaceExpression(arrowExp->get_rhs_operand(), cmtFuncRef);

#if 0
        SgExpression* fwdFuncCall = buildFunctionCallExp(buildArrowExp(
                copyExpression(thisExp), fwdFuncRef));
        replaceExpression(funcCallExp, fwdFuncCall);

        SgExpression* rvsFuncCall = buildFunctionCallExp(buildArrowExp(
                copyExpression(thisExp), rvsFuncRef));
        rvsStmt = buildExprStatement(rvsFuncCall);

        SgExpression* cmtFuncCall = buildFunctionCallExp(buildArrowExp(
                copyExpression(thisExp), cmtFuncRef));
        cmtStmt = buildExprStatement(cmtFuncCall);
#endif
    }
    else
    {
        ROSE_ASSERT(0);
#if 0
        SgExpression* fwdFuncCall = buildFunctionCallExp(fwdFuncName, returnType);
        //fwdFuncCall = buildArrowExp(SageInterface::copyExpression(thisExp), fwdFuncCall);
        SageInterface::replaceExpression(funcCallExp, fwdFuncCall);

        SgExpression* rvsFuncCall = buildFunctionCallExp(rvsFuncName, returnType);
        //SgExpression* rvsFuncCall = buildFunctionCallExp(SageInterface::copyExpression(arrowExp));
        rvsStmt = buildExprStatement(rvsFuncCall);

        SgExpression* cmtFuncCall = buildFunctionCallExp(cmtFuncName, returnType);
        cmtStmt = buildExprStatement(cmtFuncCall);
#endif
    }
    
    return make_pair(fwdFuncCall, rvsFuncCall);
}


std::string FunctionCallNode::toString() const
{
    string str;
    if (SgFunctionCallExp* funcCallExp = getFunctionCallExp())
    {
#if 0
        SgFunctionDeclaration* funcDecl = funcCallExp->getAssociatedFunctionDeclaration();
        if (funcDecl)
            str += funcDecl->get_name();
#endif
        str += funcCallExp->unparseToString();
    }
    
    if (str == "")
        str += boost::lexical_cast<string>(astNode);
    
    if (isReverse)
        str += "\\nREVERSE";
    
    if (isVirtual)
        str += "\\nVIRTUAL";
    return str;
}

std::string ValueGraphEdge::toString() const
{
    std::string str;
    
#if 1
    str += "cost:" + boost::lexical_cast<std::string>(cost) + "\\n";
    str += paths.toString() + "\\n";
    str += region.toString();
#endif
    
#if 0
    str += "\\n";
    if (controlDependences.empty())
        str += "Entry";
    
    foreach (const ControlDependence& cd, controlDependences)
    {
        str += cd.cdEdge.toString() + ":";
        
        if (SgIfStmt* ifStmt = isSgIfStmt(cd.cdNode))
        {
            str += ifStmt->get_conditional()->unparseToString();
        }
        else 
            str += cd.cdNode->class_name();
            
        str += "\\n";
    }
#endif
    
    return str;
}

std::string StateSavingEdge::toString() const
{ 
    std::string str = "SS: ";
    if (killer)
        str += killer->class_name() + "\\n";// + boost::lexical_cast<std::string>(visiblePathNum) + "\\n";
    return str + ValueGraphEdge::toString();
}

bool isArrayNode(ValueGraphNode* node)
{
    if (ScalarValueNode* valNode = isScalarValueNode(node))
    {
        if (valNode->var.name.empty())
            return false;
        
        SgType* t = valNode->var.name.back()->get_type();
        if (SgPointerType* pt = isSgPointerType(t))
            t = pt->get_base_type();
        
        if (BackstrokeUtility::isSTLContainer(t, "vector"))
            return true;
        
        if (SgExpression* exp = isSgExpression(valNode->astNode))
        {
            if (BackstrokeUtility::isSTLContainer(exp->get_type(), "vector"))
                return true;
            // TODO: check if it is an array type.
        }
    }
    return false;    
}

} // End of namespace Backstroke
