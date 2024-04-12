#include <functional>
#include <iostream>

static uint64_t increment(uint64_t num) {
  return num + 1;
};

static uint64_t call(uint64_t num) {
  uint64_t ret = 0;
  for (uint64_t i = 0; i < num; i++) {
    ret = increment(ret);
  }
  return ret;
}

int main() {
  std::cout << "Hello normal_func.cc" << std::endl;

  auto ret = call(1000000000);
  std::cout << "ret = " << ret << std::endl;

  return 0;
}
