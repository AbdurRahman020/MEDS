# int a = 42, b = 58;
# int result = a + b;
# printf("%d", result);   // 100

.text
.globl main

main:
    addi a0, zero, 42       # a0 = 42
    addi a1, zero, 58       # a1 = 58
    add  a2, a0, a1         # a2 = a0 + a1 = 100

    # print result
    addi a0, zero, 1        # ecall 1 = print integer
    mv   a1, a2             # move result into a1 for printing
    ecall                   # print 100

    # exit
    addi a0, zero, 10       # ecall 10 = exit program
    ecall                   # terminate execution