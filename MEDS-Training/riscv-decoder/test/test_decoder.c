/*
 * RISC-V Decoder Unit Tests
 * -------------------------
 * This file contains unit tests for the instruction decoder module.
 * Each test verifies that a raw 32-bit RISC-V instruction is decoded
 * correctly into its corresponding instruction type, mnemonic,
 * registers, and immediate values.
 *
 * The tests are grouped by instruction format:
 *   - R-type
 *   - I-type
 *   - S-type
 *   - B-type
 *   - U-type
 *   - J-type
 *   - Unknown / edge cases
 *
 * A small custom test framework is used to track passed and failed tests.
 */

#include <stdio.h>
#include <string.h>
#include "../include/decoder.h"

// simple test framework

static int tests_run    = 0;
static int tests_passed = 0;

#define TEST(desc, cond)                           \
    do {                                           \
        tests_run++;                               \
        if (cond) {                                \
            printf("  [PASS] %s\n", desc);         \
            tests_passed++;                        \
        } else {                                   \
            printf("  [FAIL] %s\n", desc);         \
        }                                          \
    } while (0)

// helper function: decodes a raw instruction and returns the decoded structure

static decoded_instr_t decode(uint32_t raw) {
    decoded_instr_t d;
    decode_instruction(raw, 0x00, &d);
    return d;
}

// R-type instruction tests

static void test_r_type(void) {
    printf("\n[R-type]\n");

    decoded_instr_t d;

    // add x0, x3, x3
    d = decode(0x00318033);
    TEST("ADD mnemonic",   strcmp(d.mnemonic, "add")  == 0);
    TEST("ADD type",       d.type == TYPE_R);
    TEST("ADD rs2",        d.rs2  == 3);
    TEST("ADD rs1",        d.rs1  == 3);

    // sub
    d = decode(0x40318033);
    TEST("SUB mnemonic",   strcmp(d.mnemonic, "sub")  == 0);

    // and x4, x5, x6
    d = decode(0x0062F233);
    TEST("AND mnemonic",   strcmp(d.mnemonic, "and")  == 0);
    TEST("AND rd",         d.rd   == 4);

    // or
    d = decode(0x0062E233);
    TEST("OR  mnemonic",   strcmp(d.mnemonic, "or")   == 0);

    // xor
    d = decode(0x0062C233);
    TEST("XOR mnemonic",   strcmp(d.mnemonic, "xor")  == 0);

    // sll x7, x8, x9
    d = decode(0x009413B3);
    TEST("SLL mnemonic",   strcmp(d.mnemonic, "sll")  == 0);

    // srl
    d = decode(0x009453B3);
    TEST("SRL mnemonic",   strcmp(d.mnemonic, "srl")  == 0);

    // sra
    d = decode(0x409453B3);
    TEST("SRA mnemonic",   strcmp(d.mnemonic, "sra")  == 0);

    // slt x10, x11, x12
    d = decode(0x00C5A533);
    TEST("SLT mnemonic",   strcmp(d.mnemonic, "slt")  == 0);

    // sltu
    d = decode(0x00C5B533);
    TEST("SLTU mnemonic",  strcmp(d.mnemonic, "sltu") == 0);
}

// I-type arithmetic instruction tests

static void test_i_type(void) {
    printf("\n[I-type arithmetic]\n");

    decoded_instr_t d;

    // addi x2, x0, 5
    d = decode(0x00500113);
    TEST("ADDI mnemonic",  strcmp(d.mnemonic, "addi") == 0);
    TEST("ADDI type",      d.type == TYPE_I);
    TEST("ADDI rd",        d.rd   == 2);
    TEST("ADDI imm = 5",   d.imm  == 5);

    // addi x3, x0, -1
    d = decode(0xFFF00193);
    TEST("ADDI imm sign-extended (-1)", d.imm == -1);

    // andi x4, x3, 15
    d = decode(0x00F1F213);
    TEST("ANDI mnemonic",  strcmp(d.mnemonic, "andi") == 0);
    TEST("ANDI imm = 15",  d.imm  == 15);

    // slli x9, x2, 3
    d = decode(0x00311493);
    TEST("SLLI mnemonic",  strcmp(d.mnemonic, "slli") == 0);

    // srli x10, x2, 3
    d = decode(0x00315513);
    TEST("SRLI mnemonic",  strcmp(d.mnemonic, "srli") == 0);

    // srai x11, x2, 3
    d = decode(0x40315593);
    TEST("SRAI mnemonic",  strcmp(d.mnemonic, "srai") == 0);
}

// I-type load instruction tests

static void test_i_load(void) {
    printf("\n[I-type load]\n");

    decoded_instr_t d;

    // lb x12, 0(x1)
    d = decode(0x00008603);
    TEST("LB  mnemonic",   strcmp(d.mnemonic, "lb")  == 0);
    TEST("LB  imm = 0",    d.imm == 0);
    TEST("LB  rs1 = x1",   d.rs1 == 1);

    // lh x13, 2(x1)
    d = decode(0x00209683);
    TEST("LH  mnemonic",   strcmp(d.mnemonic, "lh")  == 0);
    TEST("LH  imm = 2",    d.imm == 2);

    // lw x14, 4(x1)
    d = decode(0x0040A703);
    TEST("LW  mnemonic",   strcmp(d.mnemonic, "lw")  == 0);
    TEST("LW  imm = 4",    d.imm == 4);

    // lbu x15, 0(x1)
    d = decode(0x0000C783);
    TEST("LBU mnemonic",   strcmp(d.mnemonic, "lbu") == 0);

    // lhu x16, 2(x1)
    d = decode(0x0020D803);
    TEST("LHU mnemonic",   strcmp(d.mnemonic, "lhu") == 0);
}

// S-type instruction tests

static void test_s_type(void) {
    printf("\n[S-type]\n");

    decoded_instr_t d;

    // sw x2, 0(x1)
    d = decode(0x0020A023);
    TEST("SW  mnemonic",   strcmp(d.mnemonic, "sw")  == 0);
    TEST("SW  type",       d.type == TYPE_S);
    TEST("SW  imm = 0",    d.imm  == 0);
    TEST("SW  rs1 = x1",   d.rs1  == 1);
    TEST("SW  rs2 = x2",   d.rs2  == 2);

    // sb
    d = decode(0x00208023);
    TEST("SB  mnemonic",   strcmp(d.mnemonic, "sb")  == 0);

    // sh
    d = decode(0x00209023);
    TEST("SH  mnemonic",   strcmp(d.mnemonic, "sh")  == 0);
}

// B-type instruction tests

static void test_b_type(void) {
    printf("\n[B-type]\n");

    decoded_instr_t d;

    // beq x1, x2, 8
    d = decode(0x00208463);
    TEST("BEQ mnemonic",   strcmp(d.mnemonic, "beq")  == 0);
    TEST("BEQ type",       d.type == TYPE_B);
    TEST("BEQ imm = 8",    d.imm  == 8);

    // bne
    d = decode(0x00209463);
    TEST("BNE mnemonic",   strcmp(d.mnemonic, "bne")  == 0);

    // bne x1, x2, -8
    d = decode(0xFE209CE3);
    TEST("BNE imm = -8",   d.imm  == -8);

    // blt
    d = decode(0x0020C463);
    TEST("BLT mnemonic",   strcmp(d.mnemonic, "blt")  == 0);

    // bge
    d = decode(0x0020D463);
    TEST("BGE mnemonic",   strcmp(d.mnemonic, "bge")  == 0);

    // bltu
    d = decode(0x0020E463);
    TEST("BLTU mnemonic",  strcmp(d.mnemonic, "bltu") == 0);

    // bgeu
    d = decode(0x0020F463);
    TEST("BGEU mnemonic",  strcmp(d.mnemonic, "bgeu") == 0);
}

// U-type and J-type instruction tests

static void test_u_j_type(void) {
    printf("\n[U-type / J-type]\n");

    decoded_instr_t d;

    // lui x5, 1
    d = decode(0x000012B7);
    TEST("LUI   mnemonic", strcmp(d.mnemonic, "lui")   == 0);
    TEST("LUI   type",     d.type == TYPE_U);
    TEST("LUI   imm",      (uint32_t)d.imm == 0x00001000);

    // auipc x5, 1
    d = decode(0x00001297);
    TEST("AUIPC mnemonic", strcmp(d.mnemonic, "auipc") == 0);

    // jal x1, 4
    d = decode(0x004000EF);
    TEST("JAL   mnemonic", strcmp(d.mnemonic, "jal")   == 0);
    TEST("JAL   type",     d.type == TYPE_J);
    TEST("JAL   imm = 4",  d.imm  == 4);

    // jalr x0, 0(x2)
    d = decode(0x00010067);
    TEST("JALR  mnemonic", strcmp(d.mnemonic, "jalr")  == 0);
    TEST("JALR  type",     d.type == TYPE_I);
}

// unknown instructions and edge case tests

static void test_unknown(void) {
    printf("\n[Unknown / edge cases]\n");

    decoded_instr_t d;

    // Invalid instruction
    d = decode(0xDEADBEEF);
    TEST("DEADBEEF is UNKNOWN",      d.type == TYPE_UNKNOWN);
    TEST("DEADBEEF mnemonic",        strcmp(d.mnemonic, "UNKNOWN") == 0);

    // addi x0, x0, 0 (acts as NOP)
    d = decode(0x00000000);
    TEST("All-zero is valid (addi)", d.type != TYPE_UNKNOWN);
}

// program entry point

int main(void) {
    printf("=== RISC-V Decoder Unit Tests ===");

    test_r_type();
    test_i_type();
    test_i_load();
    test_s_type();
    test_b_type();
    test_u_j_type();
    test_unknown();

    printf("\n=================================\n");
    printf("Results: %d / %d passed\n", tests_passed, tests_run);

    return (tests_passed == tests_run) ? 0 : 1;
}
