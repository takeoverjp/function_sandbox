#pragma once

uint64_t kLoopCount = 1000000000;

#if defined(NDEBUG)
#define PRINTF(...)
#else
#define PRINTF(...) printf(__VA_ARGS__)
#endif
