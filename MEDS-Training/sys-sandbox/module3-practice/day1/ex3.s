# char *message = "Hello MEDS!";
# printf("%s", message);

.data
    message: .string "Hello MEDS!"

.text
.globl main

main:
    la   a1, message          # a1 = address of "Hello MEDS!" string

    # print string
    li   a0, 4                # ecall 4 = print string
    ecall                     # print message pointed to by a1

    # exit program
    li   a0, 10               # ecall 10 = exit
    ecall                     # terminate execution
