/*
 * DECODER_H
 * ---------
 * Core data structures and function declarations for the RISC-V RV32I
 * instruction decoder.
 *
 * This module defines:
 *   - Instruction type classification (R, I, S, B, U, J)
 *   - Decoded instruction structure holding all parsed fields
 *   - Interface for decoding and printing instructions
 */

#ifndef DECODER_H
#define DECODER_H

#include "common.h"

// instruction type classification
typedef enum {

    TYPE_R,
    TYPE_I,
    TYPE_S,
    TYPE_B,
    TYPE_U,
    TYPE_J,
    TYPE_UNKNOWN

} instr_type_t;

// decoded instruction representation
typedef struct {

    // original 32-bit machine instruction
    uint32_t raw;

    // program counter / instruction address
    uint32_t pc;

    // decoded instruction type
    instr_type_t type;

    // raw instruction fields
    uint8_t opcode;
    uint8_t rd;
    uint8_t rs1;
    uint8_t rs2;
    uint8_t funct3;
    uint8_t funct7;

    // sign-extended immediate value (if applicable)
    int32_t imm;

    // human-readable instruction name (e.g., "add", "lw")
    char mnemonic[16];

} decoded_instr_t;

// decode a raw 32-bit instruction into a structured format
void decode_instruction(uint32_t raw, uint32_t pc, decoded_instr_t *out);

// print a decoded instruction in assembly format
void print_instruction(const decoded_instr_t *instr);

#endif
