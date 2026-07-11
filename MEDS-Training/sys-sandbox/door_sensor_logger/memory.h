#ifndef MEMORY_H
#define MEMORY_H

#include <stddef.h>
#include <stdint.h>

// count the number of instructions (lines) in the hex file */
size_t count_lines(const char *filename);

// load decoded sensor records into memory
int load_hex_file(const char *filename, uint8_t *memory, size_t mem_size);

// allocate memory and load the sensor log
uint8_t *create_memory(const char *filename, size_t *mem_size, int *words_loaded);

#endif /* MEMORY_H */
