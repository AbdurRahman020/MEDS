/*
    simple RISC-V instruction decoder for U-type instructions
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

// function to decode U-type instructions
void decode_u_type(uint32_t raw, decoded_instr_t *out) {
    out->opcode = raw & 0x7F;                    // bits [6:0]
    out->rd     = (raw >> 7) & 0x1F;             // bits [11:7]
    out->imm    = (int32_t)(raw & 0xFFFFF000);   // bits [31:12], sign-extended

    // Not used for U-type
    out->funct3 = 0;
    out->rs1 = 0;
    out->rs2 = 0;
    out->funct7 = 0;
}


int main() {
    uint32_t raw_instr = 0x123452B7; // lui x5, 0x12345
    decoded_instr_t decoded;

    decode_u_type(raw_instr, &decoded);

    printf("Decoded U-type Instruction:\n");
    printf("Opcode    : 0x%02X\n", decoded.opcode);
    printf("rd        : x%d\n", decoded.rd);
    printf("Immediate : 0x%08X\n", (uint32_t)decoded.imm);

    return 0;
}
