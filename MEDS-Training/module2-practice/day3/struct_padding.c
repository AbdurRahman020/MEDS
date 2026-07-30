#include <stdio.h>
#include <stdint.h>

/*
    Structure Padding Example

    This program demonstrates:
    1. How padding affects structure size
    2. Manual size calculation
    3. Verification using sizeof()
    4. Reducing padding by reordering fields
*/


/* Poor field ordering */

typedef struct {
    char    a;   // 1 byte
    int32_t b;   // 4 bytes
    char    c;   // 1 byte
    double  d;   // 8 bytes
} bad_struct_t;

/*
    Expected layout on a typical 64-bit system:

    a          -> offset 0
    padding    -> 3 bytes, required for int32_t alignment
    b          -> offset 4..7
    c          -> offset 8
    padding    -> 7 bytes, required for double alignment
    d          -> offset 16..23

    Total size = 24 bytes
*/


/* Optimized field ordering */

typedef struct {
    double  d;   // 8 bytes
    int32_t b;   // 4 bytes
    char    a;   // 1 byte
    char    c;   // 1 byte
} good_struct_t;

/*
    Expected layout:

    d          -> offset 0..7
    b          -> offset 8..11
    a          -> offset 12
    c          -> offset 13

    padding    -> 2 bytes
                   added to satisfy overall alignment

    Total size = 16 bytes
*/


int main(void)
{
    printf("=== STRUCT PADDING DEMO ===\n\n");

    printf("bad_struct_t size  = %zu bytes\n",
           sizeof(bad_struct_t));

    printf("good_struct_t size = %zu bytes\n",
           sizeof(good_struct_t));

    return 0;
}
