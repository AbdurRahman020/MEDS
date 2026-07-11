# int power(int base, int exp) {
#    if (exp == 0) return 1;
#    return base * power(base, exp - 1);
# }
#
# int main() {
#    printf("%d\n", power(2, 10));   // 1024
#    return 0;
# }


.text
.globl main

power:
    addi sp, sp, -16          # allocate stack frame
    sw   ra, 12(sp)           # save return address (power calls itself)
    sw   s0, 8(sp)            # save s0 (holds base, preserved across recursive call)

    mv   s0, a0               # s0 = base
    beqz a1, base_case        # if exp == 0, return 1 (pseudo: beq a1, zero, base_case)

    addi a1, a1, -1           # a1 = exp - 1  (a0 still holds base, unchanged)
    call power                # a0 = power(base, exp-1)

    mul  a0, s0, a0           # a0 = base * power(base, exp-1)
    j    power_ret

base_case:
    li   a0, 1

power_ret:
    lw   s0, 8(sp)            # restore s0
    lw   ra, 12(sp)           # restore return address
    addi sp, sp, 16           # deallocate stack frame
    ret

main:
    addi sp, sp, -16
    sw   ra, 12(sp)           # save return address (main calls power)

    li   a0, 2                # base = 2
    li   a1, 10               # exp = 10
    call power                # a0 = power(2,10) = 1024

    mv   a1, a0               # move result to a1 for printing
    li   a0, 1                # ecall 1 = print integer
    ecall                     # print 1024

    lw   ra, 12(sp)
    addi sp, sp, 16

    # exit
    li   a0, 10               # ecall 10 = exit program
    ecall                     # terminate execution
