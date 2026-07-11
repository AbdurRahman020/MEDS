#include <stdio.h>
#include <stdint.h>

int main() {
    uint32_t word = 0xDEADBEEF;

    uint8_t memory[4];

    memory[0] = (word >> 0) & 0xFF;
    memory[1] = (word >> 8) & 0xFF;
    memory[2] = (word >> 16) & 0xFF;
    memory[3] = (word >> 24) & 0xFF;

    printf("%02X\n", memory[0]);
    printf("%02X\n", memory[1]);
    printf("%02X\n", memory[2]);
    printf("%02X\n", memory[3]);

    return 0;
}
