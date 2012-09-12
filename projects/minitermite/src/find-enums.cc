/**
 *  Use a ROSE traversal to extract the names of all enum values in the ROSE IR.
 *  2012 Adrian Prantl <adrian@llnl.gov>.
 */

#include <rose.h>
#include <iostream>
#include <boost/algorithm/string/predicate.hpp>

using namespace std;

class EnumWriter : public ROSE_VisitorPattern
{
  map<string, string> all_names;
public:
  virtual void visit(SgEnumDeclaration* enum_decl) {
    Sg_File_Info* fi = enum_decl->get_file_info(); 
    ROSE_ASSERT(fi);

    string  name = enum_decl->get_name();
    string qname = enum_decl->get_qualified_name();
    if (fi->isCompilerGenerated()) return;
    if (name[0] == '_') return;
    if (all_names.find(name) != all_names.end()) return;
    all_names[name] = qname;

    cout << "// "<<qname<<"\n";
    cout << "// "<<fi->get_filename()<<":"<<fi->get_line()<<"\n";
    cout << "static const char* e_"<<string(name)<<"[] = {" << "\n";
    SgInitializedNamePtrList& es = enum_decl->get_enumerators();
    SgInitializedNamePtrList::iterator e = es.begin();
    while (e != es.end()) {
      cout << "  " << (*e)->get_name() << ",\n";
      ++e;
    }
    cout << "};\n\n";
  }

  void print_init() {
    cout << "RoseEnums::RoseEnums() {\n"
	 << "  size_t i;\n";

    for (map<string, string>::const_iterator n = all_names.begin();
	 n != all_names.end(); ++n)
      cout << "  INIT( " << n->second << ", " << n->first << " )\n";

    cout << "}\n";
 }

  void print_decl() {
    for (map<string, string>::const_iterator n = all_names.begin();
	 n != all_names.end(); ++n)
      cout << "ROSEENUMS_DECLARE( " << n->second << ", " << n->first << " )\n";
  }

};


int main(int argc, char** argv) {
  // Run the EDG frontend
  cerr << "Extracting all enum values defined by the ROSE IR." << endl;
  cerr << "This may take several minutes, but it is so much more\n"
       << "future-proof than what we had before.\n"
       << "Thank you for your patience!" << endl;

  cout << "/* -*- C++ -*-" << endl;
  SgProject* project = frontend(argc, argv);
  fflush(stdout); // send all frontend warnings into the comment
  cout << "*/\n";

  cerr << "Running visitor..." << endl;
  EnumWriter enumWriter;
  cout << "#ifdef ROSEENUM_DEFS\n";
  traverseMemoryPoolVisitorPattern(enumWriter);
  enumWriter.print_init();
  cout << "#else\n";
  enumWriter.print_decl();  
  cout << "#endif\n";
  cerr << "done!" << endl;
}
