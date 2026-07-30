# int funcB(int x) {
#     return x * 2;
# }
# 
# int funcA(int x) {
#    int doubled = funcB(x);
#    return doubled + 1;
# }
# 
# int main() {
#    printf("%d\n", funcA(5));   // funcB(5)=10, funcA(5)=11
#    return 0;
# }


.text
.globl main

funcB:                        # leaf function: int funcB(int x) -> x * 2
    slli a0, a0, 1            # a0 = x * 2 (shift left by 1)
    ret                       # return, result in a0

funcA:                        # non-leaf: called by main AND calls funcB (nested call)
    addi sp, sp, -16          # allocate stack frame
    sw   ra, 12(sp)           # save return address (funcA itself calls funcB)
    sw   s0, 8(sp)            # save s0 (holds x, preserved across the call to funcB)

    mv   s0, a0                # s0 = x
    call funcB                 # a0 = funcB(x) = x*2  <- step through here in Venus
    addi a0, a0, 1             # a0 = doubled + 1

    lw   s0, 8(sp)             # restore s0
    lw   ra, 12(sp)            # restore return address
    addi sp, sp, 16            # deallocate stack frame
    ret                        # return to main

main:
    addi sp, sp, -16
    sw   ra, 12(sp)            # save return address (main calls funcA)

    li   a0, 5                 # arg = 5
    call funcA                 # a0 = funcA(5) = 11 (nested call: funcA -> funcB)

    mv   a1, a0                # move result to a1 for printing
    li   a0, 1                 # ecall 1 = print integer
    ecall                      # print 11

    lw   ra, 12(sp)
    addi sp, sp, 16

    # exit
    li   a0, 10                # ecall 10 = exit program
    ecall                      # terminate execution
