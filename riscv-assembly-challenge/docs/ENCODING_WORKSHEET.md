# Encoding Worksheet — Part 3

One instruction per format, encoded by hand using:
`instruction = (field << shift) | (field << shift) | ... | opcode`

I converted each field to binary first before shifting, just to make sure I wasn't messing up the bit positions (did this on paper first, then wrote it out below).

---

## R-type: `add x5, x6, x7`

Fields:
- opcode = 0110011 (this is fixed for all R-type instructions)
- funct3 = 000, funct7 = 0000000 (both 0 for add)
- rd = x5 → 5 = 00101
- rs1 = x6 → 6 = 00110
- rs2 = x7 → 7 = 00111

Bit layout (MSB to LSB): `funct7[31:25] | rs2[24:20] | rs1[19:15] | funct3[14:12] | rd[11:7] | opcode[6:0]`

```
0000000  00111  00110  000  00101  0110011
```

Putting that together as one 32-bit binary string:
```
0000 0000 1110 0110 0000 0010 1011 0011
```

Grouping into hex nibbles (4 bits at a time from the binary above):
```
0000 = 0
0000 = 0
1110 = E   ... wait, let me recheck this against the shift method below, since grouping by hand is where I usually slip up.
```

Redid it using the shift formula instead, which is less error-prone:
```
instr = (funct7<<25) | (rs2<<20) | (rs1<<15) | (funct3<<12) | (rd<<7) | opcode
      = (0<<25) | (7<<20) | (6<<15) | (0<<12) | (5<<7) | 0x33
      = 0x000000 + 0x700000 + 0x030000 + 0x000000 + 0x000280 + 0x000033
```

Adding these up column by column (in hex):
```
  0x700000
+ 0x030000
-----------
  0x730000
+ 0x000280
-----------
  0x730280
+ 0x000033
-----------
  0x7302B3
```

**Hex: `0x007302B3`**

(Double-checked this one against the binary grouping above and it matches — my earlier nibble grouping attempt had an error, shift method is more reliable for me.)

---

## I-type: `addi x8, x9, -20`

Fields:
- opcode = 0010011, funct3 = 000
- rd = x8 → 8 = 01000
- rs1 = x9 → 9 = 01001
- imm = -20 (this is the annoying one — needs two's complement)

Getting -20 as a 12-bit two's complement value:
```
20 in binary (12-bit)   = 0000 0001 0100
invert all bits          = 1111 1110 1011
add 1                    = 1111 1110 1100
```
So imm = `1111 1110 1100` = `0xFEC` ✓ (matches what I'd expect since -20 should be close to 0xFFF = -1)

```
instr = (imm<<20) | (rs1<<15) | (funct3<<12) | (rd<<7) | opcode
      = (0xFEC<<20) | (9<<15) | (0<<12) | (8<<7) | 0x13
```

Working out each term separately:
```
0xFEC << 20 = 0xFEC00000
9 << 15     = 0x00048000
8 << 7      = 0x00000400
opcode      = 0x00000013
```

Sum:
```
  0xFEC00000
+ 0x00048000
------------
  0xFEC48000
+ 0x00000400
------------
  0xFEC48400
+ 0x00000013
------------
  0xFEC48413
```

**Hex: `0xFEC48413`**

---

## S-type: `sw x10, 12(x11)`

Fields:
- opcode = 0100011, funct3 = 010
- rs1 = x11 (base register), rs2 = x10 (the value being stored)
- imm = 12, which needs to be split into two chunks for S-type: imm[11:5] and imm[4:0]

12 in binary (12-bit) = `0000 0000 1100`
Splitting:
```
imm[11:5] = 0000000   (top 7 bits)
imm[4:0]  = 01100     (bottom 5 bits, = 12 in decimal, checks out since 12 < 32)
```

```
instr = (imm[11:5]<<25) | (rs2<<20) | (rs1<<15) | (funct3<<12) | (imm[4:0]<<7) | opcode
      = (0<<25) | (10<<20) | (11<<15) | (2<<12) | (12<<7) | 0x23
```

Term by term:
```
10 << 20 = 0x00A00000
11 << 15 = 0x00058000
2  << 12 = 0x00002000
12 << 7  = 0x00000600
opcode   = 0x00000023
```

Adding:
```
0x00A00000 + 0x00058000 = 0x00A58000
0x00A58000 + 0x00002000 = 0x00A5A000
0x00A5A000 + 0x00000600 = 0x00A5A600
0x00A5A600 + 0x00000023 = 0x00A5A623
```

**Hex: `0x00A5A623`**

---

## B-type: `bne x12, x13, +8`

This is the format I found most confusing, since the immediate bits get scrambled around instead of being in order (I think it's done this way so rd and rs1/rs2 fields line up the same across formats, but it makes hand-encoding this one slower).

Fields:
- opcode = 1100011, funct3 = 001 (this is the code for bne, checked against the funct3 table)
- rs1 = x12, rs2 = x13
- imm = +8 (branch offset in bytes)

Since branch targets are always instruction-aligned (2-byte minimum), bit 0 of the immediate is implicitly 0 and isn't stored. So really we only need bits [12:1] of the offset.

8 in binary = `0000 0000 0000 1000` (just writing more bits than needed to keep track of positions)

Pulling out the specific bits needed:
```
imm[12]   = 0
imm[11]   = 0
imm[10:5] = 000000
imm[4:1]  = 0100
```

(bit 3 of 8 is the only 1-bit, and that lands inside the imm[4:1] chunk — makes sense since 8 = 2^3)

```
instr = (imm[12]<<31) | (imm[10:5]<<25) | (rs2<<20) | (rs1<<15)
      | (funct3<<12) | (imm[4:1]<<8) | (imm[11]<<7) | opcode
      = 0 | 0 | (13<<20) | (12<<15) | (1<<12) | (4<<8) | 0 | 0x63
```

Term by term:
```
13 << 20 = 0x00D00000
12 << 15 = 0x00060000
1  << 12 = 0x00001000
4  << 8  = 0x00000400
opcode   = 0x00000063
```

Adding these up:
```
0x00D00000 + 0x00060000 = 0x00D60000
0x00D60000 + 0x00001000 = 0x00D61000
0x00D61000 + 0x00000400 = 0x00D61400
0x00D61400 + 0x00000063 = 0x00D61463
```

**Hex: `0x00D61463`**

---

## U-type: `lui x14, 0x10`

This one's the easiest — the immediate just gets dropped straight into the top 20 bits, no splitting or two's complement needed.

Fields:
- opcode = 0110111
- rd = x14 → 14 = 01110
- imm = 0x10 (goes directly into bits[31:12])

```
instr = (imm<<12) | (rd<<7) | opcode
      = (0x10<<12) | (14<<7) | 0x37
```

```
0x10 << 12 = 0x00010000
14   << 7  = 0x00000700
opcode     = 0x00000037
```

Adding:
```
0x00010000 + 0x00000700 = 0x00010700
0x00010700 + 0x00000037 = 0x00010737
```

**Hex: `0x00010737`**

---

## J-type: `jal x15, +32`

Similar deal to B-type — the immediate bits get shuffled around, and bit 0 is implicit/not stored since jump targets are aligned too.

Fields:
- opcode = 1101111
- rd = x15 → 15 = 01111
- imm = 32 (this is the offset in bytes, need bits [20:1])

32 in binary = `0000 0000 0010 0000` (bit 5 is the 1-bit, since 32 = 2^5)

Splitting into the scrambled J-type chunks:
```
imm[20]    = 0
imm[19:12] = 00000000
imm[11]    = 0
imm[10:1]  = 0000010000   (this is a 10-bit field; bit 5 of the original offset lands here)
```

I double-checked this one by converting `0000010000` back to decimal: that's 16, and since this field represents bits [10:1] (i.e., value shifted right by 1 conceptually), 16 lines up with offset 32 divided by 2 — matches, so I trust the bit placement.

```
instr = (imm[20]<<31) | (imm[10:1]<<21) | (imm[11]<<20) | (imm[19:12]<<12) | (rd<<7) | opcode
      = 0 | (16<<21) | 0 | 0 | (15<<7) | 0x6F
```

```
16 << 21 = 0x02000000
15 << 7  = 0x00000780
opcode   = 0x0000006F
```

Adding:
```
0x02000000 + 0x00000780 = 0x02000780
0x02000780 + 0x0000006F = 0x020007EF
```

**Hex: `0x020007EF`**

---

## Summary

| Format | Instruction | Hex |
|---|---|---|
| R | `add x5, x6, x7` | `0x007302B3` |
| I | `addi x8, x9, -20` | `0xFEC48413` |
| S | `sw x10, 12(x11)` | `0x00A5A623` |
| B | `bne x12, x13, +8` | `0x00D61463` |
| U | `lui x14, 0x10` | `0x00010737` |
| J | `jal x15, +32` | `0x020007EF` |

Note to self: B and J formats took way longer than the others because of the bit-shuffling in the immediate encoding — worth double-checking these against the simulator output once Part 3's decoder is running, just to be sure the hand-encoding here is actually right.