# binary search tree (BST)
#
# node layout (12 bytes):
#   [0..3]  = data
#   [4..7]  = left child pointer
#   [8..11] = right child pointer
#
# operations:
#   insert    — add value, ignore duplicates
#   search    — print Found/Not Found
#   delete    — remove node (0, 1, or 2 children)
#   inorder   — left, root, right
#   preorder  — root, left, right
#   postorder — left, right, root
#   height    — longest root-to-leaf path
#   count     — total number of nodes


.data
    root:     .word 0
    heap:     .space 420        # 35 nodes * 12 bytes
    heap_ptr: .word 0

    msg_inserted:  .string "Inserted: "
    msg_inorder:   .string "Inorder: "
    msg_preorder:  .string "Preorder: "
    msg_postorder: .string "Postorder: "
    msg_height:    .string "Height: "
    msg_count:     .string "Count: "
    msg_search:    .string "Search "
    msg_found:     .string ": Found\n"
    msg_notfound:  .string ": Not Found\n"
    msg_deleted:   .string "Deleted: "
    msg_notdel:    .string "Not Found: "
    msg_space:     .string " "
    msg_newln:     .string "\n"

.text
.globl main

main:
    # build the BST
    li   a0, 50
    jal  ra, insert

    li   a0, 30
    jal  ra, insert

    li   a0, 70
    jal  ra, insert

    li   a0, 20
    jal  ra, insert

    li   a0, 40
    jal  ra, insert

    li   a0, 60
    jal  ra, insert

    li   a0, 80
    jal  ra, insert

    # print tree traversals
    li   a0, 4
    la   a1, msg_inorder
    ecall

    la   a0, root
    lw   a0, 0(a0)
    jal  ra, inorder

    li   a0, 4
    la   a1, msg_newln
    ecall

    li   a0, 4
    la   a1, msg_preorder
    ecall

    la   a0, root
    lw   a0, 0(a0)
    jal  ra, preorder

    li   a0, 4
    la   a1, msg_newln
    ecall

    li   a0, 4
    la   a1, msg_postorder
    ecall

    la   a0, root
    lw   a0, 0(a0)
    jal  ra, postorder

    li   a0, 4
    la   a1, msg_newln
    ecall

    # calculate and print tree height
    li   a0, 4
    la   a1, msg_height
    ecall

    la   t0, root
    lw   a0, 0(t0)
    jal  ra, height
    mv   s0, a0

    li   a0, 1
    mv   a1, s0
    ecall

    li   a0, 4
    la   a1, msg_newln
    ecall

    # count and print total nodes
    li   a0, 4
    la   a1, msg_count
    ecall

    la   t0, root
    lw   a0, 0(t0)
    jal  ra, count
    mv   s0, a0

    li   a0, 1
    mv   a1, s0
    ecall

    li   a0, 4
    la   a1, msg_newln
    ecall

    # search for existing and missing values
    li   a0, 40
    jal  ra, search

    li   a0, 99
    jal  ra, search

    # delete a leaf, a one-child node, and test not-found case
    li   a0, 20
    jal  ra, delete

    li   a0, 30
    jal  ra, delete

    li   a0, 99
    jal  ra, delete

    # print tree after deletion
    li   a0, 4
    la   a1, msg_inorder
    ecall

    la   a0, root
    lw   a0, 0(a0)
    jal  ra, inorder

    li   a0, 4
    la   a1, msg_newln
    ecall

    # Exit program
    li   a0, 10
    ecall


# alloc_node -> a0 = new node pointer
# allocate and initialize one 12-byte BST node

alloc_node:
    la   t0, heap
    la   t1, heap_ptr
    lw   t2, 0(t1)

    add  a0, t0, t2             # a0 = heap base + offset
    addi t2, t2, 12             # advance to next node
    sw   t2, 0(t1)              # update heap_ptr

    # initialize node
    sw   zero, 0(a0)            # data = 0
    sw   zero, 4(a0)            # left = NULL
    sw   zero, 8(a0)            # right = NULL
    ret


# insert(a0=value)
# insert value into the BST; duplicate values are ignored

insert:
    addi sp, sp, -12
    sw   ra, 0(sp)
    sw   s0, 4(sp)
    sw   s1, 8(sp)

    mv   s0, a0                 # s0 = value

    # print inserted value
    li   a0, 4
    la   a1, msg_inserted
    ecall

    li   a0, 1
    mv   a1, s0
    ecall

    li   a0, 4
    la   a1, msg_newln
    ecall

    # allocate and initialize new node
    jal  ra, alloc_node
    mv   s1, a0                 # s1 = new node
    sw   s0, 0(s1)              # new_node.data = value

    # check whether tree is empty
    la   t0, root
    lw   t1, 0(t0)
    beqz t1, insert_as_root

    # traverse tree to find insertion point
    mv   t2, t1                 # t2 = current node

walk:
    lw   t3, 0(t2)              # t3 = current->data

    blt  s0, t3, go_left
    bgt  s0, t3, go_right

    # value already exists
    j    insert_done

go_left:
    # follow left subtree
    lw   t4, 4(t2)
    beqz t4, set_left

    mv   t2, t4
    j    walk

set_left:
    sw   s1, 4(t2)              # current->left = new_node
    j    insert_done

go_right:
    # follow right subtree
    lw   t4, 8(t2)
    beqz t4, set_right

    mv   t2, t4
    j    walk

set_right:
    sw   s1, 8(t2)              # current->right = new_node
    j    insert_done

insert_as_root:
    # first node becomes the root
    sw   s1, 0(t0)

insert_done:
    lw   ra, 0(sp)
    lw   s0, 4(sp)
    lw   s1, 8(sp)
    addi sp, sp, 12
    ret


# search(a0=value)
# search the BST and print whether the value was found

search:
    addi sp, sp, -8
    sw   ra, 0(sp)
    sw   s0, 4(sp)

    mv   s0, a0                 # s0 = target value

    # print search value
    li   a0, 4
    la   a1, msg_search
    ecall

    li   a0, 1
    mv   a1, s0
    ecall

    # start at root
    la   t0, root
    lw   t0, 0(t0)

search_loop:
    # reached NULL -> not found
    beqz t0, search_not

    lw   t1, 0(t0)              # t1 = current->data
    beq  s0, t1, search_yes

    # choose subtree using BST ordering
    blt  s0, t1, search_left

    lw   t0, 8(t0)              # go right
    j    search_loop

search_left:
    lw   t0, 4(t0)              # go left
    j    search_loop

search_yes:
    li   a0, 4
    la   a1, msg_found
    ecall
    j    search_done

search_not:
    li   a0, 4
    la   a1, msg_notfound
    ecall

search_done:
    lw   ra, 0(sp)
    lw   s0, 4(sp)
    addi sp, sp, 8
    ret


# delete(a0=value)
# remove the first matching node
#
# cases:
#   - 0 children: remove node directly
#   - 1 child:    replace node with its child
#   - 2 children: replace data with inorder successor, then remove the successor

delete:
    addi sp, sp, -16
    sw   ra, 0(sp)
    sw   s0, 4(sp)
    sw   s1, 8(sp)
    sw   s2, 12(sp)

    mv   s0, a0                 # s0 = value to delete

    # find node and keep track of its parent
    la   t0, root
    lw   t1, 0(t0)              # t1 = current
    li   t2, 0                  # t2 = parent
    li   t3, 0                  # t3 = came from left

del_walk:
    beqz t1, del_notfound

    lw   t4, 0(t1)              # t4 = current->data
    beq  s0, t4, del_found

    blt  s0, t4, del_go_left

del_go_right:
    mv   t2, t1                 # parent = current
    lw   t1, 8(t1)              # current = current->right
    li   t3, 0                  # came from right
    j    del_walk

del_go_left:
    mv   t2, t1                 # parent = current
    lw   t1, 4(t1)              # current = current->left
    li   t3, 1                  # came from left
    j    del_walk

del_found:
    # save current node's children
    lw   s1, 4(t1)              # s1 = left child
    lw   s2, 8(t1)              # s2 = right child

    # determine number of children
    bnez s1, del_check_two
    bnez s2, del_check_two

    # No children
    j    del_zero_child

del_check_two:
    beqz s1, del_one_child      # only right child
    beqz s2, del_one_child      # only left child

    # two children: find the inorder successor (leftmost node in right subtree)
    mv   t5, t1                 # t5 = successor parent
    lw   t6, 8(t1)              # t6 = successor

succ_walk:
    lw   t0, 4(t6)              # t0 = successor->left
    beqz t0, succ_found

    mv   t5, t6                 # successor parent = successor
    mv   t6, t0                 # successor = successor->left
    j    succ_walk

succ_found:
    # copy successor's value into node being deleted
    lw   t0, 0(t6)
    sw   t0, 0(t1)

    # successor has at most one child: its right child
    lw   t0, 8(t6)

    beq  t5, t1, succ_is_direct_right

    # successor is deeper in right subtree
    sw   t0, 4(t5)              # successor_parent->left = successor->right
    j    del_print

succ_is_direct_right:
    # successor is the node's direct right child
    sw   t0, 8(t5)              # node->right = successor->right
    j    del_print


del_zero_child:
    # remove a leaf node by setting its parent's pointer to NULL
    beqz t2, del_zero_root

    beqz t3, del_zero_right

    sw   zero, 4(t2)            # parent->left = NULL
    j    del_print

del_zero_right:
    sw   zero, 8(t2)            # parent->right = NULL
    j    del_print

del_zero_root:
    # tree becomes empty
    la   t0, root
    sw   zero, 0(t0)
    j    del_print


del_one_child:
    # select the non-null child
    mv   t0, s2                 # assume right child
    bnez s1, del_use_left

    j    del_link

del_use_left:
    mv   t0, s1                 # use left child

del_link:
    # connect parent directly to the node's child
    beqz t2, del_one_root

    beqz t3, del_one_right

    sw   t0, 4(t2)              # parent->left = child
    j    del_print

del_one_right:
    sw   t0, 8(t2)              # parent->right = child
    j    del_print

del_one_root:
    # child becomes the new root
    la   t0, root

    lw   t1, 4(t1)
    bnez t1, del_root_left

    lw   t1, 8(s1)

del_root_left:
    sw   t1, 0(t0)
    j    del_print


del_print:
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
    j    del_done

del_notfound:
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

del_done:
    lw   ra, 0(sp)
    lw   s0, 4(sp)
    lw   s1, 8(sp)
    lw   s2, 12(sp)
    addi sp, sp, 16
    ret


# inorder(a0=node_ptr)
# traverse: left -> root -> right
# produces values in sorted order for a BST

inorder:
    beqz a0, inorder_ret

    addi sp, sp, -8
    sw   ra, 0(sp)
    sw   s0, 4(sp)

    mv   s0, a0                 # save current node

    # visit left subtree
    lw   a0, 4(s0)
    jal  ra, inorder

    # visit current node
    lw   a1, 0(s0)
    li   a0, 1
    ecall

    li   a0, 4
    la   a1, msg_space
    ecall

    # visit right subtree
    lw   a0, 8(s0)
    jal  ra, inorder

    lw   ra, 0(sp)
    lw   s0, 4(sp)
    addi sp, sp, 8

inorder_ret:
    ret


# preorder(a0=node_ptr)
# traverse: root -> left -> right

preorder:
    beqz a0, preorder_ret

    addi sp, sp, -8
    sw   ra, 0(sp)
    sw   s0, 4(sp)

    mv   s0, a0

    # visit current node first
    lw   a1, 0(s0)
    li   a0, 1
    ecall

    li   a0, 4
    la   a1, msg_space
    ecall

    # visit left subtree
    lw   a0, 4(s0)
    jal  ra, preorder

    # visit right subtree
    lw   a0, 8(s0)
    jal  ra, preorder

    lw   ra, 0(sp)
    lw   s0, 4(sp)
    addi sp, sp, 8

preorder_ret:
    ret


# postorder(a0=node_ptr)
# traverse: left -> right -> root

postorder:
    beqz a0, postorder_ret

    addi sp, sp, -8
    sw   ra, 0(sp)
    sw   s0, 4(sp)

    mv   s0, a0

    # visit left subtree
    lw   a0, 4(s0)
    jal  ra, postorder

    # visit right subtree
    lw   a0, 8(s0)
    jal  ra, postorder

    # visit current node last
    lw   a1, 0(s0)
    li   a0, 1
    ecall

    li   a0, 4
    la   a1, msg_space
    ecall

    lw   ra, 0(sp)
    lw   s0, 4(sp)
    addi sp, sp, 8

postorder_ret:
    ret


# height(a0=node_ptr) -> a0=height
# height is 0 for an empty tree
# for a non-empty node: height = 1 + max(left_height, right_height)

height:
    beqz a0, height_null

    addi sp, sp, -12
    sw   ra, 0(sp)
    sw   s0, 4(sp)
    sw   s1, 8(sp)

    mv   s0, a0                 # save current node

    # calculate left subtree height
    lw   a0, 4(s0)
    jal  ra, height
    mv   s1, a0                 # s1 = left height

    # calculate right subtree height
    lw   a0, 8(s0)
    jal  ra, height             # a0 = right height

    # select larger subtree height
    bge  s1, a0, height_use_left
    j    height_use_right

height_use_left:
    mv   a0, s1

height_use_right:
    addi a0, a0, 1              # include current node

    lw   ra, 0(sp)
    lw   s0, 4(sp)
    lw   s1, 8(sp)
    addi sp, sp, 12
    ret

height_null:
    li   a0, 0
    ret


# count(a0=node_ptr) -> a0=number of nodes
# count = 1 + count(left) + count(right)

count:
    beqz a0, count_null

    addi sp, sp, -12
    sw   ra, 0(sp)
    sw   s0, 4(sp)
    sw   s1, 8(sp)

    mv   s0, a0                 # save current node

    # count left subtree
    lw   a0, 4(s0)
    jal  ra, count
    mv   s1, a0                 # s1 = left count

    # count right subtree
    lw   a0, 8(s0)
    jal  ra, count              # a0 = right count

    # add left count, right count, and current node
    add  a0, a0, s1
    addi a0, a0, 1

    lw   ra, 0(sp)
    lw   s0, 4(sp)
    lw   s1, 8(sp)
    addi sp, sp, 12
    ret

count_null:
    li   a0, 0
    ret
