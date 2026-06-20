#include <stdint.h>
#include "util.h" 
#include "print.h" // Added to enable console printing
#include "uart.h"

#define TB_TRIGGER   0x20001000
#define TARGET_ADDR  0x10000400

int main() {
    uart_init();

    volatile uint32_t *tb_cmd = (volatile uint32_t *)TB_TRIGGER;
    volatile uint32_t *target = (volatile uint32_t *)TARGET_ADDR;
    volatile uint32_t dummy_read;

    printf("\n=== STARTING REPAIR BUFFER HAZARD CORNER CASES ===\n");

    // =========================================================================
    // CASE 1: CPU Overwrite (Write-Cancellation)
    // =========================================================================
    printf("\n[CPU] Starting Case 1: Write-Cancellation\n");
    *tb_cmd = 1;                  // Tell TB to inject error on next write
    *target = 0x11111111;         // CPU write (TB flips Bit 0)
    
    printf("[CPU] Reading back corrupted address to trigger buffer latch...\n");
    dummy_read = *target;         // Read 1: Buffer catches the error
    
    printf("[CPU] Performing immediate overwrite to address %x\n", TARGET_ADDR);
    *target = 0x22222222;         // Immediate write cancels buffer pending repair
    
    asm volatile("nop"); asm volatile("nop"); asm volatile("nop");


    // =========================================================================
    // CASE 2: The Idle Drain
    // =========================================================================
    printf("\n[CPU] Starting Case 2: Idle Drain\n");
    *tb_cmd = 2;                  // Tell TB to inject error on next write
    *target = 0xAAAAAAAA;         // CPU write (TB flips Bit 0)
    
    printf("[CPU] Reading back corrupted address to trigger buffer latch...\n");
    dummy_read = *target;         // Read 1: Buffer catches the error
    
    printf("[CPU] Going idle to let buffer drain...\n");
    asm volatile("nop"); asm volatile("nop"); asm volatile("nop"); asm volatile("nop");


    // =========================================================================
    // CASE 3: Two Reads (Buffer Update via Snoop)
    // =========================================================================
    printf("\n[CPU] Starting Case 3: Double Read / Buffer Overwrite\n");
    *tb_cmd = 3;                  // Tell TB to inject errors on next TWO reads
    *target = 0xBBBBBBBB;         // Write clean data
    
    printf("[CPU] Executing Read 1 (TB will flip Bit 0)...\n");
    dummy_read = *target;         
    
    printf("[CPU] Executing Read 2 (Snoop hits, but TB flips Bit 1)...\n");
    dummy_read = *target;         

    printf("[CPU] Going idle to let updated buffer drain...\n");
    asm volatile("nop"); asm volatile("nop"); asm volatile("nop"); asm volatile("nop");

    // =========================================================================
    // CASE 4: ECC Parity Bit Fault Injection
    // =========================================================================
    printf("\n[CPU] Case 4: ECC Parity Bit Fault Injection...\n");
    *tb_cmd = 4;                  
    *target = 0xCCCCCCCC;         
    
    // CPU reads the data. The payload is perfect, but the hardware decoder 
    // flags a parity error, reconstructs it, and latches it to the repair buffer.
    dummy_read = *target;         

    // CPU goes idle. Buffer drains the re-encoded, perfect 64-bit word back to SRAM.
    asm volatile("nop"); asm volatile("nop"); asm volatile("nop"); asm volatile("nop");

    printf("\n=== ALL TEST CASES COMPLETED SUCCESSFULLY ===\n");
    
    *tb_cmd = 0;
    return 0;
}