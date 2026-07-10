.text
.globl main

main:
    # add imm in x0
    li x0, -5
    
    # print
    li a0, 1                # ecall 1 = print integer
    mv a1, x0
    ecall

    # exit program
    li a0, 10               # ecall 10 = exit
    ecall
