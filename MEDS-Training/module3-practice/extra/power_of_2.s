# check power of 2: a number n is a power of 2 if exactly one bit is set
# 
# trick: n & (n-1) == 0  (and n > 0)


.data
    msg_yes:  .string " is a power of 2\n"
    msg_no:   .string " is not a power of 2\n"

.text
.globl main

# main — test several numbers
main:
    li   a0, 16
    jal  ra, check_pow2

    li   a0, 18
    jal  ra, check_pow2

    li   a0, 1
    jal  ra, check_pow2

    li   a0, 0
    jal  ra, check_pow2

    li   a0, 10
    ecall


# check_pow2(a0=n) — print whether n is a power of 2
check_pow2:
    addi sp, sp, -8
    sw   ra, 0(sp)
    sw   s0, 4(sp)

    mv   s0, a0            # s0 = n

    # print n
    li   a0, 1
    mv   a1, s0
    ecall

    blez s0, not_pow2      # n <= 0 -> not a power of 2

    addi t0, s0, -1        # t0 = n - 1
    and  t1, s0, t0        # t1 = n & (n-1)
    bnez t1, not_pow2

is_pow2:
    li   a0, 4
    la   a1, msg_yes
    ecall
    j    pow2_done

not_pow2:
    li   a0, 4
    la   a1, msg_no
    ecall

pow2_done:
    lw   ra, 0(sp)
    lw   s0, 4(sp)
    addi sp, sp, 8
    ret
