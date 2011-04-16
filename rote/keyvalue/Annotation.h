#include <iostream>
#include <string.h>
#include <map>
#include "Dynamic.h"

using namespace std;

class Annotation {
  string id;
  map<string,Dynamic *> attribs;
public:
  const string get_id();
  Dynamic *get_attrib(const string);
  void set_id(const string);
  void add_attrib(const string, Dynamic *);
  static Annotation *parse(const string);
};
