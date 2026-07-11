/*
    The memory layout of a C program, showing the addresses of different types of variables and functions

    The memory layout typically includes:
    - Text/Code segment : where the compiled code (functions) resides
    - Data segment      : for initialized global and static variables
    - BSS segment       : for uninitialized global and static variables
    - Heap              : for dynamically allocated memory
    - Stack             : for local variables and function call management
*/

#include <stdio.h>
#include <stdlib.h>

// global initialized variable -> Data segment
int global_init = 100;

// global uninitialized variable -> BSS segment
int global_uninit;

// static initialized variable -> Data segment
static int static_init = 200;

// static uninitialized variable -> BSS segment
static int static_uninit;

void test_function() {
    // local variable -> Stack */
    int local_var = 10;

    // dynamically allocated variable -> Heap
    int *heap_var = (int *)malloc(sizeof(int));
    *heap_var = 300;

    printf("\tMEMORY LAYOUT (addresses)\n\n");
    printf("local_var (Stack)         : %p\n", (void *)&local_var);
    printf("heap_var data (Heap)      : %p\n", (void *)heap_var);
    printf("global_init (Data)        : %p\n", (void *)&global_init);
    printf("global_uninit (BSS)       : %p\n", (void *)&global_uninit);
    printf("static_init (Data)        : %p\n", (void *)&static_init);
    printf("static_uninit (BSS)       : %p\n", (void *)&static_uninit);
    printf("test_function (Text/Code) : %p\n", (void *)test_function);

    free(heap_var);
}

int main() {
    test_function();
    return 0;
}
