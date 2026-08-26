# count set bits (Popcount): count how many bits are 1 in a 32-bit integer
#
# strategy:
#   - check the LSB
#   - add it to the count
#   - shift the number right
#   - repeat 32 times


.data
    msg_num:  .string "Number: "
    msg_bits: .string "Set bits: "
    msg_newln:.string "\n"

.text
.globl main

main:
    # count set bits in 29
    li   a0, 29
    jal  ra, popcount
    mv   s0, a0                 # s0 = result

    # print original number
    li   a0, 4
    la   a1, msg_num
    ecall

    li   a0, 1
    li   a1, 29
    ecall

    li   a0, 4
    la   a1, msg_newln
    ecall

    # print set-bit count
    li   a0, 4
    la   a1, msg_bits
    ecall

    li   a0, 1
    mv   a1, s0
    ecall

    li   a0, 4
    la   a1, msg_newln
    ecall

    # exit program
    li   a0, 10
    ecall


# popcount(a0=n) -> a0=number of 1 bits
# check each bit from LSB to MSB and count the 1s

popcount:
    li   t0, 0                  # t0 = count
    li   t1, 32                 # t1 = number of bits

pop_loop:
    beqz t1, pop_done

    # check the current LSB
    andi t2, a0, 1              # t2 = n & 1
    add  t0, t0, t2             # count += LSB

    # move to the next bit
    srli a0, a0, 1              # n >>= 1

    addi t1, t1, -1             # iterations--
    j    pop_loop

pop_done:
    # return count in a0
    mv   a0, t0
    ret
