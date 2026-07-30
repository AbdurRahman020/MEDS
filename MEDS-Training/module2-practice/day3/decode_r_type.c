/*
    simple RISC-V instruction decoder for R-type instructions
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

// function to decode R-type instructions
void decode_r_type(uint32_t raw, decoded_instr_t *out) {
    out->opcode = raw & 0x7F;          // bits [6:0]
    out->rd     = (raw >> 7) & 0x1F;   // bits [11:7]
    out->funct3 = (raw >> 12) & 0x07;  // bits [14:12]
    out->rs1    = (raw >> 15) & 0x1F;  // bits [19:15]
    out->rs2    = (raw >> 20) & 0x1F;  // bits [24:20]
    out->funct7 = (raw >> 25) & 0x7F;  // bits [31:25]
    
    // not used for R-type
    out->imm    = 0;
}


int main() {
    uint32_t raw_instr = 0x00A28233; // add x4, x5, x10
    decoded_instr_t decoded;

    decode_r_type(raw_instr, &decoded);

    printf("Decoded R-type Instruction:\n");
    printf("Opcode    : 0x%02X\n", decoded.opcode);
    printf("rd        : x%d\n", decoded.rd);
    printf("funct3    : 0x%X\n", decoded.funct3);
    printf("rs1       : x%d\n", decoded.rs1);
    printf("rs2       : x%d\n", decoded.rs2);
    printf("funct7    : 0x%02X\n", decoded.funct7);
    printf("Immediate : %d\n", decoded.imm);

    return 0;
}
