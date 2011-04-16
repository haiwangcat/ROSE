#include "Dynamic.h"
#include <sstream>
#include <assert.h>

DynInt::DynInt(int x) {
  data = x;
}

int DynInt::int_value() {
  return data;
}

double DynInt::double_value() {
  return double(data);
}

string DynInt::string_value() {
  stringstream out;
  out << data;
  return out.str();
}

DynString::DynString(string x) {
  data = x;
}

int DynString::int_value() {
  int x = atoi(data.c_str());
  return x;
}

double DynString::double_value() {
  double x = atof(data.c_str());
  return x;
}

string DynString::string_value() {
  return data;
}



