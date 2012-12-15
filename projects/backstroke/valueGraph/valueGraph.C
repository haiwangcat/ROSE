#include "valueGraph.h"
#include <utilities/utilities.h>
#include <boost/assign/list_inserter.hpp>
#include <boost/bind.hpp>
#include <boost/foreach.hpp>
#include <boost/graph/graphviz.hpp>
#include <boost/graph/topological_sort.hpp>

#define ROSS

namespace Backstroke
{

using namespace std;

#define foreach         BOOST_FOREACH
#define reverse_foreach BOOST_REVERSE_FOREACH

void EventReverser::buildValueGraph()
{
    // First, build the basic part of the value graph.
    buildBasicValueGraph();

    //valueGraphToDot("VG.dot");
    
    // Add all phi node edges. This is done at last because a def of a phi node may
    // not be created when this phi node is created.
    addPhiEdges();

    // Collect all available and target values.
    addAvailableAndTargetValues();

    // Add all state saving edges.
    addStateSavingEdges();
    
    // Add path information to edges.
    //addPathsToEdges();
    
    // Add a reverse edge for every non-ordered edge, and add extra nodes for + and -.
    addExtraNodesAndEdges();

    // Remove useless nodes.
    //removeUselessNodes();

    // Assign a global unique name for each node in VG.
    assignNameToNodes();
    
    valueGraphToDot(funcDef_->get_declaration()->get_name() + "_" +
            funcDef_->get_declaration()->get_mangled_name() + "_VG.dot");
}

namespace
{
    struct OperationTypeTable
    {
        OperationTypeTable()
        {
            boost::assign::insert(table)
            (V_SgPlusAssignOp,      V_SgAddOp)
            (V_SgMinusAssignOp,     V_SgSubtractOp)
            (V_SgMultAssignOp,      V_SgMultiplyOp)
            (V_SgDivAssignOp,       V_SgDivideOp)
            (V_SgAndAssignOp,       V_SgAndOp)
            (V_SgIorAssignOp,       V_SgOrOp)
            (V_SgModAssignOp,       V_SgModOp)
            (V_SgXorAssignOp,       V_SgBitXorOp)
            (V_SgLshiftAssignOp,    V_SgLshiftOp)
            (V_SgRshiftAssignOp,    V_SgRshiftOp);
        }

        map<VariantT, VariantT> table;
    };

    VariantT getOriginalType(VariantT t)
    {
        static OperationTypeTable typeTable = OperationTypeTable();
        ROSE_ASSERT(typeTable.table.count(t) > 0);
        return typeTable.table[t];
    }

} // end of anonymous



void EventReverser::buildBasicValueGraph()
{
    // Build the SSA form of the given function.
    //SSA::NodeReachingDefTable defTable = getUsesAtNode(funcDef);

    // Build a vertex which is the start point of the search.
    //root_ = addValueGraphNode(new ValueGraphNode);
    ssnode_ = addValueGraphNode(new ValueGraphNode);

    /***************************************************************************/
    // We search state variables here. This part should use a functor to determine
    // which variables are state ones.
    // Currently, we assume the parameters are state variables in C style, while
    // all data members are state variables in C++ style.


    SgFunctionDeclaration* funcDecl = funcDef_->get_declaration();
    // If the event is a member function.
    if (SgMemberFunctionDeclaration* memFuncDecl = isSgMemberFunctionDeclaration(funcDecl))
    {
        SgClassDefinition* classDef = memFuncDecl->get_class_scope();
        processClassDataMembers(classDef);
        
        // Add all parameters of the event to the value graph.
        SgInitializedNamePtrList& paraList = funcDef_->get_declaration()->get_args();
        foreach (SgInitializedName* initName, paraList)
        {
            // The argument may be anonymous.
            if (initName->get_name() == "")
                continue;
            createValueNode(initName);
            addStateVariable(initName);
        }
    }
    else
    {
        // Add all parameters of the event to the value graph.
        SgInitializedNamePtrList& paraList = funcDef_->get_declaration()->get_args();
        foreach (SgInitializedName* initName, paraList)
        {
            // The argument may be anonymous.
            if (initName->get_name() == "") continue;
            
            VGVertex newNode = createValueNode(initName, NULL);

            // FIXME State variable may not be parameters.
            
            SgType* type = initName->get_type();
            if (isSgPointerType(type) || isSgReferenceType(type))
            {
#ifdef ROSS
                // In ROSS, only the first parameter is the state variable.
                if (initName == paraList.front())
                {
                    valuesToRestore_[0].insert(newNode);
                    addStateVariable(initName);
                }
#else
                // Add the variable into wanted set.
                valuesToRestore_[0].insert(newNode);
                addStateVariable(initName);
#endif
            }
        } 
    }
    
#if 0
    cout << "State vars:\n";
    foreach (const VarName& var, stateVariables_)
    {
        cout << VersionedVariable(var, 0) << "\n";
    }
    cout << "\n\n";
#endif

    /***************************************************************************/

    vector<SgNode*> nodes = BackstrokeUtility::querySubTree<SgNode>(funcDef_);
    
    // FIXME Here we assume the CFG is a DAG.
    
    // Traverse the CFG in topological order instead of AST can make sure that each 
    // use at any point is already added to VG.
    
    
    // Filter all back edges of the CFG out then we can do a topological sort.
    set<CFGEdge> backEdges = cfg_->getAllBackEdges();
    typedef boost::filtered_graph<
            BackstrokeCFG,
            boost::function<bool(const CFGEdge&) > > FilterdCFG;
    
    // To resolve the problem of binding an overloaded function.
    set<CFGEdge>::const_iterator (set<CFGEdge>::*findEdge)
            (const set<CFGEdge>::key_type&) const = &set<CFGEdge>::find;
    FilterdCFG filteredCFG(*cfg_, 
            boost::bind(findEdge, &backEdges, ::_1) == backEdges.end());
    
    vector<CFGVertex> cfgNodes;
    boost::topological_sort(filteredCFG, back_inserter(cfgNodes));
    
    vector<SgNode*> astNodes;
    reverse_foreach (CFGVertex v, cfgNodes)
        astNodes.push_back((*cfg_)[v]->getNode());
    
    foreach (SgNode* node, astNodes)
    {
        //cout << node->class_name() << endl;

        // Statement case: variable declaration.
        if (SgStatement* stmt = isSgStatement(node))
        {
            processStatement(stmt);
        }

        // Expression case.
        else if (SgExpression* expr = isSgExpression(node))
        {
            processExpression(expr);
        }
    }
}

void EventReverser::processStatement(SgStatement* stmt)
{
    SgVariableDeclaration* varDecl = isSgVariableDeclaration(stmt);
    if (varDecl == NULL) return;

    foreach (SgInitializedName* initName, varDecl->get_variables())
    {
        SgInitializer* initalizer = initName->get_initializer();

        // A declaration without definition
        if (initalizer == NULL)
        {
            createValueNode(initName, NULL);
        }
        else if (SgAssignInitializer* assignInit =
                isSgAssignInitializer(initalizer))
        {
            SgExpression* operand = assignInit->get_operand();
            createValueNode(initName, operand);
            //addVariableToNode(rhsVertex, initName);
        }
        else
        {
            //cout << initalizer->class_name() << endl;
            //ROSE_ASSERT(!"Can only deal with assign initializer now!");
        }
    }
}

void EventReverser::processExpression(SgExpression* expr)
{
    if (BackstrokeUtility::isVariableReference(expr))
    {
        processVariableReference(expr);
        return;
    }
    
    
        
    // We use some special function calls to indicate what is the input and 
    // output of the program.
    if (SgCommaOpExp* commaOp = isSgCommaOpExp(expr))
    {
        SgExpression* rhs = commaOp->get_rhs_operand();
        if (SgIntVal* intVal = isSgIntVal(rhs))
        {
            int val = intVal->get_value();
            SgVarRefExp* var = isSgVarRefExp(commaOp->get_lhs_operand());
            ROSE_ASSERT(var);
            SgInitializedName* initName = var->get_symbol()->get_declaration();
            
            if (val == 123)
            {
                addDesiredVariable(initName);
            }
            else if (val == 456)
            {
                addStateVariable(initName);
            }
        }
    }

    // Value expression.
    if (SgValueExp* valueExp = isSgValueExp(expr))
    {
        createValueNode(valueExp);
        //addValueGraphNode(new ValueNode(valueExp), expr);
    }

    // Cast expression.
    else if (SgCastExp* castExp = isSgCastExp(expr))
    {
        //ROSE_ASSERT(nodeVertexMap_.count(castExp->get_operand()));
        if (nodeVertexMap_.count(castExp->get_operand()) > 0)
            nodeVertexMap_[castExp] = nodeVertexMap_[castExp->get_operand()];
        else
        {
            cout << "The operand of cast expression " << castExp->unparseToString()
                    << " is not added to VG yet!\n";
        }
    }

    else if (SgFunctionCallExp* funcCall = isSgFunctionCallExp(expr))
    {
#if 0
        const SSA::NodeReachingDefTable& defTable =
            ssa_->getReachingDefsAtNode_(funcCall);
        cout << "Print def table:\n";
        typedef map<VarName, SSA::ReachingDefPtr>::value_type PT;
        foreach(const PT& pt, defTable)
        {
            cout << "!" << SSA::varnameToString(pt.first) << " " << 
                    pt.second->getRenamingNumber() << endl;
        }
#endif
        
        createFunctionCallNode(funcCall);
        
        
        // Check if this function call is the operator [] of a vector, which
        // is treated as an array element.
        
        if (SgFunctionDeclaration* funcDecl = funcCall->getAssociatedFunctionDeclaration())
        {
            if (SgBinaryOp* binExp = isSgBinaryOp(funcCall->get_function()))
            {               
                SgType* type = binExp->get_lhs_operand()->get_type();
                
                if (BackstrokeUtility::isSTLContainer(type, "vector") && 
                        funcDecl->get_name() == "operator[]")
                {
                    //cout << ">>> VECTOR function call: " << funcDecl->get_name() << endl;
                    createVectorElementNode(funcCall);
                }
            }
        }
    }
    
    else if (SgDeleteExp* delExp = isSgDeleteExp(expr))
    {
        cout << "Delete Node: " << getVersionedVariable(delExp->get_variable(), false, delExp) << "\n\n";
        createValueNode(delExp->get_variable(), NULL);
    }

    // Unary expressions.
    else if (SgUnaryOp* unaryOp = isSgUnaryOp(expr))
    {
        SgExpression* operand = unaryOp->get_operand();

        VariantT t = unaryOp->variantT();
        switch (t)
        {
        case V_SgPlusPlusOp:
        case V_SgMinusMinusOp:
            {
                if (nodeVertexMap_.count(operand) == 0)
                {
                    cout << "The operand of ++ or -- is not added to VG yet!\n";
                    return;
                }
                ROSE_ASSERT(nodeVertexMap_.count(operand) > 0);

                VGVertex operandNode = nodeVertexMap_[operand];
                VGVertex result = createValueNode(operand, NULL);

                createOperatorNode(t, unaryOp, result, operandNode);
                //addVariableToNode(result, operand);

                // For postfix ++ and --, we should assign the value node
                // before modified to this expression.
                if (unaryOp->get_mode() == SgUnaryOp::postfix)
                    nodeVertexMap_[unaryOp] = operandNode;
                else
                    nodeVertexMap_[unaryOp] = result;

                break;
            }

        case V_SgAddressOfOp:
        case V_SgNotOp:
        case V_SgMinusOp:
        //case V_SgPointerDerefExp:
        case V_SgUnaryAddOp:
            if (nodeVertexMap_.count(operand) == 0)
            {
                cout << "The operand of " << unaryOp->class_name() << " is not added to VG yet!\n";
                return;
            }
            ROSE_ASSERT(nodeVertexMap_.count(operand) > 0);
            createOperatorNode(t, unaryOp, createValueNode(unaryOp), 
                nodeVertexMap_[operand]);
            break;

        default:
            ROSE_ASSERT("Unary op not handled yet!");
            break;
        }
    }

    // Binary expressions.
    else if (SgBinaryOp* binOp = isSgBinaryOp(expr))
    {
        SgExpression* lhs = binOp->get_lhs_operand();
        SgExpression* rhs = binOp->get_rhs_operand();

        VariantT t = binOp->variantT();
        switch (t)
        {
        // For assign op, we assign the node which is assigned to with a variable name.
        case V_SgAssignOp:
            if (BackstrokeUtility::isVariableReference(lhs))
            {
                VGVertex result = createValueNode(lhs, rhs);
                // Update the node-vertex table.
                nodeVertexMap_[binOp] = result;
            }
            else if (nodeVertexMap_.count(lhs) && nodeVertexMap_.count(rhs))
            {
                // It is possible that the lhs expression is not a variable reference.
                // e.g. an element of a vector.
                addValueGraphEdge(nodeVertexMap_[lhs], nodeVertexMap_[rhs]);
            }
            else
            {
                cout << "!!!Only variable can be assigned now.\n\n";
                //ROSE_ASSERT(!"Only variable can be assigned now.");
            }

            break;

        case V_SgEqualityOp:
        {
            SgIfStmt* ifStmt = isSgIfStmt(binOp->get_parent()->get_parent());
            if (ifStmt)
                addValueGraphEdge(nodeVertexMap_[lhs], nodeVertexMap_[rhs],
                        pathNumManager_->getPathNumbers(ifStmt->get_true_body()));
            else
            {
                // Temporarily added.
                addValueGraphEdge(nodeVertexMap_[lhs], nodeVertexMap_[rhs],
                        pathNumManager_->getPathNumbers(binOp));
            }
            
            createOperatorNode(t, binOp, createValueNode(binOp),
                    nodeVertexMap_[lhs], nodeVertexMap_[rhs]);
            break;
        }
        
        case V_SgNotEqualOp:
        {
            SgIfStmt* ifStmt = isSgIfStmt(binOp->get_parent()->get_parent());
            if (ifStmt)
                addValueGraphEdge(nodeVertexMap_[lhs], nodeVertexMap_[rhs],
                        pathNumManager_->getPathNumbers(ifStmt->get_false_body()));
            
            createOperatorNode(t, binOp, createValueNode(binOp),
                    nodeVertexMap_[lhs], nodeVertexMap_[rhs]);
            break;
        }
            
            
        case V_SgAddOp:
        case V_SgSubtractOp:
        case V_SgMultiplyOp:
        case V_SgDivideOp:
        case V_SgGreaterThanOp:
        case V_SgGreaterOrEqualOp:
        case V_SgLessThanOp:
        case V_SgLessOrEqualOp:
        case V_SgAndOp:
        case V_SgOrOp:
        case V_SgModOp:
        case V_SgBitAndOp:
        case V_SgBitOrOp:
        case V_SgBitXorOp:
            if (nodeVertexMap_.count(lhs) == 0 || nodeVertexMap_.count(rhs) == 0)
            {
                cout << "The operand is not added to VG yet!\n";
                return;
            }
            ROSE_ASSERT(nodeVertexMap_.count(lhs) > 0);
            ROSE_ASSERT(nodeVertexMap_.count(rhs) > 0);

            createOperatorNode(t, binOp, createValueNode(binOp),
                    nodeVertexMap_[lhs], nodeVertexMap_[rhs]);
            break;

        case V_SgPlusAssignOp:
        case V_SgMinusAssignOp:
        case V_SgMultAssignOp:
        case V_SgDivAssignOp:
        case V_SgAndAssignOp:
        case V_SgIorAssignOp:
        case V_SgModAssignOp:
        case V_SgXorAssignOp:
        case V_SgLshiftAssignOp:
        case V_SgRshiftAssignOp:
            {
                if (nodeVertexMap_.count(lhs) == 0 || nodeVertexMap_.count(rhs) == 0)
                {
                    cout << "The operand is not added to VG yet!\n";
                    return;
                }

                VersionedVariable use = getVersionedVariable(lhs);

                ROSE_ASSERT(varVertexMap_.count(use) > 0);
                ROSE_ASSERT(nodeVertexMap_.count(rhs) > 0);

                VGVertex result = createValueNode(lhs, NULL);
                createOperatorNode(
                        getOriginalType(t), binOp, result,
                        varVertexMap_[use], nodeVertexMap_[rhs]);

                // Update the node-vertex table.
                nodeVertexMap_[binOp] = result;
                break;
            }

        case V_SgCommaOpExp:
            nodeVertexMap_[binOp] = nodeVertexMap_[rhs];
            break;
            
        case V_SgPntrArrRefExp:
            break;

        default:
            break;
        }
    }
}

void EventReverser::processVariableReference(SgExpression* expr)
{
    // For a variable reference, if its def is a phi node, we build this phi node here.

    // For data member access, ignore its corresponding "this" pointer.
    if (SgThisExp* thisExp = isSgThisExp(expr))
    {
        createThisExpNode(thisExp);
    }

    else if (SgArrowExp* arrowExp = isSgArrowExp(expr))
    {
#if 0
        if (isSgThisExp(arrowExp->get_lhs_operand()))
        {
            SgExpression* rhsExp = arrowExp->get_rhs_operand();
            // It is possible that this var ref is actually a def.
            // For example, this->a = 0;
            if (nodeVertexMap_.count(rhsExp) > 0)
                nodeVertexMap_[arrowExp] = nodeVertexMap_[rhsExp];
        }
        else
#endif
        {
            VersionedVariable var = getVersionedVariable(arrowExp);
            if (varVertexMap_.count(var) == 0)
                createValueNode(arrowExp);
            else
                nodeVertexMap_[arrowExp] = varVertexMap_[var];
            
            //VersionedVariable var = getVersionedVariable(arrowExp);
            //cout << "Arrow: " << var.toString() << endl;
        }
    }
    
    else if (SgDotExp* dotExp = isSgDotExp(expr))
    {
        VersionedVariable var = getVersionedVariable(dotExp);
        //cout << "Dot: " << var.toString() << endl;
        
        map<VersionedVariable, VGVertex>::iterator iter = varVertexMap_.find(var);
        if (iter != varVertexMap_.end())
        {
            nodeVertexMap_[dotExp] = iter->second;
        }
        else
        {
            createValueNode(dotExp);
        }
    }

    // A cast expression may be a variable reference.
    else if (SgCastExp* castExp = isSgCastExp(expr))
    {
        //castExp->get_operand()->get_file_info()->display();
        //ROSE_ASSERT(nodeVertexMap_.count(castExp->get_operand()));
        if (nodeVertexMap_.count(castExp->get_operand()) > 0)
            nodeVertexMap_[castExp] = nodeVertexMap_[castExp->get_operand()];
    }

#if 0
    else if (SgPointerDerefExp* ptrDerefExp = isSgPointerDerefExp(expr))
    {
        // ...
       
    }

    else if (SgAddressOfOp* addressOfOp = isSgAddressOfOp(expr))
    {
       
    }
#endif

    else if (SgVarRefExp* varRefExp = isSgVarRefExp(expr))
    {
        // Get the var name and version for lhs.
        // We don't know if this var is a use or def now.
        //cout << expr->unparseToString() << endl;
        VersionedVariable var = getVersionedVariable(varRefExp);

        // It is possible that this var ref is actually a def. For example, a = 0;
        map<VersionedVariable, VGVertex>::iterator iter = varVertexMap_.find(var);
        if (iter != varVertexMap_.end())
        {
            nodeVertexMap_[varRefExp] = iter->second;
        }
        else
        {
//                        createValueNode(varRefExp->get_symbol()->get_declaration(), NULL);
//                        cout << varRefExp->unparseToString() << endl;
//                        ROSE_ASSERT(varVertexMap_.count(var));

#if 0
            SgDeclarationStatement* varDecl = varRefExp->get_symbol()
                    ->get_declaration()->get_declaration();

            // If this var ref is declared in a class and it is not static.
            if (isSgClassDefinition(varDecl->get_parent()) && 
                    !SageInterface::isStatic(varDecl))
            {
                createValueNode(varRefExp);
                cout << "New var skipped: " << var << endl;
                return;
            }
#endif
            
            // If this var is not added to VG. This is possible is a variable is modified
            // by a function call.
            createValueNode(varRefExp);
            cout << "!!! Var ref which is unknown!!! " << var << endl;
        }
    }

    else
    {
        cout << expr->class_name() << endl;
        //ROSE_ASSERT(false);
    }
}

void EventReverser::processClassDataMembers(SgClassDefinition* classDef)
{
    ROSE_ASSERT(classDef);
    foreach (SgDeclarationStatement* decl, classDef->get_members())
    {
        SgVariableDeclaration* varDecl = isSgVariableDeclaration(decl);
        if (varDecl == NULL)
            continue;
        foreach (SgInitializedName* initName, varDecl->get_variables())
        {
            //VarName varName(1, initName);
            //VGVertex newNode = createValueNode(initName, NULL);
            //valuesToRestore_[0].insert(newNode);
            addStateVariable(initName);
        }
    }
    
    // Process all its parent classes.
    foreach (SgBaseClass* baseClass, classDef->get_inheritances())
    {
        SgClassDeclaration* classDecl = 
                isSgClassDeclaration(baseClass->get_base_class()->get_definingDeclaration());
        ROSE_ASSERT(classDecl);
        processClassDataMembers(classDecl->get_definition());
    }
}

void EventReverser::assignNameToNodes()
{
    static int counter = 0;

    set<string> names;
    foreach (VGVertex node, boost::vertices(valueGraph_))
    {
        ScalarValueNode* valNode = isScalarValueNode(valueGraph_[node]);
        if (valNode == NULL) continue;
        if (valNode->isAvailable()) continue;

        string name;
        if (valNode->isTemp())
            name = "temp" + boost::lexical_cast<string>(counter++);
        else
            name = valNode->var.toString();
        
        while (names.count(name) > 0)
            name += "_";
        names.insert(name);
        valNode->str = name;
    }
}


void EventReverser::addPathsToEdges()
{    
    vector<VGVertex> phiNodes;

    foreach (const VGEdge& e, boost::edges(valueGraph_))
    {
        ValueGraphEdge* edge = valueGraph_[e];

        // The ordered edge (edge from operator node) does not have path info.
        if (isOrderedEdge(edge)) continue;

        VGVertex src = boost::source(e, valueGraph_);
        //VGVertex tar = boost::target(e, valueGraph_);
        //ValueGraphNode* srcNode = valueGraph_[src];
        //ValueGraphNode* tarNode = valueGraph_[tar];

        // Phi nodes are taken care specially.
        if (isPhiNode(valueGraph_[src]))
        {
            phiNodes.push_back(src);
            continue;
        }

        if (ScalarValueNode* valNode = isScalarValueNode(valueGraph_[src]))
        {
            edge->paths = pathNumManager_->getPathNumbers(valNode->astNode);
        }
    }

#if 0
    set<VGVertex> processedPhiNodes;
    foreach (VGVertex phiNode, phiNodes)
    {
        ValueGraphEdge* stateSavingEdge = 0;
        int dagIdx;
        PathSet paths;
        
        foreach (const VGEdge& e, boost::out_edges(phiNode, valueGraph_))
        {
            VGVertex tar = boost::target(e, valueGraph_);
            ValueGraphEdge* edge = valueGraph_[e];
            ValueGraphNode* node = valueGraph_[tar];

            if (isPhiNode(node))
                addPathsForPhiNodes(tar, processedPhiNodes);
            else if (tar == ssnode_)
                stateSavingEdge = edge;
            else
            {
                ScalarValueNode* valNode = isScalarValueNode(node);
                ROSE_ASSERT(valNode);
                boost::tie(edge->dagIndex, edge->paths) =
                    pathNumManager_->getPathNumbers(valNode->astNode);

                // Collect information for state saving edge from this phi node.
                if (paths.empty())
                {
                    dagIdx = edge->dagIndex;
                    paths = edge->paths;
                }
                else
                    paths |= edge->paths;
            }
        }

        // Add the path information to the state saving edge from phi node.
        ROSE_ASSERT(stateSavingEdge);
        stateSavingEdge->dagIndex = dagIdx;
        stateSavingEdge->paths = paths;
    }
#endif
}

#if 0
EventReverser::PathSetWithIndex EventReverser::addPathsForPhiNodes(
        EventReverser::VGVertex phiNode,
        set<EventReverser::VGVertex>& processedPhiNodes)
{
    // Suppose all paths are in the same set.
    //map<VGEdge, PathSetWithIndex> paths;

    foreach (VGVertex tar, boost::adjacent_vertices(phiNode, valueGraph_))
    {
        if (isPhiNode(valueGraph_[tar]))
        {
            if (processedPhiNodes.count(phiNode) == 0)
                addPathsForPhiNodes(tar, processedPhiNodes);
        }
        if (isScalarValueNode(valueGraph_[tar]))
        {
            
        }

    }

    processedPhiNodes.insert(phiNode);
}
#endif

void EventReverser::addAvailableAndTargetValues()
{
    // Collect all variables visible at the end of the event. It is needed since
    // a data member is not shown from SSA::getLastVersions() for a member event
    // function. So if a state variable does not appear the following set, it is
    // still available.
    set<VarName> varNamesAtEventEnd;
    
    // At the end of the event, find the versions of all variables,
    // and determine which variables are available during the search of VG.
    typedef SSA::NodeReachingDefTable::value_type VarNameDefPair;
    foreach (const VarNameDefPair& nameDef,
            ssa_->getLastVersions(funcDef_->get_declaration()))
             //ssa_->getReachingDefsAtNode_(funcDef_->get_body()->get_statements().back()))
    {
        VarName name = nameDef.first;
        VGVertex node;
        
        varNamesAtEventEnd.insert(name);

        // For every variable, if it is not added into VG, add it now.
        VersionedVariable var(name, nameDef.second->getRenamingNumber());
                
        //cout << "Versioned variable with last version:\t" << var.toString() << endl;
        //printVarVertexMap();
        
        if (varVertexMap_.count(var) > 0)
            node = varVertexMap_[var];
        else
            cout << "!!!Unhandled variable: " << var << endl;
            
        if (isStateVariable(name))
        {
            cout << "Available Var:\t" << var.toString() << endl;
            // If the variable is a state variable, make it available.
            addAvailableValue(node);
        }
        
        
        // If this variable is a parameter and has pointer or reference type,
        // make it available.
        if (name.size() == 1 && isSgFunctionDefinition(name[0]->get_scope()))
        {
            SgType* type = name[0]->get_type();
            if (isSgPointerType(type) || isSgReferenceType(type))
                addAvailableValue(node);
        }
        
#if 0
        // Here we treat any non-local variables as state variables. 
        // Note this is not always true.
        else if (!SageInterface::isAncestor(funcDef_, name[0]->get_scope()))
            addAvailableValue(node);
#endif
    }
    
    // Collect all target values.
    foreach (VGVertex node, boost::vertices(valueGraph_))
    {
        ScalarValueNode* valNode = isScalarValueNode(valueGraph_[node]);
        if (!valNode) continue;
        if (valNode->var.name.empty()) continue;
        
        // Only pick the first initialized name.
        VarName varName(1, valNode->var.name[0]);
        //if (isStateVariable(varName) && valNode->var.version == 0)
        if (isDesiredVariable(varName) && valNode->var.version == 0)
        {
            cout << "Target Var:\t" << valNode->var.toString() << endl;
            valuesToRestore_[0].insert(node);
        }
    }
    
#if 0
    // Those data members which are not modified by the event are also available.
    foreach (const VarName& name, stateVariables_)
    {
        if (varNamesAtEventEnd.count(name) == 0)
        {
            VersionedVariable var(name, 0);
            ROSE_ASSERT(varVertexMap_.count(var));
            addAvailableValue(varVertexMap_[var]);
        }
    }
#endif
}

void EventReverser::addExtraNodesAndEdges()
{
    //! Add reverse edges for phi nodes.
    vector<VGEdge> edges;
    foreach (const VGEdge& edge, boost::edges(valueGraph_))
        edges.push_back(edge);

    foreach (const VGEdge& edge, edges)
    {
        VGVertex src = boost::source(edge, valueGraph_);
        VGVertex tar = boost::target(edge, valueGraph_);

        // State saving edge.
        if (tar == ssnode_)
            continue;

        // If the edge is not connected to an operator node or function call node,
        // make a reverse copy.
        if (isOperatorNode(valueGraph_[src]) || isOperatorNode(valueGraph_[tar]) ||
                isMuNode(valueGraph_[src]) || isMuNode(valueGraph_[tar]) ||
                isFunctionCallNode(valueGraph_[src]) || isFunctionCallNode(valueGraph_[tar]))
            continue;
        
        // If the edge is a mu edge, don't add a reverse edge.
        if (PhiEdge* phiEdge = isPhiEdge(valueGraph_[edge]))
            if (phiEdge->muEdge)
                continue;

        VGEdge newEdge = addValueGraphEdge(tar, src, valueGraph_[edge]);
        valueGraph_[newEdge]->reverse = valueGraph_[edge]->forward;
        valueGraph_[newEdge]->forward = valueGraph_[edge]->reverse;
    }

    //! Add + and - nodes and edges for + and - operations.
    vector<VGVertex> vertices;
    foreach (VGVertex v, boost::vertices(valueGraph_))
        vertices.push_back(v);

    foreach (VGVertex node, vertices)
    {
        OperatorNode* opNode = isOperatorNode(valueGraph_[node]);
        if (opNode == NULL)
            continue;

        if (boost::in_degree(node, valueGraph_) == 0)
            continue;
        
        // The ingoing edge to this operation node.
        VGEdge inEdge = *(boost::in_edges(node, valueGraph_).first);
        
        // For + and - operations.
        if (opNode->type == V_SgAddOp || opNode->type == V_SgSubtractOp)
        {
            // Get all 3 operands first.
            VGVertex result, lhs, rhs;
            result = boost::source(inEdge, valueGraph_);

            foreach (const VGEdge& e, boost::out_edges(node, valueGraph_))
            {
                if (isOrderedEdge(valueGraph_[e])->index == 0)
                    lhs = boost::target(e, valueGraph_);
                else
                    rhs = boost::target(e, valueGraph_);
            }

            // a = b + b cannot be transformed to b = a - b
            if (lhs == rhs)
                continue;

            ValueGraphNode* lhsNode = valueGraph_[lhs];
            ValueGraphNode* rhsNode = valueGraph_[rhs];

            ScalarValueNode* lhsValNode = isScalarValueNode(lhsNode);
            ScalarValueNode* rhsValNode = isScalarValueNode(rhsNode);

            // If the operand is a constant, we don't have to build the relationship.
            if (!(lhsValNode && lhsValNode->isAvailable()))
            {
                VariantT tRev = (opNode->type == V_SgAddOp) ? V_SgSubtractOp : V_SgAddOp;
                VGVertex newNode = createOperatorNode(
                        tRev, opNode->astNode, lhs, result, rhs, valueGraph_[inEdge]);

                VGEdge newEdge = boost::edge(lhs, newNode, valueGraph_).first;
                VGEdge e = *(boost::in_edges(node, valueGraph_).first);
                *valueGraph_[newEdge] = *valueGraph_[e];
            }
            if (!(rhsValNode && rhsValNode->isAvailable()))
            {
                VGVertex newNode = createOperatorNode(
                        V_SgSubtractOp, opNode->astNode, rhs, result, lhs, valueGraph_[inEdge]);

                VGEdge newEdge = boost::edge(rhs, newNode, valueGraph_).first;
                VGEdge e = *(boost::in_edges(node, valueGraph_).first);
                *valueGraph_[newEdge] = *valueGraph_[e];
            }
        }
        // For ++ and -- operations.
        else if (opNode->type == V_SgPlusPlusOp || opNode->type == V_SgMinusMinusOp)
        {
            // Get both 2 operands first.
            VGVertex result, operand;
            result = *(boost::inv_adjacent_vertices(node, valueGraph_).first);
            operand = *(boost::adjacent_vertices(node, valueGraph_).first);

            VariantT tRev = (opNode->type == V_SgPlusPlusOp) ?
                V_SgMinusMinusOp : V_SgPlusPlusOp;
            VGVertex newNode = createOperatorNode(
                    tRev, opNode->astNode, operand, result, nullVertex(), valueGraph_[inEdge]);

            VGEdge newEdge = boost::edge(operand, newNode, valueGraph_).first;
            VGEdge e = *(boost::in_edges(node, valueGraph_).first);
            *valueGraph_[newEdge] = *valueGraph_[e];
        }
    }
}

EventReverser::VGVertex 
EventReverser::createPhiNode(VersionedVariable& var, SSA::ReachingDefPtr reachingDef)
{
    //cout << var.toString() << endl;
    
    //ROSE_ASSERT(pseudoDefMap_.count(var) > 0);
    //SSA::ReachingDefPtr reachingDef = pseudoDefMap_[var];
    SgNode* astNode = reachingDef->getDefinitionNode();

    // Add the phi node.
    VGVertex node = addValueGraphNode(new PhiNode(var, astNode));
    varVertexMap_[var] = node;
    
    // Add the reaching def of this phi node to the table then all phi edges will
    // be added after the VG is built.
    pseudoDefMap_[node] = reachingDef;

    // For every phi function parameter, check if it is also a pseudo def.
    // If it is, add another phi node and connect them. Else, add an edge.
    typedef pair<SSA::ReachingDefPtr, set<ReachingDef::FilteredCfgEdge> > PairT;
	//pair<SSA::ReachingDefPtr, set<CFGEdge> > defEdgePair;
    foreach (const PairT& defEdgePair, reachingDef->getJoinedDefs())
    {
        SSA::ReachingDefPtr def = defEdgePair.first;
        //const set<ReachingDef::FilteredCfgEdge>& cfgEdges = defEdgePair.second;
        int version = def->getRenamingNumber();

        // If this def is also a phi node, add a varWithVersin entry
        // to the varReachingDefMap_ table.
        if (def->isPhiFunction())
        {
            VersionedVariable phiVar(var.name, version, true);
            // If this phi node is not added to VG.
            if (varVertexMap_.count(phiVar) == 0)
            {
                //VGVertex phiNode = createPhiNode(phiVar, def);
                createPhiNode(phiVar, def);
            }
        }
    }

    return node;
}

EventReverser::VGVertex EventReverser::addValueGraphNode(ValueGraphNode* newNode)
{
#if 0
    if (VariableNode* varNode = isVariableNode(newNode))
        cout << "New var added:" << varNode->var << endl;
#endif

    VGVertex v = boost::add_vertex(valueGraph_);
    valueGraph_[v] = newNode;
    //	if (sgNode)
    //		nodeVertexMap_[sgNode] = v;
    return v;
}

EventReverser::VGEdge EventReverser::addValueGraphEdge(
        EventReverser::VGVertex src, 
        EventReverser::VGVertex tar,
        ValueGraphEdge* edgeToCopy)
{
    VGEdge newEdge = boost::add_edge(src, tar, valueGraph_).first;

    if (edgeToCopy)
    {
        valueGraph_[newEdge] = new ValueGraphEdge(*edgeToCopy);
        return newEdge;
    }

    ValueGraphNode* node = valueGraph_[src];
    //ROSE_ASSERT(valNode);

    // Get the path information of this edge from the source node.
    PathInfos paths = pathNumManager_->getPathNumbers(node->astNode);
    
    //ControlDependences controlDeps = cdg_->getControlDependences(node->astNode);
    
    //valueGraph_[e] = new ValueGraphEdge(valNode->getCost(), dagIndex, paths);
    //valueGraph_[newEdge] = new ValueGraphEdge(0, dagIndex, paths);
    
    valueGraph_[newEdge] = new ValueGraphEdge(paths);
    
    return newEdge;
}

EventReverser::VGEdge EventReverser::addValueGraphEdge(
        EventReverser::VGVertex src, 
        EventReverser::VGVertex tar,
        const ArrayRegion& region)
{
    VGEdge newEdge = addValueGraphEdge(src, tar);
    valueGraph_[newEdge]->region = region;
    return newEdge;
}

EventReverser::VGEdge EventReverser::addValueGraphEdge(
        EventReverser::VGVertex src, 
        EventReverser::VGVertex tar,
        const PathInfos& paths)
{
    VGEdge newEdge = boost::add_edge(src, tar, valueGraph_).first;
    valueGraph_[newEdge] = new ValueGraphEdge(paths);
    return newEdge;
}

EventReverser::VGEdge EventReverser::addValueGraphPhiEdge(
        EventReverser::VGVertex src, EventReverser::VGVertex tar,
        const BackstrokeCFG::CFGEdgeType& cfgEdge)
{
    // For every CFG edge, we add a VG edge. This is because we want each VG
    // edge to correspond a CFG edge.

    //cout << "!!!" << cfgEdge.toString() << endl;
    SgNode* node1 = cfgEdge.source().getNode();
    SgNode* node2 = cfgEdge.target().getNode();

    // cout << "\nSRC: " << node1->class_name() << endl;
    //cout << "TGT: " << node2->class_name() << endl;

    // Note that this way works since the function is normalized and every if has
    // two bodies (SgBasicBlock), so there is always a control dependence in CDG
    // for either true or false body. It is like a trick here.


    VGEdge newEdge = boost::add_edge(src, tar, valueGraph_).first;

    PathInfos paths = pathNumManager_->getPathNumbers(node1, node2);
    //ControlDependences controlDeps = cdg_->getControlDependences(node1);
    valueGraph_[newEdge] = new PhiEdge(0, paths);
    return newEdge;
}

EventReverser::VGEdge EventReverser::addValueGraphArrayRegionEdge(
        EventReverser::VGVertex src, EventReverser::VGVertex tar,
        const PathInfos& paths, const ArrayRegion& region)
{
    VGEdge newEdge = boost::add_edge(src, tar, valueGraph_).first;
    //PathInfos paths = pathNumManager_->getPathNumbers(node1, node2);
    ValueGraphEdge* e = new ValueGraphEdge(paths);
    e->region = region;
    valueGraph_[newEdge] = e;
    return newEdge;
}

EventReverser::VGEdge EventReverser::addValueGraphOrderedEdge(
        EventReverser::VGVertex src, EventReverser::VGVertex tar, int index)
{
    VGEdge newEdge = boost::add_edge(src, tar, valueGraph_).first;
    valueGraph_[newEdge] = new OrderedEdge(index);
    return newEdge;
}

void EventReverser::addValueGraphStateSavingEdges(
        VGVertex src, SgNode* killer, bool scopeKiller)
{
//    foreach (VGVertex v, availableValues_)
//    if (ValueNode* valNode = isValueNode(valueGraph_[v]))
//    cout << "Available:\t" << valNode->var << endl;
        
    // Get the cost to save this node.
    int cost = 0;
    if (!isAvailableValue(src))
        cost = valueGraph_[src]->getCost();
    
#if 0
    // Get the path information of this edge.
    int dagIndex;
    map<int, PathSet> visiblePaths;
    boost::tie(dagIndex, visiblePaths) =
            pathNumManager_->getVisiblePathNumbers(killer);
    
    typedef map<int, PathSet>::value_type IntPathsPair;
    foreach (const IntPathsPair& intPaths, visiblePaths)
    {
        if (paths.empty())
            paths = intPaths.second;
        else
            paths |= intPaths.second;
    }
#endif
    
    VGEdge newEdge = boost::add_edge(src, ssnode_, valueGraph_).first;
    PathInfos paths;
    //ControlDependences controlDeps;
    
    if (killer)
    {
        //cout << killer->class_name() << endl;
        //controlDeps = cdg_->getControlDependences(killer);
        paths = pathNumManager_->getPathNumbers(killer);
    }
    else
    {
        // No killer means available for all paths.
        //controlDeps = ??;
        paths = pathNumManager_->getAllPaths();
    }
    
    // For a Mu node, we should remove the corresponding paths of the same DAG index.
    if (MuNode* muNode = isMuNode(valueGraph_[src]))
    {
        PathInfos::iterator iter = paths.find(muNode->dagIndex);
        if (iter != paths.end())
            paths.erase(iter);
    }
    
    cout << "SS==> " << valueGraph_[src]->toString() << " " << cost << endl;
    valueGraph_[newEdge] = new StateSavingEdge(
            cost, paths, killer, scopeKiller);
    
    //valueGraph_[newEdge] = new StateSavingEdge(
    //        cost, paths, controlDeps, visiblePaths, killer);
    
    ///cout << "***" << paths.size() << endl;

//    typedef map<int, PathSet>::value_type NumPathPair;
//    foreach (const NumPathPair& numPath, paths)
//    {
//        VGEdge newEdge = boost::add_edge(src, root_, valueGraph_).first;
//        valueGraph_[newEdge] = new StateSavingEdge(
//                cost, dagIndex, numPath.first, numPath.second, killer);
//    }
}

#if 0
vector<EventReverser::VGEdge>
EventReverser::addValueGraphStateSavingEdges(VGVertex src)
{
//    foreach (VGVertex v, availableValues_)
//    if (ValueNode* valNode = isValueNode(valueGraph_[v]))
//    cout << "Available:\t" << valNode->var << endl;
    
    // Get the cost to save this node.
    int cost = 0;
    if (!isAvailableValue(src))
        cost = valueGraph_[src]->getCost();

    vector<VGEdge> newEdges;

    VGEdge newEdge = boost::add_edge(src, root_, valueGraph_).first;

    SgNode* astNode = NULL;
    if (ScalarValueNode* valNode = isScalarValueNode(valueGraph_[src]))
        astNode = valNode->astNode;
    ROSE_ASSERT(astNode);

    // Get the path information of this edge.
    PathInfos paths = pathNumManager_->getPathNumbers(astNode);
    valueGraph_[newEdge] = new StateSavingEdge(cost, paths);

    // If the variable is killed at the exit of a scope, add a state saving edge to it.

    return newEdges;
}
#endif

set<EventReverser::VGVertex> EventReverser::getKillers(VGVertex killedNode)
{
    return set<VGVertex>();
}

EventReverser::VGVertex EventReverser::createThisExpNode(SgThisExp* thisExp)
{
    VGVertex newNode = addValueGraphNode(new ScalarValueNode(thisExp));
    nodeVertexMap_[thisExp] = newNode;        
    return newNode;
}


EventReverser::VGVertex 
EventReverser::createVectorElementNode(SgFunctionCallExp* funcCallExp)
{
    // If the function called is a member one, also connect an edge from the pointer or object
    // calling this function to the function call node.
    SgBinaryOp* binExp = isSgBinaryOp(funcCallExp->get_function());
    ROSE_ASSERT(binExp);
    
    SgExpression* vecExp = binExp->get_lhs_operand();
    if (SgPointerDerefExp* derefExp = isSgPointerDerefExp(vecExp))
        vecExp = derefExp->get_operand();
    
    SgExpression* indexExp = funcCallExp->get_args()->get_expressions()[0];
    VarName varName = SSA::getVarName(vecExp);


    // Get all uses and defs from this function call.
    const SSA::NodeReachingDefTable& useTable = ssa_->getUsesAtNode(funcCallExp);
    const SSA::NodeReachingDefTable& defTable = ssa_->getDefsAtNode(funcCallExp);
    
    VGVertex useVertex, defVertex;
    
    typedef map<VarName, SSA::ReachingDefPtr>::value_type PT;
    
    bool foundUse = false;
    bool foundDef = false;
    
    foreach (const PT& nameDef, useTable)
    {
        if (nameDef.first == varName)
        {
            VersionedVariable var(varName, nameDef.second->getRenamingNumber());
            ROSE_ASSERT(varVertexMap_.count(var));
            useVertex = varVertexMap_[var];
            foundUse = true;
            break;
        }
    }
    
    foreach (const PT& nameDef, defTable)
    {
        if (nameDef.first == varName)
        {
            VersionedVariable var(varName, nameDef.second->getRenamingNumber());
            ROSE_ASSERT(varVertexMap_.count(var));
            defVertex = varVertexMap_[var];
            foundDef = true;
            break;
        }
    }
    
    if (!(foundUse && foundDef))
    {
        cout << "We cannot find both the use and def of the vector: " << endl;
        cout << binExp->unparseToString() << endl;
        foreach (SgInitializedName* name, varName)
            cout << name->get_name() << ' ';
        cout << endl;
        ROSE_ASSERT(0);
        return VGVertex();
    }
    
    
    // Create a new array element node in the VG, and connect and edge between it
    // and the array/vector.
    VersionedVariable v = getVersionedVariable(indexExp);
    //cout << valueGraph_[defVertex]->toString() << endl;
    
    if (!isScalarValueNode(valueGraph_[defVertex]))
    {
        return VGVertex();
    }
    
    
    cout << isScalarValueNode(valueGraph_[defVertex]) << ' ' << isScalarValueNode(valueGraph_[defVertex])->var.toString() << endl;
    cout << v.toString() << endl;;
    VectorElementNode* eleNode = new VectorElementNode(
            isScalarValueNode(valueGraph_[defVertex])->var,
            getVersionedVariable(indexExp),
            funcCallExp);
    VGVertex eleVertex = addValueGraphNode(eleNode);
    
    // Add this new created vertex to the map.
    nodeVertexMap_[funcCallExp] = eleVertex;

    
    
    //cout << "### Adding two edges between two vectors...\n";
    VGEdge newEdge = addValueGraphEdge(defVertex, useVertex, 
            pathNumManager_->getPathNumbers(valueGraph_[defVertex]->astNode));
    
    SymbolicRepresentation indexSymbol;
    
    // Add an edge between the vector and the element.
    if (eleNode->indexVal)
        indexSymbol.setValue(eleNode->indexVal);
    else
        indexSymbol.setVariable(eleNode->indexVar);
    
    
    // Add an edge between the vector and the element.
    addValueGraphEdge(eleVertex, defVertex,indexSymbol);
    
    
    // Now we only consider that an access of a vector is defined by an assignment.
    if (SgAssignOp* assOp = isSgAssignOp(funcCallExp->get_parent()))
    {
        if (funcCallExp == assOp->get_lhs_operand())
        {
#if 0
            if (nodeVertexMap_.count(assOp->get_rhs_operand()))
            {
            VGVertex rhs = nodeVertexMap_[assOp->get_rhs_operand()];
            addValueGraphEdge(rhs, eleVertex);
            }
#endif
            valueGraph_[newEdge]->region = ArrayRegion(indexSymbol, true);
        }
    }
    
    
    return eleVertex;
}

EventReverser::VGVertex 
EventReverser::createFunctionCallNode(SgFunctionCallExp* funcCallExp)
{   
    SgExpression* caller = NULL;
    bool isMemberFunc = false;
    
    // If the function called is a member one, also connect an edge from the pointer or object
    // calling this function to the function call node.
    if (SgBinaryOp* binExp = isSgBinaryOp(funcCallExp->get_function()))
    {
        caller = binExp->get_lhs_operand();
        isMemberFunc = true;
        
        // Note that this part will be changed once we get how to represent p and *p.
        if (SgPointerDerefExp* ptrDeref = isSgPointerDerefExp(caller))
        {
            // For this->p, we find p.
            caller = ptrDeref->get_operand();
#if 0
            if (SgArrowExp* arrowExp = isSgArrowExp(operand))
            {
                if (isSgThisExp(arrowExp->get_lhs_operand()))
                {
                    caller = arrowExp->get_rhs_operand();
                }
            }
#endif
        }
    }
    
    
    
    // Get all uses and defs from this function call.
    const SSA::NodeReachingDefTable& useTable = ssa_->getUsesAtNode(funcCallExp);
    const SSA::NodeReachingDefTable& defTable = ssa_->getDefsAtNode(funcCallExp);
    const SSA::NodeReachingDefTable& reachingDefTable = ssa_->getReachingDefsAtNode_(funcCallExp);
    //const SSA::NodeReachingDefTable& defTable = 
    
    
    typedef map<VarName, SSA::ReachingDefPtr>::value_type PT;
    
    // Add state saving edges for those modified vars.
    foreach (const PT& nameDef, defTable)
    {
        const VarName& name = nameDef.first;
        ROSE_ASSERT(reachingDefTable.count(name));
        VersionedVariable var(name, reachingDefTable.find(name)->second->getRenamingNumber());

        if (varVertexMap_.count(var) == 0)
            createForgottenValueNode(var);

        addStateSavingEdges(name, funcCallExp);

        VersionedVariable defVar(name, nameDef.second->getRenamingNumber());

        // If the defined variable is not added to the VG.
        if (varVertexMap_.count(defVar) == 0)
        {
            //createValueNode(arg, NULL);
            ScalarValueNode* valNode = new ScalarValueNode(defVar, funcCallExp);
            varVertexMap_[defVar] = addValueGraphNode(valNode);
        }
    }

    if (!isMemberFunc)
    {
        return VGVertex();
    }
    
    // Build a node for this function call in VG.
    FunctionCallNode* funcCallNode = new FunctionCallNode(funcCallExp);
    VGVertex funcCallVertex = addValueGraphNode(funcCallNode);
    
    FunctionCallNode* rvsFuncCallNode;
    VGVertex rvsFuncCallVertex;
    
    bool buildReverseNode = funcCallNode->canBeReversed;
    if (buildReverseNode)
    {
        rvsFuncCallNode = new FunctionCallNode(funcCallExp, true);
        rvsFuncCallVertex = addValueGraphNode(rvsFuncCallNode);
    }
    
    nodeVertexMap_[funcCallExp] = funcCallVertex;
    
  
    //SgExpressionPtrList argList = funcCallExp->get_args()->get_expressions();
    //if (caller) 
    //    argList.push_back(caller);
    
    //    ssa_->getOutgoingDefsAtNode(SageInterface::getEnclosingStatement(funcCallExp));
    
    
    VarName callerName = SSA::getVarName(caller);
    VGVertex callerAsUseVertex = nullVertex();
    VGVertex callerAsDefVertex = nullVertex();
    
    // Real arguments include those variables which are used or defined 
    // in the function call and may not be the arguments of this function.
    set<VGVertex> realArgs;
    
    foreach (const PT& nameDef, useTable)
    {
        VersionedVariable var(nameDef.first, nameDef.second->getRenamingNumber());
        //cout << funcCallExp->unparseToString() << " USE: " << var << "\n\n";
        ROSE_ASSERT(varVertexMap_.count(var));
        realArgs.insert(varVertexMap_[var]);
        
        if (nameDef.first == callerName)
            callerAsUseVertex = varVertexMap_[var];
    }
    
    foreach (const PT& nameDef, defTable)
    {
        const VarName& name = nameDef.first;
        ROSE_ASSERT(reachingDefTable.count(name));
        VersionedVariable var(name, reachingDefTable.find(name)->second->getRenamingNumber());

        realArgs.insert(varVertexMap_[var]);

        if (name == callerName)
        {
            VersionedVariable defVar(name, nameDef.second->getRenamingNumber());
            callerAsDefVertex = varVertexMap_[defVar];
        }
    }
    
    PathInfos paths = pathNumManager_->getPathNumbers(funcCallExp);

    
    // Add edges from the function call node to its args.
    foreach (VGVertex argVertex, realArgs)
    {
        addValueGraphEdge(funcCallVertex, argVertex, paths);
    }
    
    //if (funcCallNode->isConst)
    if (callerAsDefVertex == nullVertex())
        return funcCallVertex;
    
        
    ROSE_ASSERT(callerAsUseVertex != nullVertex());
    ROSE_ASSERT(callerAsDefVertex != nullVertex());
    ROSE_ASSERT(callerAsUseVertex != callerAsDefVertex);
    
    // Add an edge from the caller as def to the function call node.
    addValueGraphEdge(callerAsDefVertex, funcCallVertex, paths);
    
    // This edge will be added in the next loop.
    //addValueGraphEdge(funcCallVertex, callerAsUseVertex);
    
    // Add edges on the reverse function node.
    if (buildReverseNode)
    {
        addValueGraphEdge(callerAsUseVertex, rvsFuncCallVertex, paths);
        addValueGraphEdge(rvsFuncCallVertex, callerAsDefVertex, paths);
    }
    
        
#if 0
        if (funcCallNode->canBeReversed)
            addValueGraphEdge(argVertex, rvsFuncCallVertex, 
                    pathNumManager_->getPathNumbers(funcCallExp));
        
        
        ROSE_ASSERT(isScalarValueNode(valueGraph_[argVertex]));
        VersionedVariable var = isScalarValueNode(valueGraph_[argVertex])->var;
        
        //VarName varName = SSA::getVarName(arg);
        SSA::NodeReachingDefTable::const_iterator iter = defTable.find(var.name);
        if (iter != defTable.end())
        {
            // If this argument is defined by the function call, create a new node 
            // for it.
            var.version = iter->second->getRenamingNumber();
            
            if (varVertexMap_.count(var))
                argVertex = varVertexMap_[var];
            else
            {
                //createValueNode(arg, NULL);
                ScalarValueNode* valNode = new ScalarValueNode(var, funcCallExp);
                argVertex = addValueGraphNode(valNode);
                varVertexMap_[var] = argVertex;
                
                // Add state saving edges for killed defs.
                addStateSavingEdges(var.name, funcCallExp);
            }
        }
        
        // Add an edge from the value to the function call.
        //addValueGraphEdge(argVertex, funcCallVertex);
        
        // Check if we should connect this argument to the reverse function.
        if (funcCallNode->canBeReversed && rvsFuncCallNode->isNeededByInverse(var.name[0]))
        {
            if (isMemberFunc)
            {
                ROSE_ASSERT(nodeVertexMap_.count(caller));

                // For a member function, only connect the reverse function call node to its caller.
                if (nodeVertexMap_[caller] == argVertex)
                    addValueGraphEdge(rvsFuncCallVertex, argVertex);
            }
            else 
                addValueGraphEdge(rvsFuncCallVertex, argVertex);
        }
    }
#endif
    
    
#if 0
    // For a virtual function call, its inverse is called in reverse function.
    // Black box style inversion is not used.
    if (funcCallNode->canBeReversed)
    {
        // If the function called is a virtual one, add two dummy value nodes then its
        // inverse can be generated temporarily. This is a workaround!
        ScalarValueNode* valueNodeIn  = new ScalarValueNode(funcCallExp);
        ScalarValueNode* valueNodeOut = new ScalarValueNode(funcCallExp);
        VGVertex inVertex  = addValueGraphNode(valueNodeIn);
        VGVertex outVertex = addValueGraphNode(valueNodeOut);

        // Add an edge from the in value to the function call.
        addValueGraphEdge(inVertex, rvsFuncCallVertex);

        // Add an edge from the in value to the function call.
        addValueGraphEdge(rvsFuncCallVertex, outVertex);
        
        addAvailableValue(outVertex);
        foreach (std::set<VGVertex>& values, valuesToRestore_)
            values.insert(inVertex);
        
        //return funcCallVertex;
    }
#endif
    
    
#if 0
    // If the function called is a member one, also connect an edge from the pointer or object
    // calling this function to the function call node.
    if (SgBinaryOp* binExp = isSgBinaryOp(funcCallExp->get_function()))
    {
        VGVertex caller;
        SgExpression* lhs = binExp->get_lhs_operand();
        
        // Note that this part will be changed once we get how to represent p and *p.
        if (SgPointerDerefExp* ptrDeref = isSgPointerDerefExp(lhs))
        {
            // For this->p, we find p.
            SgExpression* operand = ptrDeref->get_operand();
            if (SgArrowExp* arrowExp = isSgArrowExp(operand))
            {
                if (isSgThisExp(arrowExp->get_lhs_operand()))
                {
                    SgExpression* rhs = arrowExp->get_rhs_operand();
                    ROSE_ASSERT(nodeVertexMap_.count(rhs) ? true : 
                        (cout << rhs->unparseToString() << endl, false));
        
                    caller = nodeVertexMap_[rhs];
                }
            }
        }
        else
        {
            //VersionedVariable var = getVersionedVariable(lhs, false);
            //ROSE_ASSERT(varVertexMap_.count(var) ? true : 
            //            (cout << var.toString() << endl, false));
            ROSE_ASSERT(nodeVertexMap_.count(lhs));
            caller = nodeVertexMap_[lhs];
        }
        
        addValueGraphEdge(funcCallVertex, caller);
    }
    
    
    
    const SSA::NodeReachingDefTable& defTable = ssa_->getDefsAtNode(funcCallExp);
    typedef map<VarName, SSA::ReachingDefPtr>::value_type PT;

    foreach(const PT& pt, defTable)
    {
        // Build a node for the value defined in this function call in VG.
        VersionedVariable var(pt.first, pt.second->getRenamingNumber());
        createValueNode(funcCallExp);
        
        // Here we set the AST node of this value to be the function call expression
        // in order to get its correct path information.
        ScalarValueNode* valNode = new ScalarValueNode(var, funcCallExp);
        VGVertex lhsVertex = addValueGraphNode(valNode);
        varVertexMap_[var] = lhsVertex;
        
        // Add an edge from the value to the function call.
        addValueGraphEdge(lhsVertex, funcCallVertex);
        
        // Add state saving edges for killed defs.
        addStateSavingEdges(var, funcCallExp);
    }
#endif
    
    return funcCallVertex;
}

void EventReverser::addStateSavingEdges(const VarName& varName, SgNode* astNode)
{
    if (astNode == NULL) return;
    // If the lhs node is a declaration, no state saving is added here.
    if (isSgInitializedName(astNode)) return;
    
    
    //cout << "******SS edge added for: " << varName[0]->unparseToString() << ' ' << astNode->unparseToString() << endl;
    //cout << "******SS edge added for: " << getVersionedVariable(astNode, false) << endl;
    
    // Once a variable is defined, it may kill it previous def. Here we detect
    // all it killed defs then add state saving edges for them in this specific
    //cout << "New Var Defined: " << var << endl;
    SSA::NodeReachingDefTable defTable = ssa_->getReachingDefsAtNode_(astNode);
    
    typedef SSA::NodeReachingDefTable::value_type reachingDefPair;
    foreach (const reachingDefPair& def, defTable)
    {
        // FIXME cannot get the correct reaching def for a loop header!!
        // Update: it is temporarily fixed by a workaround. 
        
        if (def.first == varName)
        {
            //cout << "Killed: " << def.second->getRenamingNumber() << endl;

            int version = def.second->getRenamingNumber();
            //ROSE_ASSERT(version != var.version);
            
            VersionedVariable killedVar(varName, version);
            //cout << "Killed: " << killedVar << endl;

#if 1
            // It is possible that the phi node is not built at this point.
            if (varVertexMap_.count(killedVar) == 0)
            {
                //cout << killedVar << endl;
                if (def.second->isPhiFunction())
                    createPhiNode(killedVar, def.second);
                else
                    continue;
                    //ROSE_ASSERT(false);
            }
#endif
            ROSE_ASSERT(varVertexMap_.count(killedVar));
            
            // We don't add SS edge to a mu node.
            if (isMuNode(valueGraph_[varVertexMap_[killedVar]]))
                continue;

            addValueGraphStateSavingEdges(varVertexMap_[killedVar], astNode);
        }
    }
}

EventReverser::VGVertex EventReverser::createForgottenValueNode(const VersionedVariable& var)
{
    VGVertex newVertex;

    // If rhs node is not created yet, create it first.
    if (varVertexMap_.count(var) == 0)
    {
        //ROSE_ASSERT(!"Infeasible path???");
        newVertex = addValueGraphNode(new ScalarValueNode(var, funcDef_));
        //nodeVertexMap_[node] = newVertex;
        if (!var.isNull())
            varVertexMap_[var] = newVertex;
    }
    else
        newVertex = varVertexMap_[var];

    return newVertex;
}

EventReverser::VGVertex EventReverser::createValueNode(SgNode* node)
{
    VGVertex newVertex;

    // If rhs node is not created yet, create it first.
    if (nodeVertexMap_.count(node) == 0)
    {
        //ROSE_ASSERT(!"Infeasible path???");
        VersionedVariable var = getVersionedVariable(node, true);
        newVertex = addValueGraphNode(new ScalarValueNode(var, node));
        nodeVertexMap_[node] = newVertex;
        if (!var.isNull())
            varVertexMap_[var] = newVertex;
    }
    else
        newVertex = nodeVertexMap_[node];

    return newVertex;
}

EventReverser::VGVertex EventReverser::createValueNode(SgNode* lhsNode, SgNode* rhsNode)
{
    VGVertex lhsVertex;
    VGVertex rhsVertex;
    VersionedVariable var = getVersionedVariable(lhsNode, false);
    
    //cout << "=======> New var added: " << var << endl;
    
    if (lhsNode)
    {
        // Add state saving edge here
        addStateSavingEdges(var.name, lhsNode);
    }

    if (rhsNode)
    {
        // If rhs node is not created yet, create it first.
        if (nodeVertexMap_.count(rhsNode) == 0)
        {
            //ROSE_ASSERT(!"Infeasible path???");
            VersionedVariable rhsVar = getVersionedVariable(rhsNode, true);
            rhsVertex = addValueGraphNode(new ScalarValueNode(rhsVar, rhsNode));
            nodeVertexMap_[rhsNode] = rhsVertex;
            if (!rhsVar.isNull())
                varVertexMap_[rhsVar] = rhsVertex;
        }
        else
            rhsVertex = nodeVertexMap_[rhsNode];
    }

#if 0
    // If rhsNode just contains a rvalue, combine those two nodes.
    if (lhsNode && rhsNode)
    {
        ScalarValueNode* rhsValNode = isScalarValueNode(valueGraph_[rhsVertex]);
        //ROSE_ASSERT(rhsValNode);
        // It is possible that rhsValNode is NULL when it is a function call node.
        if (rhsValNode && rhsValNode->var.isNull())
        {
            //rhsValNode->var = getVersionedVariable(lhsNode, false);
            rhsValNode->var = var;
            rhsValNode->astNode = lhsNode;
            varVertexMap_[rhsValNode->var] = rhsVertex;
            nodeVertexMap_[lhsNode] = rhsVertex;
            return rhsVertex;
        }
    }
#endif
    
    if (lhsNode)
    {
        //VersionedVariable var = getVersionedVariable(lhsNode, false);

        ScalarValueNode* valNode = new ScalarValueNode(var, lhsNode);
        lhsVertex = addValueGraphNode(valNode);

        varVertexMap_[var] = lhsVertex;
        nodeVertexMap_[lhsNode] = lhsVertex;

        // If rhs node is not NULL, add an edge.
        if (rhsNode)
            addValueGraphEdge(lhsVertex, rhsVertex);
        
        return lhsVertex;
    }

    return rhsVertex;
}

EventReverser::VGVertex EventReverser::createOperatorNode(
        VariantT t,
        SgNode* astNode,
        EventReverser::VGVertex result,
        EventReverser::VGVertex lhs,
        EventReverser::VGVertex rhs,
        ValueGraphEdge* edgeToCopy)
{
    // Add an operator node to VG.
    VGVertex op = addValueGraphNode(new OperatorNode(t, astNode));

    addValueGraphEdge(result, op, edgeToCopy);
    addValueGraphOrderedEdge(op, lhs, 0);
    if (rhs != nullVertex())
        addValueGraphOrderedEdge(op, rhs, 1);

    return op;
}

std::set<VersionedVariable> EventReverser::getReachingDefinitions(SgNode* node)
{
    std::set<VersionedVariable> vars;
    
    const SSA::NodeReachingDefTable& defTable =
        ssa_->getReachingDefsAtNode_(node);
    typedef map<VarName, SSA::ReachingDefPtr>::value_type PT;
    foreach(const PT& pt, defTable)
    {
        int version = pt.second->getRenamingNumber();
        vars.insert(VersionedVariable(pt.first, version));
    }
    return vars;
}

void EventReverser::addPhiEdges()
{    
    typedef SSA::NodeReachingDefTable::value_type VarNameDefPair;
    
    // At the end of the event, find the versions of all variables. It is possible 
    // that a phi node with the final version is not added to VG yet.
    vector<SgBasicBlock*> basicBlocks = BackstrokeUtility::querySubTree<SgBasicBlock>(funcDef_);
    foreach (SgBasicBlock* basicBlock, basicBlocks)
    {
        if (basicBlock->get_statements().empty())
            continue;
        
        foreach (const VarNameDefPair& nameDef, 
            ssa_->getReachingDefsAtNode_(basicBlock->get_statements().back()))
        {
            // For every variable, if it is not added into VG, add it now.
            VersionedVariable var(nameDef.first, nameDef.second->getRenamingNumber());

            if (varVertexMap_.count(var) == 0)
            {
                // Currently an object's member access is not added to VG.
                if (var.name.size() == 1)
                {
                    if (nameDef.second->isPhiFunction())
                        createPhiNode(var, nameDef.second);
                    else
                        cout << "!!!Unhandled variable: " << var << endl;
                }
            }
        }
    }
    
    // Since return statements directly point to CFG exit. We have to call SSA::getLastVersions
    // to get the final versions.
    foreach (const VarNameDefPair& nameDef, 
        ssa_->getLastVersions(funcDef_->get_declaration()))
    {
        // For every variable, if it is not added into VG, add it now.
        VersionedVariable var(nameDef.first, nameDef.second->getRenamingNumber());

        if (varVertexMap_.count(var) == 0)
        {
            // Currently an object's member access is not added to VG.
            if (var.name.size() == 1)
            {
                if (nameDef.second->isPhiFunction())
                    createPhiNode(var, nameDef.second);
                else
                    cout << "!!!Unhandled variable: " << var << endl;
            }
        }
    }
    
    // It is possible that new nodes will be added, so first collect all phi nodes.
    vector<pair<VGVertex, PhiNode*> > phiNodes;
    foreach (VGVertex node, boost::vertices(valueGraph_))
    {
        PhiNode* phiNode = isPhiNode(valueGraph_[node]);
        if(phiNode) 
        {
            ROSE_ASSERT(phiNode->var.name.size());
            phiNodes.push_back(make_pair(node, phiNode));
        }
    }
    
    // Get all back edges in CFG.
    set<BackstrokeCFG::CFGEdgeType> backEdges;
    foreach (const CFGEdge& cfgEdge, cfg_->getAllBackEdges())
        backEdges.insert(*(*cfg_)[cfgEdge]);
    
    typedef pair<VGVertex, PhiNode*> VertexPhiNode;
    foreach (const VertexPhiNode& vertexNode, phiNodes)
    {
        VGVertex node = vertexNode.first;
        PhiNode* phiNode = vertexNode.second;
        
        if (phiNode == NULL) continue;
        
        ROSE_ASSERT(pseudoDefMap_.count(node));
        
        SSA::ReachingDefPtr reachingDef = pseudoDefMap_[node];
        
        // A copy of a Mu node.
        MuNode* newMuNode = NULL;
        VGVertex duplicatedNode;
            
        // For every phi function parameter, check if it is also a pseudo def.
        // If it is, add another phi node and connect them. Else, add an edge.
        typedef pair<SSA::ReachingDefPtr, set<ReachingDef::FilteredCfgEdge> > PairT;
        foreach (const PairT& defEdgePair, reachingDef->getJoinedDefs())
        {
            SSA::ReachingDefPtr def = defEdgePair.first;
            const set<BackstrokeCFG::CFGEdgeType>& cfgEdges = defEdgePair.second;
            int version = def->getRenamingNumber();
            
            VersionedVariable defVar(phiNode->var.name, version);
            //cout << "$$$" << defVar << " for phi node: " << phiNode->var << endl;
            
            //// Currently the extern variables may not be built here. Just skip it.
            if (varVertexMap_.count(defVar) == 0)
            {
                createForgottenValueNode(defVar);
#if 0
                // It is possible that the initial def of a state variable is not added to value graph.
                // It is also possible that object access modifies the versions of all vars, and at this
                // point, if a.b is changed, we don't have the updated var of a.
                //ROSE_ASSERT(version == 0 && phiNode->var.name.size() == 1);
                //if (phiNode->var.name.size() == 1)
                if (isStateVariable(phiNode->var.name))
                    createValueNode(phiNode->var.name[0], NULL);
                else
                {
                    cout << "\n!!! Cannot find the vertex for " << defVar << "\n\n";
                    createForgottenValueNode(defVar);
                    //continue;
                }
#endif
            }
            //cout << defVar.toString() << endl;
            ROSE_ASSERT(varVertexMap_.count(defVar));
            
            // This should be a bug in SSA.
            if (node == varVertexMap_[defVar])
            {
                cout << "!!! One of the defs of a phi node is itself!\n";
                continue;
            }

            foreach (const BackstrokeCFG::CFGEdgeType& cfgEdge, cfgEdges)
            {
                if (backEdges.count(cfgEdge))
                {
                    phiNode->isMuNode = true;
                    SgBasicBlock* loopBody = isSgBasicBlock(phiNode->astNode);
                    ROSE_ASSERT(loopBody);
                    
                    if (isVectorNode(phiNode))
                        continue;
                    
                    // Connet the mu node with the last def in the loop body.
                    set<VersionedVariable> reachingDefs = 
                            getReachingDefinitions(loopBody->get_statements().back());
                    foreach (const VersionedVariable& var, reachingDefs)
                    {
                        if (phiNode->var.name == var.name)
                        {
                            cout << var << "---" << phiNode->var << endl;
                            ROSE_ASSERT(varVertexMap_.count(var));
                            ROSE_ASSERT(varVertexMap_.count(phiNode->var));
                            VGEdge newEdge = addValueGraphEdge(varVertexMap_[var], varVertexMap_[phiNode->var]);
                            valueGraph_[newEdge]->reverse = true;
                            //addValueGraphEdge(varVertexMap_[phiNode->var], varVertexMap_[var]);
                        }
                    }
#if 0
                    if (newMuNode == NULL)
                    {
                        MuNode* muNode = new MuNode(*phiNode);
                        muNode->dagIndex = pathNumManager_->getLoopDagIndex(phiNode->astNode);
                        
                        valueGraph_[node] = muNode;
                        delete phiNode;
                        phiNode = muNode;
                        
                        // A Mu mode can kill the defs from non-back edge. Add state
                        // saving edges here.
                        // Note that currently there is a bug in the SSA. We cannot get
                        // the correct reaching defs on the loop header. Here we assume
                        // a mu node kills the def coming from outside of the loop, not the 
                        // one from inside of the loop. Therefore, we make a workaround here
                        // by pass the CFG node ahead of the loop header.
                        
                        SgNode* preheader = NULL;
                        
                        foreach (BackstrokeCFG::CFGEdgePtr e, cfg_->getAllEdges())
                        {
                            //const BackstrokeCFG::CFGEdgeType& e = *ce;
                            if (e->target() == cfgEdge.target() && 
                                    *e != cfgEdge && 
                                    backEdges.count(*e) == 0)
                            {
                                preheader = e->source().getNode();
                                break;
                            }
                        }
                        ROSE_ASSERT(preheader);
                        
                        
                        // Will transform all for loops into while loops.
#if 0
                        // Set this node to the loop itself.
                        while (preheader && 
                                !isSgForStatement(preheader) && 
                                !isSgWhileStmt(preheader) && 
                                !isSgDoWhileStmt(preheader))
                            preheader = preheader->get_parent();
                        
                        // We add a null stmt just before the loop and set the preheader
                        // to this null stmt.
                        
                        SgBasicBlock* bb = isSgBasicBlock(preheader->get_parent());
                        ROSE_ASSERT(bb);
                        const vector<SgStatement*>& stmts = bb->get_statements();
                        ROSE_ASSERT(stmts.size() > 1);
                        for (size_t i = 1; i < stmts.size(); ++i)
                            if (stmts[i] == preheader)
                                preheader = stmts[i-1];
                        
                        ROSE_ASSERT(preheader);
#endif
                        
                        //cout << muNode->toString() << ' ' << preheader->unparseToString() << endl;
                        //addStateSavingEdges(muNode->var.name, preheader);
                        
#if 0
                        // For a Mu node, we duplicate it and connect all Mu edges to it.
                        duplicatedNode = boost::add_vertex(valueGraph_);
                        newMuNode = new MuNode(*muNode);
                        newMuNode->isCopy = true;
                        valueGraph_[duplicatedNode] = newMuNode;
#endif
                    }
                    //addValueGraphPhiEdge(duplicatedNode, varVertexMap_[defVar], cfgEdge);
#endif
                }
                else
                {
                    //// !!! Work-around. SSA cannot get the correct reaching def for loop headers.
                    //addValueGraphStateSavingEdges(varVertexMap_[defVar], cfgEdge.target().getNode());
                    
                    addValueGraphPhiEdge(node, varVertexMap_[defVar], cfgEdge);
                }
            }
        }
    }
}

void EventReverser::addStateSavingEdges()
{
    foreach (VGVertex v, boost::vertices(valueGraph_))
    {
        ValueGraphNode* node = valueGraph_[v];

        // SS edges are only added to phi nodes and value nodes.
        ScalarValueNode* valNode = isScalarValueNode(node);
        if (valNode == NULL) continue;
        
#if 0
        // If the variable in this node is a local variable, find its scope
        // and add a state saving edge for it containing the scope.
        SgNode* astNode = valNode->astNode;
        if (SgInitializedName* initName = isSgInitializedName(astNode))
        {
            cout << "@@@" << initName->get_name() << endl;
            // Note that the scope of a variable may be class (data member) or
            // function parameters, in which case we set its scope as function body.
            SgScopeStatement* scope = initName->get_scope();
            //SgBasicBlock* funcBody = funcDef_->get_body();
            
            if (SgFunctionDefinition* funcDef = isSgFunctionDefinition(scope))
                scope = funcDef->get_body();
            
            if (SgBasicBlock* basicBlock = isSgBasicBlock(scope))
            {
                // Find the last def of this variable in its definition scope.
                // !!! Note this is a hack since the bug in SSA.
                ROSE_ASSERT(isSgNullStatement(basicBlock->get_statements().back()));
                const SSA::NodeReachingDefTable& defTable = 
                    ssa_->getReachingDefsAtNode_(basicBlock->get_statements().back());

                const VarName& varName = valNode->var.name;
                SSA::NodeReachingDefTable::const_iterator iter = defTable.find(varName);
                //ROSE_ASSERT(iter != defTable.end());
                if (iter != defTable.end())
                {
                    SSA::ReachingDefPtr reachingDef = iter->second;
                    int version = reachingDef->getRenamingNumber();
                    VersionedVariable var(varName, version);
                    ROSE_ASSERT(varVertexMap_.count(var));

                    cout << "Add a SS edge: " << var.toString() << "--SS-->" << scope->class_name() << "\n\n";

                    ROSE_ASSERT(isSgScopeStatement(scope));
                    addValueGraphStateSavingEdges(varVertexMap_[var], scope, true);
                }       
            }
        }
#endif
        
        // Treat "this" node as an available value
        // !!! This is a work-around, since this is no version info for this node now.
        if (isSgThisExp(valNode->astNode))
        {
            addAvailableValue(v);
            //addValueGraphStateSavingEdges(v, funcDef_, true);
        }
        
        // A value node which is available should be added to available values set.
        if (valNode->isAvailable())
            addAvailableValue(v);
        
        
        // A temporary work-around for lacking of getting last defs for a variable.
        if (isAvailableValue(v))
        {
            addValueGraphStateSavingEdges(v, NULL);
        }
        
#if 0
        // For a mu node, make it available for its own DAG
        // Note this a kind of hack when doing this. A mu node is available in its
        // own DAG. The path information only contains those paths in this DAG.
        if (MuNode* muNode = isMuNode(valueGraph_[v]))
        {
            if (!muNode->isCopy)
                continue;
            
            // Only if the Mu node is a copy when it is available.
            VGEdge newEdge = boost::add_edge(v, ssnode_, valueGraph_).first;
            PathInfos paths = pathNumManager_->getPathNumbers(funcDef_);

            // The real paths only contains the paths in its own DAG.
            PathInfos realPaths;
            realPaths[muNode->dagIndex] = paths[muNode->dagIndex];

            // Null control dependence.
            //ControlDependences controlDeps;
            valueGraph_[newEdge] = new StateSavingEdge(0, realPaths, NULL);
        }
#endif
        
        
#if 0
        // Give every value node one more SS edge.
        cout << valNode->astNode->unparseToString() << endl;
        // For workaround of function calls.
        if (!isSgFunctionCallExp(valNode->astNode) 
                && SageInterface::isAncestor(funcDef_, valNode->astNode))
            addValueGraphStateSavingEdges(v, valNode->astNode);
#endif
    }
    
#if 0
    // !!!Work-around again!!! Now we cannot get the last def for each variable. So if a value node has
    // no out SS edges, we add one for it. This is for local variables mainly.
    foreach (VGVertex v, boost::vertices(valueGraph_))
    {
        ScalarValueNode* valNode = isScalarValueNode(valueGraph_[v]);
        if (!valNode || valNode->var.name.size() != 1)
            continue;
                
        bool hasSSOrPhiEdge = false;
        
        foreach (const VGEdge& edge, boost::out_edges(v, valueGraph_))
        {
            if (isStateSavingEdge(valueGraph_[edge]))
            {
                hasSSOrPhiEdge = true;
                break;
            }
        }
        
        if (!hasSSOrPhiEdge)
        {
            foreach (const VGEdge& edge, boost::in_edges(v, valueGraph_))
            {
                // Phi edge is OK.
                if (isPhiEdge(valueGraph_[edge]))
                {
                    hasSSOrPhiEdge = true;
                    break;
                }
            }
        }
        
        if (hasSSOrPhiEdge)
            continue;

        SgInitializedName* initName = valNode->var.name[0];
        SgScopeStatement* scope = initName->get_scope();
        if (!SageInterface::isAncestor(funcDef_, scope)) 
            continue;
        
        if (SgFunctionDefinition* funcDef = isSgFunctionDefinition(scope))
            scope = funcDef->get_body();
        
        cout << "Add a SS edge: " << valNode->var.toString() << "--SS-->" << scope->class_name() << "\n\n";
        
        addValueGraphStateSavingEdges(varVertexMap_[valNode->var], scope, true);
    }
#endif
    
    
    // For each scope statement, find all its early exits, and add 
    // state saving edges for local variables in that scope.
    map<SgScopeStatement*, vector<SgStatement*> > exitsForScopes;
    foreach (SgScopeStatement* scope, 
            BackstrokeUtility::querySubTree<SgScopeStatement>(funcDef_))
    {
        exitsForScopes[scope] = BackstrokeUtility::getEarlyExits(scope);
    }
    
    // This set makes sure each variable is processed only once.
    set<SgInitializedName*> processedVars;
    foreach (VGVertex v, boost::vertices(valueGraph_))
    {
        ScalarValueNode* valNode = isScalarValueNode(valueGraph_[v]);
        if (!valNode || valNode->var.name.size() != 1)
            continue;
        
        SgInitializedName* initName = valNode->var.name[0];
        if (processedVars.count(initName))
            continue;
        
        // Workaround for __func__ initName used in assert. 
        // It seems that there is no definition of __func__, which may be a keyword under MacOS.
        if (initName->get_name() == "__func__")
            continue;
        
        SgScopeStatement* scope = initName->get_scope();
        if (SgFunctionDefinition* funcDef = isSgFunctionDefinition(scope))
            scope = funcDef->get_body();
        
        if (!SageInterface::isAncestor(funcDef_, scope)) 
            continue;
        
        //ROSE_ASSERT(exitsForScopes.count(scope));
        
            
        // We have added a null statement to every basic block and then we can get the 
        // reaching defs on this statement to get all last versions of local variables.
        if (SgBasicBlock* basicBlock = isSgBasicBlock(scope))
        {
            //cout << "Scope end SS edge: " << initName->get_name() 
            //        << "--SS-->" << basicBlock->class_name() << '\n' <<
            //        basicBlock->unparseToString() << "\n\n";
            ROSE_ASSERT(isSgNullStatement(basicBlock->get_statements().back()));
            addStateSavingEdges(VarName(1, initName), basicBlock->get_statements().back());
        }
        
        
        // For each early exit, add a SS edge for this local variable.
        foreach (SgStatement* exit, exitsForScopes[scope])
        {
            //cout << "Early exit SS edge: " << initName->get_name() 
            //        << "--SS-->" << exit->class_name() << "\n\n";
            addStateSavingEdges(VarName(1, initName), exit);
        }
        
        processedVars.insert(initName);
    }
    
}

VersionedVariable EventReverser::getVersionedVariable(SgNode* node, bool isUse/*= true*/, SgNode* defNode/*= NULL*/)
{
    if (node == NULL)
        return VersionedVariable();

    // Workaround for that SSA cannot get the var name for a cast expression.
    while (SgCastExp* castExp = isSgCastExp(node))
        node = castExp->get_operand();
    
#if 0
    cout << node->class_name() << " : " << node->unparseToString() << endl;
    node->get_file_info()->display();
#endif
    
    VarName varName = SSA::getVarName(node);
    int version = 0;
#if 1
    // The following code is needed since SSA cannot give us the version of data members.
    SgInitializedName* initName = isSgInitializedName(node);
    if (initName) // && isSgClassDefinition(initName->get_declaration()->get_parent()))
    {
        varName = VarName(1, initName);
        version = 0;
    }
#endif
    
    if (varName.empty())
    {
        cout << "!!! Cannot find the var name for SgNode: " << node->class_name() << " " << node->unparseToString() << ".\n";
        return VersionedVariable(varName, -1);
    }
    
    ROSE_ASSERT(!varName.empty());

    // First, check if there is any use at the given node. If not, it should be a def.
    if (isUse)
    {
        const SSA::NodeReachingDefTable& defTable = ssa_->getUsesAtNode(node);

#if 0
        cout << "Print use table:\n";
        typedef map<VarName, SSA::ReachingDefPtr>::value_type PT;
        foreach (const PT& pt, defTable)
        cout << "!" << SSA::varnameToString(pt.first) << " " << pt.second->getRenamingNumber() << endl;
#endif
        
        SSA::NodeReachingDefTable::const_iterator iter = defTable.find(varName);
        if (iter != defTable.end())
        {
            //ROSE_ASSERT(defTable.count(varName) > 0);
            SSA::ReachingDefPtr reachingDef = iter->second;
            version = reachingDef->getRenamingNumber();
            VersionedVariable var(varName, version);
            
            // If this var already exists, return it.
            map<VersionedVariable, VGVertex>::iterator it = varVertexMap_.find(var);
            if (it != varVertexMap_.end())
                return it->first;

            // If its reaching def is a phi function, it's a pseudo def.
            // Note why we capture the phi node here is because we cannot access phi
            // nodes directly now from SSA.
            if (reachingDef->isPhiFunction())
            {
                VersionedVariable var(varName, version, true);
                //cout << "Found a phi node: " << var.toString() << "\n\n";
                //pseudoDefMap_[var] = reachingDef;
                createPhiNode(var, reachingDef);
                return var;
            }
        }
    }
    else
    {
#if 0
        cout << node->class_name() << endl;
        cout << node->get_parent()->class_name() << endl;
        cout << node->get_parent()->get_parent()->class_name() << endl;
#endif
        if (defNode == NULL)
            defNode = node->get_parent();
        const SSA::NodeReachingDefTable& defTable =
            //ssa_->getOutgoingDefsAtNode(node->get_parent());
            //ssa_->getOutgoingDefsAtNode(SageInterface::getEnclosingStatement(node));
            ssa_->getDefsAtNode(defNode);
            //ssa_->getOutgoingDefsAtNode(node->get_parent()->get_parent());

#if 0
        cout << "Print def table:\n";
        typedef map<VarName, SSA::ReachingDefPtr>::value_type PT;
        foreach (const PT& pt, defTable)
        cout << "!" << SSA::varnameToString(pt.first) << " " << pt.second->getRenamingNumber() << endl;
#endif

        SSA::NodeReachingDefTable::const_iterator iter = defTable.find(varName);
        if (iter != defTable.end())
        {
            SSA::ReachingDefPtr reachingDef = iter->second;
            version = reachingDef->getRenamingNumber();
        }
        else
        {
#if 0
            // If the AST node is a variable declaration in a class, assign version
            // 0 to it.
            SgInitializedName* initName = isSgInitializedName(node);
            if (initName == NULL)
            {
                ROSE_ASSERT(!"Cannot find the given node in the def table.");
            }

            if (isSgClassDefinition(initName->get_declaration()->get_parent()))
            {
                //VersionedVariable vv(varName, 1);
                //cout << vv.toString() << endl;
                // Due to the bug in SSA, return a versioned variable with initname
                // with version 1 here.
                return VersionedVariable(VarName(1, initName), 1);
            }
#endif
        }
    }

    return VersionedVariable(varName, version);
}

void EventReverser::removeUselessEdges()
{
    vector<VGEdge> edgesToRemove;
    foreach (const VGEdge& e, boost::edges(valueGraph_))
    {
        // We do an optimization here by removing all out edges except state
        // saving one from an available node.
        VGVertex src = boost::source(e, valueGraph_);
        if (isAvailableValue(src))
        {
            VGVertex tar = boost::target(e, valueGraph_);
            if (tar != ssnode_)
                edgesToRemove.push_back(e);
        }
    }

    foreach (const VGEdge& edge, edgesToRemove)
    {
        delete valueGraph_[edge];
        boost::remove_edge(edge, valueGraph_);
    }
}

void EventReverser::removeUselessNodes()
{
    // Remove redundant edges first, then more nodes can be removed.
    removeUselessEdges();
    
    set<VGVertex> usableNodes;

    stack<VGVertex> nodes;
    foreach (VGVertex node, valuesToRestore_[0])
    {
        usableNodes.insert(node);
        nodes.push(node);
    }

    while (!nodes.empty())
    {
        VGVertex n = nodes.top();
        nodes.pop();

        foreach (VGVertex tar, boost::adjacent_vertices(n, valueGraph_))
        {
            if (usableNodes.count(tar) == 0)
            {
                usableNodes.insert(tar);
                nodes.push(tar);
            }
        }
    }

    vector<VGEdge> edgesToRemove;

    // Remove edges first.
    foreach (const VGEdge& e, boost::edges(valueGraph_))
    {
        if (usableNodes.count(boost::source(e, valueGraph_)) == 0)
        {
            edgesToRemove.push_back(e);
            continue;
        }
    }

    foreach (const VGEdge& edge, edgesToRemove)
    {
        delete valueGraph_[edge];
        boost::remove_edge(edge, valueGraph_);
    }

    vector<VGVertex> verticesToRemove;

    // Then remove nodes.
    foreach (VGVertex v, boost::vertices(valueGraph_))
    {
        if (usableNodes.count(v) == 0)
            verticesToRemove.push_back(v);
    }

    foreach (VGVertex v, verticesToRemove)
    {
        delete valueGraph_[v];
        boost::remove_vertex(v, valueGraph_);
    }
}

void EventReverser::valueGraphToDot(const std::string& filename) const
{
    // Since the vetices are stored in a list, we have to give each vertex
    // a unique id here.
    int counter = 0;
    map<VGVertex, int> vertexIDs;
    foreach (VGVertex v, boost::vertices(valueGraph_))
        vertexIDs[v] = counter++;

    // Turn a std::map into a property map.
    boost::associative_property_map<map<VGVertex, int> > vertexIDMap(vertexIDs);

    ofstream ofile(filename.c_str(), std::ios::out);
    boost::write_graphviz(ofile, valueGraph_,
            boost::bind(&EventReverser::writeValueGraphNode, this, ::_1, ::_2),
            boost::bind(&EventReverser::writeValueGraphEdge, this, ::_1, ::_2),
            boost::default_writer(), vertexIDMap);
    ofile.close();
}

void EventReverser::routeGraphToDot(const std::string& filename) const
{
    // Since the vetices are stored in a list, we have to give each vertex
    // a unique id here.
    int counter = 0;
    map<VGVertex, int> vertexIDs;
    foreach (VGVertex v, boost::vertices(routeGraph_))
        vertexIDs[v] = counter++;

    // Turn a std::map into a property map.
    boost::associative_property_map<map<VGVertex, int> > vertexIDMap(vertexIDs);

    ofstream ofile(filename.c_str(), std::ios::out);
    boost::write_graphviz(ofile, routeGraph_,
            boost::bind(&EventReverser::writeValueGraphNode, this, ::_1, ::_2),
            boost::bind(&EventReverser::writeValueGraphEdge, this, ::_1, ::_2),
            boost::default_writer(), vertexIDMap);
    ofile.close();
}

SgNode* EventReverser::RouteGraphEdgeComp::getAstNode(const VGEdge& edge) const
{
    VGVertex src = boost::source(edge, routeGraph);
    VGVertex tgt = boost::target(edge, routeGraph);
    
    if (StateSavingEdge* ssEdge = isStateSavingEdge(routeGraph[edge]))
    {
        if (ssEdge->cost == 0)
        {
            return SageInterface::getEnclosingFunctionDefinition(routeGraph[src]->astNode);
            //return routeGraph[src]->astNode;
        }
#if 0
        if (ssEdge->scopeKiller)
        {
            // !!! Work-around
            if (SgBasicBlock* basicBlock = isSgBasicBlock(ssEdge->killer))
            {
                if (SgFunctionDefinition* funcDef = isSgFunctionDefinition(basicBlock->get_parent()))
                    return funcDef;
                
                return basicBlock->get_statements().back();
            }
            else
                ROSE_ASSERT(false);
        }
#endif
        return ssEdge->killer;
    }
    if (isOperatorNode(routeGraph[tgt]) || isFunctionCallNode(routeGraph[tgt]))
        return routeGraph[tgt]->astNode;  
    if (MuNode* muNode = isMuNode(routeGraph[src]))
        if (muNode->isCopy)
            return NULL;
    
#if 0
    if (isPhiNode(routeGraph[src]))
        return routeGraph[src]->astNode;
    if (isPhiNode(routeGraph[tgt]))
        return routeGraph[tgt]->astNode;
    return routeGraph[tgt]->astNode;  
#endif
    
    return routeGraph[src]->astNode;  
}

int EventReverser::RouteGraphEdgeComp::getEdgeValue(const VGEdge& edge) const
{
    SgNode* node = getAstNode(edge);
    
    VGVertex src = boost::source(edge, routeGraph);
    VGVertex tgt = boost::target(edge, routeGraph);

    map<SgNode*, int>::const_iterator iter = nodeIndexTable.find(node);
    
    int val = (iter == nodeIndexTable.end()) ? 0 : iter->second;
    
    // Because phi node always appears at the beginning of a basic block in CFG, decrease
    // its value to reflect this fact.
    if (isPhiNode(routeGraph[src]))    
        --val;
    
    // A functin call parameter should have lower value than the value of function call node.
    if (isSgFunctionCallExp(node) && isScalarValueNode(routeGraph[tgt]))
        --val;
    
    // Make the value of SS edge smaller to make sure the restore is generated later than its killer.
    if (isStateSavingEdge(routeGraph[edge]))
        --val;
    
    return val;
}

bool EventReverser::RouteGraphEdgeComp::operator()(
        const VGEdge& edge1, const VGEdge& edge2) const 
{
    int val1 = getEdgeValue(edge1);
    int val2 = getEdgeValue(edge2);

    //return val1 < val2;
    
#if 1
    if (val1 < val2) return true;
    if (val1 > val2) return false;
    return routeGraph[edge1]->paths[dagIndex].count() < 
           routeGraph[edge2]->paths[dagIndex].count();
#endif
    
#if 0
    ROSE_ASSERT(pathsIndexTable.count(routeGraph[edge1]->paths));
    ROSE_ASSERT(pathsIndexTable.count(routeGraph[edge2]->paths));
    return pathsIndexTable.find(routeGraph[edge1]->paths)->second > 
           pathsIndexTable.find(routeGraph[edge2]->paths)->second;
#endif
}

void EventReverser::writeValueGraphNode(std::ostream& out, VGVertex node) const
{
    string str = valueGraph_[node]->toString();
    if (SgNode* astNode = valueGraph_[node]->astNode)
    {
        str += "\\n" + astNode->class_name() + "\\n";
        if (!isSgFunctionDefinition(astNode))
            str += astNode->unparseToString();
    }
    out << "[label=\"" << str << "\"";
    
    if (node == ssnode_)
        out << ", color=blue";
    
    ValueGraphNode* vgNode = valueGraph_[node];
    if (isScalarValueNode(vgNode))
        out << ", color=purple";
    else if (isFunctionCallNode(vgNode))
        out << ", color=green";
    else if (isOperatorNode(vgNode))
        out << ", color=blue";
    else if (isArrayElementNode(vgNode) || isVectorElementNode(vgNode))
        out << ", color=brown";
    
    out << "]";
}

void EventReverser::writeValueGraphEdge(std::ostream& out, const VGEdge& edge) const
{
    out << "[label=\"" << valueGraph_[edge]->toString() << "\", fontsize = 8";
    
    if (isStateSavingEdge(valueGraph_[edge]))
        out << ", color = red";
    out << "]";
}

} // End of namespace Backstroke
