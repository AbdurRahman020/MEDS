# prime Checker
#
# trial division: check if n is divisible by any number from 2 to sqrt(n)


.data
    msg_prime:    .string " is Prime\n"
    msg_notprime: .string " is Not Prime\n"

.text
.globl main

# main — test prime numbers
main:
    li   a0, 29
    jal  ra, check_prime

    li   a0, 30
    jal  ra, check_prime

    li   a0, 10
    ecall


# check_prime(a0=n) — print whether n is prime
check_prime:
    addi sp, sp, -8
    sw   ra, 0(sp)
    sw   s0, 4(sp)

    mv   s0, a0            # s0 = n

    # print n first
    li   a0, 1
    mv   a1, s0
    ecall

    li   t0, 2             # t0 = divisor = 2

    blt  s0, t0, not_prime # n < 2 -> not prime

prime_loop:
    mul  t1, t0, t0        # t1 = divisor * divisor
    bgt  t1, s0, is_prime  # divisor^2 > n -> prime

    rem  t2, s0, t0        # t2 = n % divisor
    beqz t2, not_prime     # divisible -> not prime

    addi t0, t0, 1
    j    prime_loop

is_prime:
    li   a0, 4
    la   a1, msg_prime
    ecall
    j    prime_done

not_prime:
    li   a0, 4
    la   a1, msg_notprime
    ecall

prime_done:
    lw   ra, 0(sp)
    lw   s0, 4(sp)
    addi sp, sp, 8
    ret
