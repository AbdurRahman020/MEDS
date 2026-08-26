# Reverse entire string character by character


.data
    str:   .string "the quick brown fox jumps over the lazy dog"
    newln: .string "\n"

.text
.globl main

# main — find the end of the string and print it in reverse
main:
    la   s0, str
    mv   s1, s0

find_end:
    # find the end of the string 
    lbu  t0, 0(s1)
    beqz t0, end_found
    addi s1, s1, 1
    j    find_end

end_found:
    # print the string in reverse
    addi s1, s1, -1

print_loop:
    # print characters in reverse order
    blt  s1, s0, print_done

    lbu  a1, 0(s1)
    li   a0, 11
    ecall

    addi s1, s1, -1
    j    print_loop

print_done:
    # print newline
    li   a0, 4
    la   a1, newln
    ecall

    li   a0, 10
    ecall
