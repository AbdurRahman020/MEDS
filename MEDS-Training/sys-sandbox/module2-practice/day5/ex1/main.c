#include "decoder.h"

int main(void) {
    decode(0x00A50533);  // some test instruction
    decode(0x00000013);  // NOP
    return 0;
}
