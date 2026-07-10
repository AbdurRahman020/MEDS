# int array[8] = {2, 5, 8, 12, 16, 23, 38, 45};
# 
# int n = 8, target = 23;
# int lo = 0, hi = n - 1, result = -1;
# 
# while (lo <= hi) {
#    int mid = (lo + hi) / 2;
#    if (array[mid] == target) {
#        result = mid;
#        break;
#    } else if (array[mid] < target)
#        lo = mid + 1;
#    else
#        hi = mid - 1;
# }
# 
# printf("%d\n", result);


.data
    array: .word 2, 5, 8, 12, 16, 23, 38, 45

.text
.globl main

main:
    la   s0, array               # s0 = base address of array
    li   s1, 8                   # n = array size
    li   s2, 23                  # target value to search for

    li   t0, 0                   # lo = 0
    addi t1, s1, -1              # hi = n - 1
    li   s3, -1                  # result = -1 (not found)

search_loop:
    blt  t1, t0, search_done     # if hi < lo, stop searching

    add  t2, t0, t1              # t2 = lo + hi
    srai t2, t2, 1               # t2 = mid = (lo + hi) / 2

    slli t3, t2, 2               # t3 = mid * 4
    add  t3, s0, t3              # t3 = &array[mid]
    lw   t4, 0(t3)               # t4 = array[mid]

    beq  t4, s2, found           # if array[mid] == target, found
    blt  t4, s2, go_right        # if array[mid] < target, search right half

    addi t1, t2, -1              # hi = mid - 1
    j    search_loop

go_right:
    addi t0, t2, 1              # lo = mid + 1
    j    search_loop

found:
    mv   s3, t2                 # result = mid

search_done:
    # print result
    addi a0, zero, 1            # ecall 1 = print integer
    mv   a1, s3                 # a1 = result (index or -1)
    ecall                       # print the integer

    # exit
    addi a0, zero, 10           # ecall 10 = exit program
    ecall                       # terminate execution
