#include <assert.h>
#include <stdint.h>
#include <stdio.h>

#include <functional>

#include "common.h"

static uint64_t increment_impl(uint64_t num) { return num + 1; };

// volatile to avoid optimization
static uint64_t (*volatile increment)(uint64_t) = increment_impl;

int main(int argc, char* argv[]) {
  uint64_t ret = 0;
  for (uint64_t i = 0; i < kLoopCount; i++) {
    ret = increment(ret);
  }
  assert(ret == kLoopCount);
  return 0;
}
