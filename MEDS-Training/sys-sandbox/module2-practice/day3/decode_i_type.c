/*
    simple RISC-V instruction decoder for I-type instructions
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

// function to decode I-type instructions
void decode_i_type(uint32_t raw, decoded_instr_t *out) {
    out->opcode = raw & 0x7F;             // bits [6:0]
    out->rd     = (raw >> 7) & 0x1F;      // bits [11:7]
    out->funct3 = (raw >> 12) & 0x07;     // bits [14:12]
    out->rs1    = (raw >> 15) & 0x1F;     // bits [19:15]
    out->imm    = ((int32_t)raw) >> 20;   // bits [31:20], sign-extended
    
    // not used for I-type
    out->rs2 = 0;
    out->funct7 = 0;
}


int main() {
    uint32_t raw_instr = 0x00A28213; // addi x4, x5, 10
    decoded_instr_t decoded;

    decode_i_type(raw_instr, &decoded);

    printf("Decoded I-type Instruction:\n");
    printf("Opcode    : 0x%02X\n", decoded.opcode);
    printf("rd        : x%d\n", decoded.rd);
    printf("funct3    : 0x%X\n", decoded.funct3);
    printf("rs1       : x%d\n", decoded.rs1);
    printf("Immediate : %d\n", decoded.imm);

    return 0;
}
