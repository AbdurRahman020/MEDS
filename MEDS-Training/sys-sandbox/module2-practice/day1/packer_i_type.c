/*
    packing I-type instructions from individual fields using bit manipulation
*/

#include <stdio.h>
#include <stdint.h>

// extract bits from high:low
#define EXTRACT_BITS(val, high, low) \
    (((val) >> (low)) & ((1U << ((high) - (low) + 1)) - 1))

// place a value into bit position
#define SET_BITS(val, shift, mask) \
    (((val) & (mask)) << (shift))

// pack I-type instruction
uint32_t pack_itype(uint32_t rd,
                    uint32_t rs1,
                    uint32_t imm,
                    uint32_t funct3,
                    uint32_t opcode) {

    uint32_t instr = 0;

    instr |= SET_BITS(imm,    20, 0xFFF); // imm[11:0]
    instr |= SET_BITS(rs1,    15, 0x1F);  // rs1
    instr |= SET_BITS(funct3, 12, 0x07);  // funct3
    instr |= SET_BITS(rd,      7, 0x1F);  // rd
    instr |= SET_BITS(opcode,  0, 0x7F);  // opcode

    return instr;
}

// decode and print fields
void decode_instruction(uint32_t instr) {
    printf("Instruction : 0x%08X\n", instr);

    printf("opcode  = 0x%02X\n", EXTRACT_BITS(instr, 6, 0));
    printf("rd      = x%u\n",    EXTRACT_BITS(instr, 11, 7));
    printf("funct3  = 0x%X\n",   EXTRACT_BITS(instr, 14, 12));
    printf("rs1     = x%u\n",    EXTRACT_BITS(instr, 19, 15));
    
    // extract the immediate value (sign-extended)
    int32_t imm = ((int32_t)instr) >> 20;
    printf("imm     = %d\n", imm);

    printf("-----------------------------------\n");
}

int main() {

    // addi x4, x5, 10
    uint32_t rd     = 4;
    uint32_t rs1    = 5;
    uint32_t imm    = 10;
    uint32_t funct3 = 0x0;
    uint32_t opcode = 0x13;

    uint32_t instr = pack_itype(rd, rs1, imm, funct3, opcode);

    printf("Packed instruction = 0x%08X\n\n", instr);

    // verify by decoding
    decode_instruction(instr);

    return 0;
}