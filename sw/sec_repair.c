#include <stdint.h>
#include "uart.h"
#include "print.h"

// MMIO address to communicate the target address to the testbench
#define ARM_ADDR        ((volatile uint32_t*)0x20001000)

int main() {
    uint32_t i;

    uart_init();
    printf("\n=== Memory Access Test (32-bit Word) ===\n");

    // 1. Declare a 32-bit word as a local variable on the stack.
    //    The compiler will place it somewhere in SRAM.
    volatile uint32_t test_word;

    // 2. Provide the address of the 32-bit word to the testbench (arm signal).
    printf("Target address: 0x%x\n", (uint32_t)&test_word);
    uart_write_flush();
    *ARM_ADDR = (uint32_t)&test_word;

    // Compiler barrier: ensure the arm write happens BEFORE the actual write
    asm volatile("" ::: "memory");

    // GIVE A LOT OF TIME TO THE CHIP
    printf("Waiting for testbench to arm...\n");
    uart_write_flush();
    asm volatile("nop; nop; nop; nop; nop; nop; nop; nop;");
    asm volatile("nop; nop; nop; nop; nop; nop; nop; nop;");
    asm volatile("nop; nop; nop; nop; nop; nop; nop; nop;");
    asm volatile("nop; nop; nop; nop; nop; nop; nop; nop;");
    asm volatile("nop; nop; nop; nop; nop; nop; nop; nop;");
    printf("Done waiting.\n");
    uart_write_flush();

    // 3. Write a 32-bit pattern to memory
    printf("Writing 0xDEADBEEF to 0x%x...\n", (uint32_t)&test_word);
    test_word = 0xDEADBEEF;

    // Compiler barrier: ensure the write completes before reading back
    asm volatile("" ::: "memory");

    asm volatile("nop; nop; nop; nop; nop; nop; nop; nop;");
    asm volatile("nop; nop; nop; nop; nop; nop; nop; nop;");
    asm volatile("nop; nop; nop; nop; nop; nop; nop; nop;");
    asm volatile("nop; nop; nop; nop; nop; nop; nop; nop;");
    asm volatile("nop; nop; nop; nop; nop; nop; nop; nop;");

    // 4. Read back the 32-bit word from memory
    uint32_t read_back = test_word;
    printf("Read back  0x%x from 0x%x\n", read_back, (uint32_t)&test_word);

    // 5. Verify integrity
    if (read_back == 0xDEADBEEF) {
        printf("PASS: Data integrity verified (read value matches written value)\n");
    } else {
        printf("FAIL: Data mismatch! Expected 0xDEADBEEF, got 0x%x\n", read_back);
    }


    printf("Waiting for testbench to arm...\n");
    uart_write_flush();
    asm volatile("nop; nop; nop; nop; nop; nop; nop; nop;");
    asm volatile("nop; nop; nop; nop; nop; nop; nop; nop;");
    asm volatile("nop; nop; nop; nop; nop; nop; nop; nop;");
    asm volatile("nop; nop; nop; nop; nop; nop; nop; nop;");
    asm volatile("nop; nop; nop; nop; nop; nop; nop; nop;");
    printf("Done waiting.\n");
    uart_write_flush();
    // 6. Write a second pattern to show repeated memory access
    printf("\n--- Second access ---\n");


    asm volatile("" ::: "memory");

    read_back = test_word;
    printf("Read back  0x%x from 0x%x\n", read_back, (uint32_t)&test_word);

    if (read_back == 0xDEADBEEF) {
        printf("PASS: Data integrity verified (read value matches written value)\n");
    } else {
        printf("FAIL: Data mismatch! Expected 0xDEADBEEF, got 0x%x\n", read_back);
    }

    uart_write_flush();
    return 0;
}