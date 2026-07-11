#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>

// complete RISC-V RV32I CPU state model
typedef struct {
    uint32_t x[32];       // 32 general-purpose registers
    uint32_t pc;          // Program counter
    uint8_t *memory;      // Pointer to memory (allocated on heap)
    size_t mem_size;      // Memory size in bytes

    // statistics
    uint64_t instr_count; // Instructions executed
    uint64_t cycle_count; // Cycles simulated
} cpu_state_t;

// ABI register names
static const char *reg_abi_names[32] = {
    "zero", "ra",  "sp",  "gp",
    "tp",   "t0",  "t1",  "t2",
    "s0",   "s1",  "a0",  "a1",
    "a2",   "a3",  "a4",  "a5",
    "a6",   "a7",  "s2",  "s3",
    "s4",   "s5",  "s6",  "s7",
    "s8",   "s9",  "s10", "s11",
    "t3",   "t4",  "t5",  "t6"
};

// initialize CPU
void cpu_init(cpu_state_t *cpu, size_t mem_size) {
    memset(cpu->x, 0, sizeof(cpu->x));

    cpu->pc = 0x00000000;

    cpu->memory = calloc(mem_size, 1);
    cpu->mem_size = mem_size;

    cpu->instr_count = 0;
    cpu->cycle_count = 0;
}

// free allocated memory
void cpu_destroy(cpu_state_t *cpu) {
    free(cpu->memory);
    cpu->memory = NULL;
}

// write register (enforcing x0 = 0)
void reg_write(cpu_state_t *cpu, uint8_t rd, uint32_t value) {
    if (rd != 0 && rd < 32) {
        cpu->x[rd] = value;

        // debug print
        printf("WRITE: x%-2d (%-4s) = 0x%08X\n",
               rd,
               reg_abi_names[rd],
               value);
    }
}

// read register
uint32_t reg_read(const cpu_state_t *cpu, uint8_t rs) {
    if (rs < 32) {
        return cpu->x[rs];
    }

    return 0;
}

// dump all registers
void dump_registers(const cpu_state_t *cpu) {
    printf("\n==== RISC-V RV32I Register Dump ====\n");

    for (int i = 0; i < 32; i++) {
        printf("x%-2d (%-4s) = 0x%08X",
               i,
               reg_abi_names[i],
               cpu->x[i]);

        // print 2 registers per line
        if (i % 2 == 1)
            printf("\n");
        else
            printf("    ");
    }

    printf("\nPC           = 0x%08X\n", cpu->pc);
    printf("Instructions = %llu\n", (unsigned long long)cpu->instr_count);
    printf("Cycles       = %llu\n", (unsigned long long)cpu->cycle_count);
}

// example usage
int main() {
    cpu_state_t cpu;

    cpu_init(&cpu, 1024 * 64); // 64 KB memory

    // write values to registers
    reg_write(&cpu, 1, 0x12345678); // ra
    reg_write(&cpu, 2, 0x80000000); // sp
    reg_write(&cpu, 10, 42);        // a0

    // x0 should remain zero
    reg_write(&cpu, 0, 999);

    // Read back values
    printf("\nREAD BACK VALUES:\n");

    printf("x1  (ra) = 0x%08X\n", reg_read(&cpu, 1));
    printf("x2  (sp) = 0x%08X\n", reg_read(&cpu, 2));
    printf("x10 (a0) = 0x%08X\n", reg_read(&cpu, 10));

    // dump complete register state
    dump_registers(&cpu);

    cpu_destroy(&cpu);

    return 0;
}
