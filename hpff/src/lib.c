#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>
#include <sys/stat.h>

#define FNAME_LEN 255

void Y(const char *Z, char **A, int B) {
    FILE *C = fopen(Z, "wb");
    if (!C) {
        perror("Error opening output file");
        return;
    }

    if (fwrite(&B, sizeof(uint32_t), 1, C) != 1) {
        perror("Error writing file count");
        fclose(C);
        return;
    }

    for (int D = 0; D < B; D++) {
        const char *E = A[D];
        char F[FNAME_LEN];
        struct stat G;

        if (strncpy(F, E, FNAME_LEN - 1) == NULL) {
            perror("Error copying file name");
            continue;
        }
        F[FNAME_LEN - 1] = '\0';

        char *H = strrchr(F, '/');
        if (H) {
            H++;
        } else {
            H = F;
        }

        if (stat(E, &G) != 0) {
            perror("Error getting file stats");
            continue;
        }

        uint8_t I = strlen(H);
        if (fwrite(&I, sizeof(uint8_t), 1, C) != 1 || fwrite(H, sizeof(char), I, C) != I) {
            perror("Error writing file name");
            continue;
        }

        uint32_t J = G.st_size;
        if (fwrite(&J, sizeof(uint32_t), 1, C) != 1) {
            perror("Error writing file size");
            continue;
        }

        FILE *K = fopen(E, "rb");
        if (!K) {
            perror("Error opening input file");
            continue;
        }

        char *L = malloc(J);
        if (!L) {
            perror("Error allocating memory");
            fclose(K);
            continue;
        }

        if (fread(L, sizeof(char), J, K) != J) {
            perror("Error reading file data");
            free(L);
            fclose(K);
            continue;
        }

        if (fwrite(L, sizeof(char), J, C) != J) {
            perror("Error writing file data");
        }

        free(L);
        fclose(K);
    }

    fclose(C);
    printf("Packed %d files into %s\n", B, Z);
}

void M(const char *N, const char *O) {
    FILE *P = fopen(N, "rb");
    if (!P) {
        perror("Error opening input file");
        return;
    }

    uint32_t Q;
    if (fread(&Q, sizeof(uint32_t), 1, P) != 1) {
        perror("Error reading file count");
        fclose(P);
        return;
    }

    for (uint32_t R = 0; R < Q; R++) {
        uint8_t S;
        if (fread(&S, sizeof(uint8_t), 1, P) != 1) {
            perror("Error reading file name length");
            break;
        }

        char *T = malloc(S + 1);
        if (!T) {
            perror("Error allocating memory");
            break;
        }

        if (fread(T, sizeof(char), S, P) != S) {
            perror("Error reading file name");
            free(T);
            break;
        }
        T[S] = '\0';

        uint32_t U;
        if (fread(&U, sizeof(uint32_t), 1, P) != 1) {
            perror("Error reading file size");
            free(T);
            break;
        }

        char *V = malloc(U);
        if (!V) {
            perror("Error allocating memory");
            free(T);
            break;
        }

        if (fread(V, sizeof(char), U, P) != U) {
            perror("Error reading file data");
            free(T);
            free(V);
            break;
        }

        char W[FNAME_LEN];
        if (snprintf(W, sizeof(W), "%s/%s", O, T) >= sizeof(W)) {
            fprintf(stderr, "Error: file path too long\n");
            free(T);
            free(V);
            break;
        }

        FILE *X = fopen(W, "wb");
        if (X) {
            if (fwrite(V, sizeof(char), U, X) != U) {
                perror("Error writing file data");
            }
            fclose(X);
        } else {
            perror("Error opening output file");
        }

        free(T);
        free(V);
    }

    fclose(P);
    printf("Unpacked %d files to %s\n", Q, O);
}

char* get_file_data_from_archive(const char *input_file, const char *file_name, uint32_t *file_size_out) {
    FILE *f = fopen(input_file, "rb");
    if (!f) {
        perror("Failed to open input file");
        return NULL;
    }

    uint32_t num_files;
    if (fread(&num_files, sizeof(uint32_t), 1, f) != 1) {
        perror("Error reading file count");
        fclose(f);
        return NULL;
    }

    for (uint32_t i = 0; i < num_files; i++) {
        uint8_t name_length;
        if (fread(&name_length, sizeof(uint8_t), 1, f) != 1) {
            perror("Error reading file name length");
            break;
        }

        char *current_file_name = malloc(name_length + 1);
        if (!current_file_name) {
            perror("Error allocating memory");
            break;
        }

        if (fread(current_file_name, sizeof(char), name_length, f) != name_length) {
            perror("Error reading file name");
            free(current_file_name);
            break;
        }
        current_file_name[name_length] = '\0';

        uint32_t file_size;
        if (fread(&file_size, sizeof(uint32_t), 1, f) != 1) {
            perror("Error reading file size");
            free(current_file_name);
            break;
        }

        if (strcmp(current_file_name, file_name) == 0) {
            char *buffer = malloc(file_size);
            if (!buffer) {
                perror("Error allocating memory");
                free(current_file_name);
                break;
            }

            if (fread(buffer, sizeof(char), file_size, f) != file_size) {
                perror("Error reading file data");
                free(buffer);
                free(current_file_name);
                break;
            }

            fclose(f);
            free(current_file_name);
            *file_size_out = file_size;
            return buffer;
        }

        if (fseek(f, file_size, SEEK_CUR) != 0) {
            perror("Error seeking file data");
            free(current_file_name);
            break;
        }

        free(current_file_name);
    }

    printf("File '%s' not found in the archive.\n", file_name);
    fclose(f);
    return NULL;
}
