.text
.globl main

# // x0 is hardwired to 0 in RISC-V - it cannot be changed
# // this program tries to write -5 into x0 and prints it
# // to prove the write has no effect (result will print as 0, not -5)

main:
    li   x0, -5               # attempt: x0 = -5 -> ignored, x0 stays hardwired to 0

    # print x0 to confirm it's still 0
    li   a0, 1                # ecall 1 = print integer
    mv   a1, x0               # a1 = x0 (always 0, since write was ignored)
    ecall                     # prints 0, NOT -5

    # exit program
    li   a0, 10               # ecall 10 = exit
    ecall                     # terminate execution
