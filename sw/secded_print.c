// Copyright (c) 2024 ETH Zurich and University of Bologna.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// SRAM test: write/read 100 words to SRAM, verify, print result.

#include "uart.h"
#include "print.h"
#include "config.h"

// #define BASE ((volatile uint32_t *)0x10000800)
#define N 100

int main() {
    uint32_t ok, r;
    int i;
    volatile uint32_t p[N];
    uart_init();
    printf("SRAM test N=100\n");

    ok = 1;
    for (i = 0; i < N; i++) {
        uint32_t w = 0xDEADBEEF ^ i;
        p[i] = w;
        r = p[i];
        if (w != r) {
            printf("%x:FAIL w=0x", i);
            printf("%x", w);
            printf(" r=0x");
            printf("%x", r);
            printf("\n");
            ok = 0;
        }
    }

    if (ok) printf("PASS\n"); else printf("FAIL\n");
    uart_write_flush();
    return 0;
}