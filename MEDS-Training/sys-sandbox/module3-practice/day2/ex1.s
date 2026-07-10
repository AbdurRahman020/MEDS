# int b = 12, c = 64;
# int result = (b * 8) - (c / 4);
# printf("%d\n", result);


.text
.globl main

main:
    li   t0, 12             # t0 = b = 12
    li   t1, 64             # t1 = c = 64

    slli t2, t0, 3          # t2 = b * 8 (shift left 3 = multiply by 8)
    srai t3, t1, 2          # t3 = c / 4 (arithmetic shift right 2 = divide by 4)

    sub  a1, t2, t3         # a1 = (b*8) - (c/4)

    # print result
    addi a0, zero, 1        # ecall 1 = print integer
    ecall                   # print the integer

    # exit
    addi a0, zero, 10       # ecall 10 = exit program
    ecall                   # terminate execution
