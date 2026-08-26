# atoi — String to Integer
# Convert an ASCII string to an integer.
#
# Strategy:
#   result = 0
#   for each char c in string:
#       if c < '0' or c > '9': stop
#       result = result * 10 + (c - '0')
#
# Example:
#   "1234"  -> 1234
#   "-5678" -> -5678

.data
    str_pos: .string "1234"
    str_neg: .string "-5678"

    msg_result: .string "Result: "
    msg_newln:  .string "\n"

.text
.globl main

main:
    # Convert and print positive number
    la   a0, str_pos
    jal  ra, atoi
    mv   s0, a0

    li   a0, 4
    la   a1, msg_result
    ecall

    li   a0, 1
    mv   a1, s0
    ecall

    li   a0, 4
    la   a1, msg_newln
    ecall

    # Convert and print negative number
    la   a0, str_neg
    jal  ra, atoi
    mv   s0, a0

    li   a0, 4
    la   a1, msg_result
    ecall

    li   a0, 1
    mv   a1, s0
    ecall

    li   a0, 4
    la   a1, msg_newln
    ecall

    # Exit program
    li   a0, 10
    ecall


# atoi(a0=str_ptr) -> a0=integer
# Convert a null-terminated ASCII string to an integer.

atoi:
    li   t0, 0                 # t0 = result
    li   t1, 0                 # t1 = negative flag

    # Check for optional negative sign
    lbu  t2, 0(a0)             # first character

    li   t3, '-'
    bne  t2, t3, atoi_loop     # not '-', process digits

    li   t1, 1                 # negative flag = 1
    addi a0, a0, 1             # skip '-'

atoi_loop:
    # Read and validate the current character
    lbu  t2, 0(a0)             # t2 = current character
    beqz t2, atoi_done         # null terminator -> done

    li   t3, '0'
    blt  t2, t3, atoi_done     # char < '0' -> stop

    li   t3, '9'
    bgt  t2, t3, atoi_done     # char > '9' -> stop

    # Convert ASCII digit to its numeric value
    addi t2, t2, -48           # t2 = digit value (c - '0')

    # result = result * 10 + digit
    li   t3, 10
    mul  t0, t0, t3
    add  t0, t0, t2

    # Move to the next character
    addi a0, a0, 1
    j    atoi_loop

atoi_done:
    # Apply negative sign if necessary
    beqz t1, atoi_return
    neg  t0, t0

atoi_return:
    # Return result in a0
    mv   a0, t0
    ret
