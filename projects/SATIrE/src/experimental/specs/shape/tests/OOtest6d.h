#ifndef TEST4_H
#define TEST4_H

// non-virtual method non_virutal_foo_XX and non-virtual destructor
class A2 {
public:
  void nonvirtual_foo();
  A2* next;
};

class B2 : public A2 {
public:
  void nonvirtual_foo();
};

#endif
