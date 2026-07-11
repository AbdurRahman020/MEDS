#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>

/*
    various formats for printing a 32-bit hexadecimal value
*/

// print a 32-bit number in binary format with spacing every 4 bits
void print_binary(uint32_t num) {
    for (int i = 31; i >= 0; i--) {
        printf("%u", (num >> i) & 1U);
        
        // add spacing for readability
        if (i % 4 == 0) {
            printf(" ");
        }
    }

    printf("\n");
}

int main(int argc, char *argv[]) {
    // ensure exactly one argument is provided
    if (argc != 2) {
        fprintf(stderr, "Usage: %s <32-bit hex value>\n", argv[0]);
        return 1;
    }

    // convert hexadecimal string input to a 32-bit unsigned integer
    uint32_t num = (uint32_t)strtoul(argv[1], NULL, 16);

    // display the value in multiple representations
    printf("Hex       : 0x%08X\n", num);
    printf("Unsigned  : %u\n", num);
    printf("Signed    : %d\n", (int32_t)num);
    printf("Binary    : ");
    print_binary(num);

    return 0;
}
