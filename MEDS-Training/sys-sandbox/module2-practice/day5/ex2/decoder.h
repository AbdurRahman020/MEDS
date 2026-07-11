#ifndef DECODER_H
#define DECODER_H

#include <stdint.h>
#include <stdio.h>

// RV32 vs RV64 switch
#ifdef RV64
    typedef uint64_t reg_t;
    #define REG_FMT "0x%016lX"
#else
    typedef uint32_t reg_t;
    #define REG_FMT "0x%08X"
#endif

// debug macro — prints file & line, compiled out in release
#ifdef DEBUG
    #define LOG(fmt, ...) \
        fprintf(stderr, "[%s:%d] " fmt "\n", __FILE__, __LINE__, ##__VA_ARGS__)
#else
    #define LOG(fmt, ...)
#endif

void decode(reg_t instruction);

#endif
