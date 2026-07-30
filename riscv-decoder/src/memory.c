/*
 * Simulated Instruction Memory
 * ----------------------------
 * This file implements a simple memory module used for storing
 * RISC-V machine code instructions loaded from a hexadecimal file.
 *
 * Responsibilities:
 *   - Load hexadecimal instructions from a text file
 *   - Store instructions in simulated memory
 *   - Provide safe indexed memory access
 *   - Handle basic file and bounds errors
 */

#include <string.h>
#include "../include/memory.h"

// load hexadecimal instructions from file into memory

int mem_load_hex(memory_t *mem, const char *filename) {

    // open input file
    FILE *f = fopen(filename, "r");

    if (!f) {
        fprintf(stderr,
                "Error: cannot open file '%s'\n",
                filename);
        return -1;
    }

    mem->count = 0;

    char line[32];

    // read file line by line
    while (fgets(line, sizeof(line), f)) {

        // skip comments and empty lines
        if (line[0] == '#' ||
            line[0] == '\n' ||
            line[0] == '\r')
            continue;

        // prevent memory overflow
        if (mem->count >= MAX_INSTRUCTIONS) {

            fprintf(stderr,
                    "Warning: instruction limit reached (%d)\n",
                    MAX_INSTRUCTIONS);

            break;
        }

        // convert hexadecimal string to 32-bit integer
        mem->instructions[mem->count++] =
            (uint32_t)strtoul(line, NULL, 16);
    }

    fclose(f);

    return (int)mem->count;
}

// read instruction from simulated memory

uint32_t mem_read(const memory_t *mem, uint32_t index) {

    // bounds check
    if (index >= mem->count) {

        fprintf(stderr,
                "Error: memory read out of bounds (index %u)\n",
                index);

        return 0;
    }

    return mem->instructions[index];
}
