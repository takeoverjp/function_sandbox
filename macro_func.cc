#include <stdint.h>
#include <stdio.h>

#include "common.h"

#define increment(num) (num + 1)

int main(int argc, char *argv[]) {
  uint64_t ret = 0;
  for (uint64_t i = 0; i < kLoopCount; i++) {
    ret = increment(ret);
  }
  printf("%ld\n", ret);
  return 0;
}
