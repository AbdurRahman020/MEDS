#include <stdio.h>
#include <stdint.h>

/*
    sign extension function
*/

int32_t sign_extend(uint32_t value, int bits) {
    uint32_t sign_bit = 1U << (bits - 1);

    // if sign bit is set, extend with 1s
    if (value & sign_bit) {
        uint32_t mask = ~((1U << bits) - 1);
        value |= mask;
    }

    return (int32_t)value;
}

int main() {
    uint32_t val = 0xFFF;

    int32_t result = sign_extend(val, 12);

    printf("Input           : 0x%03X\n", val);
    printf("Sign-extended   : %d\n", result);
    printf("Hex             : 0x%08X\n", (uint32_t)result);

    return 0;
}
