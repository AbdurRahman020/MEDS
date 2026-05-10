# Lecture 3: Sequential Logic
**DDCA · Prof. Onur Mutlu · ETH Zürich · Spring 2025**

---

## The Big Idea

Combinational circuits have no memory — same inputs always give same outputs. Sequential circuits *remember* past inputs. That memory is what lets computers store programs, track state, and run loops. Most of a modern chip's area is memory.

---

## Storage Elements

From simple to useful:

### Cross-Coupled Inverters
Two inverters feeding each other. Stable in two states (Q=0 or Q=1) but no way to control which state it's in. Not useful on its own.

### R-S Latch
Adds Set and Reset control to the cross-coupled idea.

| R | S | Q |
|---|---|---|
| 1 | 1 | holds |
| 1 | 0 | 1 (set) |
| 0 | 1 | 0 (reset) |
| 0 | 0 | **forbidden** |

R=S=0 is forbidden — both outputs go to 1, which breaks the Q ≠ Q̄ contract. If both then return to 1 simultaneously, the output oscillates unpredictably. That's **metastability**.

### Gated D Latch
Fixes the R-S problem. While WE=1, Q just follows D (transparent). While WE=0, Q holds its last value.

The problem with latches: if you wire the clock to WE, Q changes *throughout* the entire high phase — not just at the edge. That makes timing unpredictable.

### D Flip-Flop
Two D latches in series, clocked on opposite phases. This solves the transparency problem:

- **Rising edge:** Q captures D
- **Everything else:** Q holds

This is the fundamental memory element for synchronous design. A latch is *level-triggered*. A flip-flop is *edge-triggered*. The edge-triggered behavior is what makes timing analysis tractable.

### Register
Just N flip-flops in parallel sharing one clock. Stores N bits, all captured on the same rising edge.

### Memory Array
Registers addressed by a decoder (selects the row) and a MUX (selects the output). Key terms: **address space** = total locations, **addressability** = bits per location. Address bits needed = log₂(locations).

A memory array can also implement any Boolean function — store the truth table, look up by address. This is a **Lookup Table (LUT)**, and it's the core of how FPGAs work.

---

## State and Clocks

The **state** of a system is everything you'd need to snapshot in order to resume from that point. A combination lock mid-sequence has state — it remembers where in the sequence it is.

**Synchronous systems** change state only at clock edges. This course assumes synchronous design. The clock period must be long enough for combinational logic to settle before the next edge.

---

## Finite State Machines (FSMs)

An FSM is a model of a system that has a finite number of states, defined transitions between them, and outputs. Every FSM in hardware has three pieces:

```
Inputs → [Next State Logic] → [State Register] → [Output Logic] → Outputs
                ↑                    ↓ CLK
                └────────────────────┘
```

1. **State register** — flip-flops holding the current state
2. **Next state logic** — combinational, computes S' from S and inputs
3. **Output logic** — combinational, computes outputs

### Moore vs. Mealy

| | Moore | Mealy |
|---|---|---|
| Outputs depend on | state only | state + inputs |
| Output changes | only at clock edges | can change mid-cycle |

Moore is simpler and safer. Mealy needs fewer states.

### Design Procedure
1. Identify all states
2. Draw the state transition diagram (circles = states, arcs = transitions)
3. Encode states in binary
4. Fill in the transition table
5. Derive Boolean expressions for S' and outputs
6. Implement with flip-flops + gates

### Traffic Light Example (Moore)

**Inputs:** TA, TB (traffic present) · **Outputs:** LA, LB (green=00, yellow=01, red=10)

| State | LA | LB | Next state |
|---|---|---|---|
| S0 | Green | Red | S0 if TA=1, else S1 |
| S1 | Yellow | Red | S2 |
| S2 | Red | Green | S2 if TB=1, else S3 |
| S3 | Red | Yellow | S0 |

Encoding: S0=00, S1=01, S2=10, S3=11
```
S'₁ = S₁ XOR S₀
S'₀ = (S̄₁·S̄₀·T̄A) + (S₁·S̄₀·T̄B)

LA1 = S₁        LB1 = S̄₁
LA0 = S̄₁·S₀    LB0 = S₁·S̄₀
```

### State Encoding Options

| Encoding | Bits | Tradeoff |
|---|---|---|
| Binary | log₂(N) | fewest flip-flops |
| One-hot | N | simplest next-state logic |
| Output encoded | varies | simplest output logic; Moore only |

---

## Quick Reference

| | |
|---|---|
| R-S latch | R=S=0 forbidden (metastability) |
| Gated D latch | transparent when WE=1 (level-triggered) |
| D flip-flop | captures on rising edge only (edge-triggered) |
| Register | N flip-flops, shared clock |
| Moore FSM | output = f(state) |
| Mealy FSM | output = f(state, input) |

---
*ETH Zürich DDCA Lecture 3 · Spring 2025*
