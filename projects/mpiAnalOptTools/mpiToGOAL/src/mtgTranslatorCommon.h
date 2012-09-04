/**
 * Common utility functions to perform the translation of MPI to GOAL
 * author: Sriram Aananthakrishnan
 * email: sriram@cs.utah.edu
 */

#ifndef _MTGTRANSLATORCOMMON_H
#define _MTGTRANSLATORCOMMON_H

#include <rose.h>
#include <string>
#include <vector>

namespace mpitogoal
{
    /**
     * insert goal specific include files in the AST
     */
    void insertGoalHeader(SgProject*, std::string headerfile);

    /**
     * insert goal init statement in the MPI application
     */
    void insertGoalInit(SgExprStatement*);

    /**
     * insert goal finalize statement in the MPI application
     */
    void insertGoalFinalize(SgFunctionDeclaration*);

    class CollectMPISetupStmts : public ROSE_VisitorPattern
    {

        /// to insert GOAL init statement after MPI_Init
        SgExprStatement *mpiInit;
        /// to insert GOAL Finalize at the end of main function
        SgFunctionDeclaration* mainFuncDecl;
    public:
        /**
         * checks if the statement is MPI_Init and sets mpiInit
         */
        virtual void visit(SgExprStatement*);
        /**
         * checks if the function call is main and sets mainFuncDecl
         */
        virtual void visit(SgFunctionDeclaration*);
        /**
         * return mpiInit
         */
        SgExprStatement* getMPIInitStmt();
        /**
         * return mainFuncDecl
         */
        SgFunctionDeclaration* getMainFuncDecl();
    };
}

#endif
