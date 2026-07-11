/*
    simple RISC-V instruction decoder for B-type instructions
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

// function to decode B-type instructions
void decode_b_type(uint32_t raw, decoded_instr_t *out) {
    out->opcode = raw & 0x7F;          // bits [6:0]
    out->funct3 = (raw >> 12) & 0x07;  // bits [14:12]
    out->rs1    = (raw >> 15) & 0x1F;  // bits [19:15]
    out->rs2    = (raw >> 20) & 0x1F;  // bits [24:20]

    /*
    immediate bits:
        imm[12]   = bit  31
        imm[11]   = bit  7
        imm[10:5] = bits 30:25
        imm[4:1]  = bits 11:8
        imm[0]    = 0
    */
    uint32_t imm =
        (((raw >> 31) & 0x1) << 12) |
        (((raw >> 7)  & 0x1) << 11) |
        (((raw >> 25) & 0x3F) << 5) |
        (((raw >> 8)  & 0xF) << 1);

    // sign-extend the 13-bit immediate
    out->imm = (imm & 0x1000) ? (int32_t)(imm | 0xFFFFE000) : (int32_t)imm;

    // not used for B-type
    out->rd = 0;
    out->funct7 = 0;
}


int main() {
    uint32_t raw_instr = 0x00208463; // beq x1, x2, 8
    decoded_instr_t decoded;

    decode_b_type(raw_instr, &decoded);

    printf("Decoded B-type Instruction:\n");
    printf("Opcode    : 0x%02X\n", decoded.opcode);
    printf("funct3    : 0x%X\n", decoded.funct3);
    printf("rs1       : x%d\n", decoded.rs1);
    printf("rs2       : x%d\n", decoded.rs2);
    printf("Immediate : %d\n", decoded.imm);

    return 0;
}
