#include "decoder.h"

void decode(reg_t instruction) {
    LOG("decode() called with " REG_FMT, instruction);
    uint32_t opcode = instruction & 0x7F;
    printf("Instruction: " REG_FMT "  Opcode: 0x%02X\n", instruction, opcode);
}
