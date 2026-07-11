/*
    packing B-type instructions from individual fields using bit manipulation
*/

#include <stdio.h>
#include <stdint.h>

// extract bits [high:low]
#define EXTRACT_BITS(val, high, low) \
    (((val) >> (low)) & ((1U << ((high) - (low) + 1)) - 1))

// place value into bit position
#define SET_BITS(val, shift, mask) \
    (((val) & (mask)) << (shift))

// pack a B-type instruction
uint32_t pack_btype(uint32_t rs2,
                    uint32_t rs1,
                    int32_t imm,
                    uint32_t funct3,
                    uint32_t opcode) {

    uint32_t instr = 0;
    uint32_t uimm = (uint32_t)imm & 0x1FFF;

    instr |= SET_BITS((uimm >> 12), 31, 0x01); // imm[12]
    instr |= SET_BITS((uimm >> 5),  25, 0x3F); // imm[10:5]
    instr |= SET_BITS(rs2,          20, 0x1F); // rs2
    instr |= SET_BITS(rs1,          15, 0x1F); // rs1
    instr |= SET_BITS(funct3,       12, 0x07); // funct3
    instr |= SET_BITS((uimm >> 1),   8, 0x0F); // imm[4:1]
    instr |= SET_BITS((uimm >> 11),  7, 0x01); // imm[11]
    instr |= SET_BITS(opcode,        0, 0x7F); // opcode

    return instr;
}

// decode and print a B-type instruction
void decode_instruction(uint32_t instr) {
    printf("Instruction : 0x%08X\n\n", instr);

    printf("opcode  = 0x%02X\n", EXTRACT_BITS(instr, 6, 0));
    printf("rs1     = x%u\n",    EXTRACT_BITS(instr, 19, 15));
    printf("rs2     = x%u\n",    EXTRACT_BITS(instr, 24, 20));
    printf("funct3  = 0x%X\n",   EXTRACT_BITS(instr, 14, 12));

    // reconstruct immediate
    uint32_t imm =
          (EXTRACT_BITS(instr, 31, 31) << 12)
        | (EXTRACT_BITS(instr, 7, 7)   << 11)
        | (EXTRACT_BITS(instr, 30, 25) << 5)
        | (EXTRACT_BITS(instr, 11, 8)  << 1);

    // sign-extend 13-bit immediate
    if (imm & 0x1000)
        imm |= 0xFFFFE000;

    printf("imm     = %d\n", (int32_t)imm);

    printf("-----------------------------------\n");
}

int main(void) {

    // beq x5, x4, 16
    uint32_t rs2    = 4;
    uint32_t rs1    = 5;
    int32_t  imm    = 16;
    uint32_t funct3 = 0x0;
    uint32_t opcode = 0x63;

    uint32_t instr = pack_btype(rs2, rs1, imm, funct3, opcode);

    printf("Packed instruction = 0x%08X\n\n", instr);

    // verify by decoding
    decode_instruction(instr);

    return 0;
}
