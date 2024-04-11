#include <functional>
#include <iostream>

static uint64_t call(std::function<uint64_t(uint64_t)> callback, uint64_t num) {
  uint64_t ret = 0;
  for (uint64_t i = 0; i < num; i++) {
    ret = callback(ret);
  }
  return ret;
}

int main() {
  std::cout << "Hello std_func.cc" << std::endl;

  std::function<uint64_t(uint64_t)> increment = [](uint64_t num) {
    return num + 1;
  };

  auto ret = call(increment, 1000000000);
  std::cout << "ret = " << ret << std::endl;

  return 0;
}
