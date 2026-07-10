# int array[10] = {3, -7, 15, 42, -100, 8, -1, 99, 0, -50};
# int max = array[0];
# for (int i = 1; i < 10; i++) {
#    if (array[i] > max) {
#        max = array[i];
#    }
# }
# printf("%d\n", max);


.data
    array: .word 3, -7, 15, 42, -100, 8, -1, 99, 0, -50

.text
.globl main

main:
    la   s0, array          # s0 = base address of array
    li   s1, 10             # array size
    lw   s2, 0(s0)          # max = array[0]
    li   t0, 1              # i = 1

loop:
    bge  t0, s1, done       # if i >= size, exit loop
    slli t1, t0, 2          # t1 = i * 4 (byte offset)
    add  t2, s0, t1         # t2 = &array[i]
    lw   t3, 0(t2)          # t3 = array[i]
    blt  t3, s2, skip       # if array[i] < max, skip update (signed compare)
    mv   s2, t3             # max = array[i]

skip:
    addi t0, t0, 1          # i++
    j    loop

done:
    # print result
    addi a0, zero, 1        # ecall 1 = print integer
    mv   a1, s2             # a1 = max
    ecall                   # print the integer

    # exit
    addi a0, zero, 10       # ecall 10 = exit program
    ecall                   # terminate execution
