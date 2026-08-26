# singly linked list
#
# node layout (8 bytes):
#   [0..3] = data  (integer)
#   [4..7] = next  (pointer, 0 = NULL)
#
# operations:
#   insert(value)  — append at tail
#   delete(value)  — remove first node with matching value
#   search(value)  — print Found/Not Found
#   print_list     — traverse and print all values


.data
    head:       .word 0                # head pointer (NULL initially)
    heap:       .space 400             # space for up to 50 nodes (8 bytes each)
    heap_ptr:   .word 0                # offset into heap (next free slot)

    # messages
    msg_found:    .string "Found: "
    msg_notfound: .string "Not Found: "
    msg_empty:    .string "[empty list]\n"
    msg_arrow:    .string " -> "
    msg_null:     .string "NULL\n"
    msg_newln:    .string "\n"
    msg_deleted:  .string "Deleted: "
    msg_notdel:   .string "Not in list: "

.text
.globl main

main:
    # insert test values
    li   a0, 10
    jal  ra, insert

    li   a0, 20
    jal  ra, insert

    li   a0, 30
    jal  ra, insert

    # print and search the list
    jal  ra, print_list        # 10 -> 20 -> 30 -> NULL

    li   a0, 20
    jal  ra, search            # found

    # delete and verify the node
    li   a0, 20
    jal  ra, delete

    jal  ra, print_list        # 10 -> 30 -> NULL

    li   a0, 20
    jal  ra, search            # not found

    # Exit program
    li   a0, 10
    ecall


# alloc_node — allocate an 8-byte node from the static heap
# returns the new node address in a0

alloc_node:
    la   t0, heap
    la   t1, heap_ptr
    lw   t2, 0(t1)              # t2 = current offset

    add  a0, t0, t2             # a0 = heap base + offset
    addi t2, t2, 8              # advance to next free node
    sw   t2, 0(t1)              # update heap_ptr

    sw   zero, 0(a0)            # node.data = 0
    sw   zero, 4(a0)            # node.next = NULL
    ret


# insert(a0=value) — append a new node at the tail

insert:
    addi sp, sp, -16
    sw   ra, 0(sp)
    sw   s0, 4(sp)
    sw   s1, 8(sp)

    mv   s0, a0                 # s0 = value to insert

    # allocate and initialize new node
    jal  ra, alloc_node
    mv   s1, a0                 # s1 = new node
    sw   s0, 0(s1)              # new_node.data = value
    sw   zero, 4(s1)            # new_node.next = NULL

    # check whether the list is empty
    la   t0, head
    lw   t1, 0(t0)              # t1 = head

    beqz t1, insert_empty

insert_walk:
    # traverse until current->next is NULL
    lw   t2, 4(t1)              # t2 = current->next
    beqz t2, insert_tail

    mv   t1, t2                 # current = current->next
    j    insert_walk

insert_tail:
    # link new node after the current tail
    sw   s1, 4(t1)              # tail->next = new_node
    j    insert_done

insert_empty:
    # first node becomes the head
    sw   s1, 0(t0)              # head = new_node

insert_done:
    lw   ra, 0(sp)
    lw   s0, 4(sp)
    lw   s1, 8(sp)
    addi sp, sp, 16
    ret


# delete(a0=value) — remove the first node matching value

delete:
    addi sp, sp, -8
    sw   ra, 0(sp)
    sw   s0, 4(sp)

    mv   s0, a0                 # s0 = target value

    la   t0, head
    lw   t1, 0(t0)              # t1 = head

    # empty list means target cannot be found
    beqz t1, delete_notfound

    # check whether the head is the target
    lw   t2, 0(t1)              # t2 = head->data
    bne  t2, s0, delete_walk_init

    # remove the head node
    lw   t3, 4(t1)              # t3 = head->next
    sw   t3, 0(t0)              # head = head->next
    j    delete_found

delete_walk_init:
    # start traversal with prev and curr pointers
    mv   t3, t1                 # t3 = prev
    lw   t1, 4(t3)              # t1 = curr = head->next

delete_walk:
    beqz t1, delete_notfound

    lw   t2, 0(t1)              # t2 = curr->data
    beq  t2, s0, delete_match

    # advance both pointers
    mv   t3, t1                 # prev = curr
    lw   t1, 4(t1)              # curr = curr->next
    j    delete_walk

delete_match:
    # bypass the matching node
    lw   t4, 4(t1)              # t4 = curr->next
    sw   t4, 4(t3)              # prev->next = curr->next

delete_found:
    # print deleted value
    li   a0, 4
    la   a1, msg_deleted
    ecall

    li   a0, 1
    mv   a1, s0
    ecall

    li   a0, 4
    la   a1, msg_newln
    ecall

    j    delete_done

delete_notfound:
    # print value that was not found
    li   a0, 4
    la   a1, msg_notdel
    ecall

    li   a0, 1
    mv   a1, s0
    ecall

    li   a0, 4
    la   a1, msg_newln
    ecall

delete_done:
    lw   ra, 0(sp)
    lw   s0, 4(sp)
    addi sp, sp, 8
    ret


# search(a0=value) — search for the first matching node

search:
    mv   t0, a0                 # t0 = target value

    la   t1, head
    lw   t1, 0(t1)              # t1 = head

search_loop:
    # reaching NULL means the value was not found
    beqz t1, search_notfound

    lw   t2, 0(t1)              # t2 = curr->data
    beq  t2, t0, search_found

    lw   t1, 4(t1)              # curr = curr->next
    j    search_loop

search_found:
    # print found value
    li   a0, 4
    la   a1, msg_found
    ecall

    li   a0, 1
    mv   a1, t0
    ecall

    li   a0, 4
    la   a1, msg_newln
    ecall
    ret

search_notfound:
    # print value that was not found
    li   a0, 4
    la   a1, msg_notfound
    ecall

    li   a0, 1
    mv   a1, t0
    ecall

    li   a0, 4
    la   a1, msg_newln
    ecall
    ret


# print_list — traverse and print all node values

print_list:
    addi sp, sp, -4
    sw   ra, 0(sp)

    la   t0, head
    lw   t0, 0(t0)              # t0 = head

    # Handle empty list
    beqz t0, print_empty

print_node:
    beqz t0, print_end_null

    # print current node's data
    lw   a1, 0(t0)              # a1 = node->data
    li   a0, 1
    ecall

    li   a0, 4
    la   a1, msg_arrow
    ecall

    # move to next node
    lw   t0, 4(t0)
    j    print_node

print_end_null:
    # reached end of list
    li   a0, 4
    la   a1, msg_null
    ecall
    j    print_done

print_empty:
    # list contains no nodes
    li   a0, 4
    la   a1, msg_empty
    ecall

print_done:
    lw   ra, 0(sp)
    addi sp, sp, 4
    ret
