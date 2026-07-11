#  int fib(int n) {
#    if (n == 0) return 0;
#    if (n == 1) return 1;
#    return fib(n - 1) + fib(n - 2);
# }
# 
# int main() {
#    printf("%d\n", fib(10));   // 55
#    return 0;
# }


.text
.globl main

fib:
    addi sp, sp, -16            # allocate 16-byte stack frame
    sw   ra, 12(sp)             # save return address (fib calls itself)
    sw   s0, 8(sp)              # save s0 (holds n, preserved across calls)
    sw   s1, 4(sp)              # save s1 (holds fib(n-1), preserved across 2nd call)

    mv   s0, a0                 # s0 = n

    li   t0, 0
    beq  s0, t0, base_zero      # if n == 0, return 0
    li   t0, 1
    beq  s0, t0, base_one       # if n == 1, return 1

    addi a0, s0, -1             # a0 = n - 1
    call fib                    # a0 = fib(n-1)
    mv   s1, a0                 # s1 = fib(n-1), save before next call

    addi a0, s0, -2             # a0 = n - 2
    call fib                    # a0 = fib(n-2)

    add  a0, s1, a0             # a0 = fib(n-1) + fib(n-2)
    j    fib_ret

base_zero:
    li   a0, 0
    j    fib_ret

base_one:
    li   a0, 1

fib_ret:
    lw   s1, 4(sp)              # restore s1
    lw   s0, 8(sp)              # restore s0
    lw   ra, 12(sp)             # restore return address
    addi sp, sp, 16             # deallocate stack frame
    ret

main:
    addi sp, sp, -16
    sw   ra, 12(sp)             # save return address (main calls fib)

    li   a0, 10                 # n = 10
    call fib                    # a0 = fib(10) = 55

    mv   a1, a0                 # move result to a1 for printing
    li   a0, 1                  # ecall 1 = print integer
    ecall                       # print 55

    lw   ra, 12(sp)
    addi sp, sp, 16

    # exit
    li   a0, 10                # ecall 10 = exit program
    ecall                      # terminate execution
