/*
    simple RISC-V instruction decoder for J-type instructions
*/

#include <stdio.h>
#include <stdint.h>

// structure to hold decoded instruction fields
typedef struct {
    uint32_t opcode;
    uint32_t rd;
    uint32_t funct3;
    uint32_t rs1;
    uint32_t rs2;
    uint32_t funct7;
    int32_t imm;
} decoded_instr_t;

// function to decode J-type instructions
void decode_j_type(uint32_t raw, decoded_instr_t *out) {
    out->opcode = raw & 0x7F;          // bits [6:0]
    out->rd     = (raw >> 7) & 0x1F;   // bits [11:7]

    /* 
    immediate bits:
        imm[20]    = bit 31
        imm[10:1]  = bits 30:21
        imm[11]    = bit 20
        imm[19:12] = bits 19:12
        imm[0]     = 0
    */
    uint32_t imm =
        (((raw >> 31) & 0x1) << 20) |
        (((raw >> 21) & 0x3FF) << 1) |
        (((raw >> 20) & 0x1) << 11) |
        (((raw >> 12) & 0xFF) << 12);

    // sign-extend the 21-bit immediate
    out->imm = (imm & 0x100000) ? (int32_t)(imm | 0xFFE00000) : (int32_t)imm;

    // not used for J-type
    out->funct3 = 0;
    out->rs1 = 0;
    out->rs2 = 0;
    out->funct7 = 0;
}


int main() {
    uint32_t raw_instr = 0x008000EF; // jal x1, 8
    decoded_instr_t decoded;

    decode_j_type(raw_instr, &decoded);

    printf("Decoded J-type Instruction:\n");
    printf("Opcode    : 0x%02X\n", decoded.opcode);
    printf("rd        : x%d\n", decoded.rd);
    printf("Immediate : %d\n", decoded.imm);

    return 0;
}
