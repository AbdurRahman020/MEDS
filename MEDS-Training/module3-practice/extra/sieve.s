# Sieve of Eratosthenes (find all primes up to N)
#
# strategy:
#   - allocate boolean array is_prime[0..N], initialize all to 1
#   - for each p from 2 to sqrt(N), if is_prime[p], mark all multiples as 0
#   - print all indices where is_prime[i] == 1


.data
    N:          .word 50
    is_prime:   .space 51
    msg_header: .string "Primes up to 50:\n"
    msg_space:  .string " "
    msg_newln:  .string "\n"

.text
.globl main

main:
    # print header
    li   a0, 4
    la   a1, msg_header
    ecall

    # initialize is_prime[0..N] to 1
    la   t0, is_prime
    li   t1, 0                # index
    lw   t2, N                # t2 = N

init_loop:
    bgt  t1, t2, init_done
    add  t3, t0, t1
    li   t4, 1
    sb   t4, 0(t3)            # is_prime[i] = 1
    addi t1, t1, 1
    j    init_loop

init_done:
    # 0 and 1 are not prime
    la   t0, is_prime
    sb   zero, 0(t0)
    sb   zero, 1(t0)

    # sieve candidate primes up to sqrt(N)
    li   s0, 2                # s0 = p

sieve_outer:
    mul  t0, s0, s0
    lw   t1, N
    bgt  t0, t1, sieve_done   # p*p > N -> done

    la   t2, is_prime
    add  t3, t2, s0
    lbu  t4, 0(t3)
    beqz t4, next_p            # is_prime[p] == 0 -> skip

    # mark multiples of p starting from p*p
    mul  s1, s0, s0            # s1 = p*p

mark_loop:
    lw   t0, N
    bgt  s1, t0, next_p

    la   t2, is_prime
    add  t3, t2, s1
    sb   zero, 0(t3)           # is_prime[s1] = 0

    add  s1, s1, s0            # next multiple
    j    mark_loop

next_p:
    # move to next candidate
    addi s0, s0, 1
    j    sieve_outer

sieve_done:
    # print all remaining primes
    li   s2, 2                 # s2 = index

print_loop:
    lw   t0, N
    bgt  s2, t0, print_done

    la   t1, is_prime
    add  t2, t1, s2
    lbu  t3, 0(t2)
    beqz t3, skip_print

    li   a0, 1
    mv   a1, s2
    ecall

    li   a0, 4
    la   a1, msg_space
    ecall

skip_print:
    addi s2, s2, 1
    j    print_loop

print_done:
    # print newline and exit
    li   a0, 4
    la   a1, msg_newln
    ecall

    li   a0, 10
    ecall
