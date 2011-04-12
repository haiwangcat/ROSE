#include <assert.h>
#include "Annotation.h"

Annotation::Annotation(const string aid) {
  id = aid;
}

const string Annotation::get_id() {
  return id;
}

Dynamic *Annotation::get_attrib(const string key) {
  return attribs[key];
}

void Annotation::add_attrib(const string key, Dynamic *val) {
  assert(attribs.count(key) == 0);
  attribs[key] = val;
}

Annotation *Annotation::parse(const string input) {
  return NULL;
}
