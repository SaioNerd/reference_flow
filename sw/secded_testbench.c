// SECDED Encoder/Decoder Testbench
// Single-file program: includes custom SECDED functions + main test logic.
// Communicates all results to the SV testbench via magic memory addresses.

#include "config.h"
#include "util.h"

// ============================================================
// Configurable parameters
// ============================================================
#define N_SAMPLES   1

// ============================================================
// Magic addresses for SV testbench (past ROM range 0x2000_0000-0x2000_0FFF)
// Timing: write 1 to start, write 0 to stop.
// Results: write the value, SV captures it and prints.
// These addresses hit the error subordinate which accepts all writes.
// ============================================================
#define ENC_TIMING_ADDR    ((volatile uint32_t *)0x20100000)
#define DEC_TIMING_ADDR    ((volatile uint32_t *)0x20100004)
#define RES_NUM_SAMPLES    ((volatile uint32_t *)0x20100008)
#define RES_DOUBLE_ERRS    ((volatile uint32_t *)0x2010000C)
#define RES_MISMATCHES     ((volatile uint32_t *)0x20100010)
#define RES_ERR_MISMATCHES ((volatile uint32_t *)0x20100014)
#define RES_TEST_PASS      ((volatile uint32_t *)0x20100018)
#define PROGRESS_ADDR      ((volatile uint32_t *)0x2010001C)

// ============================================================
// Global arrays
// ============================================================
volatile uint32_t samples[N_SAMPLES];
volatile uint64_t encoded[N_SAMPLES] __attribute__((aligned(8)));
volatile uint8_t  err_flags[N_SAMPLES];

// ============================================================
// SECDED Helper: Hsiao(13,8) parity for 8-bit data
// ============================================================
static inline uint8_t calc_parity(uint8_t d) {
    uint8_t p0 = ((d >> 0) ^ (d >> 1) ^ (d >> 2) ^ (d >> 3) ^ (d >> 4) ^ (d >> 5)) & 1;
    uint8_t p1 = ((d >> 0) ^ (d >> 1) ^ (d >> 2) ^ (d >> 6) ^ (d >> 7)) & 1;
    uint8_t p2 = ((d >> 0) ^ (d >> 3) ^ (d >> 4) ^ (d >> 6) ^ (d >> 7)) & 1;
    uint8_t p3 = ((d >> 1) ^ (d >> 3) ^ (d >> 5) ^ (d >> 6)) & 1;
    uint8_t p4 = ((d >> 2) ^ (d >> 4) ^ (d >> 5) ^ (d >> 7)) & 1;
    return (p4 << 4) | (p3 << 3) | (p2 << 2) | (p1 << 1) | p0;
}

// ============================================================
// SECDED Encoder: 32-bit word -> 64-bit doubleword
// ============================================================
uint64_t secded_encode_word(volatile uint32_t data) {
    uint64_t result = 0;

    for (int i = 0; i < 4; i++) {
        uint8_t d = (data >> (i * 8)) & 0xFF;
        uint8_t p = calc_parity(d);

        // Invert parity and combine: {~p, d_in}
        uint8_t p_inv = (~p) & 0x1F;
        uint16_t enc = ((uint16_t)p_inv << 8) | d;

        result |= (uint64_t)(enc & 0x1FFF) << (i * 16);
    }

    return result;
}

// ============================================================
// SECDED Decoder: 64-bit doubleword -> 32-bit word + error flag
// ============================================================
uint32_t secded_decode_word(volatile uint64_t data, uint8_t *err_status) {
    uint32_t result = 0;
    uint8_t max_err = 0;

    for (int i = 0; i < 4; i++) {
        // Extract 13-bit encoded word from 16-bit slot
        uint16_t slot = (data >> (i * 16)) & 0x1FFF;

        uint8_t d_in  =  slot & 0xFF;
        uint8_t p_in  = (~(slot >> 8)) & 0x1F;  // Re-invert parity
        uint8_t p_calc = calc_parity(d_in);

        // Syndrome = recalculated XOR stored
        uint8_t syndrome = p_calc ^ p_in;

        // Odd/even weight (XOR reduction, matches Verilog ^syndrome)
        uint8_t is_odd  = ((syndrome >> 0) ^ (syndrome >> 1) ^ (syndrome >> 2) ^
                           (syndrome >> 3) ^ (syndrome >> 4)) & 1;
        uint8_t is_even = !is_odd;
        uint8_t is_zero = (syndrome == 0);

        // Check if syndrome matches any data column
        uint8_t flip_d = 0;
        if (syndrome == 0x07) flip_d |= (1 << 0);
        if (syndrome == 0x0B) flip_d |= (1 << 1);
        if (syndrome == 0x13) flip_d |= (1 << 2);
        if (syndrome == 0x0D) flip_d |= (1 << 3);
        if (syndrome == 0x15) flip_d |= (1 << 4);
        if (syndrome == 0x19) flip_d |= (1 << 5);
        if (syndrome == 0x0E) flip_d |= (1 << 6);
        if (syndrome == 0x16) flip_d |= (1 << 7);

        // Valid single error
        uint8_t valid_single = is_odd &&
                               (syndrome == 0x01 || syndrome == 0x02 ||
                                syndrome == 0x04 || syndrome == 0x08 ||
                                syndrome == 0x10 || flip_d);

        uint8_t single_err = valid_single;
        uint8_t double_err = (is_even && !is_zero) ||
                             (is_odd && !valid_single);

        // Correct single-bit error
        uint8_t data_out = d_in ^ flip_d;

        // Assemble corrected byte
        result |= (uint32_t)data_out << (i * 8);

        // Track worst error across all 4 bytes
        if (double_err) max_err = 2;
        else if (single_err && max_err < 2) max_err = 1;
    }

    if (err_status) *err_status = max_err;
    return result;
}

// ============================================================
// Main: Testbench (no printf — all results via magic addresses)
// ============================================================
int main() {
    // Signal to SV testbench that execution has started
    *PROGRESS_ADDR = 1;

    // Tell SV testbench how many samples we are using
    *RES_NUM_SAMPLES = N_SAMPLES;

    // ---- Initialize samples with test data ----
    for (int i = 0; i < N_SAMPLES; i++) {
        if (i < 10)
            samples[i] = 0xDEADBEEF;
        else if (i < 20)
            samples[i] = 0x00000000;
        else if (i < 30)
            samples[i] = 0xFFFFFFFF;
        else
            samples[i] = 0x9E3779B9U + i;
    }

    // ---- Encode all samples (timed by SV testbench via magic addresses) ----
    *ENC_TIMING_ADDR = 1;
    for (int i = 0; i < N_SAMPLES; i++) {
        encoded[i] = secded_encode_word(samples[i]);
    }
    *ENC_TIMING_ADDR = 0;

    // ---- Decode all samples in-place (timed by SV testbench via magic addresses) ----
    *DEC_TIMING_ADDR = 1;
    for (int i = 0; i < N_SAMPLES; i++) {
        uint8_t err;
        uint32_t dec = secded_decode_word(encoded[i], &err);
        err_flags[i] = err;
        // Overwrite encoded slot with decoded 32-bit value (saves memory:
        // decoded needs only half the space of the 64-bit encrypted word)
        *(volatile uint32_t *)&encoded[i] = dec;
    }
    *DEC_TIMING_ADDR = 0;

    // ---- Validate results ----
    uint32_t double_errs = 0;
    uint32_t mismatches  = 0;
    uint32_t err_mismatches = 0;

    for (int i = 0; i < N_SAMPLES; i++) {
        volatile uint32_t decoded = *(volatile uint32_t *)&encoded[i];
        uint8_t err = err_flags[i];
        uint32_t orig = samples[i];

        if (err == 2) {
            double_errs++;
        } else {
            if (decoded != orig) {
                mismatches++;
            }
        }

        int data_ok = (decoded == orig);
        if ((err == 0 || err == 1) && !data_ok) {
            err_mismatches++;
        }
    }

    // ---- Write results to magic addresses for SV testbench printing ----
    *RES_DOUBLE_ERRS    = double_errs;
    *RES_MISMATCHES     = mismatches;
    *RES_ERR_MISMATCHES = err_mismatches;

    // Test pass flag: 1 = PASS, 0 = FAIL
    *RES_TEST_PASS = (mismatches == 0 && err_mismatches == 0) ? 1 : 0;

    return 0;
}