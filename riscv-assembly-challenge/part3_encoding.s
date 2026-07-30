/*
// Extended: now also decodes the immediate field for I, S, B, U, J types

// I-type:  imm[11:0]  = instr[31:20], sign-extended
// S-type:  imm[11:5]  = instr[31:25], imm[4:0]  = instr[11:7], sign-extended
// B-type:  imm[12|10:5|4:1|11] = instr[31|30:25|11:8|7], sign-extended, LSB=0
// U-type:  imm[31:12] = instr[31:12] (NOT sign-extended, printed as 20-bit value)
// J-type:  imm[20|10:1|11|19:12] = instr[31|30:21|20|19:12], sign-extended, LSB=0
*/


.data
instr1: .word 0x007302B3         # R-type: add  x5, x6, x7
instr2: .word 0xFEC48413         # I-type: addi x8, x9, -20
instr3: .word 0x00A5A623         # S-type: sw   x10, 12(x11)
instr4: .word 0x00D61463         # B-type: bne  x12, x13, +8
instr5: .word 0x00010737         # U-type: lui  x14, 0x10
instr6: .word 0x020007EF         # J-type: jal  x15, +32

opcode_label: .string "opcode="
rd_label:     .string "  rd="
funct3_label: .string "  funct3="
rs1_label:    .string "  rs1="
imm_label:    .string "  imm="
newline:      .string "\n"

.text
.globl main

# extract_fields: a0 = instruction word
# Prints opcode, rd, funct3, rs1, imm (when applicable) all on one line
extract_fields:
    addi sp, sp, -16
    sw   ra, 12(sp)
    sw   s0, 8(sp)

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

    # decode and print immediate based on opcode (no imm for R-type)
    mv   a0, s0
    call decode_immediate

    # end of line for this instruction
    li   a0, 4
    la   a1, newline
    ecall

    lw   s0, 8(sp)
    lw   ra, 12(sp)
    addi sp, sp, 16
    ret

# decode_immediate: a0 = instruction word
# Branches on opcode to the correct imm decoder, prints result (skips R-type)
decode_immediate:
    addi sp, sp, -16
    sw   ra, 12(sp)
    sw   s0, 8(sp)
    mv   s0, a0

    andi t0, s0, 0x7F        # opcode

    li   t1, 0x33            # R-type opcode
    beq  t0, t1, imm_done     # R-type has no immediate, skip

    li   t1, 0x13            # I-type opcode (addi)
    beq  t0, t1, do_i_imm

    li   t1, 0x23            # S-type opcode
    beq  t0, t1, do_s_imm

    li   t1, 0x63            # B-type opcode
    beq  t0, t1, do_b_imm

    li   t1, 0x37            # U-type opcode (lui)
    beq  t0, t1, do_u_imm

    li   t1, 0x6F            # J-type opcode (jal)
    beq  t0, t1, do_j_imm

    j    imm_done             # unknown opcode, skip

do_i_imm:
    # imm[11:0] = instr[31:20], sign-extended via arithmetic shift
    srai t2, s0, 20
    j    print_imm

do_s_imm:
    # imm[11:5] = instr[31:25] (sign-extended), imm[4:0] = instr[11:7]
    srai t2, s0, 25          # sign-extended bits 31:25 -> imm[11:5]
    slli t2, t2, 5
    srli t3, s0, 7
    andi t3, t3, 0x1F        # imm[4:0]
    or   t2, t2, t3
    j    print_imm

do_b_imm:
    # imm[12]=instr[31], imm[11]=instr[7], imm[10:5]=instr[30:25], imm[4:1]=instr[11:8]
    srli t2, s0, 31
    andi t2, t2, 0x1
    slli t2, t2, 12          # imm[12]

    srli t3, s0, 7
    andi t3, t3, 0x1
    slli t3, t3, 11          # imm[11]
    or   t2, t2, t3

    srli t3, s0, 25
    andi t3, t3, 0x3F
    slli t3, t3, 5           # imm[10:5]
    or   t2, t2, t3

    srli t3, s0, 8
    andi t3, t3, 0xF
    slli t3, t3, 1           # imm[4:1]
    or   t2, t2, t3

    slli t2, t2, 19          # sign-extend from bit 12 (13-bit field)
    srai t2, t2, 19
    j    print_imm

do_u_imm:
    # imm[31:12] = instr[31:12], NOT sign-extended (printed as raw 20-bit value)
    srli t2, s0, 12
    j    print_imm

do_j_imm:
    # imm[20]=instr[31], imm[19:12]=instr[19:12], imm[11]=instr[20], imm[10:1]=instr[30:21]
    srli t2, s0, 31
    andi t2, t2, 0x1
    slli t2, t2, 20          # imm[20]

    srli t3, s0, 12
    andi t3, t3, 0xFF
    slli t3, t3, 12          # imm[19:12]
    or   t2, t2, t3

    srli t3, s0, 20
    andi t3, t3, 0x1
    slli t3, t3, 11          # imm[11]
    or   t2, t2, t3

    srli t3, s0, 21
    andi t3, t3, 0x3FF
    slli t3, t3, 1           # imm[10:1]
    or   t2, t2, t3

    slli t2, t2, 11          # sign-extend from bit 20 (21-bit field)
    srai t2, t2, 11
    j    print_imm

print_imm:
    la   a0, imm_label
    mv   a1, t2
    call print_field

imm_done:
    lw   s0, 8(sp)
    lw   ra, 12(sp)
    addi sp, sp, 16
    ret

# print_field: a0 = label address, a1 = int value -> prints "<label><value>" (no newline)
print_field:
    mv   t1, a0
    mv   t0, a1
    li   a0, 4
    mv   a1, t1
    ecall
    li   a0, 1
    mv   a1, t0
    ecall
    ret

main:
    addi sp, sp, -16
    sw   ra, 12(sp)

    la   t0, instr1
    lw   a0, 0(t0)
    call extract_fields          # R-type (no imm printed)

    la   t0, instr2
    lw   a0, 0(t0)
    call extract_fields          # I-type: expect imm = -20

    la   t0, instr3
    lw   a0, 0(t0)
    call extract_fields          # S-type: expect imm = 12

    la   t0, instr4
    lw   a0, 0(t0)
    call extract_fields          # B-type: expect imm = 8

    la   t0, instr5
    lw   a0, 0(t0)
    call extract_fields          # U-type: expect imm = 0x10 (16)

    la   t0, instr6
    lw   a0, 0(t0)
    call extract_fields          # J-type: expect imm = 32

    lw   ra, 12(sp)
    addi sp, sp, 16

    li   a0, 10
    ecall
