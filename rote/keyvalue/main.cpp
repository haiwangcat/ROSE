#include <iostream>
#include "Annotation.h"

int main() {
  string x = "ANNTYPE a1=50 a2=whatever a3=\"hello world\"";
  for(int i=0; i < 10; i++) {
    Annotation *ann = Annotation::parse(x);
    if(ann != NULL) {
      cout << "id=" << ann->get_id() << endl;
      cout << "attrib a1=" << ann->get_attrib("a1")->int_value() << endl;
      cout << "attrib a2=" << ann->get_attrib("a2")->string_value() << endl;
      cout << "attrib a3=" << ann->get_attrib("a3")->string_value() << endl;
      delete ann;
    }
  }
  cout << "done" << endl;
  return 0;
}
