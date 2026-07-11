/* 
    Reverses the elements of an array in place
*/

#include <stdio.h>
#include <stdint.h>

void reverse_arr(uint32_t *arr, size_t size) {
    uint32_t *start = arr;
    uint32_t *end = arr + size - 1;

    while (start < end) {
        uint32_t temp = *start;
        *start = *end;
        *end = temp;

        start++;
        end--;
    }
}

void print_arr(const uint32_t *arr, size_t size) {
    for (size_t i = 0; i < size; i++) {
        printf("%u ", arr[i]);
    }
    printf("\n");
}

int main() {
    uint32_t arr[] = {1, 2, 3, 4, 5};
    size_t size = sizeof(arr) / sizeof(arr[0]);

    printf("Original array: ");
    print_arr(arr, size);

    reverse_arr(arr, size);

    printf("Reversed array: ");
    print_arr(arr, size);

    return 0;
}
