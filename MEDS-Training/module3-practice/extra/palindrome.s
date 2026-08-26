# palindrome checker


.data
    str1:     .string "level"
    str2:     .string "hello"
    msg_true: .string " -> Palindrome\n"
    msg_false:.string " -> Not Palindrome\n"

.text
.globl main

main:
    # check "level"
    la   a0, str1
    li   a1, 5
    jal  ra, check_palindrome

    # check "hello"
    la   a0, str2
    li   a1, 5
    jal  ra, check_palindrome

    # exit program
    li   a0, 10
    ecall


# check_palindrome(a0=str_ptr, a1=length)
# print the string and report whether it is a palindrome

check_palindrome:
    addi sp, sp, -16
    sw   ra, 0(sp)
    sw   s0, 4(sp)
    sw   s1, 8(sp)
    sw   s2, 12(sp)

    mv   s0, a0                # s0 = str base
    mv   s1, a1                # s1 = length

    # print the string
    li   a0, 4
    mv   a1, s0
    ecall

    # initialize pointers at both ends of the string
    li   t1, 0                 # i = 0
    addi t2, s1, -1            # j = length - 1

while_:
    # stop when the two pointers meet or cross
    bge  t1, t2, pal

    # load characters at positions i and j
    add  t5, s0, t1
    lbu  t3, 0(t5)             # str[i]

    add  t6, s0, t2
    lbu  t4, 0(t6)             # str[j]

    # mismatched characters mean the string is not a palindrome
    bne  t3, t4, not_pal

    # move both pointers toward the center
    addi t1, t1, 1             # i++
    addi t2, t2, -1            # j--
    j    while_

pal:
    # all character pairs matched
    li   a0, 4
    la   a1, msg_true
    ecall
    j    pal_done

not_pal:
    # a character pair did not match
    li   a0, 4
    la   a1, msg_false
    ecall

pal_done:
    # restore saved registers and return
    lw   ra, 0(sp)
    lw   s0, 4(sp)
    lw   s1, 8(sp)
    lw   s2, 12(sp)
    addi sp, sp, 16
    ret
