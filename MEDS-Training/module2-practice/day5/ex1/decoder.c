#include "decoder.h"
#include <stdio.h>

void decode(uint32_t instruction) {
    uint32_t opcode = instruction & 0x7F;
    printf("Instruction: 0x%08X  Opcode: 0x%02X\n", instruction, opcode);
}
