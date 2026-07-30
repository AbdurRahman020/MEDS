/*
 * COMMON_H
 * --------
 * Shared definitions and utilities for the RISC-V RV32I decoder project.
 *
 * This header provides:
 *   - Standard library includes used across the project
 *   - Global constants (memory size, instruction limits)
 *   - Bit manipulation utilities for decoding instructions
 *   - RV32I opcode definitions
 */

#ifndef COMMON_H
#define COMMON_H

#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>

// memory configuration: maximum number of instructions supported in simulated memory
#define MAX_INSTRUCTIONS 1024

// extract bits from position [hi:lo] (inclusive)
#define EXTRACT_BITS(val, hi, lo) (((val) >> (lo)) & ((1u << ((hi) - (lo) + 1)) - 1))

// sign-extend a value with given bit-width
#define SIGN_EXTEND(val, bits) ((int32_t)(((val) << (32 - (bits))) >> (32 - (bits))))

// RV32I opcode definitions
#define OPCODE_R        0x33
#define OPCODE_I_ARITH  0x13
#define OPCODE_I_LOAD   0x03
#define OPCODE_I_JALR   0x67
#define OPCODE_S        0x23
#define OPCODE_B        0x63
#define OPCODE_U_LUI    0x37
#define OPCODE_U_AUIPC  0x17
#define OPCODE_J_JAL    0x6F

#endif
