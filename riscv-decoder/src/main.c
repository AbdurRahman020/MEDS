/*
 * RISC-V RV32I Instruction Decoder
 * --------------------------------
 * This program loads hexadecimal machine code instructions from a file,
 * decodes each instruction using the RV32I decoder module, and prints
 * the corresponding assembly representation.
 *
 * Features:
 *   - Loads instructions into simulated memory
 *   - Decodes and displays assembly instructions
 *   - Tracks valid and unknown instructions
 *   - Uses heap allocation for memory management
 */

#include "decoder.h"
#include "memory.h"

int main(int argc, char *argv[]) {

    // check command-line arguments
    if (argc < 2) {
        fprintf(stderr, "Usage: %s <hex_file>\n", argv[0]);
        return 1;
    }

    // allocate simulated memory on the heap, using heap allocation avoids large stack usage
    memory_t *mem = malloc(sizeof(memory_t));

    if (!mem) {
        fprintf(stderr, "Error: out of memory\n");
        return 1;
    }

    // load hexadecimal instructions from file
    int count = mem_load_hex(mem, argv[1]);

    if (count < 0) {
        free(mem);
        return 1;
    }

    // decoder header
    printf("RISC-V RV32I Instruction Decoder\n");
    printf("================================\n");
    printf("Loaded %d instructions from %s\n\n", count, argv[1]);

    // table header
    printf("%-12s %-12s %s\n", "Addr", "Hex", "Assembly");
    printf("---------- ---------- -------------------------\n");

    int valid = 0;
    int unknown = 0;

    // decode and print each instruction
    for (uint32_t i = 0; i < mem->count; i++) {

        decoded_instr_t instr;

        // read instruction from memory and decode it
        decode_instruction(mem_read(mem, i), i * 4, &instr);

        // print decoded instruction
        print_instruction(&instr);

        // track valid vs unknown instructions
        if (instr.type == TYPE_UNKNOWN)
            unknown++;
        else
            valid++;
    }

    // final summary
    printf("\nDecoded %d instructions (%d valid, %d unknown)\n",
           count, valid, unknown);

    // release allocated memory
    free(mem);

    return 0;
}
