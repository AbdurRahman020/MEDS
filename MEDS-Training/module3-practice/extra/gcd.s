# GCD — Euclidean Algorithm (iterative)
# calculate the greatest common divisor of two integers
#
# strategy:
#   - repeatedly replace (a, b) with (b, a % b)
#   - stop when b == 0
#   - at that point, a is the GCD


.data
    msg_gcd:  .string "GCD: "
    msg_newln:.string "\n"

.text
.globl main

main:
    # calculate gcd(48, 18)
    li   a0, 48
    li   a1, 18
    jal  ra, gcd

    # save result
    mv   s0, a0

    # print GCD
    li   a0, 4
    la   a1, msg_gcd
    ecall

    li   a0, 1
    mv   a1, s0
    ecall

    li   a0, 4
    la   a1, msg_newln
    ecall

    # exit program
    li   a0, 10
    ecall


# gcd(a0=a, a1=b) -> a0=GCD
# repeatedly replace (a, b) with (b, a % b)

gcd:
    # when b == 0, a contains the GCD
    beqz a1, gcd_done

    # compute next pair: (a, b) -> (b, a % b)
    rem  t0, a0, a1            # t0 = a % b
    mv   a0, a1                # a = b
    mv   a1, t0                # b = a % b
    j    gcd

gcd_done:
    # return GCD in a0
    ret
