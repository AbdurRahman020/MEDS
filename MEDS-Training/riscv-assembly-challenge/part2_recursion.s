/*
int cache[21];   // memoization cache, -1 means "not computed"

int fib(int n) {
    if (n == 0) return 0;
    if (n == 1) return 1;
    if (cache[n] != -1) return cache[n];
    int result = fib(n - 1) + fib(n - 2);
    cache[n] = result;
    return result;
}

int main() {
    // cache is pre-initialized to -1 in .data
    printf("fib(10) = %d\n", fib(10));   // 55
    printf("fib(15) = %d\n", fib(15));   // 610
    printf("fib(20) = %d\n", fib(20));   // 6765
    return 0;
}
*/

.data
# cache[0..20], pre-filled with -1 = "not yet computed"
cache: .word -1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1

label10:  .string "fib(10) = "
label15:  .string "fib(15) = "
label20:  .string "fib(20) = "
newline:  .string "\n"

.text
.globl main

# fib: a0 = n -> a0 = fib(n), using cache[] for memoization
fib:
    addi sp, sp, -16                   # allocate stack frame (fib calls itself recursively)
    sw   ra, 12(sp)                    # save return address
    sw   s0, 8(sp)                     # save s0 (holds n, preserved across recursive calls)
    sw   s1, 4(sp)                     # save s1 (holds fib(n-1), preserved across 2nd call)

    mv   s0, a0                        # s0 = n

    li   t0, 0
    beq  s0, t0, base_zero             # if n == 0, return 0
    li   t0, 1
    beq  s0, t0, base_one              # if n == 1, return 1

    # check cache[n]
    la   t1, cache                     # t1 = base address of cache
    slli t2, s0, 2                     # t2 = n * 4
    add  t2, t1, t2                    # t2 = &cache[n]
    lw   t3, 0(t2)                     # t3 = cache[n]
    li   t4, -1
    beq  t3, t4, compute               # if cache[n] == -1, not yet computed
    mv   a0, t3                        # else return cached value
    j    fib_ret

compute:
    addi a0, s0, -1                   # a0 = n - 1
    call fib                          # a0 = fib(n-1)
    mv   s1, a0                       # s1 = fib(n-1), save before next call

    addi a0, s0, -2                   # a0 = n - 2
    call fib                          # a0 = fib(n-2)

    add  a0, s1, a0                   # a0 = fib(n-1) + fib(n-2)

    # store result in cache[n]
    la   t1, cache
    slli t2, s0, 2
    add  t2, t1, t2
    sw   a0, 0(t2)                    # cache[n] = result
    j    fib_ret

base_zero:
    li   a0, 0
    j    fib_ret

base_one:
    li   a0, 1

fib_ret:
    lw   s1, 4(sp)                    # restore s1
    lw   s0, 8(sp)                    # restore s0
    lw   ra, 12(sp)                   # restore return address
    addi sp, sp, 16                   # deallocate stack frame
    ret

# print_result: a0 = label address, a1 = int value -> prints "<label><value>\n"
print_result:
    mv   t1, a0
    mv   t0, a1
    li   a0, 4
    mv   a1, t1
    ecall
    li   a0, 1
    mv   a1, t0
    ecall
    li   a0, 4
    la   a1, newline
    ecall
    ret

main:
    addi sp, sp, -16
    sw   ra, 12(sp)                   # save return address (main calls fib)

    # fib(10)
    li   a0, 10
    call fib
    mv   a1, a0
    la   a0, label10
    call print_result

    # fib(15) -- reuses cache built up from fib(10)
    li   a0, 15
    call fib
    mv   a1, a0
    la   a0, label15
    call print_result

    # fib(20) -- reuses cache built up from fib(10) and fib(15)
    li   a0, 20
    call fib
    mv   a1, a0
    la   a0, label20
    call print_result

    lw   ra, 12(sp)
    addi sp, sp, 16

    # exit
    li   a0, 10                       # ecall 10 = exit program
    ecall                             # terminate execution
