#include "rose.h"
#include "mtgTranslatorCommon.h"

int main(int argc, char* argv[])
{
    SgProject* project = frontend(argc, argv);

    // insert libGOAL header
    mpitogoal::insertGoalHeader(project, "libGOAL.hpp");

    // collect information for instrumentation setup
    mpitogoal::CollectMPISetupStmts collectMPISetup;
    traverseMemoryPoolVisitorPattern(collectMPISetup);

    mpitogoal::insertGoalInit(collectMPISetup.getMPIInitStmt());
    mpitogoal::insertGoalFinalize(collectMPISetup.getMainFuncDecl());


    AstTests::runAllTests(project);    
    project->unparse();

    return 0;
}
