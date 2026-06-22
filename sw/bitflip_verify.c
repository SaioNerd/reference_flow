#include <stdint.h>
#include "uart.h"
#include "print.h"

#define ARRAY_SIZE      256

// MMIO address to communicate the faulty array address to the testbench
#define ARM_ADDR        ((volatile uint32_t*)0x20001000)

// ============================================================================
// Global Variables & Interrupt Handlers
// ============================================================================

volatile int double_error_interrupt_raised = 0;

void __attribute__((interrupt)) handle_double_error_isr(void) {
    double_error_interrupt_raised = 1;
}

// Reference array: stored in normal SRAM (Bank 0, safe from corruption)
volatile uint8_t ref_array[ARRAY_SIZE];

// Configure RISC-V Control and Status Registers for interrupts
void setup_interrupts() {
    // 1. Point the Trap Vector (mtvec) to your ISR function
    asm volatile("csrw mtvec, %0" : : "r"(handle_double_error_isr));
    
    // 2. Enable Machine External Interrupts (Bit 11) in the 'mie' register
    asm volatile("csrs mie, %0" : : "r"(1 << 11)); 
    
    // 3. Enable Global Interrupts in the 'mstatus' register (MIE is bit 3)
    asm volatile("csrs mstatus, %0" : : "r"(1 << 3));
}

int main() {
    int i;

    uart_init();
    setup_interrupts();
    printf("\n=== SECDED Fault Injection Test ===\n");

    // 1. Declare the faulty array as a local variable.
    //    The compiler will place it somewhere in SRAM (likely Bank 0 or Bank 1).
    //    We pass its address to the testbench so it knows where to inject faults.
    volatile uint8_t faulty_array[ARRAY_SIZE];

    // 2. Tell the testbench the address of the faulty array BEFORE writing to it.
    //    This is the arm signal: the testbench captures the address and starts
    //    monitoring writes to that region.
    printf("Arming testbench with array address 0x%08x...\n", (uint32_t)faulty_array);
    uart_write_flush();  // Ensure the printf is fully transmitted before the arm write
    *ARM_ADDR = (uint32_t)faulty_array;

    // Compiler barrier: ensure the arm write happens BEFORE the array writes
    asm volatile("" ::: "memory");

    // 3. Initialize both arrays with identical data (0..255)
    printf("Writing data to arrays...\n");
    // NOTE: Fault injection happens during this loop!
    // The TB monitors the SRAM bus and injects bit-flips into the 64-bit
    // encoded data on writes to the array's address range.
    // No flush needed here — we WANT the writes to happen immediately.
    for (i = 0; i < ARRAY_SIZE; i++) {
        faulty_array[i] = (uint8_t)i;
        ref_array[i]    = (uint8_t)i;
    }

    // Compiler barrier: ensure array writes complete before reading back
    asm volatile("" ::: "memory");

    // 4. Wait a few cycles for the testbench to inject faults
    //    while the faulty_array data is being written to Bank 1.
    printf("Waiting for fault injection...\n");
    uart_write_flush();  // Ensure printf is transmitted before the wait begins
    asm volatile("nop; nop; nop; nop; nop; nop; nop; nop;");
    asm volatile("nop; nop; nop; nop; nop; nop; nop; nop;");
    printf("Done waiting.\n");
    uart_write_flush();  // Ensure the above printf is transmitted

    // 5. Read back and compare the arrays
    int mismatch_count = 0;
    int first_mismatch = -1;
    int last_mismatch  = -1;

    printf("Verifying data integrity...\n");
    for (i = 0; i < ARRAY_SIZE; i++) {
        uint8_t f_val = faulty_array[i];
        uint8_t r_val = ref_array[i];
        if (f_val != r_val) {
            if (mismatch_count == 0) {
                first_mismatch = i;
            }
            last_mismatch = i;
            mismatch_count++;
        }
    }


    // 6. Report results
    if (mismatch_count == 0) {
        printf("PASS: All %x bytes match (SEC corrected all errors)\n. Mismatch count : %x", ARRAY_SIZE, mismatch_count);
    } else if (double_error_interrupt_raised) {
        // Double errors cause mismatches, but the interrupt caught it!
        printf("PASS: %d mismatches, BUT Double Error Interrupt successfully caught them!\n", mismatch_count);
    } else {
        printf("FAIL: %d mismatch(es) detected with NO interrupt raised (Silent Data Corruption)\n", mismatch_count);
        printf("First mismatch at index %d, last at index %d\n", first_mismatch, last_mismatch);
    }

    uart_write_flush();
    return mismatch_count;
}