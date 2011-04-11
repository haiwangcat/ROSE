#include "Dynamic.h"
#include <assert.h>

Dynamic::Dynamic() {
  type = UNIT_TYPE;
  data = NULL;
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
  assert(this->type == INT_TYPE);
  int val = *(int *)(this->data);
  return val;
}

string Dynamic::string_value() {
  assert(this->type == STRING_TYPE);
  string val = *(string *)(this->data);
  return val;
}

// int main() {
//   Dynamic *x = Dynamic::dynamic_int(5);
//   Dynamic *y = Dynamic::dynamic_string("Hello");
//   cout << x->int_value() << endl;
//   cout << y->string_value() << endl;
//   return 0;
// }
