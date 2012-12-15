/* -*- C++ -*-
Copyright 2006 Christoph Bonitz <christoph.bonitz@gmail.com>
          2007-2008 Adrian Prantl <adrian@complang.tuwien.ac.at>
*/
#include "minitermite.h"
#include <iostream>
#include <stdio.h>
#include <rose.h>
#include "TermToRose.h"
#include <getopt.h>
#include <rose_config.h>

using namespace std;
using namespace term;

void usage(const char* me) 
{
  cout << "Usage: " << me
       << " [OPTION]... [FILE.term]\n"
       << "Unparse a term file to its original source representation.\n\n"

       << "Options:\n"
       << "  -o, --output sourcefile.c\n"
       << "    Override the name of the unparsed file.\n"
       << "    For mult-file projects, this will only affect the first file.\n\n"

       << "  -s, --suffix '.suffix'  Default: '.unparsed'\n"

       << "    Use the original file names with the additional suffix.\n\n"

       << "  -d, --dir DIRECTORY\n"
       << "    Create the unparsed files in DIRECTORY.\n\n"

       << "  --dot\n"
       << "    Create a dotty graph of the syntax tree.\n\n"

       << "  --pdf\n"
       << "    Create a PDF printout of the syntax tree.\n\n"

       << "  --stratego\n"
       << "    Read term input in Stratego/XT format.\n\n"

       << "  --stl-engine\n"
#if ROSE_HAVE_SWI_PROLOG
       << "    Do not use SWI-Prolog to parse term input.\n\n"
#else
       << "    Ignored for compatibility reasons.\n\n"
#endif
       << "This program was built against "<<PACKAGE_STRING<<",\n"
       << "please report bugs to <"<<PACKAGE_BUGREPORT<<">."

       << endl;

}

int main(int argc, char** argv) {
  //  cout << prote->getRepresentation();
  const char* infile = "";
  const char* outfile= "";
  const char* outdir = ".";
  const char* suffix = ".unparsed";
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

  while (1) {
    static struct option long_options[] = {
      /* These options set a flag. */
      {"dot", no_argument, &dot_flag, 1},
      {"pdf", no_argument, &pdf_flag, 1},
      {"stratego", no_argument, &stratego_flag, 1},
      {"stl-engine", no_argument, &stl_flag, 1},
      {"version", no_argument, &version_flag, 1},
      {"help", no_argument, &help_flag, 1},
      /* These don't */
      {"dir",    required_argument, 0, 'd'},
      {"output", required_argument, 0, 'o'},
      {"suffix", required_argument, 0, 's'},
      {0, 0, 0, 0}
    };
    /* getopt_long stores the option index here. */
    int option_index = 0;
     
    int c = getopt_long(argc, argv, "d:o:s:", long_options, &option_index);
     
    /* Detect the end of the options. */
    if (c == -1)
      break;
     
    switch (c) {
    case 'd': outdir  = optarg; break;
    case 'o': outfile = optarg; break;
    case 's': suffix  = optarg; break;
     
    default: ;
    }
  }
  if (help_flag) {
    usage(argv[0]);
    return 0;
  }
  if (version_flag) {
    cout << argv[0] << " version " << PACKAGE_VERSION << "\n";
    return 0;
  }
  if (optind < argc) {
    infile = strdup(argv[optind]);
  } else {
    usage(argv[0]);
    return 1;
  }

  init_termite(argc, argv);

  // Choose the way to parse terms based on the options
  TermFactory* termFactory;
  if (stratego_flag) {
    yy_use_stratego_filter = true;
    termFactory = new StrategoTermFactory();
  } else 
    if (stl_flag)
      termFactory = new STLTermFactory();
#if ROSE_HAVE_SWI_PROLOG
    else termFactory = new SWIPLTermFactory();
#endif

  TermToRose conv(*termFactory);
  SgNode* p = conv.toRose(infile);

  if (help_flag || version_flag) return 0;

  if (dot_flag) {
    //  Create dot and pdf files
    //  DOT generation (numbering:preoder)
    AstDOTGeneration dotgen;
    dotgen.generateInputFiles((SgProject*)p,AstDOTGeneration::PREORDER);
  }
  if (pdf_flag) {
    //  PDF generation
    AstPDFGeneration pdfgen;
    pdfgen.generateInputFiles((SgProject*)p);
  }
  conv.unparse(outfile, outdir, suffix, p);
  return 0;
}
