#include <iostream>

using namespace std;

class Dynamic {
public:
  virtual int int_value() = 0;
  virtual double double_value() = 0;
  virtual string string_value() = 0;
};

class DynInt : public Dynamic {
  int data;
public:
  DynInt(int);
  virtual int int_value();
  virtual double double_value();
  virtual string string_value();
};

class DynString : public Dynamic {
  string data;
public:
  DynString(string);
  virtual int int_value();
  virtual double double_value();
  virtual string string_value();
};

