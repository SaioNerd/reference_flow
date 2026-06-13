// Copyright 2025 ETH Zurich and University of Bologna.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

#pragma once

#include <stdint.h>

// SECDED-encode a 32-bit word into a 64-bit doubleword.
// Separates the input into 4 bytes, applies Hsiao(13,8) with inverted parity
// (matching secded_byte_encode.sv), stores each 13-bit result in a 16-bit slot
// (upper 3 bits zero), and packs the 4 slots into a 64-bit return value.
uint64_t secded_encode_word(volatile uint32_t data);

// SECDED-decode a 64-bit doubleword back into a 32-bit word.
// Splits the input into 4 halfwords, reads 13 LSBs of each, applies Hsiao(13,8)
// decode with error correction (matching secded_byte_decode.sv), and packs the
// 4 corrected bytes into a 32-bit return value.
// err_status output: 0 = no error, 1 = single error corrected, 2 = double error
uint32_t secded_decode_word(volatile uint64_t data, uint8_t *err_status);