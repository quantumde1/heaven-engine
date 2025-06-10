#pragma once

#include <stdlib.h>
#include <stdint.h>

char* concat_strings(const char* str1, const char* str2);

typedef struct {
    char* name;
    uint32_t size;
    char* data;
} FileEntry;

FileEntry* get_file_from_archive(const char* archive_path, const char* filename);