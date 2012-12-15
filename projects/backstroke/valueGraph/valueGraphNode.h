#ifndef BACKSTROKE_VALUEGRAPHNODE_H
#define	BACKSTROKE_VALUEGRAPHNODE_H

#include "types.h"
#include "arrayRegion.h"
#include <slicing/backstrokeCDG.h>
#include <rose.h>
#include <boost/lexical_cast.hpp>
#include <fstream>

namespace Backstroke
{

typedef std::vector<SgInitializedName*> VarName;




/**********************************************************************************************************/
// Value Graph Nodes


struct ValueGraphNode
{
	explicit ValueGraphNode(SgNode* node = NULL) : astNode(node) {}

	virtual std::string toString() const
	{ return ""; }

    virtual int getCost() const
    { return 100; }

    //! The corresponding AST node of this value graph node.
    SgNode* astNode;
};


struct ValueNode : ValueGraphNode
{
	explicit ValueNode(SgNode* node = NULL)
    : ValueGraphNode(node), isStateVar(false) {}   
    
    virtual SgExpression* buildExpression() const = 0;
    virtual VarName getVarName() const = 0;
	virtual bool isAvailable() const { return false; }
    virtual SgType* getType() const {return NULL; }
    virtual bool isTemp() const { return false; }
    
    //! Indicates if the variable is a state one.
    bool isStateVar;
};

//! A value node can hold a lvalue and a rvalue.
struct ScalarValueNode : ValueNode
{    
	explicit ScalarValueNode(SgNode* node = NULL)
    : ValueNode(node) {}
    explicit ScalarValueNode(const VersionedVariable& v, SgNode* node = NULL)
    : ValueNode(node), var(v) {}

	virtual std::string toString() const;
    virtual int getCost() const;
    
    
    virtual SgExpression* buildExpression() const
    {
        if (SgExpression* val = isSgValueExp(astNode))
            return SageInterface::copyExpression(val);
        return var.getVarRefExp();
    }
    
    
    virtual VarName getVarName() const
    {
        return var.name;
    }

    //void addVariable(const VersionedVariable& newVar);

	virtual bool isTemp() const 
    { return !isAvailable() && var.isNull(); }

    //! If the AST node is a value expression, it is avaiable.
	virtual bool isAvailable() const { return isSgValueExp(astNode) != NULL; }

    //! Get the type of the value.
    virtual SgType* getType() const;
    

//    SgNode* getNode() const { return astNode; }
//    void setNode(SgNode* node)  { astNode = node; }

    //! All variables sharing the same value.
	VersionedVariable var;

    //! The unique name of this value node in VG which becomes
    //! the name of the corresponding variable
    std::string str;
    
};

  
struct ArrayNode : ValueNode
{
    explicit ArrayNode(SgNode* node = NULL)
    : ValueNode(node) {}
    
    virtual int getCost() const
    { return 10000; }
};

struct ArrayElementNode : ValueNode
{
    explicit ArrayElementNode(SgNode* node = NULL)
    : ValueNode(node) {}
};

struct VectorElementNode : ValueNode
{
#if 0
    explicit VectorElementNode(SgFunctionCallExp* funcCallExp)
    : ValueGraphNode(funcCallExp), indexExp(NULL)
    {
        SgBinaryOp* binExp = isSgBinaryOp(funcCallExp->get_function());
        ROSE_ASSERT(binExp);
        vecExp = binExp->get_lhs_operand();
        indexExp = funcCallExp->get_args()->get_expressions()[0];
    }
#endif
    
    VectorElementNode(const VersionedVariable& vec, 
        const VersionedVariable& index, SgFunctionCallExp* funcCallExp);
    
	virtual std::string toString() const;
    virtual SgExpression* buildExpression() const;
    
    
    virtual VarName getVarName() const
    {
        return vecVar.name;
    }
    
    
    SgExpression* vecExp;
    SgExpression* indexExp;
    
	VersionedVariable vecVar;
	VersionedVariable indexVar;
	SgValueExp* indexVal;
};

//! This node represents a phi node in the SSA form CFG. The AST node inside (actually
//! from its parent class ValueNode) only describe the place of this Phi node in the CFG.
struct PhiNode : ScalarValueNode
{
//    enum GateType
//    {
//        phi,
//        mu,
//        eta
//    };

	PhiNode(const VersionedVariable& v, SgNode* node)
    : ScalarValueNode(v, node), isMuNode(false) {}

	//std::vector<ValueGraphNode*> nodes;

	virtual std::string toString() const
    { 
        if (isMuNode) 
            return "MU_" + var.toString(); 
        return "PHI_" + var.toString(); 
    }

    virtual int getCost() const;

//    SgType* getType() const
//    { return var.name.back()->get_type(); }

//    //! The DAG index.
//    int dagIndex;
    
    bool isMuNode;

    //! The type of this gate function
    //GateType type;
};

//! A Mu node is a special phi node which has a data dependence through a back 
//! edge in a loop. This node is placed on the loop header node in CFG.
struct MuNode : PhiNode
{
    MuNode(const VersionedVariable& v, SgNode* node)
    : PhiNode(v, node), dagIndex(0), isCopy(false) {}
    
    explicit MuNode(const PhiNode& phiNode) 
    : PhiNode(phiNode), dagIndex(0), isCopy(false) {}
    	
    virtual std::string toString() const
	{ 
        std::string str = "MU_" + var.toString() + "\\n" 
                + boost::lexical_cast<std::string>(dagIndex);
        return isCopy ? str + "\\nAVAILABLE" : str;
    }

    //! The DAG index.
    int dagIndex;
    
    //! If it is a copy.
    bool isCopy;
};

//! An operator node represents a unary or binary operation. It only has one in edge,
//! and one or two out edges, for unary and binary operation separately.
struct OperatorNode : ValueGraphNode
{
    static std::map<VariantT, std::string> typeStringTable;
    static void buildTypeStringTable();

	//OperatorNode(OperatorType t) : ValueGraphNode(), type(t) {}
	explicit OperatorNode(VariantT t, SgNode* node = NULL);

	virtual std::string toString() const;
	
	VariantT type;
};

struct FunctionCallNode: ValueGraphNode
{
    typedef boost::tuple<std::string, std::string, std::string> FunctionNamesT;
    
    explicit FunctionCallNode(SgFunctionCallExp* funcCall, bool isRvs = false);
    
    SgFunctionCallExp* getFunctionCallExp() const
    { return isSgFunctionCallExp(astNode); }
    
    //! Returns if a parameter is needed in the reverse functino call.
    bool isNeededByInverse(SgInitializedName* initName) const
    { return true; }
    
    FunctionNamesT getFunctionNames() const;
    
    virtual std::string toString() const;
    
    std::pair<SgExpression*, SgExpression*> buildFwdAndRvsFuncCalls() const;
    
    std::pair<SgExpression*, SgExpression*> buildFwdAndRvsFuncCallsForSTL() const;
    
    SgFunctionDeclaration* funcDecl;
    std::string funcName;
    
    //! If this function call node is the reverse one.
    bool isReverse;
    
    //! If this function is declared as virtual.
    bool isVirtual;
    
    //! If this function is constant.
    bool isConst;
    
    //! If this function is a member function.
    bool isMemberFunction;
        
    //! If this function call is from std library.
    bool isStd;
    
    //! Indicates if this function call can be reversed.
    bool canBeReversed;
    
    //! If the function is a member function, this the caller.
    SgExpression* caller;
    
    bool isReversibleSTLFunction;
    std::string STLContainerName;
    
    static std::set<SgMemberFunctionDeclaration*> functionsToReverse;
    
    static std::ofstream os;
    
    static std::set<std::pair<std::string, std::string> > reversibleStlFunctions; 
};

#if 0
struct UnaryOperaterNode : OperatorNode
{
	enum OperationType
	{
		otPlus,
		otMinus
	} type;

	ValueGraphNode* operand;
};


struct BinaryOperaterNode : OperatorNode
{
	enum OperaterType
	{
		otAdd,
		otMinus,
		otMultiply,
		otDevide,
		otMod,
		otAssign,
	} type;

	BinaryOperaterNode(OperaterType t) : type(t) {}
	ValueGraphNode* lhsOperand;
	ValueGraphNode* rhsOperand;
};
#endif

/**********************************************************************************************************/
// Value Graph Edges

struct ValueGraphEdge
{
    ValueGraphEdge() : cost(TRIVIAL_COST), forward(false), reverse(false) {}
    explicit ValueGraphEdge(const PathInfos& pths, int cst = TRIVIAL_COST)
    : cost(cst), paths(pths), forward(false), reverse(false) {}
    
    //ValueGraphEdge(int cst, const PathInfos& pths, const ControlDependences& cd)
    //: cost(cst), paths(pths), controlDependences(cd) {}

    virtual ~ValueGraphEdge() {}

	virtual std::string toString() const;
    
    virtual ValueGraphEdge* clone() 
    { return new ValueGraphEdge(*this); }

    static const int TRIVIAL_COST = 1;
    
    //! The cost attached on this edge. The cost may come from state saving,
    //! or operations.
	int cost;
    
    //! All paths on which this relationship exists.
    PathInfos paths;
    
    //! For array nodes. Indicates which region of two arrays are identical.
    ArrayRegion region;
    
    bool forward;
    bool reverse;
    
    ////! All immediate control dependences representing conditions in VG.
    //ControlDependences controlDependences;
};

//! An edge coming from an operator node.
struct OrderedEdge : ValueGraphEdge
{
	explicit OrderedEdge(int idx) : ValueGraphEdge(), index(idx) {}

	virtual std::string toString() const
	{ return boost::lexical_cast<std::string>(index) 
            + "\\n" + ValueGraphEdge::toString(); }
    
    virtual OrderedEdge* clone() 
    { return new OrderedEdge(*this); }

	int index;
};

#if 1
//! An edge coming from a phi node.
struct PhiEdge : ValueGraphEdge
{
    PhiEdge(int cst, const PathInfos& pths)
    : ValueGraphEdge(pths, cst), muEdge(false) {}
    //PhiEdge(const std::set<ReachingDef::FilteredCfgEdge>* edges)
    //: ValueGraphEdge(0, dagIdx, paths), visiblePathNum(visibleNum) {}
    //! A set of edges indicating where the target def comes from in CFG.
    //std::set<ReachingDef::FilteredCfgEdge> cfgEdges;
    
    virtual std::string toString() const
    {
        std::string str = ValueGraphEdge::toString();
        return muEdge ? str + "\\nMU" : str;
    }
    
    bool muEdge;
};
#endif


//! A structure storing the information of each edge during the search.
struct EdgeInfo
{
    PathInfos paths;
    ArrayRegion region;
};


#if 0
//! An edge connecting two array nodes or an array and an array element node.
struct ArrayRegionEdge : ValueGraphEdge
{
    ArrayRegionEdge() {}
    ArrayRegionEdge(const ArrayRegion& reg, const PathInfos& pths) 
    : ValueGraphEdge(pths), region(reg) {}
    
    ArrayRegion region;
};
#endif


//! An edge going to the root node.
struct StateSavingEdge : ValueGraphEdge
{
	//StateSavingEdge() : visiblePathNum(0) {}
//    StateSavingEdge(int cost, int dagIdx, int visibleNum,
//        const PathSet& paths, SgNode* killerNode)
//    :   ValueGraphEdge(cost, dagIdx, paths), 
//        visiblePathNum(visibleNum), killer(killerNode) {}
    
    StateSavingEdge(int cost, const PathInfos& paths,
                    SgNode* killerNode, bool isKillerScope = false)
    :   ValueGraphEdge(paths, cost), 
        killer(killerNode), 
        scopeKiller(isKillerScope),
        varStored(false) 
    {}
    
    StateSavingEdge(int cost, const PathInfos& paths,
                    const std::map<int, PathSet> visiblePaths, 
                    SgNode* killerNode, bool isKillerScope = false)
    :   ValueGraphEdge(paths, cost), 
        visiblePaths(visiblePaths), 
        killer(killerNode), 
        scopeKiller(isKillerScope),
        varStored(false)
    {}
    
    
	virtual std::string toString() const;
    
    virtual StateSavingEdge* clone() 
    { return new StateSavingEdge(*this); }

	//int visiblePathNum;
    std::map<int, PathSet> visiblePaths;
    SgNode* killer;
    
    //! Indicate if the killer is a scope or not. If the killer is a scope, the SS
    //! statement is inserted at the end of the scope. Or else, it is inserted before
    //! the killer statement.
    bool scopeKiller;
    
    //! If state saving is done. It is needed since a SS edge in a loop is traversed
    //! more than once by difference DAGs.
    bool varStored;
    
};

/**********************************************************************************************************/
// Utility functions

//inline TempVariableNode* isTempVariableNode(ValueGraphNode* node)
//{
//	return dynamic_cast<TempVariableNode*>(node);
//}

inline PhiNode* isPhiNode(ValueGraphNode* node)
{
	return dynamic_cast<PhiNode*>(node);
}

inline OperatorNode* isOperatorNode(ValueGraphNode* node)
{
	return dynamic_cast<OperatorNode*>(node);
}

inline ArrayElementNode* isArrayElementNode(ValueGraphNode* node)
{
	return dynamic_cast<ArrayElementNode*>(node);
}

inline VectorElementNode* isVectorElementNode(ValueGraphNode* node)
{
	return dynamic_cast<VectorElementNode*>(node);
}

inline ValueNode* isValueNode(ValueGraphNode* node)
{
	return dynamic_cast<ValueNode*>(node);
}

inline ScalarValueNode* isScalarValueNode(ValueGraphNode* node)
{
	return dynamic_cast<ScalarValueNode*>(node);
}

inline MuNode* isMuNode(ValueGraphNode* node)
{
	return dynamic_cast<MuNode*>(node);
}

inline ArrayNode* isArrayNode(ValueGraphNode* node)
{
	return dynamic_cast<ArrayNode*>(node);
}

bool isVectorNode(ValueGraphNode* node);

inline FunctionCallNode* isFunctionCallNode(ValueGraphNode* node)
{
	return dynamic_cast<FunctionCallNode*>(node);
}

inline OrderedEdge* isOrderedEdge(ValueGraphEdge* edge)
{
	return dynamic_cast<OrderedEdge*>(edge);
}

inline StateSavingEdge* isStateSavingEdge(ValueGraphEdge* edge)
{
	return dynamic_cast<StateSavingEdge*>(edge);
}

inline PhiEdge* isPhiEdge(ValueGraphEdge* edge)
{
	return dynamic_cast<PhiEdge*>(edge);
}

}  // End of namespace Backstroke

#endif	/* BACKSTROKE_VALUEGRAPHNODE2_H */

