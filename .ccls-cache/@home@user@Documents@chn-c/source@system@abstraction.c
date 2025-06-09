#include <stdio.h>
#include <string.h>
#include <stdlib.h>

char* concat_strings(const char* str1, const char* str2) {
    char* result = malloc(strlen(str1) + strlen(str2) + 1);
    
    if (result == NULL) {
        fprintf(stderr, "Error memory allocation\n");
        exit(1);
    }
    
    strcpy(result, str1);
    strcat(result, str2);
    
    return result;
}