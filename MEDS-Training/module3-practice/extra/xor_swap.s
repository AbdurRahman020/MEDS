# swap without temp register (xor trick)
#
# how it works:
#   a = a ^ b
#   b = a ^ b
#   a = a ^ b


.data
    msg_before_a: .string "Before -> a: "
    msg_before_b: .string " b: "
    msg_after_a:  .string "After  -> a: "
    msg_after_b:  .string " b: "
    msg_newln:    .string "\n"

.text
.globl main

# main — demonstrate XOR swap
main:
    li   s0, 25
    li   s1, 70

    # print before
    li   a0, 4
    la   a1, msg_before_a
    ecall

    li   a0, 1
    mv   a1, s0
    ecall

    li   a0, 4
    la   a1, msg_before_b
    ecall

    li   a0, 1
    mv   a1, s1
    ecall

    li   a0, 4
    la   a1, msg_newln
    ecall

    # XOR swap
    xor  s0, s0, s1
    xor  s1, s0, s1
    xor  s0, s0, s1

    # print after
    li   a0, 4
    la   a1, msg_after_a
    ecall

    li   a0, 1
    mv   a1, s0
    ecall

    li   a0, 4
    la   a1, msg_after_b
    ecall

    li   a0, 1
    mv   a1, s1
    ecall

    li   a0, 4
    la   a1, msg_newln
    ecall

    # exit
    li   a0, 10
    ecall
