#include "mtgTranslatorCommon.h"

namespace mpitogoal
{
    void insertGoalHeader(SgProject* project, std::string headerfile)
    {
        std::vector<SgNode*> globalScopeStatements = NodeQuery::querySubTree(project, V_SgGlobal);
        std::vector<SgNode*>::iterator g_it;
        for(g_it = globalScopeStatements.begin(); g_it != globalScopeStatements.end(); g_it++) {
            SgGlobal* _global = isSgGlobal(*g_it);
            SageInterface::insertHeader(headerfile, PreprocessingInfo::after, false, _global); // should insert in all global scopes ??
        }
    }
   
    void insertGoalInit(SgExprStatement* mpiInitStmt)
    {
        SgFunctionCallExp* fncall_exp = isSgFunctionCallExp(mpiInitStmt->get_expression());
        ROSE_ASSERT(fncall_exp);
        SgName goalInitName("GOAL_Init");
        // build GOAL_Init statement with same scope as MPI_Init
        SgExprStatement* goalInitStmt = SageBuilder::buildFunctionCallStmt(goalInitName,
                                                                           SageBuilder::buildIntType(),
                                                                           SageBuilder::buildExprListExp(),
                                                                           mpiInitStmt->get_scope());
        SageInterface::insertStatement(mpiInitStmt, 
                                       goalInitStmt, 
                                       false,
                                       true);
    }

    void insertGoalFinalize(SgFunctionDeclaration* mainFuncDecl)
    {
        ROSE_ASSERT(mainFuncDecl);
        SgName goalFinalizeName("GOAL_Finalize");
        // build GOAL_Finalize()
        SgExprStatement* goalFinalizeStmt = SageBuilder::buildFunctionCallStmt(goalFinalizeName,
                                                                               SageBuilder::buildIntType(),
                                                                               SageBuilder::buildExprListExp(),
                                                                               mainFuncDecl->get_scope());
        // insert at the end of main function
        SageInterface::instrumentEndOfFunction(mainFuncDecl, goalFinalizeStmt);
    }

    void CollectMPISetupStmts::visit(SgExprStatement* statement)
    {
        SgFunctionCallExp* fncall_exp = isSgFunctionCallExp(statement->get_expression());
        if(fncall_exp) {
            std::string fncall_name = ((fncall_exp->getAssociatedFunctionSymbol())->get_name()).getString();
            if(fncall_name.size() > 0 && fncall_name.compare("MPI_Init") == 0) {
                mpiInit = statement;
            }
        }
    }

    void CollectMPISetupStmts::visit(SgFunctionDeclaration* funcDecl)
    {
        std::string funcName = (funcDecl->get_name()).getString();
        if(funcName.compare("main") == 0) {
            mainFuncDecl = funcDecl;
        }
    }

    SgExprStatement* CollectMPISetupStmts::getMPIInitStmt()
    {
        ROSE_ASSERT(mpiInit);
        return mpiInit;
    }

    SgFunctionDeclaration* CollectMPISetupStmts::getMainFuncDecl()
    {
        ROSE_ASSERT(mainFuncDecl);
        return mainFuncDecl;
    }
}
