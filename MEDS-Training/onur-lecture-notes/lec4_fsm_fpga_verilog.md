# Lecture 4: FSMs, FPGAs & Verilog
**DDCA · Prof. Onur Mutlu · ETH Zürich · Spring 2025**

---

## Part 1 — FSM Design (Deep Dive)

### Traffic Light Walkthrough

This is the canonical FSM design example — worth knowing cold.

**Inputs:** TA, TB · **Outputs:** LA, LB (green=00, yellow=01, red=10)

| State | LA | LB | Next state |
|---|---|---|---|
| S0 | Green | Red | S0 if TA=1, else S1 |
| S1 | Yellow | Red | S2 |
| S2 | Red | Green | S2 if TB=1, else S3 |
| S3 | Red | Yellow | S0 |

State encoding: S0=00, S1=01, S2=10, S3=11

Transition table → Boolean expressions:
```
S'₁ = S₁ XOR S₀
S'₀ = (S̄₁·S̄₀·T̄A) + (S₁·S̄₀·T̄B)

LA1 = S₁      LB1 = S̄₁
LA0 = S̄₁·S₀   LB0 = S₁·S₀
```

### Moore vs. Mealy (Snail Example)

**Problem:** Output 1 when last 4 digits crawled are 1101.

- **Moore** needs 5 states — output lives inside the state circle
- **Mealy** needs only 4 states — output lives on transition arcs as `input/output`

Mealy saves states but the output can glitch mid-cycle since it reacts immediately to inputs. Moore is cleaner to reason about.

### FSM Design Procedure
1. Identify all states
2. Draw the transition diagram, starting from reset
3. Encode states
4. Fill the transition table
5. Derive Boolean expressions for S' and outputs
6. Implement

### State Encoding Options

| Encoding | Bits | Best for |
|---|---|---|
| Binary | log₂(N) | fewest flip-flops |
| One-hot | N | simplest next-state logic |
| Output encoded | varies | simplest output logic; Moore only |

---

## Part 2 — FPGAs

An FPGA is a piece of hardware you can reprogram in software. You configure its logic, wiring, and I/O to build any circuit you want.

```
CPU ←—————————————————→ ASIC
Flexible / Easy           Efficient
       GPU     FPGA
```

FPGAs are a sweet spot: way more efficient than a CPU for custom logic, but you don't need to tape out a chip.

### Inside an FPGA
Three main components: **Logic Blocks** (LUTs + flip-flops), **Switch Blocks** (configurable wiring between logic blocks), **I/O Blocks** (interface to the outside world).

A **K-input LUT** is just a MUX: the K inputs are the select lines, and the truth table values are stored in configuration memory. A 3-LUT can implement any 3-input Boolean function. Modern FPGAs use 6-LUTs.

### Design Flow
```
Write Verilog  →  Logic Synthesis  →  Placement & Routing  →  Bitstream  →  FPGA
   (you)                          (all automated by Xilinx Vivado)
```

---

## Part 3 — Verilog: Combinational Logic

### Module Basics
```verilog
module example (input a, b, c, output y);
  assign y = ~a & ~b & ~c | a & ~b & ~c | a & ~b & c;
endmodule
```

Two styles — **structural** (wire up gate instances) and **behavioral** (describe what it does). Most real designs mix both.

### Key Operators
```verilog
assign y1 = a & b;       // AND
assign y2 = a | b;       // OR
assign y3 = a ^ b;       // XOR
assign y4 = ~(a & b);    // NAND
assign y5 = &a;          // reduction AND (all bits of a)
assign y  = s ? d1 : d0; // MUX
```

### Buses, Slicing, Concatenation
```verilog
input [31:0] a;                    // always [MSB:LSB]
assign b = a[12:5];                // bit slicing
assign y = {a[2], a[1], a[0]};    // concatenation
assign x = {4{a[0]}};             // duplication
```

### Numbers
```
8'b0000_1001   4'hFA   12'd255
```
`X` = invalid/unknown · `Z` = floating/high-impedance

### Tri-State Buffer
```verilog
assign y = en ? a : 4'bz;  // floats when en=0
```
Used when multiple drivers share a bus.

### Parameterized Modules
```verilog
module mux2 #(parameter width = 8)
  (input [width-1:0] d0, d1, input s, output [width-1:0] y);
  assign y = s ? d1 : d0;
endmodule

mux2 #(12) i_mux (d0, d1, s, out);  // 12-bit version
```

### Module Instantiation
```verilog
small i_first (.A(A), .B(SEL), .Y(n1));   // always use named ports
small i_second (.A(n1), .B(C), .Y(Y));
```
Never use positional instantiation — it breaks the moment you reorder ports.

> Timing delays like `assign #5 z = ~a;` are simulation-only and cannot be synthesized.

---

## Part 4 — Verilog: Sequential Logic

### D Flip-Flop
```verilog
module flop (input clk, input [3:0] d, output reg [3:0] q);
  always @ (posedge clk)
    q <= d;   // "q gets d" — non-blocking
endmodule
```
Variables assigned inside `always` must be `reg`. Use `<=` (non-blocking) in sequential blocks.

### Reset
```verilog
// Asynchronous — resets immediately regardless of clock
always @ (posedge clk, negedge reset)
  if (reset == 0) q <= 0;
  else            q <= d;

// Synchronous — only resets on clock edge
always @ (posedge clk)
  if (reset == 0) q <= 0;
  else            q <= d;
```

### `always` for Combinational Logic
```verilog
always @ (*)          // * catches all RHS signals
  if (sel) y = a;
  else     y = b;
```

If you forget a branch → **unintentional latch** (Vivado will warn you). Always cover every case. Always have a `default` in `case` blocks.

```verilog
always @ (*)
  case (data)
    4'd0: segments = 7'b111_1110;
    4'd1: segments = 7'b011_0000;
    default: segments = 7'b000_0000;  // don't skip this
  endcase
```

### Blocking vs. Non-Blocking

| `<=` Non-blocking | `=` Blocking |
|---|---|
| All assigned at **end** of block — parallel | Each assigned **immediately** — sequential |
| Use in `always @(posedge clk)` | Use in `always @(*)` |

```verilog
always @ (posedge clk)   q <= d;      // sequential: non-blocking
assign y = a & b;                      // simple combinational: assign
always @ (*)   if (sel) y = a;         // complex combinational: blocking
               else     y = b;
```

---

## Part 5 — FSMs in Verilog

Three always blocks, one assign:

```verilog
module divideby3FSM (input clk, reset, output q);
  reg [1:0] state, nextstate;
  parameter S0=2'b00, S1=2'b01, S2=2'b10;

  // State register
  always @ (posedge clk, posedge reset)
    if (reset) state <= S0;
    else       state <= nextstate;

  // Next state logic
  always @ (*)
    case (state)
      S0: nextstate = S1;
      S1: nextstate = S2;
      S2: nextstate = S0;
      default: nextstate = S0;
    endcase

  // Output logic (Moore)
  assign q = (state == S0);
endmodule
```

Mealy output just references the input too:
```verilog
assign smile = (number & state == S3);
```

---

## Quick Reference

| | |
|---|---|
| Bus order | `[MSB:LSB]` always |
| Sequential | `<=` in `always @(posedge clk)` |
| Combinational | `=` in `always @(*)` or `assign` |
| Missing branch | → unintentional latch |
| Moore output | `assign q = (state == Sx)` |
| Mealy output | `assign q = (input & state == Sx)` |
| FPGA LUT | MUX implementing a truth table |
| FPGA flow | Verilog → Vivado → bitstream → chip |

---
*ETH Zürich DDCA Lecture 4a, 4b & 4c · Spring 2025*
