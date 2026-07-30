# int array[8] = {10, 20, 30, 40, 50, 60, 70, 80};
# int sum = 0;
# for (int i = 0; i < 8; i++) {
#     sum += array[i];
# }
# printf("%d\n", sum);


.data
    array: .word 10, 20, 30, 40, 50, 60, 70, 80

.text
.globl main

main:
    la   s0, array          # s0 = base address of array
    li   s1, 8              # array size
    li   s2, 0              # sum = 0
    li   t0, 0              # i = 0

loop:
    bge  t0, s1, done       # if i >= size, exit loop
    slli t1, t0, 2          # t1 = i * 4 (byte offset)
    add  t2, s0, t1         # t2 = &array[i]
    lw   t3, 0(t2)          # t3 = array[i]
    add  s2, s2, t3         # sum += array[i]
    addi t0, t0, 1          # i++
    j    loop

done:
    # print result
    addi a0, zero, 1        # ecall 1 = print integer
    mv   a1, s2              # a1 = sum
    ecall                   # print the integer

    # exit
    addi a0, zero, 10       # ecall 10 = exit program
    ecall                   # terminate execution
