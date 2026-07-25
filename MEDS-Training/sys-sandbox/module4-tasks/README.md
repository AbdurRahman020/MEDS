# SystemVerilog Tasks — MEDS Lab Module 4

Solutions to MEDS Lab's Module 4: SystemVerilog for Digital Design (Summer Training Programme 2026, Cohort 4).

Each task is self-contained in its own folder, built and simulated with [Verilator](https://www.veripool.org/verilator/) and viewed in [GTKWave](https://gtkwave.sourceforge.net/).

## Task Index

| Folder | Task | Topic |
|---|---|---|
| `t1_gates_demo` | Task 1 | Hello Gate — AND/OR/XOR demo |
| `t2_self_check_tb` | Task 2 | Self-checking testbench pattern |
| `t3_adder` | Task 3 | Half adder (assign vs always_comb) + full adder |
| `t4_nor_gates` | Task 4 | NOR-only realization |
| `t5_4bit_parity` | Task 5 | 4-bit parity generator |
| `t6_decoder_3x8` | Task 6 | 3-to-8 decoder from 2-to-4 decoders |
| `t7_lead_zero_counter` | Task 7 | 32-bit leading zero counter |
| `t8_min_term` | Task 8 | Σm(1,2,3,6,7) via 4x1 MUX + majority via 2:1 MUXes |
| `t9_barrel_shifter` | Task 9 | Single-position shifter + 4-bit barrel shifter |
| `t10_up_down_counter` | Task 10 | 4-bit up-down counter, async reset |
| `t11_synchronizer` | Task 11 | 2-flop reset synchroniser |
| `t12_freq_divider` | Task 12 | Modulo-10 frequency divider (T flip-flops) |
| `t13_stop_watch` | Task 13 | 4-digit stopwatch (M:SS:D) |
| `t14_custom_counter_fsm` | Task 14 | Custom 0-1-3-4-7 sequence counter (T flip-flop excitation) |
| `t15_mimo_fsm` | Task 15 | Multi-input/multi-output Moore FSM |
| `t16_serial_divider` | Task 16 | Mealy FSM — serial input divisible by 3 |
| `t17_fifo` | Task 17 | Parameterized synchronous FIFO controller |
| `t18_fifo_flags` | Task 18 | FIFO + almost_full / almost_empty flags |

## Folder Structure (per task)

```
t<N>_<name>/
├── docs/           # diagram for the task — flowchart, block diagram,
│                   # circuit schematic, or state diagram (.drawio),
│                   # whichever fits the task
├── scripts/
│   ├── setup_env.sh    # checks verilator/gtkwave/VS Code + draw.io ext
│   └── simulate.sh     # builds with verilator, runs sim, moves dump.vcd
├── sim/
│   └── tb_<name>.sv    # testbench
├── src/
│   └── <name>.sv       # synthesizable RTL
├── Makefile
└── README.md
```

## Usage

From inside any task folder:

```bash
make setup     # check verilator/gtkwave/VS Code draw.io ext are installed
make run       # (or just `make`) build with Verilator and run the simulation
make wave      # open output/dump.vcd in GTKWave
make diagram   # open the docs/*.drawio diagram in VS Code
make clean     # remove the output/ directory
make help      # list all available targets
```

## Requirements

- [Verilator](https://www.veripool.org/verilator/)
- [GTKWave](https://gtkwave.sourceforge.net/)
- VS Code with the [draw.io integration](https://marketplace.visualstudio.com/items?itemName=hediet.vscode-drawio) extension (for viewing/editing diagrams)

## Reference

Built against MEDS Lab's Module 4: SystemVerilog for Digital Design curriculum (data types, combinational/sequential design, decoders/encoders, muxes/shifters, flip-flops & reset, counters, FSMs, and the synchronous FIFO controller integration task).
