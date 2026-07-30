/*
    packing J-type instructions from individual fields using bit manipulation
*/

#include <stdio.h>
#include <stdint.h>

// extract bits [high:low]
#define EXTRACT_BITS(val, high, low) \
    (((val) >> (low)) & ((1U << ((high) - (low) + 1)) - 1))

// place value into bit position
#define SET_BITS(val, shift, mask) \
    (((val) & (mask)) << (shift))

// pack a J-type instruction
uint32_t pack_jtype(uint32_t rd,
                    int32_t imm,
                    uint32_t opcode) {

    uint32_t instr = 0;
    uint32_t uimm = (uint32_t)imm & 0x1FFFFF;

    instr |= SET_BITS((uimm >> 20), 31, 0x01);  // imm[20]
    instr |= SET_BITS((uimm >> 1),  21, 0x3FF); // imm[10:1]
    instr |= SET_BITS((uimm >> 11), 20, 0x01);  // imm[11]
    instr |= SET_BITS((uimm >> 12), 12, 0xFF);  // imm[19:12]
    instr |= SET_BITS(rd,            7, 0x1F);  // rd
    instr |= SET_BITS(opcode,        0, 0x7F);  // opcode

    return instr;
}

// decode and print a J-type instruction
void decode_instruction(uint32_t instr) {
    printf("Instruction : 0x%08X\n\n", instr);

    printf("opcode  = 0x%02X\n", EXTRACT_BITS(instr, 6, 0));
    printf("rd      = x%u\n",    EXTRACT_BITS(instr, 11, 7));

    // reconstruct immediate
    uint32_t imm =
          (EXTRACT_BITS(instr, 31, 31) << 20)
        | (EXTRACT_BITS(instr, 19, 12) << 12)
        | (EXTRACT_BITS(instr, 20, 20) << 11)
        | (EXTRACT_BITS(instr, 30, 21) << 1);

    // sign-extend 21-bit immediate
    if (imm & 0x100000)
        imm |= 0xFFE00000;

    printf("imm     = %d\n", (int32_t)imm);

    printf("-----------------------------------\n");
}

int main(void) {

    // jal x1, 256
    uint32_t rd     = 1;
    int32_t  imm    = 256;
    uint32_t opcode = 0x6F;

    uint32_t instr = pack_jtype(rd, imm, opcode);

    printf("Packed instruction = 0x%08X\n\n", instr);

    // verify by decoding
    decode_instruction(instr);

    return 0;
}
