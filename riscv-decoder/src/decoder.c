/*
 * RISC-V RV32I Instruction Decoder
 * --------------------------------
 * This file implements the instruction decoding logic for a subset
 * of the RISC-V RV32I ISA.
 *
 * Responsibilities:
 *   - Extract instruction fields from raw 32-bit machine code
 *   - Decode instruction type and mnemonic
 *   - Extract and sign-extend immediates
 *   - Store decoded information in a structured format
 *   - Print human-readable assembly instructions
 *
 * Supported instruction formats:
 *   - R-type
 *   - I-type
 *   - S-type
 *   - B-type
 *   - U-type
 *   - J-type
 */

#include "decoder.h"
#include <string.h>
#include <stdio.h>

// ------------------------------
// immediate extraction helpers
// ------------------------------

// extract I-type immediate from bits [31:20]
static int32_t imm_i(uint32_t raw) {
    return SIGN_EXTEND(EXTRACT_BITS(raw, 31, 20), 12);
}

// extract S-type immediate
//   - imm[11:5] = bits [31:25]
//   - imm[4:0]  = bits [11:7]
static int32_t imm_s(uint32_t raw) {

    uint32_t hi = EXTRACT_BITS(raw, 31, 25);
    uint32_t lo = EXTRACT_BITS(raw, 11,  7);

    return SIGN_EXTEND((hi << 5) | lo, 12);
}

// extract B-type branch immediate: immediate bits are scattered across the instruction
static int32_t imm_b(uint32_t raw) {

    uint32_t b12   = EXTRACT_BITS(raw, 31, 31);
    uint32_t b11   = EXTRACT_BITS(raw,  7,  7);
    uint32_t b10_5 = EXTRACT_BITS(raw, 30, 25);
    uint32_t b4_1  = EXTRACT_BITS(raw, 11,  8);

    uint32_t imm =
        (b12   << 12) |
        (b11   << 11) |
        (b10_5 << 5)  |
        (b4_1  << 1);

    return SIGN_EXTEND(imm, 13);
}

// extract U-type immediate: lower 12 bits are always zero
static int32_t imm_u(uint32_t raw) {
    return (int32_t)(raw & 0xFFFFF000);
}

// extract J-type immediate: imm[20|10:1|11|19:12]
static int32_t imm_j(uint32_t raw) {

    uint32_t b20    = EXTRACT_BITS(raw, 31, 31);
    uint32_t b19_12 = EXTRACT_BITS(raw, 19, 12);
    uint32_t b11    = EXTRACT_BITS(raw, 20, 20);
    uint32_t b10_1  = EXTRACT_BITS(raw, 30, 21);

    uint32_t imm =
        (b20    << 20) |
        (b19_12 << 12) |
        (b11    << 11) |
        (b10_1  << 1);

    return SIGN_EXTEND(imm, 21);
}

// ---------------------------
// R-type instruction decode
// ---------------------------

static void decode_r(decoded_instr_t *d) {

    // funct3 + funct7 determine the operation
    switch (d->funct3) {

        case 0x0:
            if (d->funct7 == 0x00)
                strncpy(d->mnemonic, "add", 15);
            else if (d->funct7 == 0x20)
                strncpy(d->mnemonic, "sub", 15);
            break;

        case 0x1:
            strncpy(d->mnemonic, "sll", 15);
            break;

        case 0x2:
            strncpy(d->mnemonic, "slt", 15);
            break;

        case 0x3:
            strncpy(d->mnemonic, "sltu", 15);
            break;

        case 0x4:
            strncpy(d->mnemonic, "xor", 15);
            break;

        case 0x5:
            if (d->funct7 == 0x00)
                strncpy(d->mnemonic, "srl", 15);
            else if (d->funct7 == 0x20)
                strncpy(d->mnemonic, "sra", 15);
            break;

        case 0x6:
            strncpy(d->mnemonic, "or", 15);
            break;

        case 0x7:
            strncpy(d->mnemonic, "and", 15);
            break;

        default:
            strncpy(d->mnemonic, "UNKNOWN", 15);
            d->type = TYPE_UNKNOWN;
    }
}

// --------------------------
// I-type arithmetic decode
// --------------------------

static void decode_i_arith(decoded_instr_t *d) {

    switch (d->funct3) {

        case 0x0:
            strncpy(d->mnemonic, "addi", 15);
            break;

        case 0x1:
            strncpy(d->mnemonic, "slli", 15);
            break;

        case 0x2:
            strncpy(d->mnemonic, "slti", 15);
            break;

        case 0x3:
            strncpy(d->mnemonic, "sltiu", 15);
            break;

        case 0x4:
            strncpy(d->mnemonic, "xori", 15);
            break;

        case 0x5:
            // funct7 distinguishes SRLI vs SRAI
            if (d->funct7 == 0x00)
                strncpy(d->mnemonic, "srli", 15);
            else
                strncpy(d->mnemonic, "srai", 15);
            break;

        case 0x6:
            strncpy(d->mnemonic, "ori", 15);
            break;

        case 0x7:
            strncpy(d->mnemonic, "andi", 15);
            break;

        default:
            strncpy(d->mnemonic, "UNKNOWN", 15);
            d->type = TYPE_UNKNOWN;
    }
}

// --------------------
// I-type load decode
// --------------------

static void decode_i_load(decoded_instr_t *d) {

    switch (d->funct3) {

        case 0x0:
            strncpy(d->mnemonic, "lb", 15);
            break;

        case 0x1:
            strncpy(d->mnemonic, "lh", 15);
            break;

        case 0x2:
            strncpy(d->mnemonic, "lw", 15);
            break;

        case 0x4:
            strncpy(d->mnemonic, "lbu", 15);
            break;

        case 0x5:
            strncpy(d->mnemonic, "lhu", 15);
            break;

        default:
            strncpy(d->mnemonic, "UNKNOWN", 15);
            d->type = TYPE_UNKNOWN;
    }
}

// ---------------
// S-type decode
// ---------------

static void decode_s(decoded_instr_t *d) {

    switch (d->funct3) {

        case 0x0:
            strncpy(d->mnemonic, "sb", 15);
            break;

        case 0x1:
            strncpy(d->mnemonic, "sh", 15);
            break;

        case 0x2:
            strncpy(d->mnemonic, "sw", 15);
            break;

        default:
            strncpy(d->mnemonic, "UNKNOWN", 15);
            d->type = TYPE_UNKNOWN;
    }
}

// ----------------
// B-type decode
// ----------------

static void decode_b(decoded_instr_t *d) {

    switch (d->funct3) {

        case 0x0:
            strncpy(d->mnemonic, "beq", 15);
            break;

        case 0x1:
            strncpy(d->mnemonic, "bne", 15);
            break;

        case 0x4:
            strncpy(d->mnemonic, "blt", 15);
            break;

        case 0x5:
            strncpy(d->mnemonic, "bge", 15);
            break;

        case 0x6:
            strncpy(d->mnemonic, "bltu", 15);
            break;

        case 0x7:
            strncpy(d->mnemonic, "bgeu", 15);
            break;

        default:
            strncpy(d->mnemonic, "UNKNOWN", 15);
            d->type = TYPE_UNKNOWN;
    }
}

// --------------------------
// main instruction decoder
// --------------------------

void decode_instruction(uint32_t raw, uint32_t pc, decoded_instr_t *out) {

    // Clear structure before filling fields
    memset(out, 0, sizeof(decoded_instr_t));

    // extract common instruction fields
    out->raw    = raw;
    out->pc     = pc;
    out->opcode = EXTRACT_BITS(raw, 6, 0);
    out->rd     = EXTRACT_BITS(raw, 11, 7);
    out->funct3 = EXTRACT_BITS(raw, 14, 12);
    out->rs1    = EXTRACT_BITS(raw, 19, 15);
    out->rs2    = EXTRACT_BITS(raw, 24, 20);
    out->funct7 = EXTRACT_BITS(raw, 31, 25);

    // decode instruction based on opcode
    switch (out->opcode) {

        case OPCODE_R:
            out->type = TYPE_R;
            decode_r(out);
            break;

        case OPCODE_I_ARITH:
            out->type = TYPE_I;
            out->imm  = imm_i(raw);
            decode_i_arith(out);
            break;

        case OPCODE_I_LOAD:
            out->type = TYPE_I;
            out->imm  = imm_i(raw);
            decode_i_load(out);
            break;

        case OPCODE_I_JALR:
            out->type = TYPE_I;
            out->imm  = imm_i(raw);
            strncpy(out->mnemonic, "jalr", 15);
            break;

        case OPCODE_S:
            out->type = TYPE_S;
            out->imm  = imm_s(raw);
            decode_s(out);
            break;

        case OPCODE_B:
            out->type = TYPE_B;
            out->imm  = imm_b(raw);
            decode_b(out);
            break;

        case OPCODE_U_LUI:
            out->type = TYPE_U;
            out->imm  = imm_u(raw);
            strncpy(out->mnemonic, "lui", 15);
            break;

        case OPCODE_U_AUIPC:
            out->type = TYPE_U;
            out->imm  = imm_u(raw);
            strncpy(out->mnemonic, "auipc", 15);
            break;

        case OPCODE_J_JAL:
            out->type = TYPE_J;
            out->imm  = imm_j(raw);
            strncpy(out->mnemonic, "jal", 15);
            break;

        default:
            out->type = TYPE_UNKNOWN;
            strncpy(out->mnemonic, "UNKNOWN", 15);
            break;
    }
}

// pretty printer: converts decoded instruction into assembly-style output
void print_instruction(const decoded_instr_t *d) {

    // print unknown instructions directly
    if (d->type == TYPE_UNKNOWN) {
        printf("0x%08X  %08X  %s\n",
               d->pc,
               d->raw,
               d->mnemonic);
        return;
    }

    char assembly[48];

    switch (d->type) {

        case TYPE_R:
            snprintf(assembly,
                     sizeof(assembly),
                     "%s x%d, x%d, x%d",
                     d->mnemonic,
                     d->rd,
                     d->rs1,
                     d->rs2);
            break;

        case TYPE_I:

            // loads and JALR use offset(base) format
            if (d->opcode == OPCODE_I_LOAD ||
                d->opcode == OPCODE_I_JALR)

                snprintf(assembly,
                         sizeof(assembly),
                         "%s x%d, %d(x%d)",
                         d->mnemonic,
                         d->rd,
                         d->imm,
                         d->rs1);

            else
                snprintf(assembly,
                         sizeof(assembly),
                         "%s x%d, x%d, %d",
                         d->mnemonic,
                         d->rd,
                         d->rs1,
                         d->imm);
            break;

        case TYPE_S:
            snprintf(assembly,
                     sizeof(assembly),
                     "%s x%d, %d(x%d)",
                     d->mnemonic,
                     d->rs2,
                     d->imm,
                     d->rs1);
            break;

        case TYPE_B:
            snprintf(assembly,
                     sizeof(assembly),
                     "%s x%d, x%d, %d",
                     d->mnemonic,
                     d->rs1,
                     d->rs2,
                     d->imm);
            break;

        case TYPE_U:

            // shift immediate back down for readability
            snprintf(assembly,
                     sizeof(assembly),
                     "%s x%d, 0x%X",
                     d->mnemonic,
                     d->rd,
                     (uint32_t)d->imm >> 12);
            break;

        case TYPE_J:
            snprintf(assembly,
                     sizeof(assembly),
                     "%s x%d, %d",
                     d->mnemonic,
                     d->rd,
                     d->imm);
            break;

        default:
            break;
    }

    // print formatted instruction
    printf("0x%08X  %08X  %s\n",
           d->pc,
           d->raw,
           assembly);
}
