/* A simple memory simulation for testing load/store operations */

#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>

// global memory
uint8_t mem[256];

// load a 32-bit word from memory (little-endian)
uint32_t load_word(uint32_t addr) {
    // check for out-of-bounds access
    if (addr + 3 >= 256) {
        fprintf(stderr, "Error: Address 0x%08X is out of bounds.\n", addr);
        exit(EXIT_FAILURE);
    }

    // check for alignment
    if (addr % 4 != 0) {
        fprintf(stderr, "Error: Address 0x%08X is not 4-byte aligned.\n", addr);
        exit(EXIT_FAILURE);
    }

    // read the value in little-endian format
    uint32_t word = 0;
    word |= mem[addr];
    word |= mem[addr + 1] << 8;
    word |= mem[addr + 2] << 16;
    word |= mem[addr + 3] << 24;

    return word;
}

// store a 32-bit word into memory (little-endian)
void store_word(uint32_t addr, uint32_t value) {
    // check for out-of-bounds access
    if (addr + 3 >= 256) {
        fprintf(stderr, "Error: Address 0x%08X is out of bounds.\n", addr);
        exit(EXIT_FAILURE);
    }
    
    // check for alignment
    if (addr % 4 != 0) {
        fprintf(stderr, "Error: Address 0x%08X is not 4-byte aligned.\n", addr);
        exit(EXIT_FAILURE);
    }

    // store the value in little-endian format
    mem[addr]     = value & 0xFF;
    mem[addr + 1] = (value >> 8) & 0xFF;
    mem[addr + 2] = (value >> 16) & 0xFF;
    mem[addr + 3] = (value >> 24) & 0xFF;
}

int main(void) {
    // test case 1: normal load/store
    store_word(4, 0x12345678);
    uint32_t loaded = load_word(4);

    printf("Test 1\n");
    printf("Stored : 0x%08X\n", 0x12345678);
    printf("Loaded : 0x%08X\n\n", loaded);

    // test case 2: another normal load/store but at a different address
    store_word(8, 0xAABBCCDD);
    uint32_t loaded2 = load_word(8);

    printf("Test 2\n");
    printf("Stored : 0x%08X\n", 0xAABBCCDD);
    printf("Loaded : 0x%08X\n\n", loaded2);

    // test case 3: unaligned access
    printf("Test 3 (Expected Failure - Unaligned)\n");
    store_word(3, 0x11111111);

    // test case 4: out-of-bounds access
    /*
    printf("Test 4 (Expected Failure - Out of Bounds)\n");
    store_word(254, 0xDEADBEEF);
    */

    return 0;
}
