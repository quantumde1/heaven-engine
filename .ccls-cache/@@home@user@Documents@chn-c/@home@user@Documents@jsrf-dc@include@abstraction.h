#pragma once

#include "stdio.h"

#ifdef _arch_dreamcast
#define ASSETS_PATH "/cd/assets/"
#else
#define ASSETS_PATH "assets/"
#endif

void glInit(int* pargc, char** argv);
void glSwapBuffers();

#define writeln(...) do { \
    printf(__VA_ARGS__); \
    printf("\n"); \
    fflush(stdout); \
} while (0)

char* concat_strings(const char* str1, const char* str2);