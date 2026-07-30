/*
 * The Four Deadly Memory Sins Practice
 * 
 * Compile with ONE of these -D flags to select which error to test:
 *   gcc -Wall -Wextra -std=c11 -g -DMEMORY_LEAK     -o test memory_errors.c
 *   gcc -Wall -Wextra -std=c11 -g -DDANGLING_PTR    -o test memory_errors.c
 *   gcc -Wall -Wextra -std=c11 -g -DDOUBLE_FREE     -o test memory_errors.c
 *   gcc -Wall -Wextra -std=c11 -g -DBUFFER_OVERFLOW -o test memory_errors.c
 *
 * Then run with valgrind:
 *   valgrind --leak-check=full ./test
 */

#include <stdio.h>
#include <stdlib.h>

//  Memory Leak
#ifdef MEMORY_LEAK

int main(void)
{
    int *ptr = malloc(100 * sizeof(int));
    ptr[0] = 10;
    // free(ptr) never called - valgrind will report "definitely lost" bytes
    return 0;
}

// Danngling Pointer 
#elif defined(DANGLING_PTR)

int main(void)
{
    int *ptr = malloc(sizeof(int));
    *ptr = 25;
    free(ptr);
    // ptr is now dangling; reading it is undefined behaviour
    printf("%d\n", *ptr);
    return 0;
}

// Double Free 
#elif defined(DOUBLE_FREE)

int main(void)
{
    int *ptr = malloc(sizeof(int));
    free(ptr);
    free(ptr);   // second free corrupts the heap
    return 0;
}

// Buffer Overflow 
#elif defined(BUFFER_OVERFLOW)

int main(void)
{
    int *arr = malloc(5 * sizeof(int));
    // loop goes 0..5 - index 5 is one past the end (out-of-bounds write)
    for (int i = 0; i <= 5; i++) {
        arr[i] = i;
    }
    free(arr);
    return 0;
}

// no flag given
#else
#  error "Define one of: MEMORY_LEAK, DANGLING_PTR, DOUBLE_FREE, BUFFER_OVERFLOW"
#endif
