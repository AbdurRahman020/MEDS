.data
message: .string "Hello MEDS!"

.text
.globl main

main:
    # load address of the string
    la a1, message

    # print string
    li a0, 4          # ecall 4 = print string
    ecall

    # exit program
    li a0, 10         # ecall 10 = exit 
    ecall
