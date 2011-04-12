#include <iostream>
#include <string.h>
#include <map>

using namespace std;

class Annotation {
  string id;
  map<string,string> attribs;
public:
  Annotation(const string);
  const string get_id();
  const string get_attrib(const string);
  void add_attrib(const string, const string);
  Annotation *parse(const string);
};
