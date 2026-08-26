/*
int array[12] = {5, -3, 12, -8, 0, 45, -1, 22, -17, 9, -100, 33};
int temp[12];   // scratch buffer for merging

void merge_sort(int *arr, int left, int right) {
    if (left >= right) return;          // base case: 0 or 1 element
    int mid = (left + right) / 2;
    merge_sort(arr, left, mid);
    merge_sort(arr, mid + 1, right);
    merge(arr, left, mid, right);
}

void merge(int *arr, int left, int mid, int right) {
    int i = left, j = mid + 1, k = left;
    while (i <= mid && j <= right) {
        if (arr[i] <= arr[j]) temp[k++] = arr[i++];
        else                  temp[k++] = arr[j++];
    }
    while (i <= mid)   temp[k++] = arr[i++];
    while (j <= right) temp[k++] = arr[j++];
    for (int x = left; x <= right; x++) arr[x] = temp[x];
}

int main() {
    merge_sort(array, 0, 11);
    for (int i = 0; i < 12; i++) printf("%d ", array[i]);
    return 0;
}
*/


.data
array:      .word 5, -3, 12, -8, 0, 45, -1, 22, -17, 9, -100, 33
temp:       .word 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
size:       .word 12

sorted_msg: .string "Sorted array: "
space:      .string " "
newline:    .string "\n"

.text
.globl main

# merge_sort: a0 = arr_ptr, a1 = left, a2 = right
merge_sort:
    addi sp, sp, -32
    sw   ra, 28(sp)                # save return address (recurses twice)
    sw   s0, 24(sp)                # s0 = arr_ptr
    sw   s1, 20(sp)                # s1 = left
    sw   s2, 16(sp)                # s2 = right
    sw   s3, 12(sp)                # s3 = mid

    bge  a1, a2, ms_done           # if left >= right, base case, return

    mv   s0, a0
    mv   s1, a1
    mv   s2, a2

    # mid = (left + right) / 2
    add  t0, s1, s2
    srai s3, t0, 1                  # s3 = mid

    # merge_sort(arr, left, mid)
    mv   a0, s0
    mv   a1, s1
    mv   a2, s3
    call merge_sort

    # merge_sort(arr, mid+1, right)
    mv   a0, s0
    addi a1, s3, 1
    mv   a2, s2
    call merge_sort

    # merge(arr, left, mid, right)
    mv   a0, s0
    mv   a1, s1
    mv   a2, s3
    mv   a3, s2
    call merge

ms_done:
    lw   ra, 28(sp)
    lw   s0, 24(sp)
    lw   s1, 20(sp)
    lw   s2, 16(sp)
    lw   s3, 12(sp)
    addi sp, sp, 32
    ret

# merge: a0 = arr_ptr, a1 = left, a2 = mid, a3 = right
# merges arr[left..mid] and arr[mid+1..right] using temp[] as scratch space
merge:
    addi sp, sp, -48
    sw   ra, 44(sp)
    sw   s0, 40(sp)                # s0 = arr_ptr
    sw   s1, 36(sp)                # s1 = i (index into left half)
    sw   s2, 32(sp)                # s2 = j (index into right half)
    sw   s3, 28(sp)                # s3 = k (index into temp)
    sw   s4, 24(sp)                # s4 = mid
    sw   s5, 20(sp)                # s5 = right
    sw   s6, 16(sp)                # s6 = left (needed later for copy-back loop)

    mv   s0, a0
    mv   s6, a1                    # left
    mv   s4, a2                    # mid
    mv   s5, a3                    # right

    mv   s1, s6                    # i = left
    addi s2, s4, 1                 # j = mid + 1
    mv   s3, s6                    # k = left

merge_loop:
    bgt  s1, s4, merge_left_done   # if i > mid, left half exhausted
    bgt  s2, s5, merge_left_done   # if j > right, right half exhausted

    # t0 = &arr[i], t1 = &arr[j]
    slli t0, s1, 2
    add  t0, s0, t0
    lw   t2, 0(t0)                 # t2 = arr[i]
    slli t1, s2, 2
    add  t1, s0, t1
    lw   t3, 0(t1)                 # t3 = arr[j]

    bgt  t2, t3, merge_take_right  # if arr[i] > arr[j], take from right

    # take arr[i] -> temp[k]
    la   t4, temp
    slli t5, s3, 2
    add  t4, t4, t5
    sw   t2, 0(t4)
    addi s1, s1, 1                 # i++
    addi s3, s3, 1                 # k++
    j    merge_loop

merge_take_right:
    la   t4, temp
    slli t5, s3, 2
    add  t4, t4, t5
    sw   t3, 0(t4)
    addi s2, s2, 1                 # j++
    addi s3, s3, 1                 # k++
    j    merge_loop

merge_left_done:
    bgt  s1, s4, merge_right_done  # if left half already exhausted, skip
copy_left:
    slli t0, s1, 2
    add  t0, s0, t0
    lw   t2, 0(t0)                 # arr[i]
    la   t4, temp
    slli t5, s3, 2
    add  t4, t4, t5
    sw   t2, 0(t4)                 # temp[k] = arr[i]
    addi s1, s1, 1
    addi s3, s3, 1
    ble  s1, s4, copy_left

merge_right_done:
    bgt  s2, s5, copy_back         # if right half already exhausted, skip
copy_right:
    slli t1, s2, 2
    add  t1, s0, t1
    lw   t3, 0(t1)                 # arr[j]
    la   t4, temp
    slli t5, s3, 2
    add  t4, t4, t5
    sw   t3, 0(t4)                 # temp[k] = arr[j]
    addi s2, s2, 1
    addi s3, s3, 1
    ble  s2, s5, copy_right

copy_back:
    mv   t6, s6                    # t6 = x = left
copy_back_loop:
    bgt  t6, s5, merge_done        # if x > right, done copying
    slli t0, t6, 2
    la   t4, temp
    add  t4, t4, t0
    lw   t2, 0(t4)                 # temp[x]
    add  t1, s0, t0
    sw   t2, 0(t1)                 # arr[x] = temp[x]
    addi t6, t6, 1
    j    copy_back_loop

merge_done:
    lw   ra, 44(sp)
    lw   s0, 40(sp)
    lw   s1, 36(sp)
    lw   s2, 32(sp)
    lw   s3, 28(sp)
    lw   s4, 24(sp)
    lw   s5, 20(sp)
    lw   s6, 16(sp)
    addi sp, sp, 48
    ret

# print_result: a0 = int value -> prints "<value> "
print_result:
    mv   t0, a0
    li   a0, 1                     # ecall 1 = print integer
    mv   a1, t0
    ecall
    li   a0, 4                     # ecall 4 = print string
    la   a1, space
    ecall
    ret

main:
    addi sp, sp, -16
    sw   ra, 12(sp)                 # save return address (main calls merge_sort)

    la   a0, array
    li   a1, 0                      # left = 0
    li   a2, 11                     # right = size - 1 = 11
    call merge_sort

    # print sorted array
    li   a0, 4
    la   a1, sorted_msg
    ecall

    la   s0, array                  # s0 = array pointer (callee-saved across loop)
    li   s1, 0                      # i = 0
print_loop:
    li   t0, 12
    bge  s1, t0, print_done
    slli t1, s1, 2
    add  t1, s0, t1
    lw   a0, 0(t1)
    call print_result
    addi s1, s1, 1
    j    print_loop
print_done:
    li   a0, 4
    la   a1, newline
    ecall

    lw   ra, 12(sp)
    addi sp, sp, 16

    # exit
    li   a0, 10                     # ecall 10 = exit program
    ecall                           # terminate execution