#include <stdint.h>
#include <stdio.h>

#include <functional>

#include "common.h"

static std::function<uint64_t(uint64_t)> increment = [](uint64_t num) {
  return num + 1;
};

static uint64_t call(uint64_t num) {
  uint64_t ret = 0;
  for (uint64_t i = 0; i < num; i++) {
    ret = increment(ret);
  }
  return ret;
}

int main(int argc, char *argv[]) {
  PRINTF("%s start\n", argv[0]);
  auto ret = call(kLoopCount);
  PRINTF("%s end (ret=%lu)\n", argv[0], ret);
  return 0;
}
