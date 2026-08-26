# Bit Reversal (32-bit)
# Reverse the bit order of a 32-bit integer.
#
# Strategy:
#   - Extract the LSB of n
#   - Shift it into result
#   - Shift n right
#   - Repeat 32 times
#
# Example:
#   0x00000001 (1) -> 0x80000000

.data
    msg_orig: .string "Original (hex not available, decimal): "
    msg_rev:  .string "Reversed (decimal): "
    msg_newln:.string "\n"

.text
.globl main

main:
    # Reverse 0x000000F0 (240)
    li   a0, 0x000000F0
    jal  ra, bit_reverse
    mv   s0, a0

    # Print original value
    li   a0, 4
    la   a1, msg_orig
    ecall

    li   a0, 1
    li   a1, 240
    ecall

    li   a0, 4
    la   a1, msg_newln
    ecall

    # Print reversed value
    li   a0, 4
    la   a1, msg_rev
    ecall

    li   a0, 1
    mv   a1, s0
    ecall

    li   a0, 4
    la   a1, msg_newln
    ecall

    # Exit program
    li   a0, 10
    ecall


# bit_reverse(a0=n) -> a0=bit-reversed n
# Process all 32 bits from LSB to MSB.

bit_reverse:
    li   t0, 0                 # t0 = result
    li   t1, 32                # t1 = number of bits

rev_loop:
    beqz t1, rev_done

    # Shift result left and append n's current LSB
    slli t0, t0, 1             # result <<= 1
    andi t2, a0, 1             # t2 = LSB of n
    or   t0, t0, t2             # result |= LSB

    # Move to the next bit of n
    srli a0, a0, 1              # n >>= 1

    addi t1, t1, -1             # counter--
    j    rev_loop

rev_done:
    # Return reversed value in a0
    mv   a0, t0
    ret
