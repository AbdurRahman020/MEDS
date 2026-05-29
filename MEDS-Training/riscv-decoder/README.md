# riscv-decoder — MEDS Module 2 Grand Assignment

A shell-based command-line tool written in C that reads a `.hex` file of RISC-V machine code,
decodes each 32-bit instruction, and prints the human-readable assembly output.

Built as the Module 2 capstone for MEDS Lab - UET Lahore.

---

## What it does

- Decodes all **RV32I** instruction types: R, I, S, B, U, J
- Covers **37 instructions**: ADD, SUB, AND, OR, XOR, SLL, SRL, SRA, SLT, SLTU, ADDI, ANDI, ORI, XORI, SLTI, SLTIU, SLLI, SRLI, SRAI, LB, LH, LW, LBU, LHU, SB, SH, SW, BEQ, BNE, BLT, BGE, BLTU, BGEU, LUI, AUIPC, JAL, JALR
- Properly **sign-extends** all immediates
- Prints `UNKNOWN` for unrecognized encodings — no crashes
- Heap-allocates instruction memory — verified zero leaks via Valgrind
- Reports total valid vs unknown instruction counts at the end

---

## Installation

No installation needed. Clone the repo and navigate to the project folder:

```bash
git clone https://github.com/AbdurRahman020/MEDS
cd MEDS/MEDS-Training/riscv-decoder
```

Make sure the following tools are available on your system:

| Tool      | Purpose                        |
|-----------|--------------------------------|
| `gcc`     | Compile C source files         |
| `make`    | Run build targets              |
| `valgrind`| Memory leak checking (optional)|
| `gdb`     | Debugging (optional)           |

---

## Build

All commands are run from the project root (`riscv-decoder/`):

```bash
make          # build release binary → bin/riscv-decoder
make debug    # build with -g -O0 flags for use with GDB
make clean    # delete the bin/ directory and all compiled output
```

---

## Usage

### Decode a single hex file

```bash
make run FILE=test/programs/<hex_file>
```

Or directly:

```bash
./bin/riscv-decoder <hex_file>
```

### Run decoder on all test files

```bash
make test
```

This runs the decoder against all 4 hex files in `test/programs/`:
- `r_type.hex` — R-type instructions
- `i_type.hex` — I-type arithmetic and load instructions
- `branch.hex` — B-type branch instructions
- `mixed.hex`  — Mixed instruction program

### Check for memory leaks

```bash
make valgrind
```

Runs Valgrind with `--leak-check=full` on `mixed.hex`. Exits with error if any leaks are found.

### Run unit tests

```bash
gcc -Iinclude test/test_decoder.c src/decoder.c -o bin/test_decoder
./bin/test_decoder
```

---


## Hex File Format

Each `.hex` file contains one 32-bit instruction per line in plain hexadecimal (no `0x` prefix).
Lines starting with `#` are treated as comments and skipped.

Example:
```
# addi x2, x0, 5
00500113
# add x1, x2, x3
003100B3
```

---

## Sample Output (verified)

**Decoding `mixed.hex`:**
```bash
$ ./bin/riscv-decoder test/programs/mixed.hex
```

```
RISC-V RV32I Instruction Decoder
================================
Loaded 8 instructions from test/programs/mixed.hex

Addr         Hex          Assembly
---------- ---------- --------------------
0x00000000  00500113  addi x2, x0, 5
0x00000004  00A00193  addi x3, x0, 10
0x00000008  003100B3  add x1, x2, x3
0x0000000C  40310133  sub x2, x2, x3
0x00000010  0020A023  sw x2, 0(x1)
0x00000014  0000A103  lw x2, 0(x1)
0x00000018  FE209CE3  bne x1, x2, -8
0x0000001C  004000EF  jal x1, 4

Decoded 8 instructions (8 valid, 0 unknown)
```

**Unit test output:**
```
=== RISC-V Decoder Unit Tests ===

[R-type]
  [PASS] ADD mnemonic
  [PASS] ADD type

[Unknown / edge cases]
  [PASS] DEADBEEF is UNKNOWN
  [PASS] All-zero is valid (addi)

=================================
Results: 62 / 62 passed
```

---

## Project Structure

```
riscv-decoder/
├── README.md
├── Makefile
├── .gitignore
├── include/
│   ├── common.h          # Shared macros, types, constants, opcodes
│   ├── decoder.h         # decoded_instr_t struct, instr_type_t enum, prototypes
│   └── memory.h          # memory_t struct, load and read prototypes
├── src/
│   ├── main.c            # Entry point — loads hex file, drives decode loop, prints summary
│   ├── decoder.c         # Field extraction, mnemonic decode, assembly formatter
│   └── memory.c          # Hex file loader, bounds-checked memory read
├── test/
│   ├── test_decoder.c    # 62 unit tests covering all instruction types and edge cases
│   └── programs/
│       ├── r_type.hex    # R-type test cases (ADD, SUB, AND, OR, XOR, SLL, SRL, SRA, SLT, SLTU)
│       ├── i_type.hex    # I-type arithmetic + load + JALR test cases
│       ├── branch.hex    # B-type branch test cases (BEQ, BNE, BLT, BGE, BLTU, BGEU)
│       └── mixed.hex     # Mixed program — matches expected output from assignment spec
└── docs/
    └── DESIGN.md         # Decoder architecture and key design decisions
```
