# int n;
# scanf("%d", &n);
# if (n > 0)      printf("Positive\n");
# else if (n < 0) printf("Negative\n");
# else            printf("Zero\n");


.data
    pos_msg:  .string "Positive\n"
    neg_msg:  .string "Negative\n"
    zero_msg: .string "Zero\n"

.text
.globl main

main:
    addi a0, zero, 5          # ecall 5 = read integer
    ecall                     # a0 = n
    mv   t0, a0               # t0 = n

    blt  t0, zero, negative   # if n < 0, go negative
    beq  t0, zero, is_zero    # if n == 0, go zero

    # positive case
    la   a1, pos_msg          # a1 = address of "Positive\n"
    j    print_result

negative:
    la   a1, neg_msg          # a1 = address of "Negative\n"
    j    print_result

is_zero:
    la   a1, zero_msg         # a1 = address of "Zero\n"

print_result:
    addi a0, zero, 4          # ecall 4 = print string
    ecall                     # print the message

    # exit
    addi a0, zero, 10         # ecall 10 = exit program
    ecall                     # terminate execution
