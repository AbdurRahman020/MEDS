# int a, b;
# scanf("%d", &a);
# scanf("%d", &b);
# printf("%d", a + b);


.text
.globl main

main:
    addi a0, zero, 5        # ecall 5 = read integer
    ecall                   # waits for input
    mv   a1, a0             # save first number

    addi a0, zero, 5        # ecall 5 = read integer
    ecall                   # waits for second input
    mv   a2, a0             # save second number

    add  a3, a2, a1         # a3 = a1 + a2

    # print result
    addi a0, zero, 1        # ecall 1 = print integer
    mv   a1, a3             # move result to a1 for printing
    ecall                   # print the integer

    # exit
    addi a0, zero, 10       # ecall 10 = exit program
    ecall                   # terminate execution