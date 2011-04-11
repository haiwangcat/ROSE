#include <iostream>

using namespace std;

enum DynamicType { UNIT_TYPE, ID_TYPE, STRING_TYPE, INT_TYPE, FLOAT_TYPE };

class Dynamic {
  DynamicType type;
  void *data;
public:
  Dynamic();
  static Dynamic *dynamic_int(int);
  static Dynamic *dynamic_string(const string);
  int int_value();
  string string_value();
};
