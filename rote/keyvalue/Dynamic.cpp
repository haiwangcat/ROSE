#include "Dynamic.h"
#include <assert.h>

Dynamic::Dynamic() {
  type = UNIT_TYPE;
  data = NULL;
}

Dynamic::~Dynamic() {
  switch(type) {
    case UNIT_TYPE:
      break;
    case ID_TYPE:
      delete (string *)data;
      break;
    case STRING_TYPE:
      delete (string *)data;
      break;
    case INT_TYPE:
      delete (int *)data;
      break;
    case FLOAT_TYPE:
      delete (double *)data;
      break;
  }
}

Dynamic *Dynamic::dynamic_int(int n) {
  Dynamic *val = new Dynamic();
  val->type = INT_TYPE;
  val->data = new int(n);
  return val;
}

Dynamic *Dynamic::dynamic_string(const string s) {
  Dynamic *val = new Dynamic();
  val->type = STRING_TYPE;
  val->data = new string(s);
  return val;
}

int Dynamic::int_value() {
  assert(type == INT_TYPE);
  int val = *(int *)data;
  return val;
}

string Dynamic::string_value() {
  assert(type == STRING_TYPE);
  string val = *(string *)data;
  return val;
}

int main() {
  Dynamic *x;
  for(int i=0; i < 10000; i++) {
    x = Dynamic::dynamic_string("Hello");
    cout << x->string_value() << endl;
    delete x;
  }
  return 0;
}
