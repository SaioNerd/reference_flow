#include <stdint.h>
#include "util.h" 
#include "print.h"
#include "uart.h"

#define TB_TRIGGER   0x20001000
#define TARGET_ADDR  0x10000400

int main() {
    // Initialize UART to prevent CPU stalling during printf
    uart_init();
    
    volatile uint32_t *tb_cmd = (volatile uint32_t *)TB_TRIGGER;
    volatile uint32_t *target = (volatile uint32_t *)TARGET_ADDR;
    volatile uint32_t dummy_read;

    printf("\n=== STARTING FATAL DOUBLE ERROR TEST ===\n");

    printf("[CPU] Arming Testbench Case 5...\n");
    *tb_cmd = 5;                  
    
    printf("[CPU] Writing target payload. TB will inject a double-bit fault.\n");
    *target = 0xDDDDDDDD;         
    
    // CRITICAL: Do not place any printf statements between the write and the read.
    // The read pulls the corrupted codeword through the decoder, identifying the 
    // impossible syndrome and triggering the fatal interrupt line.
    dummy_read = *target;         

    // Allow clock cycles for the hardware monitor to register the interrupt
    asm volatile("nop"); asm volatile("nop"); asm volatile("nop"); asm volatile("nop");

    printf("\n[CPU] Test execution finished. Check HW Monitor logs for interrupts_o[0] spike.\n");
    
    // Disarm testbench and end simulation gracefully
    *tb_cmd = 0;
    return 0;
}