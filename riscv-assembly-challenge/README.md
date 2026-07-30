# RISC-V Assembly Challenge

MEDS Lab • Module 3: RISC-V ISA

A three-part RISC-V assembly challenge covering array processing, recursion with memoization, and hand-encoding/decoding of the six base instruction formats (R, I, S, B, U, J).

## Repository Structure

```
riscv-assembly-challenge/
├── README.md               # This file
├── .gitignore
├── part1_array_ops.s       # Part 1: Array processing
├── part2_recursion.s       # Part 2: Recursive algorithm (memoized Fibonacci)
├── part3_encoding.s        # Part 3: Instruction encoder/decoder
├── screenshots/            # Venus screenshots showing output
└── docs/
    ├── ENCODING_WORKSHEET.md   # Hand-encoded instructions (worked by hand)
    ├── PRIVILEGED_SUMMARY.md   # Privileged spec self-study notes
    └── EXTENSION_SUMMARY.md    # RISC-V "V" (Vector) extension self-study notes
```

## Build / Run Instructions

All three `.s` files are written for the **Venus** RISC-V simulator (RARS-compatible syntax).

1. Open [Venus](https://venus.cs61c.org/) or a local RARS installation.
2. Load the desired file (`part1_array_ops.s`, `part2_recursion.s`, or `part3_encoding.s`).
3. Assemble and run. Each program prints its own labeled output and exits via `ecall 10`.
4. Step through with breakpoints to inspect registers/memory where noted in comments.

## Part 1 — Array Processing (`part1_array_ops.s`)

Defines a 12-element signed `.data` array (including negative values) and implements four functions, each following the calling convention `(a0 = array_ptr, a1 = size) → a0 = result`:

- `sum_array` — sum of all elements
- `find_min` — minimum signed value
- `find_max` — maximum signed value
- `count_negative` — count of negative elements

`main` calls each function in turn and prints results with labels (`Sum:`, `Min:`, `Max:`, `Negative count:`). All functions are leaf functions (t-registers only); `main` saves/restores `ra` since it makes calls.

## Part 2 — Recursive Algorithm (`part2_recursion.s`)

Implements **recursive Fibonacci with memoization**, using a `.data` cache array (`cache[0..20]`, pre-filled with `-1` to mark "not yet computed").

- `fib(n)` checks base cases (`n == 0`, `n == 1`), then checks the cache before recursing.
- Follows calling convention properly: `ra`, `s0` (holds `n`), and `s1` (holds `fib(n-1)` across the second recursive call) are saved/restored per stack frame.
- `main` prints `fib(10) = 55`, `fib(15) = 610`, `fib(20) = 6765`, with later calls reusing cache entries built up by earlier ones.

## Part 3 — Instruction Encoding (`part3_encoding.s`)

Complements the hand-encoding work in `docs/ENCODING_WORKSHEET.md` with a program that decodes the same 6 instructions (one per format) programmatically:

| Format | Instruction | Hex |
|---|---|---|
| R | `add x5, x6, x7` | `0x007302B3` |
| I | `addi x8, x9, -20` | `0xFEC48413` |
| S | `sw x10, 12(x11)` | `0x00A5A623` |
| B | `bne x12, x13, +8` | `0x00D61463` |
| U | `lui x14, 0x10` | `0x00010737` |
| J | `jal x15, +32` | `0x020007EF` |

For each instruction, `extract_fields` decodes `opcode`, `rd`, `funct3`, `rs1` using shift-and-mask (`andi`/`srli`), then `decode_immediate` branches on opcode to reconstruct the format-specific immediate (I/S/B/U/J), including sign-extension where required and the bit-scrambling reassembly needed for B-type and J-type immediates.

Expected decoded immediates: I → `-20`, S → `12`, B → `8`, U → `0x10` (16, raw/unsigned), J → `32`. R-type has no immediate and is skipped.

## Docs

- **`ENCODING_WORKSHEET.md`** — step-by-step hand-encoding of all 6 instructions above, worked out with the shift formula (`(field << shift) | ...`) rather than manual bit-grouping, since that method proved more reliable.
- **`PRIVILEGED_SUMMARY.md`** — self-study summary of the RISC-V Privileged Architecture spec: M/S/U privilege modes, key CSRs (`mstatus`, `mtvec`, `mepc`, `mcause`, `mtval`), and the trap handling flow (exceptions vs. interrupts).
- **`EXTENSION_SUMMARY.md`** — self-study summary of the RISC-V "V" (Vector) extension: `vsetvli`, VLEN/SEW/LMUL, and why scalable vector length matters for ML/DSP-style workloads.

## Verification

All outputs have been verified in Venus (see `screenshots/`), and the hand-encoded values in `ENCODING_WORKSHEET.md` were cross-checked against `part3_encoding.s`'s decoder output.
