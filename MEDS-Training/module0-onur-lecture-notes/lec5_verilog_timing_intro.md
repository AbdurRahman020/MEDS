# Lecture 5: Verilog II + Timing & Verification (Intro)
**DDCA · Prof. Onur Mutlu · ETH Zürich · Spring 2025**

---

## Part 1 — Verilog Review

This lecture builds on Lecture 4's Verilog intro. The key points to internalize:

Hardware is **concurrent** — everything runs at once, not line by line. HDLs are designed to express that. When you write Verilog, you're describing hardware, not writing a program.

**Hierarchical design** is how complexity is managed — simple modules → bigger modules → complex systems. Top-down (define the top, subdivide) or bottom-up (build blocks, combine).

### Module & Port Recap
```verilog
module example (input a, b, c, output y);
  assign y = ~a & ~b & ~c | a & ~b & ~c | a & ~b & c;
endmodule
```
- Buses: always `[MSB:LSB]` e.g. `[31:0]`
- Slicing: `a[7:4]`, concatenation: `{a, b}`, duplication: `{4{a[0]}}`

### Operators
```verilog
assign y1 = a & b;       // AND
assign y2 = a | b;       // OR
assign y3 = a ^ b;       // XOR
assign y4 = ~(a & b);    // NAND
assign y5 = &a;          // reduction AND
assign y  = s ? d1 : d0; // MUX
```

### Sequential Logic Rules
```verilog
always @ (posedge clk)   q <= d;       // flip-flop: non-blocking
assign y = a & b;                       // simple comb: assign
always @ (*)  if (sel) y = a; else y = b; // complex comb: blocking
```

Missing a branch in `always @(*)` → **unintentional latch**. Use `default` in all `case` blocks.

### FSMs in Verilog (recap)
Three parts: state register (`always @(posedge clk)`), next state logic (`always @(*)`), output logic (`assign`). Moore output depends on state only; Mealy output depends on state and input.

---

## Part 2 — Synthesis vs. Simulation

**Synthesis** maps your Verilog to actual gates and wires on hardware. **Simulation** runs your design in software to check behavior before building anything. They're related but different:

- Timing delays (`assign #5 z = ~a;`) are simulation-only — the synthesizer ignores them
- Not all Verilog is synthesizable — testbench constructs like `initial`, `#10`, and `$display` are simulation-only
- Tools optimize your synthesized circuit, but can't guarantee a globally optimal result

---

## Part 3 — Combinational Timing

In reality, gates don't switch instantly. Real circuits have delay from capacitance, resistance, and the finite speed of light (yes, this matters at nanosecond timescales).

Two numbers characterize every circuit's delay:

- **t_cd (contamination delay)** — the *earliest* the output starts changing (minimum delay, short path)
- **t_pd (propagation delay)** — the *latest* the output finishes changing (maximum delay, critical path)

The **critical path** is the longest path through the circuit. It sets t_pd, which sets the minimum clock period, which sets f_max.

**Glitch** = one input change causes *multiple* output transitions. Happens when a fast path and slow path both propagate the same change — the fast one flips the output first, then the slow one corrects it. If only steady-state output matters, glitches are usually harmless and not worth fixing.

---

## Part 4 — Sequential Timing

### Setup and Hold Times

The D flip-flop has strict requirements around the clock edge:

| Term | Meaning |
|---|---|
| **t_setup** | D must be stable *before* the clock edge for this long |
| **t_hold** | D must stay stable *after* the clock edge for this long |
| **Aperture** | Total stable window = t_setup + t_hold |

Violate either → **metastability**: the flip-flop output gets stuck between 0 and 1, then eventually settles to some unpredictable value.

### Flip-Flop Output Timing

| Term | Meaning |
|---|---|
| **t_pcq** | Latest Q finishes changing after clock edge |
| **t_ccq** | Earliest Q starts changing after clock edge |

### The Two Constraints

For a pipeline stage `R1 → combinational logic → R2`:

**Setup constraint** (limits max speed):
```
Tc > t_pcq + t_pd + t_setup
```

**Hold constraint** (requires minimum delay — independent of clock period!):
```
t_ccq + t_cd > t_hold
```

The hold constraint is the dangerous one — it can't be fixed by slowing the clock. Fix: add buffer gates to the short path to increase t_cd.

**Clock skew** (clock arriving at different times at different flip-flops) makes both constraints worse:
```
Setup: Tc > t_pcq + t_pd + t_setup + t_skew
Hold:  t_ccq + t_cd > t_hold + t_skew
```

---

## Part 5 — Verification Strategy

Two things to verify: **functional correctness** (does it compute the right thing?) and **timing correctness** (does it meet constraints at the target frequency?).

The fundamental problem: exhaustive testing is impossible. A 32-bit adder has 2⁶⁴ input combinations — at 1 billion tests/second that's 58.5 years. You need smarter strategies.

Split the work by level:
- **High-level (Verilog/C):** check functional correctness — fast, high coverage
- **Circuit-level (SPICE/Vivado):** check timing and power — slow, targeted

In this course, functional verification = **Verilog testbenches**.

---

## Quick Reference

| | |
|---|---|
| t_cd | min delay (short path, output starts changing) |
| t_pd | max delay (critical path, output done changing) |
| t_setup | D stable before clock edge |
| t_hold | D stable after clock edge |
| t_pcq | Q done changing after clock edge |
| t_ccq | Q starts changing after clock edge |
| Setup constraint | `Tc > t_pcq + t_pd + t_setup` |
| Hold constraint | `t_ccq + t_cd > t_hold` |
| Hold violation fix | add buffers to short path |
| Clock skew | adds to both constraints |

---
*ETH Zürich DDCA Lecture 5a & 5b · Spring 2025*
