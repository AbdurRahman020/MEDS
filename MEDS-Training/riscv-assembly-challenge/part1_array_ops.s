/*
int array[12] = {5, -3, 12, -8, 0, 45, -1, 22, -17, 9, -100, 33};

int sum_array(int *ptr, int size) {
    int sum = 0;
    for (int i = 0; i < size; i++) sum += ptr[i];
    return sum;
}
int find_min(int *ptr, int size) {
    int min = ptr[0];
    for (int i = 1; i < size; i++) if (ptr[i] < min) min = ptr[i];
    return min;
}
int find_max(int *ptr, int size) {
    int max = ptr[0];
    for (int i = 1; i < size; i++) if (ptr[i] > max) max = ptr[i];
    return max;
}
int count_negative(int *ptr, int size) {
    int count = 0;
    for (int i = 0; i < size; i++) if (ptr[i] < 0) count++;
    return count;
}
int main() {
    printf("Sum: %d\n", sum_array(array, 12));
    printf("Min: %d\n", find_min(array, 12));
    printf("Max: %d\n", find_max(array, 12));
    printf("Negative count: %d\n", count_negative(array, 12));
    return 0;
}
*/

.data
array:     .word 5, -3, 12, -8, 0, 45, -1, 22, -17, 9, -100, 33

sum_label: .string "Sum: "
min_label: .string "Min: "
max_label: .string "Max: "
neg_label: .string "Negative count: "
newline:   .string "\n"

.text
.globl main

# sum_array: a0 = array_ptr, a1 = size -> a0 = sum
# Leaf function: only uses t-regs, no stack frame needed
sum_array:
    li   t0, 0                    # sum = 0
    li   t1, 0                    # i = 0
sum_loop:
    bge  t1, a1, sum_done         # if i >= size, done
    slli t2, t1, 2                # t2 = i * 4
    add  t2, a0, t2               # t2 = &array[i]
    lw   t3, 0(t2)                # t3 = array[i]
    add  t0, t0, t3               # sum += array[i]
    addi t1, t1, 1                # i++
    j    sum_loop
sum_done:
    mv   a0, t0                   # return sum
    ret

# find_min: a0 = array_ptr, a1 = size -> a0 = min (signed)
find_min:
    lw   t0, 0(a0)                # min = array[0]
    li   t1, 1                    # i = 1
find_min_loop:
    bge  t1, a1, find_min_done    # if i >= size, done
    slli t2, t1, 2                # t2 = i * 4
    add  t2, a0, t2               # t2 = &array[i]
    lw   t3, 0(t2)                # t3 = array[i]
    bge  t3, t0, find_min_skip    # if array[i] >= min, skip update
    mv   t0, t3                   # min = array[i]
find_min_skip:
    addi t1, t1, 1                # i++
    j    find_min_loop
find_min_done:
    mv   a0, t0                   # return min
    ret

# find_max: a0 = array_ptr, a1 = size -> a0 = max (signed)
find_max:
    lw   t0, 0(a0)               # max = array[0]
    li   t1, 1                   # i = 1
find_max_loop:
    bge  t1, a1, find_max_done   # if i >= size, done
    slli t2, t1, 2               # t2 = i * 4
    add  t2, a0, t2              # t2 = &array[i]
    lw   t3, 0(t2)               # t3 = array[i]
    ble  t3, t0, find_max_skip   # if array[i] <= max, skip update
    mv   t0, t3                  # max = array[i]
find_max_skip:
    addi t1, t1, 1                # i++
    j    find_max_loop
find_max_done:
    mv   a0, t0                   # return max
    ret

# count_negative: a0 = array_ptr, a1 = size -> a0 = count of negatives
count_negative:
    li   t0, 0                    # count = 0
    li   t1, 0                    # i = 0
count_neg_loop:
    bge  t1, a1, count_neg_done   # if i >= size, done
    slli t2, t1, 2                # t2 = i * 4
    add  t2, a0, t2               # t2 = &array[i]
    lw   t3, 0(t2)                # t3 = array[i]
    bge  t3, zero, count_neg_skip # if array[i] >= 0, skip
    addi t0, t0, 1                # count++
count_neg_skip:
    addi t1, t1, 1                # i++
    j    count_neg_loop
count_neg_done:
    mv   a0, t0                   # return count
    ret

# print_result: a0 = label address, a1 = int value -> prints "<label><value>\n"
# Leaf function: only uses t-regs, no stack frame needed
print_result:
    mv   t1, a0                  # save label address
    mv   t0, a1                  # save value
    li   a0, 4                   # ecall 4 = print string
    mv   a1, t1
    ecall
    li   a0, 1                   # ecall 1 = print integer
    mv   a1, t0
    ecall
    li   a0, 4                   # ecall 4 = print string
    la   a1, newline
    ecall
    ret

main:
    addi sp, sp, -16             # allocate stack frame (main calls other functions)
    sw   ra, 12(sp)              # save return address

    la   s0, array               # s0 = array base pointer (callee-saved, reused per call)
    li   s1, 12                  # s1 = array size (callee-saved, reused per call)

    # Sum
    mv   a0, s0
    mv   a1, s1
    call sum_array
    mv   a1, a0
    la   a0, sum_label
    call print_result

    # Min
    mv   a0, s0
    mv   a1, s1
    call find_min
    mv   a1, a0
    la   a0, min_label
    call print_result

    # Max
    mv   a0, s0
    mv   a1, s1
    call find_max
    mv   a1, a0
    la   a0, max_label
    call print_result

    # Negative count
    mv   a0, s0
    mv   a1, s1
    call count_negative
    mv   a1, a0
    la   a0, neg_label
    call print_result

    lw   ra, 12(sp)             # restore return address
    addi sp, sp, 16             # deallocate stack frame

    # exit
    li   a0, 10                 # ecall 10 = exit program
    ecall                       # terminate execution
