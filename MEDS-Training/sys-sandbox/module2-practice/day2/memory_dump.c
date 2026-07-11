/*
    Prints memory in a hex dump format, showing both hexadecimal values and their ASCII representation

    Example output:
    0x0000: DE AD BE EF CA FE BA BE 48 65 6C 6C 6F |........Hello|
*/

#include <stdio.h>
#include <stdint.h>
#include <ctype.h>

void memory_dump(const uint8_t *mem, size_t size) {
    // process memory 16 bytes at a time
    for (size_t i = 0; i < size; i += 16) {
        // print the current memory offset/address
        printf("0x%04zx: ", i);
        // print bytes in hexadecimal
        for (size_t j = 0; j < 16; j++) {
            // make sure we don't read past the buffer
            if (i + j < size)
                printf("%02X ", mem[i + j]);
            // add spacing for incomplete last line
            else
                printf("   ");
        }

        // start ASCII section
        printf("|");

        // print printable characters, otherwise print '.'
        for (size_t j = 0; j < 16 && (i + j) < size; j++) {
            uint8_t c = mem[i + j];

            printf("%c", isprint(c) ? c : '.');
        }

        // end ASCII section
        printf("|\n");
    }
}

int main() {
    // example data stored in memory
    uint8_t data[] = {
        0xDE, 0xAD, 0xBE, 0xEF,
        0xCA, 0xFE, 0xBA, 0xBE,
        'H', 'e', 'l', 'l', 'o'
    };

    // dump the contents of the array
    memory_dump(data, sizeof(data));

    return 0;
}
