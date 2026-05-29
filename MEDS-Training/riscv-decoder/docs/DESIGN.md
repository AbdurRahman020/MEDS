# DESIGN.md — RISC-V Decoder Design Notes

This document explains how the decoder is structured and why certain decisions were made.

---

## How a RISC-V Instruction Works

Every RV32I instruction is exactly **32 bits wide**. Depending on the instruction type, those 32 bits are divided into fields differently — but the **lowest 7 bits (opcode)** always tell you what kind of instruction it is.

```
R-type:  [ funct7 | rs2 | rs1 | funct3 | rd  | opcode ]
          31    25 24 20 19 15 14    12 11  7 6      0

I-type:  [    imm[11:0]  | rs1 | funct3 | rd  | opcode ]
J-type:  [ imm (scrambled 20 bits)      | rd  | opcode ]
```

The decoder's job is to **unpack these fields** from the raw 32-bit value.

---

## Project Structure at a Glance

```
src/main.c      → reads the hex file, drives the decode loop
src/memory.c    → loads hex file into an array of uint32_t
src/decoder.c   → unpacks fields, identifies instruction, formats output
include/        → shared types and constants used across all files
```

---

## Key Design Decisions

### 1. EXTRACT_BITS macro (`common.h`)

Instead of writing raw bit shifts everywhere, one macro handles all field extraction:

```c
#define EXTRACT_BITS(val, hi, lo) (((val) >> (lo)) & ((1u << ((hi) - (lo) + 1)) - 1))
```

For example, extracting the opcode (bits 6–0):
```c
EXTRACT_BITS(raw, 6, 0)   // shifts right 0, masks lowest 7 bits
```

This keeps the decode logic readable and less error-prone.

---

### 2. Sign Extension (`common.h`)

Immediates in RISC-V are **signed** — a 12-bit immediate like `0xFFF` means `-1`, not `4095`.  
To convert it to a proper 32-bit signed integer:

```c
#define SIGN_EXTEND(val, bits) ((int32_t)(((val) << (32 - (bits))) >> (32 - (bits))))
```

This shifts the value up so its sign bit reaches bit 31, then arithmetic-shifts it back down — filling the upper bits with the sign.

---

### 3. Immediate Extraction per Type

Each instruction type scatters its immediate bits differently. Separate static functions handle each case:

| Function   | Type   | Why it's different                                   |
|------------|--------|------------------------------------------------------|
| `imm_i()`  | I      | Simple — bits 31:20                                  |
| `imm_s()`  | S      | Split across bits 31:25 and 11:7                     |
| `imm_b()`  | B      | Scrambled — bit 12, 11, 10:5, 4:1 in different slots |
| `imm_u()`  | U      | Upper 20 bits, lower 12 are always zero              |
| `imm_j()`  | J      | Most scrambled — 4 separate chunks reassembled       |

B and J types are scrambled by design in the RISC-V spec to minimize hardware mux complexity.

---

### 4. Decode Flow (`decoder.c`)

```
decode_instruction()
    │
    ├── extract opcode, rd, rs1, rs2, funct3, funct7
    │
    └── switch(opcode)
            ├── OPCODE_R       → decode_r()       (funct7 + funct3)
            ├── OPCODE_I_ARITH → decode_i_arith()  (funct3)
            ├── OPCODE_I_LOAD  → decode_i_load()   (funct3)
            ├── OPCODE_I_JALR  → "jalr"
            ├── OPCODE_S       → decode_s()        (funct3)
            ├── OPCODE_B       → decode_b()        (funct3)
            ├── OPCODE_U_LUI   → "lui"
            ├── OPCODE_U_AUIPC → "auipc"
            ├── OPCODE_J_JAL   → "jal"
            └── default        → TYPE_UNKNOWN
```

Within R-type, `funct7` is needed on top of `funct3` — for example, ADD and SUB share the same `funct3 = 0x0` but differ in `funct7` (0x00 vs 0x20). Same for SRL vs SRA.

---

### 5. `decoded_instr_t` Struct (`decoder.h`)

All decoded fields are stored in one struct:

```c
typedef struct {
    uint32_t     raw;         // original 32-bit instruction
    uint32_t     pc;          // address (index × 4)
    instr_type_t type;        // R / I / S / B / U / J / UNKNOWN
    uint8_t      rd, rs1, rs2, funct3, funct7;
    int32_t      imm;         // sign-extended immediate
    char         mnemonic[16];
} decoded_instr_t;
```

Keeping everything in one place makes it easy to pass around and print.

---

### 6. Memory Model (`memory.c`)

The hex file is loaded line by line into a flat array of `uint32_t`. Lines starting with `#` are treated as comments and skipped. The struct holds the array and a count:

```c
typedef struct {
    uint32_t instructions[MAX_INSTRUCTIONS];
    uint32_t count;
} memory_t;
```

This is allocated on the **heap** in `main.c` (`malloc`) to avoid a large stack frame. It is `free()`d before exit — verified clean by Valgrind.

---
