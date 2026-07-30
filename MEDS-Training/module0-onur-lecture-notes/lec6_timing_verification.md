# Lecture 6: Timing & Verification II
**DDCA · Prof. Onur Mutlu · ETH Zürich · Spring 2025**

---

## The Big Idea

A circuit can be logically correct and still fail in the real world. Timing is why. This lecture makes the timing model concrete and shows how to actually verify a design.

---

## Part 1 — Combinational Timing (Deep Dive)

Gates don't switch instantly. Delay comes from capacitance, resistance, and wire length. The same gate can have different delays depending on which input switched, whether it's a rising or falling transition, temperature, and even how old the chip is.

The two numbers that bound all possible delays:

| Symbol | Name | Meaning |
|---|---|---|
| **t_cd** | contamination delay | *minimum* — when output first starts changing |
| **t_pd** | propagation delay | *maximum* — when output is fully settled |

To find t_pd: trace the **critical path** (longest path), sum up t_pd of each gate.
To find t_cd: trace the **short path** (shortest path), sum up t_cd of each gate.

```
Example:
  Critical path (3 AND gates): t_pd = 3 × t_pd_AND
  Short path (1 AND gate):      t_cd = 1 × t_cd_AND
```

### Glitches

A glitch is when one input transition causes *multiple* output transitions. It happens when a signal travels through a fast path and a slow path simultaneously — the fast path updates the output first (wrong value), then the slow path corrects it (right value), creating an extra transition.

To eliminate a glitch: cover the transition in the K-map with an extra prime implicant (consensus term). But most of the time glitches don't matter — if you only read the output after it's settled, you don't care what it did in the middle. Fix them only if something is sampling during the transient.

---

## Part 2 — Sequential Timing (Deep Dive)

### Setup & Hold Times

Around every clock edge, D must be stable for a window of time:

- **t_setup** — D must be stable *before* the edge (at least this long)
- **t_hold** — D must stay stable *after* the edge (at least this long)
- **Aperture** = t_setup + t_hold = the full stable window required

Violate either → **metastability**. The flip-flop output gets stuck somewhere between 0 and 1, then randomly resolves to one or the other. Non-deterministic and very bad.

### Flip-Flop Output Timing

| Symbol | Meaning |
|---|---|
| **t_pcq** | Q finishes changing (latest) — propagation clock-to-Q |
| **t_ccq** | Q starts changing (earliest) — contamination clock-to-Q |

### Setup Constraint

In a pipeline: `R1 → Combinational Logic → R2`

Data launched by R1 must arrive at R2's D pin before R2's setup window starts.

$$T_c > t_{pcq} + t_{pd} + t_{setup}$$

This is what limits your maximum clock frequency. The **sequencing overhead** (t_pcq + t_setup) is time you spend on the flip-flop itself, not on useful computation.

### Hold Constraint

Data launched by R1 must not arrive at R2 too *quickly* — it needs to stay stable through R2's hold window.

$$t_{ccq} + t_{cd} > t_{hold}$$

This one is independent of clock period — slowing the clock won't fix it. It requires a minimum combinational delay. If violated, **add buffer gates** to the short path to increase t_cd.

> Hold violations are particularly painful because they often can't be fixed without redesigning part of the circuit.

### Worked Example

Given: t_ccq=30ps, t_pcq=50ps, t_setup=60ps, t_hold=70ps, t_pd=35ps/gate, t_cd=25ps/gate

**Setup (3-gate critical path):**
- t_pd = 3 × 35 = 105 ps
- Tc > 50 + 105 + 60 = **215 ps** → f_max = **4.65 GHz** ✅

**Hold (1-gate short path):**
- t_ccq + t_cd = 30 + 25 = 55 ps vs t_hold = 70 ps → **55 < 70 → VIOLATION** ❌

**Fix:** add one buffer to short path → t_cd = 2 × 25 = 50 ps
- 30 + 50 = 80 ps > 70 ps ✅ — and f_max is unchanged.

### Clock Skew

When the clock doesn't arrive at all flip-flops at the same time, both constraints get harder:

```
Setup: Tc > t_pcq + t_pd + t_setup + t_skew
Hold:  t_ccq + t_cd > t_hold + t_skew
```

Solution: careful clock distribution networks that balance path lengths across the chip.

---

## Part 3 — Verification

### The Problem

You can't test everything. A 32-bit adder has 2⁶⁴ input combinations — exhaustive testing at 1B tests/second takes 58 years. Need a strategy.

**Two things to verify:**
1. Functional correctness — does it compute the right thing?
2. Timing correctness — does it meet setup/hold at the target frequency?

Split by level: use high-level simulation (Verilog) for functional checking (fast), and circuit-level tools (Vivado/SPICE) for timing/power (slow, targeted).

### Testbenches

A testbench is a Verilog module that exists only in simulation — it's not synthesizable. It generates inputs and checks outputs for your **Device Under Test (DUT)**.

```
[Input Generator] → [DUT] → [Output Checker]
```

Four levels of sophistication:

**1. Simple:** manually write inputs, visually check waveforms. Easy but doesn't scale.

**2. Self-Checking:** add `if (y !== expected) $display("FAILED")`. Still manual inputs.
```verilog
a = 0; b = 0; c = 0; #10;
if (y !== 1) $display("000 failed.");
```

**3. Testvector File:** read inputs and expected outputs from a `.tv` file. Use a simulated clock to separate applying inputs (rising edge) from checking outputs (falling edge).
```verilog
always @(posedge clk)
  {a, b, c, yexpected} = testvectors[vectornum];

always @(negedge clk)
  if (y !== yexpected) $display("Error on %b", {a, b, c});
```

**4. Golden Model:** build a simple reference implementation alongside the DUT. Auto-compare outputs. Fully automated, highly scalable.
```verilog
// DUT and golden model get same inputs; compare their outputs
```
The catch: writing a correct golden model is hard, and choosing *which* inputs to test still matters.

### Timing Verification

Tools like Vivado handle this automatically once you provide constraints (target frequency, I/O timing). They:
- Check setup/hold on every flip-flop pair
- Minimize clock skew
- Generate timing reports with worst-case paths and violations

When tools fail to meet timing:
1. Try different synthesis/place-and-route settings
2. Simplify logic on the critical path
3. **Pipeline** — split long combinational paths with flip-flops
4. **Add buffers** — fix hold violations on short paths

---

## Quick Reference

| Symbol | Meaning |
|---|---|
| t_pd | max combinational delay (critical path) |
| t_cd | min combinational delay (short path) |
| t_setup | D stable before clock edge |
| t_hold | D stable after clock edge |
| t_pcq | Q done after clock edge |
| t_ccq | Q starts after clock edge |
| **Setup** | `Tc > t_pcq + t_pd + t_setup` |
| **Hold** | `t_ccq + t_cd > t_hold` |
| Hold fix | add buffers to short path (doesn't affect f_max) |
| Glitch fix | add consensus term in K-map (usually not needed) |

---
*ETH Zürich DDCA Lecture 6 · Spring 2025*
