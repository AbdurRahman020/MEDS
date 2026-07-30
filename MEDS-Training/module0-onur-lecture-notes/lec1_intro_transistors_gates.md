# Lecture 1: Introduction — Transistors & Gates
**DDCA · Prof. Onur Mutlu · ETH Zürich · Spring 2025**

---

## The Big Idea

Every computer — from a phone to a supercomputer — is ultimately just electrons switching on and off. But between "a human problem" and "electrons," there's a whole stack of abstraction:

```
Problem → Algorithm → Program → System Software
→ ISA → Microarchitecture → Logic → Devices → Electrons
```

Computer Architecture isn't just one layer — the best designers think across the whole stack.

Every computer, no matter how complex, has exactly three things: **computation** (processing), **communication** (moving data around), and **storage** (holding programs and data).

---

## Transistors

A transistor is a voltage-controlled switch. There are two flavors:

| Type | Conducts when gate = | Good at |
|---|---|---|
| **nMOS** | 1 (high) | Pulling output to 0 |
| **pMOS** | 0 (low) | Pulling output to 1 |

The reason there are two types is physics — nMOS is bad at passing high voltages, and pMOS is bad at passing low ones. So we use each for what it does well.

Modern gates use **CMOS** — always one pull-up network (pMOS) and one pull-down network (nMOS). The golden rule: **exactly one network is ON at any time**. Both ON = short circuit. Both OFF = floating output (undefined). Neither is acceptable.

Transistors in **series** = all must conduct (AND-like). Transistors in **parallel** = any one conducting is enough (OR-like). Series is slower because resistance adds up.

---

## Logic Gates

**NOT (Inverter):** input 0 → pMOS pulls output to 1. Input 1 → nMOS pulls output to 0. Simple.

**NAND:** pMOS in parallel (output = 1 unless *both* inputs are 1), nMOS in series (output pulled to 0 only when *both* inputs are 1).

**AND:** You can't build AND directly — it would need nMOS in the pull-up role, which it does poorly. So AND = NAND + NOT. This is why AND costs more transistors than NAND.

The pattern generalizes:

| Gate | pMOS network | nMOS network |
|---|---|---|
| NAND | Parallel | Series |
| NOR | Series | Parallel |
| NOT | Single pMOS | Single nMOS |

---

## Quick Reference

| | |
|---|---|
| nMOS closes on | high (1) |
| pMOS closes on | low (0) |
| CMOS rule | exactly one of pull-up/pull-down ON |
| AND gate | NAND + NOT (physics reason) |
| Series transistors | slower, AND-like |
| Parallel transistors | OR-like |

---
*ETH Zürich DDCA Lecture 1 · Spring 2025*
