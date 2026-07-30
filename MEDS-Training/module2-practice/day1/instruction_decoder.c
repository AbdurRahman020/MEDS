#include <stdio.h>
#include <stdint.h>

/*
    decoding RISC-V instructions
*/

#define EXTRACT_BITS(val, high, low) \
    (((val) >> (low)) & ((1U << ((high)-(low)+1)) - 1))

void decode_instruction(uint32_t instr) {

    uint32_t opcode = EXTRACT_BITS(instr, 6, 0);
    uint32_t rd     = EXTRACT_BITS(instr, 11, 7);
    uint32_t funct3 = EXTRACT_BITS(instr, 14, 12);
    uint32_t rs1    = EXTRACT_BITS(instr, 19, 15);
    uint32_t rs2    = EXTRACT_BITS(instr, 24, 20);
    uint32_t funct7 = EXTRACT_BITS(instr, 31, 25);

    printf("Instruction : 0x%08X\n", instr);
    printf("opcode      : 0x%02X\n", opcode);
    printf("rd          : x%u\n", rd);
    printf("funct3      : 0x%X\n", funct3);
    printf("rs1         : x%u\n", rs1);
    printf("rs2         : x%u\n", rs2);
    printf("funct7      : 0x%02X\n", funct7);

    printf("-----------------------------------\n");
}

int main() {

    uint32_t instructions[] = {
        0x00A28233, // add x4,  x5,  x10
        0x40B50533, // sub x10, x10, x11
        0x0020A233, // slt x4,  x1,  x2
        0x00C586B3, // add x13, x11, x12
        0x0062E633  // or  x12, x5,  x6
    };

    int n = sizeof(instructions) / sizeof(instructions[0]);

    for (int i = 0; i < n; i++) {
        decode_instruction(instructions[i]);
    }

    uint32_t user_instr;

    printf("Enter an RV32 instruction in hex: ");
    scanf("%x", &user_instr);

    decode_instruction(user_instr);

    return 0;
}
