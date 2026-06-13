// Copyright 2025 ETH Zurich and University of Bologna.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

// Minimal SECDED encoder/decoder: Hsiao(13,8) with inverted parity,
// matching secded_byte_encode.sv and secded_byte_decode.sv exactly.

#include "secded.h"

// ---- Helper: Hsiao parity calculation for 8-bit data ----
static inline uint8_t calc_parity(uint8_t d) {
    uint8_t p0 = ((d >> 0) ^ (d >> 1) ^ (d >> 2) ^ (d >> 3) ^ (d >> 4) ^ (d >> 5)) & 1;
    uint8_t p1 = ((d >> 0) ^ (d >> 1) ^ (d >> 2) ^ (d >> 6) ^ (d >> 7)) & 1;
    uint8_t p2 = ((d >> 0) ^ (d >> 3) ^ (d >> 4) ^ (d >> 6) ^ (d >> 7)) & 1;
    uint8_t p3 = ((d >> 1) ^ (d >> 3) ^ (d >> 5) ^ (d >> 6)) & 1;
    uint8_t p4 = ((d >> 2) ^ (d >> 4) ^ (d >> 5) ^ (d >> 7)) & 1;
    return (p4 << 4) | (p3 << 3) | (p2 << 2) | (p1 << 1) | p0;
}

// ---- Encoder ----
uint64_t secded_encode_word(volatile uint32_t data) {
    uint64_t result = 0;

    for (int i = 0; i < 4; i++) {
        uint8_t d = (data >> (i * 8)) & 0xFF;
        uint8_t p = calc_parity(d);

        // Invert parity and combine with data: {~p, d_in}
        uint8_t p_inv = (~p) & 0x1F;
        uint16_t encoded = ((uint16_t)p_inv << 8) | d;

        // Store 13-bit result in 16-bit slot, pack into 64-bit
        result |= (uint64_t)(encoded & 0x1FFF) << (i * 16);
    }

    return result;
}

// ---- Decoder ----
uint32_t secded_decode_word(volatile uint64_t data, uint8_t *err_status) {
    uint32_t result = 0;
    uint8_t max_err = 0;

    for (int i = 0; i < 4; i++) {
        // Extract 13-bit encoded word from 16-bit slot
        uint16_t slot = (data >> (i * 16)) & 0x1FFF;

        uint8_t d_in  =  slot & 0xFF;
        uint8_t p_in  = (~(slot >> 8)) & 0x1F;  // Re-invert parity
        uint8_t p_calc = calc_parity(d_in);

        // Syndrome = recalculated parity XOR stored parity
        uint8_t syndrome = p_calc ^ p_in;

        // Error evaluation: XOR reduction (matches Verilog ^syndrome)
        uint8_t is_odd_weight  = ((syndrome >> 0) ^ (syndrome >> 1) ^ (syndrome >> 2) ^
                                 (syndrome >> 3) ^ (syndrome >> 4)) & 1;
        uint8_t is_even_weight = !is_odd_weight;
        uint8_t is_zero        = (syndrome == 0);

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

        // Valid single error: odd weight AND syndrome matches a valid column
        uint8_t valid_single_err = is_odd_weight &&
                                   (syndrome == 0x01 || syndrome == 0x02 ||
                                    syndrome == 0x04 || syndrome == 0x08 ||
                                    syndrome == 0x10 || flip_d);

        uint8_t single_err = valid_single_err;
        uint8_t double_err = (is_even_weight && !is_zero) ||
                             (is_odd_weight && !valid_single_err);

        // Apply single-error correction
        uint8_t data_out = d_in ^ flip_d;

        // Assemble corrected byte into output
        result |= (uint32_t)data_out << (i * 8);

        // Track worst error status across all 4 bytes
        if (double_err) max_err = 2;
        else if (single_err && max_err < 2) max_err = 1;
    }

    if (err_status) *err_status = max_err;
    return result;
}