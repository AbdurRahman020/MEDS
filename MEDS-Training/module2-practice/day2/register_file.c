/*
    A simple register file simulation for testing register read/write operations
*/

#include <stdint.h>
#include <stdio.h>

// write value to register rd
void write_reg(uint32_t *regs, uint8_t rd, uint32_t value) {
    // x0 is hardwired to 0, so writes to x0 are ignored
    if (rd == 0) {
        return;
    }
    // write value to the specified register
    regs[rd] = value;
}

// read value from register rs
uint32_t read_reg(const uint32_t *regs, uint8_t rs) {
    return regs[rs];
}

int main(void) {
    // simulated 32-register file
    uint32_t regs[32] = {0};

    write_reg(regs, 1, 42);
    write_reg(regs, 2, 84); 
    write_reg(regs, 0, 123);

    printf("x0 = %u\n", read_reg(regs, 0));
    printf("x1 = %u\n", read_reg(regs, 1));
    printf("x2 = %u\n", read_reg(regs, 2));

    return 0;
}
