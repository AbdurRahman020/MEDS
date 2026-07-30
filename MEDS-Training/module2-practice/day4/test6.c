#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int main(int argc, char *argv[])
{
    int mem_size = 1024;
    int start_addr = 0;
    int trace = 0;

    for (int i = 1; i < argc; i++) {

        if (strcmp(argv[i], "--mem-size") == 0 && i + 1 < argc) {

            mem_size = atoi(argv[i + 1]);
            i++;
        }

        else if (strcmp(argv[i], "--start-addr") == 0 && i + 1 < argc) {

            start_addr = atoi(argv[i + 1]);
            i++;
        }

        else if (strcmp(argv[i], "--trace") == 0) {

            trace = 1;
        }
    }

    printf("Memory Size = %d\n", mem_size);
    printf("Start Address = %d\n", start_addr);
    printf("Trace = %d\n", trace);

    return 0;
}
