# int N, sum = 0;
# scanf("%d", &N);
# for (int i = 1; i <= N; i++) {
#     sum += i;
# }
# printf("%d", sum);

.text
.globl main

main:
    addi a0, zero, 5        # ecall 5 = read integer
    ecall                   # read N
    mv   t0, a0             # t0 = N

    addi t1, zero, 0        # t1 = sum = 0
    addi t2, zero, 1        # t2 = i = 1

loop:
    bgt  t2, t0, end_loop    # if i > N, exit loop
    add  t1, t1, t2          # sum += i
    addi t2, t2, 1           # i++
    j    loop                # repeat

end_loop:
    addi a0, zero, 1         # ecall 1 = print integer
    mv   a1, t1              # a1 = sum
    ecall                    # print sum

    addi a0, zero, 10        # ecall 10 = exit
    ecall
