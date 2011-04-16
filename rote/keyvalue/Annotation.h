#include <iostream>
#include <string.h>
#include <map>

using namespace std;

class Annotation {
  string id;
  map<string,string> attribs;
public:
  const string get_id();
  const string get_attrib(const string);
  void set_id(const string);
  void add_attrib(const string, const string);
  static Annotation *parse(const string);
};
