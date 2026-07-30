# int max(int a, int b) {
#    return (a > b) ? a : b;
# }
#
# int sum_array(int *ptr, int size) {
#    int sum = 0;
#    for (int i = 0; i < size; i++) sum += ptr[i];
#    return sum;
# }
#
# int main() {
#    int m = max(7, 12);
#    int arr[5] = {1, 2, 3, 4, 5};
#    int s = sum_array(arr, 5);
#    printf("%d\n", m);
#    printf("%d\n", s);
#    return 0;
# }


.data
test_array: .word 1, 2, 3, 4, 5

.text
.globl main

max:                          # leaf function: int max(int a, int b) -> a0
    bge  a0, a1, max_done     # if a0 >= a1, a0 already holds the max
    mv   a0, a1               # else max = b
max_done:
    ret                       # return, result in a0

sum_array:                    # leaf function: int sum_array(int *ptr, int size) -> a0
    li   t0, 0                # sum = 0
    li   t1, 0                # i = 0
sum_loop:
    bge  t1, a1, sum_done     # if i >= size, done
    slli t2, t1, 2            # t2 = i * 4
    add  t2, a0, t2           # t2 = ptr + i*4
    lw   t3, 0(t2)            # t3 = ptr[i]
    add  t0, t0, t3           # sum += ptr[i]
    addi t1, t1, 1            # i++
    j    sum_loop
sum_done:
    mv   a0, t0                # return sum in a0
    ret

main:
    addi sp, sp, -16          # allocate stack frame
    sw   ra, 12(sp)           # save return address (main calls other functions)

    # call max(7, 12)
    li   a0, 7                # arg0 = 7
    li   a1, 12               # arg1 = 12
    call max                  # a0 = max(7,12) = 12

    mv   a1, a0               # move result to a1 for printing
    li   a0, 1                # ecall 1 = print integer
    ecall                     # print 12

    # call sum_array(test_array, 5)
    la   a0, test_array       # arg0 = pointer to array
    li   a1, 5                # arg1 = size
    call sum_array            # a0 = sum_array(test_array, 5) = 15

    mv   a1, a0               # move result to a1 for printing
    li   a0, 1                # ecall 1 = print integer
    ecall                     # print 15

    lw   ra, 12(sp)           # restore return address
    addi sp, sp, 16           # deallocate stack frame

    # exit
    li   a0, 10               # ecall 10 = exit program
    ecall                     # terminate execution
