#include <assert.h>
#include <stdint.h>
#include <stdio.h>

#include <functional>

#include "common.h"

static inline uint64_t increment(uint64_t num) { return num + 1; };

int main(int argc, char *argv[]) {
  uint64_t ret = 0;
  for (uint64_t i = 0; i < kLoopCount; i++) {
    ret = increment(ret);
  }
  assert(ret == kLoopCount);
  return 0;
}
