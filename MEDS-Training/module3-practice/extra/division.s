# Integer Division without div instruction
# Uses repeated subtraction to calculate quotient and remainder
#
# Formula:
#   quotient  = a / b
#   remainder = a % b


.data
    msg_q:    .string "Quotient:  "
    msg_r:    .string "Remainder: "
    msg_newln:.string "\n"

.text
.globl main

main:
    # divide 47 by 5
    li   a0, 47
    li   a1, 5
    jal  ra, divide

    # save quotient and remainder
    mv   s0, a0                # s0 = quotient
    mv   s1, a1                # s1 = remainder

    # print quotient
    li   a0, 4
    la   a1, msg_q
    ecall

    li   a0, 1
    mv   a1, s0
    ecall

    li   a0, 4
    la   a1, msg_newln
    ecall

    # print remainder
    li   a0, 4
    la   a1, msg_r
    ecall

    li   a0, 1
    mv   a1, s1
    ecall

    li   a0, 4
    la   a1, msg_newln
    ecall

    # exit program
    li   a0, 10
    ecall


# divide(a0=dividend, a1=divisor) -> a0=quotient, a1=remainder
# repeatedly subtract the divisor until the dividend is smalle

divide:
    li   t0, 0                 # t0 = quotient

div_loop:
    # stop when the remaining dividend is smaller than divisor
    blt  a0, a1, div_done

    # subtract divisor and increment quotient
    sub  a0, a0, a1            # dividend -= divisor
    addi t0, t0, 1             # quotient++
    j    div_loop

div_done:
    # remaining dividend is the remainder
    mv   a1, a0                # a1 = remainder
    mv   a0, t0                # a0 = quotient
    ret
