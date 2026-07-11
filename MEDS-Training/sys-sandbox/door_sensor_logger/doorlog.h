#ifndef DOORLOG_H
#define DOORLOG_H

#include <stdint.h>
#include <stddef.h>
#include <stdio.h>
#include <stdlib.h>

// extract bits from position [hi:lo] (inclusive)
#define EXTRACT_BITS(val, hi, lo) \
    (((val) >> (lo)) & ((1u << ((hi) - (lo) + 1)) - 1))

// sign extend a value with given bit-width
#define SIGN_EXTEND(val, bits) \
    ((int32_t)(((val) << (32 - (bits))) >> (32 - (bits))))

// decoded sensor log entry
typedef struct {
    uint8_t device_id;
    uint8_t sensor_type;
    int active;
    uint8_t readings;
} decoded_instr_t;

// supported sensor types
typedef enum {
    DOOR = 0,
    MOTION = 1,
    TEMP = 2
} sensor_type_t;

// print memory contents and statistics
void print_memory(const uint8_t *memory, size_t mem_size);

#endif /* DOORLOG_H */
