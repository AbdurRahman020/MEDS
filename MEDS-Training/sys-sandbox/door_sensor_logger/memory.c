#include "doorlog.h"
#include "memory.h"

// count lines in a file
size_t count_lines(const char *filename) {
    FILE *fp = fopen(filename, "r");

    if (fp == NULL) {
        perror("Cannot open file");
        return 0;
    }

    char line[64];
    size_t count = 0;

    while (fgets(line, sizeof(line), fp) != NULL) {
        count++;
    }

    fclose(fp);

    return count;
}

// load hex file into memory
int load_hex_file(const char *filename, uint8_t *memory, size_t mem_size) {
    FILE *fp = fopen(filename, "r");

    if (fp == NULL) {
        perror("Cannot open hex file");
        return -1;
    }

    char line[64];
    uint32_t addr = 0;

    while (fgets(line, sizeof(line), fp) != NULL) {
        if (addr + 4 > mem_size)
            break;

        uint32_t word = (uint32_t)strtoul(line, NULL, 16);

        // store the word in memory in little-endian format
        memory[addr + 0] = EXTRACT_BITS(word, 7, 0);    // readings
        memory[addr + 1] = EXTRACT_BITS(word, 8, 8);    // status
        memory[addr + 2] = EXTRACT_BITS(word, 11, 9);   // sensor type
        memory[addr + 3] = EXTRACT_BITS(word, 15, 12);  // device id

        addr += 4;
    }

    fclose(fp);

    return addr / 4;
}

uint8_t *create_memory(const char *filename, size_t *mem_size, int *words_loaded) {
    size_t num_words = count_lines(filename);

    if (num_words == 0)
        return NULL;

    *mem_size = num_words * 4;

    uint8_t *memory = malloc(*mem_size);

    if (memory == NULL)
        return NULL;

    *words_loaded = load_hex_file(filename, memory, *mem_size);

    if (*words_loaded < 0) {
        free(memory);
        return NULL;
    }

    return memory;
}
