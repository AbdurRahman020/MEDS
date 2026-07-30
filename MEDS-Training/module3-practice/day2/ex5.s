# unsigned int value = 0xDEADBEEF;                            // stored little-endian: bytes EF BE AD DE
# unsigned int   word_val = value;                            // load word,      offset 0
# unsigned short half0    = *(unsigned short*)&value;         // load half-word, offset 0 -> 0xBEEF
# unsigned short half2    = *((unsigned short*)&value + 1);   // load half-word, offset 2 -> 0xDEAD
# unsigned char  byte0    = *(unsigned char*)&value;          // load byte,      offset 0 -> 0xEF
# printf("%u\n%u\n%u\n%u\n", word_val, half0, half2, byte0);


.data
    value: .word 0xDEADBEEF

.text
.globl main

main:
    la   t0, value          # t0 = address of value

    lw   t1, 0(t0)          # t1 = full word  = 0xDEADBEEF
    lhu  t2, 0(t0)          # t2 = half-word at offset 0 = 0xBEEF
    lhu  t3, 2(t0)          # t3 = half-word at offset 2 = 0xDEAD
    lbu  t4, 0(t0)          # t4 = byte at offset 0      = 0xEF

    # print word
    addi a0, zero, 1        # ecall 1 = print integer
    mv   a1, t1
    ecall

    # print half-word at offset 0
    addi a0, zero, 1
    mv   a1, t2
    ecall

    # print half-word at offset 2
    addi a0, zero, 1
    mv   a1, t3
    ecall

    # print byte at offset 0
    addi a0, zero, 1
    mv   a1, t4
    ecall

    # exit
    addi a0, zero, 10       # ecall 10 = exit program
    ecall                   # terminate execution
