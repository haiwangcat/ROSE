//! translator to test makeDataSharingExplicit, edited by Hongyi Ma on August 7th, 2012
//TODO: added into OpenMP Checker, now it is still under construction. 

#include "rose.h"
#include "omp_lowering.h"
#include <stdio.h>
#include <stdlib.h>


using namespace OmpSupport;
using namespace std;

int main( int argc, char* argv[] )
 {

   printf(" July/31/2012 here is the test for making data-sharing explicit!  \n");
 
   SgProject* project = frontend( argc, argv );
   ROSE_ASSERT( project != NULL );

   SgFile& localFile = project->get_file(0);

   SgFile* file = &localFile;

   printf(" patchUp begin:  \n");

	 int i = OmpSupport::makeDataSharingExplicit( file );

 //  return 0;
 return backend(project);
 }
