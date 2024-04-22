#include <stdint.h>
#include <stdio.h>

#include <functional>

static constexpr uint64_t increment(uint64_t num) { return num + 1; };

static constexpr uint64_t increment_loop(uint64_t count) {
  uint64_t ret = 0;
  for (uint64_t i = 0; i < count; i++) {
    ret = increment(ret);
  }
  return ret;
};

int main(int argc, char *argv[]) {
  // constexpr has loop/ops limitation...
  const uint64_t kLoopCount = 100000;
  constexpr uint64_t ret = increment_loop(kLoopCount);
  printf("%ld\n", ret);
  return 0;
}
