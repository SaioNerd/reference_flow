#include <stdint.h>

#define ARRAY_SIZE      256
// UserBank0 ranges from 0x1000_0000 to 0x1000_0800 (2048 bytes / 512 words)
#define SRC_ARRAY_ADDR  ((volatile uint8_t*)0x10000800) // Word index 0 to 63
#define DST_ARRAY_ADDR  ((volatile uint8_t*)0x10000900) // Word index 64 to 127
#define TRIGGER_ADDR    ((volatile uint32_t*)0x10001000) // Magic Memory Address to trigger the testbench to inject faults

volatile int double_error_interrupt_raised = 0;

// Example Interrupt Service Routine for Double Error (DED)
void __attribute__((interrupt)) handle_double_error_isr(void) {
    double_error_interrupt_raised = 1;
    // Clear interrupt pending flags here if necessary
}

void verify_secded_system() {
    double_error_interrupt_raised = 0;

    // 1. Populate both memory spaces with identical data
    for (int i = 0; i < ARRAY_SIZE; i++) {
        SRC_ARRAY_ADDR[i] = (uint8_t)i;
        DST_ARRAY_ADDR[i] = (uint8_t)i;
    }

    // 2. Alert the testbench by storing to the trigger address
    // We pass the value '1' for SEC test, or '2' for DED test
    *TRIGGER_ADDR = 1; 

    // Synchronize pipeline execution to allow the testbench to inject faults
    asm volatile("nop; nop; nop;");

    // 3. Read back and evaluate the results
    int mismatch_detected = 0;
    for (int i = 0; i < ARRAY_SIZE; i++) {
        if (SRC_ARRAY_ADDR[i] != DST_ARRAY_ADDR[i]) {
            mismatch_detected++;
        }
    }

    // 4. Report status
    if (mismatch_detected == 0) {
        // SUCCESS for Single Error Correction (SEC): data was transparently restored!
    } else if (double_error_interrupt_raised) {
        // SUCCESS for Double Error Detection (DED): data mismatch occurred but caught by ISR!
    }
}