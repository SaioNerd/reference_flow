// Copyright (c) 2025 ETH Zurich and University of Bologna.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
//
// SECDED Benchmark: Measures average encode and decode time for the
// Hsiao (13,8) code used by secded_sram_impl.sv via software.
// Operates on 32-bit words <-> 64-bit SECDED words (4 bytes x 16 bits each).
// Signals start/stop to the testbench via writes to USER_DESIGN addresses.
// All timing is measured externally in the testbench.
//
// Customizable defines (pass via -D to compiler):
//   NUM_SAMPLES=100     - Number of encode/decode iterations per benchmark
//   NUM_TEST_PATTERNS=5 - Number of patterns in self_test (0 to skip)

#include "uart.h"
#include "print.h"
#include "util.h"
#include "config.h"

#ifndef NUM_SAMPLES
#define NUM_SAMPLES 100
#endif
#ifndef NUM_TEST_PATTERNS
#define NUM_TEST_PATTERNS 5
#endif

// Signal addresses for testbench timing
#define ENC_SIGNAL_ADDR  ((volatile unsigned int *)(USER_DESIGN_BASE_ADDR + 0x000))
#define DEC_SIGNAL_ADDR  ((volatile unsigned int *)(USER_DESIGN_BASE_ADDR + 0x004))

static void enc_start(void) { *ENC_SIGNAL_ADDR = 1; }
static void enc_stop(void)  { *ENC_SIGNAL_ADDR = 0; }
static void dec_start(void) { *DEC_SIGNAL_ADDR = 1; }
static void dec_stop(void)  { *DEC_SIGNAL_ADDR = 0; }

// ---------------------------------------------------------------------------
// Hsiao (13,8) SECDED Encoder (matching secded_byte.sv)
// ---------------------------------------------------------------------------
static unsigned short secded_encode_byte(unsigned char d) {
    unsigned char p0, p1, p2, p3, p4;
    p0 = ((d >> 0) ^ (d >> 1) ^ (d >> 2) ^ (d >> 3) ^ (d >> 4) ^ (d >> 5)) & 1;
    p1 = ((d >> 0) ^ (d >> 1) ^ (d >> 2) ^ (d >> 6) ^ (d >> 7)) & 1;
    p2 = ((d >> 0) ^ (d >> 3) ^ (d >> 4) ^ (d >> 6) ^ (d >> 7)) & 1;
    p3 = ((d >> 1) ^ (d >> 3) ^ (d >> 5) ^ (d >> 6)) & 1;
    p4 = ((d >> 2) ^ (d >> 4) ^ (d >> 5) ^ (d >> 7)) & 1;
    unsigned short enc = 0;
    enc |= (unsigned short)(~p0 & 1) << 8;
    enc |= (unsigned short)(~p1 & 1) << 9;
    enc |= (unsigned short)(~p2 & 1) << 10;
    enc |= (unsigned short)(~p3 & 1) << 11;
    enc |= (unsigned short)(~p4 & 1) << 12;
    enc |= (unsigned short)d;
    return enc;
}

// ---------------------------------------------------------------------------
// Hsiao (13,8) SECDED Decoder (matching secded_byte.sv)
// ---------------------------------------------------------------------------
static void secded_decode_byte(unsigned short enc_in,
                               unsigned char *data_out,
                               unsigned char *single_err,
                               unsigned char *double_err) {
    unsigned char d = (unsigned char)(enc_in & 0xFF);
    unsigned char p_in = ~((enc_in >> 8) & 0x1F) & 0x1F;

    unsigned char pc0, pc1, pc2, pc3, pc4;
    pc0 = ((d >> 0) ^ (d >> 1) ^ (d >> 2) ^ (d >> 3) ^ (d >> 4) ^ (d >> 5)) & 1;
    pc1 = ((d >> 0) ^ (d >> 1) ^ (d >> 2) ^ (d >> 6) ^ (d >> 7)) & 1;
    pc2 = ((d >> 0) ^ (d >> 3) ^ (d >> 4) ^ (d >> 6) ^ (d >> 7)) & 1;
    pc3 = ((d >> 1) ^ (d >> 3) ^ (d >> 5) ^ (d >> 6)) & 1;
    pc4 = ((d >> 2) ^ (d >> 4) ^ (d >> 5) ^ (d >> 7)) & 1;

    unsigned char syn = (pc0 ^ ((p_in>>0)&1)) | ((pc1 ^ ((p_in>>1)&1))<<1) |
                        ((pc2 ^ ((p_in>>2)&1))<<2) | ((pc3 ^ ((p_in>>3)&1))<<3) |
                        ((pc4 ^ ((p_in>>4)&1))<<4);

    unsigned char pop = 0;
    for (unsigned char t = syn; t; t >>= 1) pop += t & 1;

    unsigned char odd = pop & 1;
    unsigned char flip = 0;
    if (syn == 0b00111) flip = 1<<0; if (syn == 0b01011) flip = 1<<1;
    if (syn == 0b10011) flip = 1<<2; if (syn == 0b01101) flip = 1<<3;
    if (syn == 0b10101) flip = 1<<4; if (syn == 0b11001) flip = 1<<5;
    if (syn == 0b01110) flip = 1<<6; if (syn == 0b10110) flip = 1<<7;

    *data_out = d ^ flip;

    unsigned char vs = odd && (
        syn == 0b00001 || syn == 0b00010 || syn == 0b00100 ||
        syn == 0b01000 || syn == 0b10000 ||
        syn == 0b00111 || syn == 0b01011 || syn == 0b10011 ||
        syn == 0b01101 || syn == 0b10101 || syn == 0b11001 ||
        syn == 0b01110 || syn == 0b10110);

    *single_err = vs;
    *double_err = (!odd && syn != 0) || (odd && !vs);
}

// ---------------------------------------------------------------------------
// 32-bit <-> 64-bit SECDED word conversion
// ---------------------------------------------------------------------------
static void encode_word(unsigned int din,
                        unsigned int *lo, unsigned int *hi) {
    unsigned short e0 = secded_encode_byte((unsigned char)(din >> 0));
    unsigned short e1 = secded_encode_byte((unsigned char)(din >> 8));
    unsigned short e2 = secded_encode_byte((unsigned char)(din >> 16));
    unsigned short e3 = secded_encode_byte((unsigned char)(din >> 24));
    *lo = ((unsigned int)e1 << 16) | e0;
    *hi = ((unsigned int)e3 << 16) | e2;
}

static void decode_word(unsigned int lo, unsigned int hi,
                        unsigned int *dout,
                        unsigned char *se, unsigned char *de) {
    unsigned char d0, d1, d2, d3;
    unsigned char se_[4], de_[4];
    secded_decode_byte((unsigned short)(lo >> 0), &d0, &se_[0], &de_[0]);
    secded_decode_byte((unsigned short)(lo >> 16), &d1, &se_[1], &de_[1]);
    secded_decode_byte((unsigned short)(hi >> 0), &d2, &se_[2], &de_[2]);
    secded_decode_byte((unsigned short)(hi >> 16), &d3, &se_[3], &de_[3]);
    *dout = ((unsigned int)d0 << 0) | ((unsigned int)d1 << 8) |
            ((unsigned int)d2 << 16) | ((unsigned int)d3 << 24);
    *se = se_[0] | se_[1] | se_[2] | se_[3];
    *de = de_[0] | de_[1] | de_[2] | de_[3];
}

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
// Main
// ---------------------------------------------------------------------------
// Register address used to communicate NUM_SAMPLES to the testbench
#define NUM_SAMPLES_REG  ((volatile unsigned int *)(USER_DESIGN_BASE_ADDR + 0x008))

int main(void) {
    unsigned int data, recovered, lo, hi;
    unsigned char se, de;
    unsigned int i, state;

    uart_init();
    printf("SECDED bench N=");
    printf("%x", NUM_SAMPLES);
    printf("\n");

    // Write NUM_SAMPLES to a register so the testbench can read it
    *NUM_SAMPLES_REG = NUM_SAMPLES;

#if NUM_TEST_PATTERNS > 0
    printf("Self-test N=");
    printf("%x", NUM_TEST_PATTERNS);
    printf("\n");
    for (unsigned int p = 0; p < NUM_TEST_PATTERNS; p++) {
        state = p * 0x9E3779B9;
        data = lfsr_next(&state);
        encode_word(data, &lo, &hi);
        decode_word(lo, hi, &recovered, &se, &de);
        if (recovered != data || se || de) {
            printf("SFAIL p=");
            printf("%x", p);
            printf("\n");
            uart_write_flush();
            return 1;
        }
        // Test single-bit error correction on 5 bit positions
        for (int b = 0; b < 5; b++) {
            unsigned int clo = lo, chi = hi;
            int bit = p * 10 + b;
            int chunk = (bit % 52) / 13;
            int bit_in = (bit % 52) % 13;
            int pos = chunk * 16 + bit_in;
            if (pos < 32) clo ^= (1 << pos); else chi ^= (1 << (pos - 32));
            decode_word(clo, chi, &recovered, &se, &de);
            if (recovered != data) {
                printf("CFAIL p=");
                printf("%x", p);
                printf(" b=");
                printf("%x", b);
                printf("\n");
                uart_write_flush();
                return 1;
            }
        }
    }
    printf("Self-test OK\n");
#endif

    // Generate samples
    unsigned int samples[NUM_SAMPLES];
    state = 0xACE1;
    for (i = 0; i < NUM_SAMPLES; i++) samples[i] = lfsr_next(&state);

    // Use volatile for benchmark output variables to force the compiler
    // to actually execute the encode/decode operations (otherwise it may
    // optimize them away since their results are never used by the C code)
    volatile unsigned int v_lo, v_hi, v_recovered;
    volatile unsigned char v_se, v_de;

    // Pre-encode for decode benchmarks
    unsigned int e_lo[NUM_SAMPLES], e_hi[NUM_SAMPLES];
    for (i = 0; i < NUM_SAMPLES; i++) encode_word(samples[i], &e_lo[i], &e_hi[i]);

    // ----- Encode -----
    
    for (i = 0; i < NUM_SAMPLES; i++){
        enc_start();

        // FORCE COMPILER BARRIER: Math cannot leak upward
        asm volatile("" ::: "memory");

        encode_word(samples[i], (unsigned int *)&v_lo, (unsigned int *)&v_hi);

        // FORCE COMPILER BARRIER: Math cannot leak downward
        asm volatile("" ::: "memory");

        enc_stop();
    };

    // ----- Decode -----
   
    for (i = 0; i < NUM_SAMPLES; i++){
        dec_start();

        // FORCE COMPILER BARRIER: Math cannot leak downward
        asm volatile("" ::: "memory");

        decode_word(e_lo[i], e_hi[i], (unsigned int *)&v_recovered, (unsigned char *)&v_se, (unsigned char *)&v_de);

        // FORCE COMPILER BARRIER: Math cannot leak downward
        asm volatile("" ::: "memory");

        dec_stop();
    };

    // ----- Combined -----
    // enc_start();
    // for (i = 0; i < NUM_SAMPLES; i++) {
    //     encode_word(samples[i], (unsigned int *)&v_lo, (unsigned int *)&v_hi);
    //     decode_word(v_lo, v_hi, (unsigned int *)&v_recovered, (unsigned char *)&v_se, (unsigned char *)&v_de);
    // }
    // enc_stop();

    // ----- Decode + Correction -----
    
    for (i = 0; i < NUM_SAMPLES; i++) {
        unsigned int clo = e_lo[i], chi = e_hi[i];
        clo ^= (1 << (i % 8));
        dec_start();

        // FORCE COMPILER BARRIER: Math cannot leak downward
        asm volatile("" ::: "memory");

        decode_word(clo, chi, (unsigned int *)&v_recovered, (unsigned char *)&v_se, (unsigned char *)&v_de);

        // FORCE COMPILER BARRIER: Math cannot leak downward
        asm volatile("" ::: "memory");// FORCE COMPILER BARRIER: Math cannot leak downward
        
        dec_stop();
    }
    

    printf("Done\n");
    uart_write_flush();
    return 0;
}