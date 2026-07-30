#include <stdio.h>

// rv32i base instruction opcodes
typedef enum {
    OP_LOAD      = 0x03, // Load instructions
    OP_MISC_MEM  = 0x0F, // FENCE instructions
    OP_I_TYPE    = 0x13, // Immediate arithmetic
    OP_AUIPC     = 0x17, // Add upper immediate to PC
    OP_STORE     = 0x23, // Store instructions
    OP_R_TYPE    = 0x33, // Register-register arithmetic
    OP_LUI       = 0x37, // Load upper immediate
    OP_BRANCH    = 0x63, // Conditional branches
    OP_JALR      = 0x67, // Jump and link register
    OP_JAL       = 0x6F, // Jump and link
    OP_SYSTEM    = 0x73  // System/CSR instructions
} opcode_t;

// convert an opcode enum value to a readable string
const char *opcode_to_string(opcode_t op)
{
    switch (op) {
        case OP_LOAD:
            return "LOAD";

        case OP_MISC_MEM:
            return "MISC-MEM";

        case OP_I_TYPE:
            return "I-TYPE";

        case OP_AUIPC:
            return "AUIPC";

        case OP_STORE:
            return "STORE";

        case OP_R_TYPE:
            return "R-TYPE";

        case OP_LUI:
            return "LUI";

        case OP_BRANCH:
            return "BRANCH";

        case OP_JALR:
            return "JALR";

        case OP_JAL:
            return "JAL";

        case OP_SYSTEM:
            return "SYSTEM";

        default:
            return "UNKNOWN";
    }
}

int main(void)
{
    // list of valid RV32I opcodes to test
    opcode_t ops[] = {
        OP_LOAD,
        OP_MISC_MEM,
        OP_I_TYPE,
        OP_AUIPC,
        OP_STORE,
        OP_R_TYPE,
        OP_LUI,
        OP_BRANCH,
        OP_JALR,
        OP_JAL,
        OP_SYSTEM
    };

    int count = sizeof(ops) / sizeof(ops[0]);

    // print each opcode and its mnemonic
    for (int i = 0; i < count; i++) {
        printf("Opcode 0x%02X -> %s\n",
               ops[i],
               opcode_to_string(ops[i]));
    }

    // test handling of an unknown opcode
    printf("Opcode 0x%02X -> %s\n",
           0xFF,
           opcode_to_string((opcode_t)0xFF));

    return 0;
}