#include <stdio.h>
#include <stdint.h>

// view the same 32-bit instruction as different formats
typedef union {

    uint32_t raw; // full 32-bit instruction

    // R-type instruction format
    struct {
        uint32_t opcode : 7;
        uint32_t rd     : 5;
        uint32_t funct3 : 3;
        uint32_t rs1    : 5;
        uint32_t rs2    : 5;
        uint32_t funct7 : 7;
    } r_type;

    // I-type instruction format
    struct {
        uint32_t opcode : 7;
        uint32_t rd     : 5;
        uint32_t funct3 : 3;
        uint32_t rs1    : 5;
        uint32_t imm    : 12;
    } i_type;

    // S-type instruction format
    struct {
        uint32_t opcode  : 7;
        uint32_t imm4_0  : 5;
        uint32_t funct3  : 3;
        uint32_t rs1     : 5;
        uint32_t rs2     : 5;
        uint32_t imm11_5 : 7;
    } s_type;

    // B-type instruction format
    struct {
        uint32_t opcode  : 7;
        uint32_t imm11   : 1;
        uint32_t imm4_1  : 4;
        uint32_t funct3  : 3;
        uint32_t rs1     : 5;
        uint32_t rs2     : 5;
        uint32_t imm10_5 : 6;
        uint32_t imm12   : 1;
    } b_type;

    // U-type instruction format
    struct {
        uint32_t opcode : 7;
        uint32_t rd     : 5;
        uint32_t imm    : 20;
    } u_type;

    // J-type instruction format
    struct {
        uint32_t opcode   : 7;
        uint32_t rd       : 5;
        uint32_t imm19_12 : 8;
        uint32_t imm11    : 1;
        uint32_t imm10_1  : 10;
        uint32_t imm20    : 1;
    } j_type;

} instruction_t;

int main() {

    instruction_t inst;

    // R-type: add x4, x5, x10
    // Binary:
    // funct7 rs2 rs1 funct3 rd opcode
    // 0000000 01010 00101 000 00100 0110011

    inst.raw = 0x00A28233;

    printf("Raw instruction = 0x%08X\n", inst.raw);

    printf("=== R-Type Decode ===\n");
    printf("opcode = 0x%X\n", inst.r_type.opcode);
    printf("rd     = x%u\n", inst.r_type.rd);
    printf("funct3 = 0x%X\n", inst.r_type.funct3);
    printf("rs1    = x%u\n", inst.r_type.rs1);
    printf("rs2    = x%u\n", inst.r_type.rs2);
    printf("funct7 = 0x%X\n\n", inst.r_type.funct7);

    // I-type: addi x2, x0, 5
    // Binary:
    // imm[11:0] rs1 funct3 rd opcode
    // 000000000101 00000 000 00010 0010011

    inst.raw = 0x00500113;

    printf("Raw instruction = 0x%08X\n", inst.raw);

    printf("=== I-Type Decode ===\n");
    printf("opcode = 0x%X\n", inst.i_type.opcode);
    printf("rd     = x%u\n", inst.i_type.rd);
    printf("funct3 = 0x%X\n", inst.i_type.funct3);
    printf("rs1    = x%u\n", inst.i_type.rs1);
    printf("imm    = %u\n\n", inst.i_type.imm);

    // S-type: sw x2, 8(x1)
    // Binary:
    // imm[11:5] rs2 rs1 funct3 imm[4:0] opcode
    // 0000000 00010 00001 010 01000 0100011

    inst.raw = 0x0020A423;

    printf("Raw instruction = 0x%08X\n", inst.raw);

    printf("=== S-Type Decode ===\n");
    printf("opcode  = 0x%X\n", inst.s_type.opcode);
    printf("funct3  = 0x%X\n", inst.s_type.funct3);
    printf("rs1     = x%u\n", inst.s_type.rs1);
    printf("rs2     = x%u\n", inst.s_type.rs2);
    printf("imm11_5 = %u\n", inst.s_type.imm11_5);
    printf("imm4_0  = %u\n\n", inst.s_type.imm4_0);

    // B-type: beq x1, x2, 8
    // Binary:
    // imm12 imm10:5 rs2 rs1 funct3 imm4:1 imm11 opcode
    // 0 000000 00010 00001 000 0100 0 1100011

    inst.raw = 0x00208463;

    printf("Raw instruction = 0x%08X\n", inst.raw);

    printf("=== B-Type Decode ===\n");
    printf("opcode  = 0x%X\n", inst.b_type.opcode);
    printf("funct3  = 0x%X\n", inst.b_type.funct3);
    printf("rs1     = x%u\n", inst.b_type.rs1);
    printf("rs2     = x%u\n", inst.b_type.rs2);
    printf("imm12   = %u\n", inst.b_type.imm12);
    printf("imm11   = %u\n", inst.b_type.imm11);
    printf("imm10_5 = %u\n", inst.b_type.imm10_5);
    printf("imm4_1  = %u\n\n", inst.b_type.imm4_1);

    // U-type: lui x5, 0x12345
    // Binary:
    // imm[31:12] rd opcode
    // 00010010001101000101 00101 0110111

    inst.raw = 0x123452B7;

    printf("Raw instruction = 0x%08X\n", inst.raw);

    printf("=== U-Type Decode ===\n");
    printf("opcode = 0x%X\n", inst.u_type.opcode);
    printf("rd     = x%u\n", inst.u_type.rd);
    printf("imm    = 0x%05X\n\n", inst.u_type.imm);

    // J-type: jal x1, 8
    // Binary:
    // imm20 imm10:1 imm11 imm19:12 rd opcode
    // 0 0000000100 0 00000000 00001 1101111

    inst.raw = 0x008000EF;

    printf("Raw instruction = 0x%08X\n", inst.raw);

    printf("=== J-Type Decode ===\n");
    printf("opcode   = 0x%X\n", inst.j_type.opcode);
    printf("rd       = x%u\n", inst.j_type.rd);
    printf("imm20    = %u\n", inst.j_type.imm20);
    printf("imm19_12 = %u\n", inst.j_type.imm19_12);
    printf("imm11    = %u\n", inst.j_type.imm11);
    printf("imm10_1  = %u\n", inst.j_type.imm10_1);

    return 0;
}
