/*
 * MEMORY_H
 * --------
 * Header file for the simulated instruction memory module.
 *
 * This module provides:
 *   - A simple structure for storing RISC-V instructions
 *   - Functions to load instructions from a hexadecimal file
 *   - Safe indexed memory access
 */

#ifndef MEMORY_H
#define MEMORY_H

#include "common.h"

// ------------------------------
// simulated instruction memory
// ------------------------------

typedef struct {

    // Array storing loaded machine instructions
    uint32_t instructions[MAX_INSTRUCTIONS];

    // Number of valid instructions currently loaded
    uint32_t count;

} memory_t;

// ----------------------------
// memory interface functions
// ----------------------------

// load hexadecimal instructions from file into memory
int mem_load_hex(memory_t *mem, const char *filename);

// read instruction from memory by index
uint32_t mem_read(const memory_t *mem, uint32_t index);

#endif
