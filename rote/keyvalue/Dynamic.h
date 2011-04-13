#include <iostream>

using namespace std;

enum DynamicType { UNIT_TYPE, ID_TYPE, STRING_TYPE, INT_TYPE, FLOAT_TYPE };

class Dynamic {
  DynamicType type;
  void *data;
public:
  static Dynamic *dynamic_int(int);
  static Dynamic *dynamic_string(const string);

  Dynamic();
  ~Dynamic();
  int int_value();
  string string_value();
};
