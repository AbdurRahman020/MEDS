# unsigned int val = 0xDEADBEEF;
# unsigned int lower_byte  = val & 0xFF;
# unsigned int second_byte = (val >> 8) & 0xFF;
# unsigned int upper_half  = (val >> 16) & 0xFFFF;
# printf("%d\n%d\n%d\n", lower_byte, second_byte, upper_half);


.text
.globl main

main:
    li   t0, 0xDEADBEEF      # t0 = 0xDEADBEEF (li expands to LUI + ADDI/ORI)

    andi t1, t0, 0xFF        # t1 = lower byte = 0xEF

    srli t2, t0, 8           # t2 = val >> 8
    andi t2, t2, 0xFF        # t2 = second byte = 0xBE

    srli t3, t0, 16          # t3 = upper half-word = 0xDEAD (top bits already shifted out)

    # print lower byte
    addi a0, zero, 1        # ecall 1 = print integer
    mv   a1, t1             # a1 = lower byte
    ecall                   # print the integer

    # print second byte
    addi a0, zero, 1
    mv   a1, t2             # a1 = second byte
    ecall

    # print upper half-word
    addi a0, zero, 1
    mv   a1, t3             # a1 = upper half-word
    ecall

    # exit
    addi a0, zero, 10       # ecall 10 = exit program
    ecall                   # terminate execution
