# stack
#
# node layout: each element is a 4-byte word
#   top = -1 means empty;
#   top = MAX-1 means full
#
# operations:
#   push(value) — add value on top
#   pop         — remove and print top value
#   peek        — print top value without removing
#   is_empty    — print Empty/Not Empty
#   print_stack — print all elements top to bottom


.data
    MAX:        .word 10            # max stack size
    stack_arr:  .space 40           # 10 words * 4 bytes
    top:        .word -1            # top index (-1 = empty)

    msg_push:     .string "Pushed: "
    msg_pop:      .string "Popped: "
    msg_peek:     .string "Top: "
    msg_empty:    .string "Stack is Empty\n"
    msg_notempty: .string "Stack is Not Empty\n"
    msg_overflow: .string "Push failed: Stack is Full\n"
    msg_underflow:.string "Pop failed: Stack is Empty\n"
    msg_peekempty:.string "Peek failed: Stack is Empty\n"
    msg_arrow:    .string " -> "
    msg_bottom:   .string "BOTTOM\n"
    msg_newln:    .string "\n"

.text
.globl main

main:
    # test push operation
    li   a0, 10
    jal  ra, push

    li   a0, 20
    jal  ra, push

    li   a0, 30
    jal  ra, push

    # test stack operations
    jal  ra, print_stack       # 30 -> 20 -> 10 -> BOTTOM
    jal  ra, peek              # Top: 30
    jal  ra, is_empty          # stack is not empty

    jal  ra, pop               # popped: 30
    jal  ra, pop               # popped: 20

    jal  ra, print_stack       # 10 -> BOTTOM

    jal  ra, pop               # popped: 10
    jal  ra, pop               # Pop failed: stack is Empty

    jal  ra, is_empty          # stack is Empty

    # Exit program
    li   a0, 10
    ecall


# push(a0=value)
# add a value to the top of the stack

push:
    addi sp, sp, -8
    sw   ra, 0(sp)
    sw   s0, 4(sp)

    mv   s0, a0                # s0 = value

    # check whether the stack is full
    la   t0, top
    lw   t1, 0(t0)             # t1 = top
    lw   t2, MAX
    addi t2, t2, -1            # t2 = MAX - 1
    bge  t1, t2, push_overflow

    # increment top and store the new value
    addi t1, t1, 1             # top++
    sw   t1, 0(t0)

    la   t2, stack_arr
    slli t3, t1, 2             # offset = top * 4
    add  t2, t2, t3
    sw   s0, 0(t2)             # stack_arr[top] = value

    # print pushed value
    li   a0, 4
    la   a1, msg_push
    ecall

    li   a0, 1
    mv   a1, s0
    ecall

    li   a0, 4
    la   a1, msg_newln
    ecall

    j    push_done

push_overflow:
    # stack is full; do not modify it
    li   a0, 4
    la   a1, msg_overflow
    ecall

push_done:
    lw   ra, 0(sp)
    lw   s0, 4(sp)
    addi sp, sp, 8
    ret


# pop — remove and print the top value

pop:
    addi sp, sp, -4
    sw   ra, 0(sp)

    # check whether the stack is empty
    la   t0, top
    lw   t1, 0(t0)             # t1 = top
    li   t2, -1
    beq  t1, t2, pop_underflow

    # load the top value and decrement top
    la   t2, stack_arr
    slli t3, t1, 2
    add  t2, t2, t3
    lw   s0, 0(t2)             # s0 = stack_arr[top]

    addi t1, t1, -1            # top--
    sw   t1, 0(t0)

    # print popped value
    li   a0, 4
    la   a1, msg_pop
    ecall

    li   a0, 1
    mv   a1, s0
    ecall

    li   a0, 4
    la   a1, msg_newln
    ecall

    j    pop_done

pop_underflow:
    # stack is empty; nothing to pop
    li   a0, 4
    la   a1, msg_underflow
    ecall

pop_done:
    lw   ra, 0(sp)
    addi sp, sp, 4
    ret


# peek — print the top value without removing it

peek:
    # check whether the stack is empty
    la   t0, top
    lw   t1, 0(t0)
    li   t2, -1
    beq  t1, t2, peek_empty

    # load the top value
    la   t2, stack_arr
    slli t3, t1, 2
    add  t2, t2, t3
    lw   t4, 0(t2)             # t4 = stack_arr[top]

    # print top value
    li   a0, 4
    la   a1, msg_peek
    ecall

    li   a0, 1
    mv   a1, t4
    ecall

    li   a0, 4
    la   a1, msg_newln
    ecall

    ret

peek_empty:
    # stack is empty; nothing to peek
    li   a0, 4
    la   a1, msg_peekempty
    ecall
    ret


# is_empty — check whether the stack is empty

is_empty:
    la   t0, top
    lw   t0, 0(t0)
    li   t1, -1
    beq  t0, t1, stack_empty

    li   a0, 4
    la   a1, msg_notempty
    ecall
    ret

stack_empty:
    li   a0, 4
    la   a1, msg_empty
    ecall
    ret


# print_stack — print all elements from top to bottom

print_stack:
    addi sp, sp, -4
    sw   ra, 0(sp)

    la   t0, top
    lw   t0, 0(t0)             # t0 = top index
    li   t1, -1
    beq  t0, t1, ps_empty

ps_loop:
    bltz t0, ps_bottom

    # load and print stack[t0]
    la   t1, stack_arr
    slli t2, t0, 2
    add  t1, t1, t2
    lw   a1, 0(t1)             # value at index t0

    li   a0, 1
    ecall

    li   a0, 4
    la   a1, msg_arrow
    ecall

    addi t0, t0, -1
    j    ps_loop

ps_bottom:
    # reached the bottom of the stack
    li   a0, 4
    la   a1, msg_bottom
    ecall
    j    ps_done

ps_empty:
    # stack contains no elements
    li   a0, 4
    la   a1, msg_empty
    ecall

ps_done:
    lw   ra, 0(sp)
    addi sp, sp, 4
    ret
