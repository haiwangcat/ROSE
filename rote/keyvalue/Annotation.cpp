#include "Annotation.h"

Annotation::Annotation(const string aid) {
  id = aid;
}

const string Annotation::get_id() {
  return id;
}

Dynamic Annotation::get_attrib(const string key) {
  return attribs[key];
}

void Annotation::add_attrib(const string key, Dynamic val) {
  attribs[key] = val;
}

int main() {
  Annotation ann("ok");
  ann.add_attrib("a1", *(Dynamic::dynamic_int(5)));
  cout << ann.get_id() << endl;
  cout << ann.get_attrib("a1").int_value() << endl;
  return 0;
}
