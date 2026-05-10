# Lecture 2: Combinational Logic
**DDCA · Prof. Onur Mutlu · ETH Zürich · Spring 2025**

---

## The Big Idea

A combinational circuit is memoryless — the output depends *only* on the current inputs, nothing from the past. That's the defining rule. Everything in this lecture builds from there.

---

## Boolean Algebra

The laws you'll actually use:

| Law | Expression |
|---|---|
| Identity | `X + 0 = X`, `X · 1 = X` |
| Null | `X + 1 = 1`, `X · 0 = 0` |
| Complement | `X + X̄ = 1`, `X · X̄ = 0` |
| Involution | `X̄̄ = X` |
| Distributive | `X·(Y+Z) = X·Y + X·Z` |
| **Uniting** | `X·Y + X·Ȳ = X` ← the main simplification trick |
| Absorption | `X + X·Y = X` |

**DeMorgan's Law** — probably the most useful one:
```
NOT(A · B · ...) = Ā + B̄ + ...    →  NAND = OR with inverted inputs
NOT(A + B + ...) = Ā · B̄ · ...    →  NOR  = AND with inverted inputs
```

**Duality:** swap AND↔OR and 0↔1 in any valid identity — it's still valid. Free laws.

**Simplification in one sentence:** find two minterms where only one variable differs — that variable cancels out.
```
AB̄ + AB = A(B̄ + B) = A
```

---

## Standard Forms: SOP and POS

### Sum of Products (SOP)
Look at the truth table. For every row where output = **1**, write a minterm (AND of all inputs — complement where input = 0). OR all of them together.

```
Rule: input 0 → complemented literal,  input 1 → true literal
```

### Product of Sums (POS)
Same idea but for rows where output = **0**. Each row gives a maxterm (OR of all inputs — but the complementing rule *flips* vs. SOP).

```
Rule: input 0 → true literal,  input 1 → complemented literal   ← opposite of SOP!
```

### Conversions

| Want | From SOP | How |
|---|---|---|
| POS of F | SOP of F | Use the *remaining* row indices |
| SOP of F̄ | SOP of F | Use the *remaining* row indices |
| POS of F̄ | SOP of F | Use the *same* row indices |

Canonical forms are unique, but not minimal. Minimization (K-maps) shrinks them.

---

## Building Blocks

### Decoder
n inputs → 2ⁿ outputs. Exactly one output is HIGH — whichever matches the input pattern. Used for address decoding and instruction decoding.

### Multiplexer (MUX)
N data inputs + log₂N select bits → 1 output. The select lines choose which data input passes through.
```
2:1 MUX:  y = s ? d1 : d0
```
A MUX can implement *any* logic function by hardwiring truth table values as data inputs — that's exactly how an FPGA's **LUT** works.

### Full Adder
One bit of addition: inputs aᵢ, bᵢ, Cᵢₙ → outputs Sᵢ, Cₒᵤₜ.
```
S    = A ⊕ B ⊕ Cin        (XOR)
Cout = AB + ACin + BCin    (majority)
```
Chain N full adders → ripple carry adder. (Carry lookahead is faster but more complex.)

### PLA (Programmable Logic Array)
AND array + OR array = any two-level SOP function. The basis of the fact that {AND, OR, NOT} is **logically complete** — you can build any circuit from them. (NAND alone, or NOR alone, also works.)

---

## Quick Reference

| | |
|---|---|
| Uniting theorem | `XY + XȲ = X` |
| DeMorgan | NAND↔OR-with-inverts, NOR↔AND-with-inverts |
| SOP complementing | 0→complemented, 1→true |
| POS complementing | 0→true, 1→complemented (opposite!) |
| Decoder | n in → 2ⁿ out, one-hot |
| MUX | selects one of N inputs |
| Full adder | S=XOR, Cout=majority |
| LUT | MUX implementing a truth table |

---
*ETH Zürich DDCA Lecture 2 · Spring 2025*
