.text
.globl main

main:
    addi a0, zero, 42
    addi a1, zero, 58
    add  a2, a0, a1

    # print result
    addi a0, zero, 1
    mv   a1, a2
    ecall

    # exit
    addi a0, zero, 10
    ecall
