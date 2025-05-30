#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>
#include <sys/stat.h>
#include "lib.h"

int main(int argc, char *argv[]) {
    if (argc < 3) {
        fprintf(stderr, "Usage:\n");
        fprintf(stderr, "  To pack files: %s pack <output_file> <file1> <file2> ... <fileN>\n", argv[0]);
        fprintf(stderr, "  To unpack files: %s unpack <input_file> <output_directory>\n", argv[0]);
        return EXIT_FAILURE;
    }

    if (strcmp(argv[1], "pack") == 0) {
        const char *output_file = argv[2];
        int num_files = argc - 3;
        char **file_list = malloc(num_files * sizeof(char *));
        if (!file_list) {
            perror("Error allocating memory for file list");
            return EXIT_FAILURE;
        }

        for (int i = 0; i < num_files; i++) {
            file_list[i] = argv[i + 3];
        }

        Y(output_file, file_list, num_files);
        free(file_list);
    } else if (strcmp(argv[1], "unpack") == 0) {
        const char *input_file = argv[2];
        const char *output_directory = argv[3];
        M(input_file, output_directory);
    } else {
        fprintf(stderr, "Invalid command. Use 'pack' or 'unpack'.\n");
        return EXIT_FAILURE;
    }

    return EXIT_SUCCESS;
}
