# power x^n — iterative and recursive


.data
    msg_iter: .string "Iterative 2^10: "
    msg_rec:  .string "Recursive 2^10: "
    msg_newln:.string "\n"

.text
.globl main

# main — test iterative and recursive power functions
main:
    # iterative
    li   a0, 2
    li   a1, 10
    jal  ra, power_iter
    mv   s0, a0

    li   a0, 4
    la   a1, msg_iter
    ecall
    li   a0, 1
    mv   a1, s0
    ecall
    li   a0, 4
    la   a1, msg_newln
    ecall

    # recursive
    li   a0, 2
    li   a1, 10
    jal  ra, power_rec
    mv   s0, a0

    li   a0, 4
    la   a1, msg_rec
    ecall
    li   a0, 1
    mv   a1, s0
    ecall
    li   a0, 4
    la   a1, msg_newln
    ecall

    li   a0, 10
    ecall


# power_iter(a0=base, a1=exp) -> a0
power_iter:
    li   t0, 1             # t0 = result = 1

iter_loop:
    beqz a1, iter_done
    mul  t0, t0, a0        # result *= base
    addi a1, a1, -1        # exp--
    j    iter_loop

iter_done:
    mv   a0, t0
    ret


# power_rec(a0=base, a1=exp) -> a0
power_rec:
    addi sp, sp, -12
    sw   ra, 0(sp)
    sw   s0, 4(sp)
    sw   s1, 8(sp)

    mv   s0, a0            # s0 = base
    mv   s1, a1            # s1 = exp

    beqz s1, rec_base_case

    addi a1, s1, -1        # exp - 1
    jal  ra, power_rec     # a0 = power_rec(base, exp-1)
    mul  a0, s0, a0        # base * power_rec(...)
    j    rec_done

rec_base_case:
    li   a0, 1

rec_done:
    lw   ra, 0(sp)
    lw   s0, 4(sp)
    lw   s1, 8(sp)
    addi sp, sp, 12
    ret
