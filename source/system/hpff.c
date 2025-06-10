#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>
#include <sys/stat.h>

#define MAX_FILENAME_LEN 255
#define PATH_SEPARATOR '/'

#pragma pack(push, 1)
typedef struct {
    uint8_t name_length;
    uint32_t data_offset;
    uint32_t data_size;
    char name[MAX_FILENAME_LEN];
} FileTableEntry;
#pragma pack(pop)

#include "../../include/abstraction.h"

void free_file_entry(FileEntry* entry) {
    if (entry) {
        free(entry->name);
        free(entry->data);
        free(entry);
    }
}

// Pack files into an archive with file table at the beginning
int create_archive(const char* archive_path, char** file_paths, int file_count) {
    FILE* archive_file = fopen(archive_path, "wb");
    if (!archive_file) {
        perror("Failed to open archive file");
        return -1;
    }

    // 1. Write placeholder for file count and table size
    uint32_t file_count_header = file_count;
    uint32_t table_size = 0; // Will be filled later
    if (fwrite(&file_count_header, sizeof(uint32_t), 1, archive_file) != 1 ||
        fwrite(&table_size, sizeof(uint32_t), 1, archive_file) != 1) {
        perror("Failed to write header");
        fclose(archive_file);
        return -1;
    }

    // 2. First pass - collect file info and write file table
    FileTableEntry* table = calloc(file_count, sizeof(FileTableEntry));
    if (!table) {
        perror("Failed to allocate file table");
        fclose(archive_file);
        return -1;
    }

    uint32_t current_offset = sizeof(uint32_t) * 2; // After header

    // Calculate table size and offsets
    for (int i = 0; i < file_count; i++) {
        const char* input_path = file_paths[i];
        struct stat file_stat;

        // Get base filename
        const char* last_sep = strrchr(input_path, PATH_SEPARATOR);
        const char* base_name = last_sep ? last_sep + 1 : input_path;
        uint8_t name_length = strlen(base_name);

        if (name_length >= MAX_FILENAME_LEN) {
            fprintf(stderr, "Filename too long: %s\n", input_path);
            free(table);
            fclose(archive_file);
            return -1;
        }

        // Get file stats
        if (stat(input_path, &file_stat) != 0) {
            perror("Failed to get file stats");
            free(table);
            fclose(archive_file);
            return -1;
        }

        // Fill table entry
        table[i].name_length = name_length;
        table[i].data_size = file_stat.st_size;
        strncpy(table[i].name, base_name, name_length);
        
        // First entry starts right after the table
        if (i == 0) {
            table[i].data_offset = sizeof(uint32_t) * 2 + sizeof(FileTableEntry) * file_count;
        } else {
            table[i].data_offset = table[i-1].data_offset + table[i-1].data_size;
        }
    }

    // Write file table
    table_size = sizeof(FileTableEntry) * file_count;
    if (fwrite(table, sizeof(FileTableEntry), file_count, archive_file) != file_count) {
        perror("Failed to write file table");
        free(table);
        fclose(archive_file);
        return -1;
    }

    // 3. Second pass - write actual file data
    for (int i = 0; i < file_count; i++) {
        const char* input_path = file_paths[i];
        FILE* input_file = fopen(input_path, "rb");
        if (!input_file) {
            perror("Failed to open input file");
            continue;
        }

        char* buffer = malloc(table[i].data_size);
        if (!buffer) {
            perror("Failed to allocate memory");
            fclose(input_file);
            continue;
        }

        if (fread(buffer, 1, table[i].data_size, input_file) != table[i].data_size) {
            perror("Failed to read file data");
            free(buffer);
            fclose(input_file);
            continue;
        }

        if (fwrite(buffer, 1, table[i].data_size, archive_file) != table[i].data_size) {
            perror("Failed to write file data");
        }

        free(buffer);
        fclose(input_file);
    }

    // 4. Update header with actual table size
    fseek(archive_file, sizeof(uint32_t), SEEK_SET);
    if (fwrite(&table_size, sizeof(uint32_t), 1, archive_file) != 1) {
        perror("Failed to update table size");
    }

    free(table);
    fclose(archive_file);
    printf("Successfully packed %d files into %s\n", file_count, archive_path);
    return 0;
}

// Extract all files from archive
int extract_archive(const char* archive_path, const char* output_dir) {
    FILE* archive_file = fopen(archive_path, "rb");
    if (!archive_file) {
        perror("Failed to open archive file");
        return -1;
    }

    // Read header
    uint32_t file_count, table_size;
    if (fread(&file_count, sizeof(uint32_t), 1, archive_file) != 1 ||
        fread(&table_size, sizeof(uint32_t), 1, archive_file) != 1) {
        perror("Failed to read header");
        fclose(archive_file);
        return -1;
    }

    // Read file table
    FileTableEntry* table = malloc(table_size);
    if (!table) {
        perror("Failed to allocate file table");
        fclose(archive_file);
        return -1;
    }

    if (fread(table, 1, table_size, archive_file) != table_size) {
        perror("Failed to read file table");
        free(table);
        fclose(archive_file);
        return -1;
    }

    // Extract files
    for (uint32_t i = 0; i < file_count; i++) {
        // Create output path
        char output_path[MAX_FILENAME_LEN * 2];
        snprintf(output_path, sizeof(output_path), "%s/%s", output_dir, table[i].name);

        // Seek to file data
        if (fseek(archive_file, table[i].data_offset, SEEK_SET) != 0) {
            perror("Failed to seek to file data");
            continue;
        }

        // Read file data
        char* file_data = malloc(table[i].data_size);
        if (!file_data) {
            perror("Failed to allocate memory");
            continue;
        }

        if (fread(file_data, 1, table[i].data_size, archive_file) != table[i].data_size) {
            perror("Failed to read file data");
            free(file_data);
            continue;
        }

        // Write output file
        FILE* output_file = fopen(output_path, "wb");
        if (output_file) {
            if (fwrite(file_data, 1, table[i].data_size, output_file) != table[i].data_size) {
                perror("Failed to write output file");
            }
            fclose(output_file);
        } else {
            perror("Failed to create output file");
        }

        free(file_data);
    }

    free(table);
    fclose(archive_file);
    printf("Successfully unpacked %d files to %s\n", file_count, output_dir);
    return 0;
}

// Get specific file from archive by name
FileEntry* get_file_from_archive(const char* archive_path, const char* filename) {
    FILE* archive_file = fopen(archive_path, "rb");
    if (!archive_file) {
        perror("Failed to open archive file");
        return NULL;
    }

    // Read header
    uint32_t file_count, table_size;
    if (fread(&file_count, sizeof(uint32_t), 1, archive_file) != 1 ||
        fread(&table_size, sizeof(uint32_t), 1, archive_file) != 1) {
        perror("Failed to read header");
        fclose(archive_file);
        return NULL;
    }

    // Read file table
    FileTableEntry* table = malloc(table_size);
    if (!table) {
        perror("Failed to allocate file table");
        fclose(archive_file);
        return NULL;
    }

    if (fread(table, 1, table_size, archive_file) != table_size) {
        perror("Failed to read file table");
        free(table);
        fclose(archive_file);
        return NULL;
    }

    // Find requested file
    FileEntry* entry = NULL;
    for (uint32_t i = 0; i < file_count; i++) {
        if (strcmp(table[i].name, filename) == 0) {
            // Found the file - read its data
            if (fseek(archive_file, table[i].data_offset, SEEK_SET) != 0) {
                perror("Failed to seek to file data");
                break;
            }

            entry = malloc(sizeof(FileEntry));
            if (!entry) {
                perror("Failed to allocate memory");
                break;
            }

            entry->name = strdup(table[i].name);
            entry->size = table[i].data_size;
            entry->data = malloc(table[i].data_size);
            
            if (!entry->data || !entry->name) {
                perror("Failed to allocate memory");
                free_file_entry(entry);
                entry = NULL;
                break;
            }

            if (fread(entry->data, 1, table[i].data_size, archive_file) != table[i].data_size) {
                perror("Failed to read file data");
                free_file_entry(entry);
                entry = NULL;
            }

            break;
        }
    }

    free(table);
    fclose(archive_file);
    return entry;
}