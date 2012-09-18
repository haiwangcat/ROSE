/* -*- C++ -*-
Copyright 2006 Christoph Bonitz <christoph.bonitz@gmail.com>
          2007-2009 Adrian Prantl <adrian@complang.tuwien.ac.at>

 * Purpose: create a TERMITE representation of a given AST
 */

#include <iostream>
#include <fstream>

#include <rose.h>
#include <rose_config.h>

#include <getopt.h>

// GB (2009-02-25): We want to build c2term without ICFG stuff to avoid
// having to link against libsatire. Also, want to avoid PAG DFI stuff.
#define HAVE_SATIRE_ICFG 0
#undef HAVE_PAG
#include "TermPrinter.h"

using namespace std;
using namespace term;

void usage(const char* me) 
{
  cout << "Usage: " << me
  <<" [FRONTEND OPTIONS] [--dot] [--pdf] src1.c src2.cpp src3.f ... [-o termfile.pl]\n"
  <<"  Parse one or more source files and convert them into a TERMITE file."
       << "\n  Header files will be included in the term representation.\n\n"

       << "Options:\n"
       << "  [FRONTENT OPTIONS] will be passed to the C/C++/Fortran frontend.\n\n" 

       << "  --rose-help\n"
       << "    Display the help for the C/C++/Fortran frontend.\n\n"

       << "  -o, --output <termfile.pl>\n"
       << "    Write the output to <termifile.pl> instead of stdout.\n\n"

       << "  --dot\n"
       << "    Create a dotty graph of the syntax tree.\n\n"

       << "  --pdf\n"
       << "    Create a PDF printout of the syntax tree.\n\n"

       << "  --stratego\n"
       << "    Create term output compatible with the Stratego/XT.\n\n"
       << "  --stl-engine\n"
#if ROSE_HAVE_SWI_PROLOG
       << "    Do not use SWI-Prolog to generate term output.\n\n"
#else
       << "    Ignored for compatibility reasons.\n\n"
#endif
       << "This program was built against "<<PACKAGE_STRING<<",\n"
       << "please report bugs to <"<<PACKAGE_BUGREPORT<<">."

       << endl;
}

int main(int argc, char** argv) {
  // Turn off the frontend's warnings; they are distracting in the
  // automated test outputs.
  vector<char*> argv1;
  char warningOpt[] = "-edg:w";
  char includeOpt[] = "-I" ROSE_INCLUDE_DIR;
  argv1.push_back(argv[0]);
  argv1.push_back(warningOpt);
  argv1.push_back(includeOpt);
  for (int i = 1; i < argc; ++i)
    argv1.push_back(argv[i]);
  int argc1 = argc+2;
// Process our own options
  const char* outfile = NULL;
  int dot_flag = 0;
  int pdf_flag = 0;
  int stratego_flag = 0;
#if ROSE_HAVE_SWI_PROLOG
  int stl_flag = 0;
#else
  int stl_flag = 1;
#endif
  int version_flag = 0;
  int help_flag = 0;
  int rose_help_flag = 0;

  static struct option long_options[] = {
    /* These options set a flag. */
    {"version", no_argument, &version_flag, 1},
    {"help", no_argument, &help_flag, 1},
    {"rose-help", no_argument, &rose_help_flag, 1},
    {"dot", no_argument, &dot_flag, 1},
    {"pdf", no_argument, &pdf_flag, 1},
    {"stratego", no_argument, &stratego_flag, 1},
    {"stl-engine", no_argument, &stl_flag, 1},
    /* These don't */
    {"output", required_argument, 0, 'o'},
    {0, 0, 0, 0}
  };

  // Surely not the most efficient thing to do, but we need to remove
  // those pesky -I... and -D... options to not confuse getopt
  for (int i = 1; i < argc; ++i) {
    if (argv[i][0] == '-') {
      char empty[] = "";
      bool edg_opt = true;
      for (struct option *opt = long_options; opt->name; ++opt) {
	if (argv[i]+1 && string(argv[i]+2) == string(opt->name)) edg_opt = false;
	if (argv[i][1] == 'o') edg_opt = false;
      }
      if (edg_opt)
	argv[i] = empty;
    }
  }

  while (1) {
    /* getopt_long stores the option index here. */
    int option_index = 0;
     
    int c = getopt_long(argc, argv, "o:", long_options, &option_index);
     
    /* Detect the end of the options. */
    if (c == -1)
      break;
     
    switch (c) {
    case 'o': outfile = optarg; break;
    default: ; /* ignore - pass to frontend */
    }
  }
  if (help_flag) { 
    usage(argv[0]); 
    return 0;
  }
  if (rose_help_flag) { 
    argc1 = 2;
    argv1[1] = strdup("--help");
    frontend(argc1,&argv1[0]);
    return 0;
  }
  if (version_flag) { 
    cout << argv[0] << " version " << PACKAGE_VERSION << "\n"; 
    return 0;
  }
  if (optind < argc) {
    //infile = argv[optind];
  } else {
    usage(argv[0]);
    return 1;
  }

  //cerr<<"% frontend"<<endl;

  // Run the EDG frontend
  SgProject* project = frontend(argc1,&argv1[0]);

  if (dot_flag) {
    //  Create dot and pdf files
    //  DOT generation (numbering:preoder)
    AstDOTGeneration dotgen;
    dotgen.generateInputFiles(project, AstDOTGeneration::PREORDER);
  }
  if (pdf_flag) {
    //  PDF generation
    AstPDFGeneration pdfgen;
    pdfgen.generateInputFiles(project);
  }

  init_termite(argc, argv);

  // Choose the way to construct terms based on the options
  TermFactory* termFactory;
  if (stratego_flag) 
    termFactory = new StrategoTermFactory();
  else 
    if (stl_flag)
      termFactory = new STLTermFactory();
#if ROSE_HAVE_SWI_PROLOG
    else termFactory = new SWIPLTermFactory();
#endif

  // Create prolog term
  BasicTermPrinter tp(*termFactory);
  //cerr<<"% conversion"<<endl;
  tp.traverse(project); // With headers

  Term* genTerm = tp.getTerm();
  
  if (outfile) {
    ofstream ofile(outfile);
    //ofile << genTerm->getRepresentation() << "." << endl;
    //cerr<<"% dump"<<endl;
    genTerm->dump(ofile);
    ofile << "." << endl;

    ofile.close();
  } else cout << genTerm->getRepresentation() << "." << endl;
		
  return 0;
}
