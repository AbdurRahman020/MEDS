# bubble sort: sort an integer array in ascending order
#
# Strategy (outer/inner nested loops):
#   for i = 0 to n-1:
#       for j = 0 to n-i-2:
#           if arr[j] > arr[j+1]: swap them
#
# each pass bubbles the largest unsorted element to its final position


.data
    arr:      .word 64, 34, 25, 12, 22, 11, 90
    n:        .word 7

    msg_before: .string "Before: "
    msg_after:  .string "After:  "
    msg_space:  .string " "
    msg_newln:  .string "\n"

.text
.globl main

main:
    # print label then array before sorting
    li   a0, 4
    la   a1, msg_before
    ecall
    
    la   a0, arr
    lw   a1, n
    jal  ra, print_arr

    # sort array in ascending order
    la   a0, arr
    lw   a1, n
    jal  ra, bubble_sort

    # print label then array after sorting
    li   a0, 4
    la   a1, msg_after
    ecall

    la   a0, arr
    lw   a1, n
    jal  ra, print_arr

    # exit program
    li   a0, 10
    ecall


# bubble_sort(a0=arr_ptr, a1=n)
# Sort the array in ascending order using bubble sort

bubble_sort:
    addi sp, sp, -16
    sw   ra, 0(sp)
    sw   s0, 4(sp)
    sw   s1, 8(sp)
    sw   s2, 12(sp)

    mv   s0, a0                # s0 = arr base
    mv   s1, a1                # s1 = n
    li   s2, 0                 # s2 = i = 0

outer_loop:
    bge  s2, s1, sort_done     # i >= n -> done

    # inner loop compares adjacent elements
    li   t0, 0                 # t0 = j = 0
    sub  t1, s1, s2            # t1 = n - i
    addi t1, t1, -1            # t1 = n - i - 1

inner_loop:
    bge  t0, t1, outer_next    # j >= n-i-1 -> next outer pass

    # Load arr[j] and arr[j+1]
    slli t2, t0, 2
    add  t3, s0, t2
    lw   t4, 0(t3)             # t4 = arr[j]
    lw   t5, 4(t3)             # t5 = arr[j+1]

    # swap if elements are out of order
    ble  t4, t5, no_swap       # arr[j] <= arr[j+1] -> no swap

    sw   t5, 0(t3)             # arr[j] = arr[j+1]
    sw   t4, 4(t3)             # arr[j+1] = arr[j]

no_swap:
    addi t0, t0, 1             # j++
    j    inner_loop

outer_next:
    addi s2, s2, 1             # i++
    j    outer_loop

sort_done:
    # restore registers and return
    lw   ra, 0(sp)
    lw   s0, 4(sp)
    lw   s1, 8(sp)
    lw   s2, 12(sp)
    addi sp, sp, 16
    ret


# print_arr(a0=arr_ptr, a1=n)
# print all array elements separated by spaces

print_arr:
    addi sp, sp, -12
    sw   ra, 0(sp)
    sw   s0, 4(sp)
    sw   s1, 8(sp)

    mv   s0, a0                # s0 = arr base
    mv   s1, a1                # s1 = n
    li   t0, 0                 # t0 = index

pa_loop:
    bge  t0, s1, pa_done

    # load and print arr[index]
    slli t1, t0, 2
    add  t1, s0, t1
    lw   a1, 0(t1)

    li   a0, 1
    ecall

    # print space after element
    li   a0, 4
    la   a1, msg_space
    ecall

    addi t0, t0, 1
    j    pa_loop

pa_done:
    # print newline
    li   a0, 4
    la   a1, msg_newln
    ecall

    # restore registers and return
    lw   ra, 0(sp)
    lw   s0, 4(sp)
    lw   s1, 8(sp)
    addi sp, sp, 12
    ret
