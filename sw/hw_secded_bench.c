// SECDED Hardware Benchmark
// Measures the execution time of hardware-level SECDED by profiling 
// native memory loads and stores.

#include "uart.h"
#include "print.h"
#include "util.h"
#include "config.h"

#ifndef NUM_SAMPLES
#define NUM_SAMPLES 100
#endif

// Signal addresses for testbench timing
#define ENC_SIGNAL_ADDR  ((volatile unsigned int *)(USER_DESIGN_BASE_ADDR + 0x000))
#define DEC_SIGNAL_ADDR  ((volatile unsigned int *)(USER_DESIGN_BASE_ADDR + 0x004))
#define NUM_SAMPLES_REG  ((volatile unsigned int *)(USER_DESIGN_BASE_ADDR + 0x008))

static void enc_start(void) { *ENC_SIGNAL_ADDR = 1; }
static void enc_stop(void)  { *ENC_SIGNAL_ADDR = 0; }
static void dec_start(void) { *DEC_SIGNAL_ADDR = 1; }
static void dec_stop(void)  { *DEC_SIGNAL_ADDR = 0; }

// ---------------------------------------------------------------------------
// Simple 32-bit LFSR
// ---------------------------------------------------------------------------
static unsigned int lfsr_next(unsigned int *state) {
    unsigned int bit = ((*state >> 15) ^ (*state >> 13) ^
                        (*state >> 12) ^ (*state >> 10)) & 1;
    *state = (*state << 1) | bit;
    return *state ^ (*state << 16);
}

// ---------------------------------------------------------------------------
// Main Target Memory
// ---------------------------------------------------------------------------
// This array represents the memory region protected by the hardware SECDED.
// 'volatile' prevents the compiler from optimizing out the memory accesses.
volatile unsigned int hw_test_mem[NUM_SAMPLES];

int main(void) {
    unsigned int i, state;
    volatile unsigned int v_recovered;

    uart_init();
    printf("HW SECDED bench N=");
    printf("%x", NUM_SAMPLES);
    printf("\n");

    // Write NUM_SAMPLES to a register so the testbench can read it
    *NUM_SAMPLES_REG = NUM_SAMPLES;

    // Generate test data
    unsigned int samples[NUM_SAMPLES];
    state = 0xACE1;
    for (i = 0; i < NUM_SAMPLES; i++) samples[i] = lfsr_next(&state);

    // ----- Encode (Hardware Memory Writes) -----
    // Writing to SRAM triggers the hardware encoder automatically.
    
    for (i = 0; i < NUM_SAMPLES; i++) {
        enc_start();
        hw_test_mem[i] = samples[i]; 
        enc_stop();
    }
    

    // ----- Decode (Hardware Memory Reads) -----
    // Reading from SRAM triggers the hardware decoder automatically.
    
    for (i = 0; i < NUM_SAMPLES; i++) {
        dec_start();
        v_recovered = hw_test_mem[i];
        dec_stop();
    }
    

    printf("Done\n");
    uart_write_flush();
    return 0;
}