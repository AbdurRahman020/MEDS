#include <stdio.h>
#include <string.h>

int main() {
    FILE *fp = fopen("simulation.log", "r");

    if (fp == NULL) {
        perror("Failed to open file");
        return 1;
    }

    char line[256];

    int pass = 0;
    int fail = 0;
    int skip = 0;

    while (fgets(line, sizeof(line), fp) != NULL) {
        if (strstr(line, "PASS") != NULL)
            pass++;
        
        else if (strstr(line, "FAIL") != NULL)
            fail++;
        
        else if(strstr(line, "SKIP") != NULL)
            skip++;
    }

    fclose(fp);

    printf("PASS = %d\n", pass);
    printf("FAIL = %d\n", fail);
    printf("SKIP = %d\n", skip);

    return 0;
}