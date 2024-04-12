#pragma once

uint64_t kLoopCount = 1000000000;

#if defined(DEBUG)
#define PRINTF(...) printf(__VA_ARGS__)
#else
#define PRINTF(...)
#endif
