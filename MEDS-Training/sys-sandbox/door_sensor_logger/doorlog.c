#include <stdio.h>
#include "doorlog.h"

// convert sensor enum to string
static const char *sensor_to_string(sensor_type_t sensor) {
    switch (sensor) {
        case DOOR:
            return "DOOR";
        case MOTION:
            return "MOTION";
        case TEMP:
            return "TEMP";
        default:
            return "UNKNOWN";
    }
}

// print memory contents and statistics
void print_memory(const uint8_t *memory, size_t mem_size) {
    decoded_instr_t instr;

    size_t active_count = 0;
    size_t inactive_count = 0;
    size_t unknown_count = 0;

    int temp_sum = 0;
    size_t temp_count = 0;

    printf("%-4s %-10s %-12s %-8s %-10s\n", "Idx", "Device ID", "Sensor", "Active", "Reading");

    for (size_t i = 0; i < mem_size; i += 4) {
        // copy one record from memory into the struct
        instr.readings    = memory[i + 0];
        instr.active      = memory[i + 1];
        instr.sensor_type = memory[i + 2];
        instr.device_id   = memory[i + 3];

        // count active/inactive
        if (instr.active)
            active_count++;
        else
            inactive_count++;

        // count unknown sensors
        if (instr.sensor_type > TEMP)
            unknown_count++;

        printf("%-4zu ", i / 4);
        printf("%-10u ", instr.device_id);
        printf("%-12s ", sensor_to_string((sensor_type_t)instr.sensor_type));
        printf("%-8s ", instr.active ? "YES" : "NO");

        if (instr.sensor_type == TEMP) {
            int temp = SIGN_EXTEND(instr.readings, 8);

            temp_sum += temp;
            temp_count++;

            printf("%d", temp);
        } else {
            printf("%u", instr.readings);
        }

        printf("\n");
    }

    printf("\n===SUMMARY===\n");
    printf("Active devices   : %zu\n", active_count);
    printf("Inactive devices : %zu\n", inactive_count);
    printf("Unknown sensors  : %zu\n", unknown_count);

    if (temp_count == 0) {
        printf("Average Temp     : N/A (No temperature readings)\n");
    } else {
        printf("Average Temp     : %.2f\n",
               (double)temp_sum / temp_count);
    }
}
