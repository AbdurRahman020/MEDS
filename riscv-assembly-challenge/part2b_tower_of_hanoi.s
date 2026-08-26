/*
void hanoi(int n, char from, char to, char aux) {
    if (n == 0) return;
    hanoi(n - 1, from, aux, to);
    printf("Move disk %d from %c to %c\n", n, from, to);
    hanoi(n - 1, aux, to, from);
}

int main() {
    hanoi(4, 'A', 'C', 'B');   // move 4 disks from A to C using B as auxiliary
    return 0;
}
*/


.data
move_msg1: .string "Move disk "
move_msg2: .string " from "
move_msg3: .string " to "
newline:   .string "\n"

.text
.globl main

# hanoi: a0 = n, a1 = from (char), a2 = to (char), a3 = aux (char)
hanoi:
    addi sp, sp, -32               # allocate stack frame (hanoi recurses twice)
    sw   ra, 28(sp)                # save return address
    sw   s0, 24(sp)                # save s0 (holds n)
    sw   s1, 20(sp)                # save s1 (holds from)
    sw   s2, 16(sp)                # save s2 (holds to)
    sw   s3, 12(sp)                # save s3 (holds aux)

    li   t0, 0
    beq  a0, t0, hanoi_done         # if n == 0, return (base case)

    mv   s0, a0                    # s0 = n
    mv   s1, a1                    # s1 = from
    mv   s2, a2                    # s2 = to
    mv   s3, a3                    # s3 = aux

    # hanoi(n-1, from, aux, to)  -- move n-1 disks out of the way onto aux
    addi a0, s0, -1
    mv   a1, s1                    # from
    mv   a2, s3                    # to = aux
    mv   a3, s2                    # aux = to
    call hanoi

    # print "Move disk n from <from> to <to>"
    la   a0, move_msg1
    call print_str
    mv   a0, s0                    # a0 = n (disk number)
    call print_int
    la   a0, move_msg2
    call print_str
    mv   a0, s1                    # from char
    call print_char
    la   a0, move_msg3
    call print_str
    mv   a0, s2                    # to char
    call print_char
    la   a0, newline
    call print_str

    # hanoi(n-1, aux, to, from) -- move the n-1 disks from aux onto to
    addi a0, s0, -1
    mv   a1, s3                    # from = aux
    mv   a2, s2                    # to
    mv   a3, s1                    # aux = from
    call hanoi

hanoi_done:
    lw   ra, 28(sp)
    lw   s0, 24(sp)
    lw   s1, 20(sp)
    lw   s2, 16(sp)
    lw   s3, 12(sp)
    addi sp, sp, 32
    ret

# print_str: a0 = string address
print_str:
    mv   t0, a0
    li   a0, 4                     # ecall 4 = print string
    mv   a1, t0
    ecall
    ret

# print_int: a0 = integer value
print_int:
    mv   t0, a0
    li   a0, 1                     # ecall 1 = print integer
    mv   a1, t0
    ecall
    ret

# print_char: a0 = ASCII value (char)
print_char:
    mv   t0, a0
    li   a0, 11                    # ecall 11 = print character (Venus convention)
    mv   a1, t0
    ecall
    ret

main:
    addi sp, sp, -16
    sw   ra, 12(sp)                # save return address (main calls hanoi)

    li   a0, 4                     # n = 4 disks
    li   a1, 'A'                   # from = 'A'
    li   a2, 'C'                   # to = 'C'
    li   a3, 'B'                   # aux = 'B'
    call hanoi

    lw   ra, 12(sp)
    addi sp, sp, 16

    # exit
    li   a0, 10                    # ecall 10 = exit program
    ecall                          # terminate execution