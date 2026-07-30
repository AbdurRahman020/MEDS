# int array[7] = {64, 34, 25, 12, 22, 11, 90};
# 
# int n = 7;
# for (int i = 0; i < n - 1; i++) {
#     for (int j = 0; j < n - 1 - i; j++) {
#         if (array[j] > array[j + 1]) {
#             int tmp      = array[j];
#             array[j]     = array[j + 1];
#             array[j + 1] = tmp;
#        }
#    }
# }
# 
# for (int i = 0; i < n; i++) {
#     printf("%d\n", array[i]);
# }


.data
    array: .word 64, 34, 25, 12, 22, 11, 90

.text
.globl main

main:
    la   s0, array            # s0 = base address of array
    li   s1, 7                # n = array size
    li   t0, 0                # i = 0

outer_loop:
    addi t3, s1, -1           # t3 = n - 1
    bge  t0, t3, print_array  # if i >= n-1, sorting is done

    li   t1, 0                # j = 0
    sub  t4, t3, t0           # t4 = (n-1) - i, inner loop bound

inner_loop:
    bge  t1, t4, inner_done   # if j >= (n-1-i), inner loop done

    slli t2, t1, 2            # t2 = j * 4
    add  t2, s0, t2           # t2 = &array[j]
    lw   t5, 0(t2)            # t5 = array[j]
    lw   t6, 4(t2)            # t6 = array[j+1]

    ble  t5, t6, no_swap      # if array[j] <= array[j+1], no swap needed

    sw   t6, 0(t2)            # array[j] = array[j+1]
    sw   t5, 4(t2)            # array[j+1] = old array[j]

no_swap:
    addi t1, t1, 1            # j++
    j    inner_loop

inner_done:
    addi t0, t0, 1            # i++
    j    outer_loop

print_array:
    li   t0, 0                # i = 0
print_loop:
    bge  t0, s1, exit_prog    # if i >= n, exit
    slli t2, t0, 2            # t2 = i * 4
    add  t2, s0, t2           # t2 = &array[i]
    lw   a1, 0(t2)            # a1 = array[i]
    addi a0, zero, 1          # ecall 1 = print integer
    ecall                     # print the integer
    addi t0, t0, 1            # i++
    j    print_loop

exit_prog:
    addi a0, zero, 10         # ecall 10 = exit program
    ecall                     # terminate execution
