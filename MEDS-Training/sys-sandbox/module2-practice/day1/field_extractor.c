#include <stdio.h>
#include <stdint.h>

/*
    extracting specific fields from a 32-bit RISC-V instruction using bit manipulation
*/

// macro to extract bits from high to low
#define EXTRACT_BITS(val, high, low) \
    (((val) >> (low)) & ((1U << ((high) - (low) + 1)) - 1))

int main() {

    uint32_t instr = 0x00A28233;

    // decode R-type fields using macro
    uint32_t opcode = EXTRACT_BITS(instr, 6, 0);
    uint32_t rd     = EXTRACT_BITS(instr, 11, 7);
    uint32_t funct3 = EXTRACT_BITS(instr, 14, 12);
    uint32_t rs1    = EXTRACT_BITS(instr, 19, 15);
    uint32_t rs2    = EXTRACT_BITS(instr, 24, 20);
    uint32_t funct7 = EXTRACT_BITS(instr, 31, 25);

    // print decoded fields
    printf("Instruction: 0x%08X\n", instr);
    printf("opcode   = 0x%X\n", opcode);
    printf("rd       = x%u\n", rd);
    printf("funct3   = 0x%X\n", funct3);
    printf("rs1      = x%u\n", rs1);
    printf("rs2      = x%u\n", rs2);
    printf("funct7   = 0x%X\n", funct7);

    return 0;
}
