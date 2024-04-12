#include <stdint.h>
#include <stdio.h>

#include <functional>

#include "common.h"

#define increment(num) (num + 1)

static uint64_t call(uint64_t num) {
  uint64_t ret = 0;
  for (uint64_t i = 0; i < num; i++) {
    ret = increment(ret);
  }
  return ret;
}

int main(int argc, char *argv[]) {
  printf("%s start\n", argv[0]);
  auto ret = call(kLoopCount);
  printf("%s end (ret=%lu)\n", argv[0], ret);
  return 0;
}
