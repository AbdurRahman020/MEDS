/*
// The 6 hand-encoded instructions from ENCODING_WORKSHEET.md,
// loaded as raw 32-bit words and decoded field-by-field.
unsigned int instructions[6] = {
    0x007302B3,  // R: add x5, x6, x7
    0xFEC48413,  // I: addi x8, x9, -20
    0x00A5A623,  // S: sw x10, 12(x11)
    0x00D61463,  // B: bne x12, x13, +8
    0x00010737,  // U: lui x14, 0x10
    0x020007EF   // J: jal x15, +32
};

void extract_fields(unsigned int instr) {
    unsigned int opcode = instr & 0x7F;
    unsigned int rd     = (instr >> 7)  & 0x1F;
    unsigned int funct3 = (instr >> 12) & 0x7;
    unsigned int rs1    = (instr >> 15) & 0x1F;
    printf("  opcode = %u\n", opcode);
    printf("  rd     = %u\n", rd);
    printf("  funct3 = %u\n", funct3);
    printf("  rs1    = %u\n", rs1);
}

int main() {
    for (int i = 0; i < 6; i++) extract_fields(instructions[i]);
    return 0;
}
// NOTE: for U-type and J-type instructions there is no real rs1/funct3 field --
// those bit positions are part of the larger immediate, so the extracted
// "rs1"/"funct3" values for instr5 and instr6 are not semantically meaningful.
*/

.data
instr1: .word 0x007302B3         # R-type: add  x5, x6, x7
instr2: .word 0xFEC48413         # I-type: addi x8, x9, -20
instr3: .word 0x00A5A623         # S-type: sw   x10, 12(x11)
instr4: .word 0x00D61463         # B-type: bne  x12, x13, +8
instr5: .word 0x00010737         # U-type: lui  x14, 0x10
instr6: .word 0x020007EF         # J-type: jal  x15, +32

opcode_label: .string "  opcode = "
rd_label:     .string "  rd     = "
funct3_label: .string "  funct3 = "
rs1_label:    .string "  rs1    = "
newline:      .string "\n"

.text
.globl main

# extract_fields: a0 = instruction word
# Prints opcode, rd, funct3, rs1 using shift-and-mask (andi/srli)
extract_fields:
    addi sp, sp, -16
    sw   ra, 12(sp)             # save return address (calls print_field)
    sw   s0, 8(sp)              # save s0 (holds instruction word across calls)

    mv   s0, a0                 # s0 = instruction word

    # opcode = instr & 0x7F  (bits 6:0)
    andi t0, s0, 0x7F
    la   a0, opcode_label
    mv   a1, t0
    call print_field

    # rd = (instr >> 7) & 0x1F  (bits 11:7)
    srli t0, s0, 7
    andi t0, t0, 0x1F
    la   a0, rd_label
    mv   a1, t0
    call print_field

    # funct3 = (instr >> 12) & 0x7  (bits 14:12)
    srli t0, s0, 12
    andi t0, t0, 0x7
    la   a0, funct3_label
    mv   a1, t0
    call print_field

    # rs1 = (instr >> 15) & 0x1F  (bits 19:15)
    srli t0, s0, 15
    andi t0, t0, 0x1F
    la   a0, rs1_label
    mv   a1, t0
    call print_field

    lw   s0, 8(sp)
    lw   ra, 12(sp)
    addi sp, sp, 16
    ret

# print_field: a0 = label address, a1 = int value -> prints "<label><value>\n"
print_field:
    mv   t1, a0
    mv   t0, a1
    li   a0, 4
    mv   a1, t1
    ecall
    li   a0, 1
    mv   a1, t0
    ecall
    li   a0, 4
    la   a1, newline
    ecall
    ret

main:
    addi sp, sp, -16
    sw   ra, 12(sp)              # save return address (main calls extract_fields)

    la   t0, instr1
    lw   a0, 0(t0)
    call extract_fields          # R-type fields

    la   t0, instr2
    lw   a0, 0(t0)
    call extract_fields          # I-type fields

    la   t0, instr3
    lw   a0, 0(t0)
    call extract_fields          # S-type fields

    la   t0, instr4
    lw   a0, 0(t0)
    call extract_fields          # B-type fields

    la   t0, instr5
    lw   a0, 0(t0)
    call extract_fields          # U-type fields (rs1/funct3 not meaningful here)

    la   t0, instr6
    lw   a0, 0(t0)
    call extract_fields          # J-type fields (rs1/funct3 not meaningful here)

    lw   ra, 12(sp)
    addi sp, sp, 16

    # exit
    li   a0, 10                  # ecall 10 = exit program
    ecall                        # terminate execution
