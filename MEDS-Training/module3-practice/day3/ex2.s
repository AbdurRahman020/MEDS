# int n, fact = 1;
# scanf("%d", &n);
# for (int i = 1; i <= n; i++) {
#     fact *= i;
# }
# printf("%d\n", fact);


.text
.globl main

main:
    addi a0, zero, 5        # ecall 5 = read integer
    ecall                   # a0 = n
    mv   t0, a0             # t0 = n

    li   t1, 1              # fact = 1
    li   t2, 1              # i = 1

loop:
    bgt  t2, t0, done        # if i > n, exit loop (pseudo: blt t0, t2, done)
    mul  t1, t1, t2          # fact *= i
    addi t2, t2, 1           # i++
    j    loop

done:
    # print result
    addi a0, zero, 1        # ecall 1 = print integer
    mv   a1, t1             # a1 = fact
    ecall                   # print the integer

    # exit
    addi a0, zero, 10       # ecall 10 = exit program
    ecall                   # terminate execution
