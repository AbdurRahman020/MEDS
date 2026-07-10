# C pseudocode:
# int n;
# scanf("%d", &n);
# if ((n & 1) == 0)
#     printf("Even");
# else
#     printf("Odd");

.text
.globl main

main:
    addi a0, zero, 5        # ecall 5 = read integer
    ecall                   # read n
    mv   t0, a0             # t0 = n

    andi t1, t0, 1           # t1 = n & 1 (isolate LSB: 0 = even, 1 = odd)

    beq  t1, zero, even      # if LSB == 0, go print "Even"

odd:
    la   a0, odd_msg          # load address of "Odd" string
    addi a1, zero, 4          # ecall 4 = print string
    mv   a0, a1               # a0 = 4 (print string)
    la   a1, odd_msg          # a1 = address of string
    ecall                     # print "Odd"
    j    exit

even:
    addi a0, zero, 4          # ecall 4 = print string
    la   a1, even_msg         # a1 = address of "Even" string
    ecall                     # print "Even"

exit:
    addi a0, zero, 10         # ecall 10 = exit program
    ecall

.data
even_msg: .asciiz "Even"
odd_msg:  .asciiz "Odd"
