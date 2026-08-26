# queue
#
# node layout (8 bytes):
#   [0..3] = data  (integer)
#   [4..7] = next  (pointer, 0 = NULL)
#
# pointers:
#   front — dequeue / peek from here
#   rear  — enqueue here
#
# operations:
#   enqueue(value) — add node at rear
#   dequeue        — remove node from front, print value
#   peek           — print front value without removing
#   is_empty       — print Empty/Not Empty
#   print_queue    — print all values front to rear


.data
    front:      .word 0                # front pointer (NULL = empty)
    rear:       .word 0                # rear pointer

    heap:       .space 400             # up to 50 nodes (8 bytes each)
    heap_ptr:   .word 0                # next free offset in heap

    msg_enqueue:  .string "Enqueued: "
    msg_dequeue:  .string "Dequeued: "
    msg_peek:     .string "Front: "
    msg_empty:    .string "Queue is Empty\n"
    msg_notempty: .string "Queue is Not Empty\n"
    msg_arrow:    .string " -> "
    msg_null:     .string "NULL\n"
    msg_newln:    .string "\n"
    msg_underflow:.string "Dequeue failed: Queue is Empty\n"
    msg_peekempty:.string "Peek failed: Queue is Empty\n"

.text
.globl main

main:
    # test enqueue operation
    li   a0, 10
    jal  ra, enqueue

    li   a0, 20
    jal  ra, enqueue

    li   a0, 30
    jal  ra, enqueue

    # test queue operations
    jal  ra, print_queue
    jal  ra, peek
    jal  ra, is_empty

    jal  ra, dequeue
    jal  ra, dequeue

    jal  ra, print_queue

    jal  ra, dequeue
    jal  ra, is_empty

    # test dequeue on an empty queue
    jal  ra, dequeue

    # exit program
    li   a0, 10
    ecall


# alloc_node — allocate and initialize a new node
# returns the node address in a0

alloc_node:
    la   t0, heap
    la   t1, heap_ptr
    lw   t2, 0(t1)

    add  a0, t0, t2
    addi t2, t2, 8
    sw   t2, 0(t1)

    sw   zero, 0(a0)           # data = 0
    sw   zero, 4(a0)           # next = NULL
    ret


# enqueue(a0=value) — add a node at the rear

enqueue:
    addi sp, sp, -12
    sw   ra, 0(sp)
    sw   s0, 4(sp)
    sw   s1, 8(sp)

    mv   s0, a0                # s0 = value

    jal  ra, alloc_node
    mv   s1, a0                # s1 = new node
    sw   s0, 0(s1)             # new_node.data = value

    # check whether the queue is empty
    la   t0, front
    lw   t1, 0(t0)              # t1 = front
    la   t2, rear

    beqz t1, enqueue_empty

    # link the new node after the current rear
    lw   t3, 0(t2)              # t3 = rear
    sw   s1, 4(t3)              # rear->next = new_node
    sw   s1, 0(t2)              # rear = new_node
    j    enqueue_done

enqueue_empty:
    # first node becomes both front and rear
    sw   s1, 0(t0)              # front = new_node
    sw   s1, 0(t2)              # rear = new_node

enqueue_done:
    # print enqueued value
    li   a0, 4
    la   a1, msg_enqueue
    ecall

    li   a0, 1
    mv   a1, s0
    ecall

    li   a0, 4
    la   a1, msg_newln
    ecall

    lw   ra, 0(sp)
    lw   s0, 4(sp)
    lw   s1, 8(sp)
    addi sp, sp, 12
    ret


# dequeue — remove and print the front value

dequeue:
    addi sp, sp, -4
    sw   ra, 0(sp)

    # check whether the queue is empty
    la   t0, front
    lw   t1, 0(t0)              # t1 = front

    beqz t1, dequeue_empty

    # load the front value and advance front
    lw   s0, 0(t1)              # s0 = front->data
    lw   t2, 4(t1)              # t2 = front->next
    sw   t2, 0(t0)              # front = front->next

    # if queue is now empty, clear rear as well
    bnez t2, dequeue_print
    la   t3, rear
    sw   zero, 0(t3)            # rear = NULL

dequeue_print:
    # print dequeued value
    li   a0, 4
    la   a1, msg_dequeue
    ecall

    li   a0, 1
    mv   a1, s0
    ecall

    li   a0, 4
    la   a1, msg_newln
    ecall

    j    dequeue_done

dequeue_empty:
    # queue is empty; nothing to dequeue
    li   a0, 4
    la   a1, msg_underflow
    ecall

dequeue_done:
    lw   ra, 0(sp)
    addi sp, sp, 4
    ret


# peek — print the front value without removing it

peek:
    # check whether the queue is empty
    la   t0, front
    lw   t1, 0(t0)              # t1 = front

    beqz t1, peek_empty

    # load and print front value
    lw   t2, 0(t1)              # t2 = front->data

    li   a0, 4
    la   a1, msg_peek
    ecall

    li   a0, 1
    mv   a1, t2
    ecall

    li   a0, 4
    la   a1, msg_newln
    ecall

    ret

peek_empty:
    # queue is empty; nothing to peek
    li   a0, 4
    la   a1, msg_peekempty
    ecall
    ret


# is_empty — check whether the queue is empty

is_empty:
    la   t0, front
    lw   t0, 0(t0)

    beqz t0, is_empty_yes

    li   a0, 4
    la   a1, msg_notempty
    ecall
    ret

is_empty_yes:
    li   a0, 4
    la   a1, msg_empty
    ecall
    ret


# print_queue — print all values from front to rear

print_queue:
    addi sp, sp, -4
    sw   ra, 0(sp)

    la   t0, front
    lw   t0, 0(t0)              # t0 = front

    beqz t0, pq_empty

pq_node:
    # stop when the end of the linked list is reached
    beqz t0, pq_null

    # print current node's data
    lw   a1, 0(t0)
    li   a0, 1
    ecall

    li   a0, 4
    la   a1, msg_arrow
    ecall

    # move to the next node
    lw   t0, 4(t0)
    j    pq_node

pq_null:
    # reached the end of the queue
    li   a0, 4
    la   a1, msg_null
    ecall
    j    pq_done

pq_empty:
    # queue contains no nodes
    li   a0, 4
    la   a1, msg_empty
    ecall

pq_done:
    lw   ra, 0(sp)
    addi sp, sp, 4
    ret
