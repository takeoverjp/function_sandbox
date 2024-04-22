#include <stdint.h>
#include <stdio.h>

#include "common.h"

class MyClass {
 public:
  uint64_t increment(uint64_t num) { return num + 1; }
};

int main(int argc, char *argv[]) {
  MyClass obj;
  uint64_t ret = 0;
  for (uint64_t i = 0; i < kLoopCount; i++) {
    ret = obj.increment(ret);
  }
  printf("%ld\n", ret);
  return 0;
}
