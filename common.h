#pragma once

uint64_t kLoopCount = 1000000000;

#define DEBUG
#if defined(DEBUG)
#define PRINTF(...) printf(__VA_ARGS__)
#else
#define PRINTF()
#endif
