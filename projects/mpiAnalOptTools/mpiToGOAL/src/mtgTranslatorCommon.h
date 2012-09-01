#ifndef _MTGTRANSLATORCOMMON_H
#define _MTGTRANSLATORCOMMON_H

#include <rose.h>
#include <string>
#include <vector>

namespace mpitogoal
{
    /**
     * \brief insert goal specific include files in the AST
     */
    void insertGoalHeader(SgProject*, std::string headerfile);

    /**
     * \brief insert goal init statement in the MPI application
     */
    void insertGoalInit(SgExprStatement*);

    /**
     * \brief insert goal finalize statement in the MPI application
     */
    void insertGoalFinalize(SgFunctionDeclaration*);

    class CollectMPISetupStmts : public ROSE_VisitorPattern
    {
        SgExprStatement *mpiInit;
        SgFunctionDeclaration* mainFuncDecl;
    public:
        virtual void visit(SgExprStatement*);
        virtual void visit(SgFunctionDeclaration*);
        SgExprStatement* getMPIInitStmt();
        SgFunctionDeclaration* getMainFuncDecl();
    };
}

#endif
