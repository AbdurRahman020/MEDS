# Known Issue: multiplicand = -128

While running the edge-case sweep in `tb_top.sv`, every test with
`multiplicand = -128` (paired with a non-zero multiplier) came back wrong.
The magnitude was always right, but the sign was flipped:

```
FAIL: -128 x -1   = -128   (expected  128)
FAIL: -128 x 127  = 16256  (expected -16256)
FAIL: -128 x -128 = -16384 (expected  16384)
FAIL: -128 x 1    = 128    (expected -128)
FAIL: -128 x -10  = -1280  (expected  1280)
```

`multiplicand = 0` and `multiplicand = -128, multiplier = 0` both passed, so
it's specifically triggered by the ALU doing a real add/subtract with
`M = -128`.

## Why this happens

Booth's algorithm subtracts the multiplicand whenever it sees the bit
pattern `Q0=1, Q-1=0`:

```
A = A - M
```

When `M = -128`, that's:

```
A - (-128) = A + 128
```

`-128` is the one value in 8-bit two's complement that has no positive
counterpart in 8 bits (the range is -128 to 127). So computing `A + 128`
inside an 8-bit signed register can overflow the representable range, and
the result silently wraps.

Example, first iteration with `A = 0`:

```
0 - (-128) = 128        <- true value, needs 9 bits to represent as positive
truncated to 8 bits: 1000_0000   <- read as -128, not +128
```

The arithmetic right-shift step depends on the sign bit of the ALU result
to sign-extend correctly for the next iteration. Since the 8-bit
truncation turned a positive value into something that looks negative
(sign bit flips to 1), the shifter propagates the wrong sign from that
point on. That wrong sign carries through the rest of the iterations, and
by the last shift the final 16-bit product has the correct magnitude but
the wrong sign - exactly what shows up in the failing tests above.

Only the multiplicand can trigger this, not the multiplier - the
multiplier (`Q` register) is never added or subtracted, it only gets
shifted a bit at a time. Only `M` goes through the adder/subtractor, so
only `M = -128` (the minimum 8-bit value) can cause this overflow.

## Fix

Give the accumulator (`A`) one extra guard bit internally - i.e. do the
add/subtract and the shift on a `WIDTH+1`-bit register instead of
`WIDTH` bits, then drop the guard bit when assembling the final product.
That extra bit gives enough headroom that `A ± M` can never overflow the
representable range, no matter what `M` is. Confirmed this fixes every
case above in a quick Python model of the datapath before touching the
actual RTL.

Not yet applied to `adder_subtractor.sv` / `shift_register.sv` /
`datapath.sv` - noting it here first since it changes the width of a
signal that flows through three modules.
