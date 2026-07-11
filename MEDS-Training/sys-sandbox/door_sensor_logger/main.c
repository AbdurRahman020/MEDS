#include <stdio.h>
#include <stdlib.h>

#include "memory.h"
#include "doorlog.h"

int main(void) {
    const char *filename = "sensor_log.hex";

    size_t mem_size = 0;
    int words_loaded = 0;

    uint8_t *memory = create_memory(filename, &mem_size, &words_loaded);

    if (memory == NULL) {
        fprintf(stderr, "Failed to load '%s'\n", filename);
        return EXIT_FAILURE;
    }

    printf("Loaded %d sensor log entr%s.\n\n", words_loaded, (words_loaded == 1) ? "y" : "ies");

    print_memory(memory, mem_size);

    free(memory);

    return EXIT_SUCCESS;
}
