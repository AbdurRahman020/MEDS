# int array[6] = {1, 2, 3, 4, 5, 6};
# int n = 6;
# for (int i = 0, j = n - 1; i < j; i++, j--) {
#    int tmp   = array[i];
#    array[i]  = array[j];
#    array[j]  = tmp;
# }
# 
# for (int i = 0; i < n; i++) {
#    printf("%d\n", array[i]);
# }


.data
    array: .word 1, 2, 3, 4, 5, 6

.text
.globl main

main:
    la   s0, array              # s0 = base address of array
    li   s1, 6                  # n = array size
    li   t0, 0                  # i = 0
    addi t1, s1, -1             # j = n - 1

swap_loop:
    bge  t0, t1, print_array    # if i >= j, swapping is done

    slli t2, t0, 2              # t2 = i * 4
    add  t2, s0, t2             # t2 = &array[i]
    slli t3, t1, 2              # t3 = j * 4
    add  t3, s0, t3             # t3 = &array[j]

    lw   t4, 0(t2)              # t4 = array[i]
    lw   t5, 0(t3)              # t5 = array[j]
    sw   t5, 0(t2)              # array[i] = array[j]
    sw   t4, 0(t3)              # array[j] = old array[i]

    addi t0, t0, 1              # i++
    addi t1, t1, -1             # j--
    j    swap_loop

print_array:
    li   t0, 0                  # i = 0
print_loop:
    bge  t0, s1, exit_prog      # if i >= n, exit
    slli t2, t0, 2              # t2 = i * 4
    add  t2, s0, t2             # t2 = &array[i]
    lw   a1, 0(t2)              # a1 = array[i]
    addi a0, zero, 1            # ecall 1 = print integer
    ecall                       # print the integer
    addi t0, t0, 1              # i++
    j    print_loop

exit_prog:
    addi a0, zero, 10           # ecall 10 = exit program
    ecall                       # terminate execution
