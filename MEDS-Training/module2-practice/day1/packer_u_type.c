/*
    packing U-type instructions from individual fields using bit manipulation
*/

#include <stdio.h>
#include <stdint.h>

// extract bits [high:low]
#define EXTRACT_BITS(val, high, low) \
    (((val) >> (low)) & ((1U << ((high) - (low) + 1)) - 1))

// place value into bit position
#define SET_BITS(val, shift, mask) \
    (((val) & (mask)) << (shift))

// pack a U-type instruction
uint32_t pack_utype(uint32_t rd,
                    int32_t imm,
                    uint32_t opcode) {

    uint32_t instr = 0;
    // extract the upper 20 bits of the immediate value
    uint32_t uimm = ((uint32_t)imm >> 12) & 0xFFFFF;

    instr |= SET_BITS(uimm,   12, 0xFFFFF); // imm[31:12]
    instr |= SET_BITS(rd,       7, 0x1F);   // rd
    instr |= SET_BITS(opcode,   0, 0x7F);   // opcode

    return instr;
}

// decode and print a U-type instruction
void decode_instruction(uint32_t instr) {
    printf("Instruction : 0x%08X\n\n", instr);

    printf("opcode  = 0x%02X\n", EXTRACT_BITS(instr, 6, 0));
    printf("rd      = x%u\n",    EXTRACT_BITS(instr, 11, 7));

    // reconstruct immediate
    uint32_t imm = EXTRACT_BITS(instr, 31, 12) << 12;
    printf("imm     = 0x%08X (%d)\n", imm, (int32_t)imm);

    printf("-----------------------------------\n");
}

int main(void) {

    // lui x5, 0x12345000
    uint32_t rd     = 5;
    int32_t  imm    = 0x12345000;
    uint32_t opcode = 0x37;

    uint32_t instr = pack_utype(rd, imm, opcode);

    printf("Packed instruction = 0x%08X\n\n", instr);

    // verify by decoding
    decode_instruction(instr);

    return 0;
}
