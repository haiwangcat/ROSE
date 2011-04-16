#include <iostream>
#include "Annotation.h"

int main() {
  Annotation *ann = Annotation::parse("ANN ok = 5 test = null key = value");
  if(ann != NULL) {
    cout << "Annotation: " << ann->get_id() << endl;
    cout << "ok=" << ann->get_attrib("ok") << endl;
    delete ann;
  }
  cout << "done" << endl;
  return 0;
}
