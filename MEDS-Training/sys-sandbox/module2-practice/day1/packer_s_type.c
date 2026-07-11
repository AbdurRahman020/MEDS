/*
    packing S-type instructions from individual fields using bit manipulation
*/

#include <stdio.h>
#include <stdint.h>

// extract bits [high:low]
#define EXTRACT_BITS(val, high, low) \
    (((val) >> (low)) & ((1U << ((high) - (low) + 1)) - 1))

// place value into bit position
#define SET_BITS(val, shift, mask) \
    (((val) & (mask)) << (shift))

// pack an S-type instruction
uint32_t pack_stype(uint32_t rs2,
                    uint32_t rs1,
                    int32_t imm,
                    uint32_t funct3,
                    uint32_t opcode) {

    uint32_t instr = 0;
    uint32_t uimm = (uint32_t)imm & 0xFFF;

    instr |= SET_BITS((uimm >> 5), 25, 0x7F); // imm[11:5]
    instr |= SET_BITS(rs2,         20, 0x1F); // rs2
    instr |= SET_BITS(rs1,         15, 0x1F); // rs1
    instr |= SET_BITS(funct3,      12, 0x07); // funct3
    instr |= SET_BITS(uimm,         7, 0x1F); // imm[4:0]
    instr |= SET_BITS(opcode,       0, 0x7F); // opcode

    return instr;
}

// decode and print an S-type instruction
void decode_instruction(uint32_t instr) {
    printf("Instruction : 0x%08X\n\n", instr);

    printf("opcode  = 0x%02X\n", EXTRACT_BITS(instr, 6, 0));
    printf("rs1     = x%u\n",    EXTRACT_BITS(instr, 19, 15));
    printf("rs2     = x%u\n",    EXTRACT_BITS(instr, 24, 20));
    printf("funct3  = 0x%X\n",   EXTRACT_BITS(instr, 14, 12));

    // reconstruct immediate
    uint32_t imm =
        (EXTRACT_BITS(instr, 31, 25) << 5) | EXTRACT_BITS(instr, 11, 7);

    // sign-extend 12-bit immediate
    if (imm & 0x800)
        imm |= 0xFFFFF000;

    printf("imm     = %d\n", (int32_t)imm);

    printf("-----------------------------------\n");
}

int main(void) {
    
    // sw x4, 10(x5)
    uint32_t rs2    = 4;
    uint32_t rs1    = 5;
    int32_t  imm    = 10;
    uint32_t funct3 = 0x2;
    uint32_t opcode = 0x23;

    uint32_t instr = pack_stype(rs2, rs1, imm, funct3, opcode);

    printf("Packed instruction = 0x%08X\n\n", instr);
    
    // verify by decoding
    decode_instruction(instr);

    return 0;
}
