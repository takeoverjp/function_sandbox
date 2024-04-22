#include <stdint.h>
#include <stdio.h>

#include "common.h"

class BaseClass {
 public:
  virtual uint64_t increment(uint64_t num) { return num + 2; }
};

class DerivedClass : public BaseClass {
 public:
  virtual uint64_t increment(uint64_t num) { return num + 1; }
};

int main(int argc, char *argv[]) {
  DerivedClass obj;
  BaseClass *ptr = &obj;
  uint64_t ret = 0;
  for (uint64_t i = 0; i < kLoopCount; i++) {
    ret = ptr->increment(ret);
  }
  printf("%ld\n", ret);
  return 0;
}
