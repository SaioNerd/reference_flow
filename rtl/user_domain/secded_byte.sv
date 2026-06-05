// Module: secded_byte
// Description: SECDED (Single Error Correction, Double Error Detection) 
//              for 8-bit data using an inverted Hsiao code (13,8).

`default_nettype none

// ============================================================================
// ENCODER MODULE
// ============================================================================
module secded_byte_encode (
    input  logic [7:0]  data_in,
    output logic [12:0] encoded_out
);
    logic [4:0] p;

    // Hsiao Matrix Calculation (Columns of weight 3)
    // d0: 00111, d1: 01011, d2: 10011, d3: 01101
    // d4: 10101, d5: 11001, d6: 01110, d7: 10110
    assign p[0] = data_in[0] ^ data_in[1] ^ data_in[2] ^ data_in[3] ^ data_in[4] ^ data_in[5];
    assign p[1] = data_in[0] ^ data_in[1] ^ data_in[2] ^ data_in[6] ^ data_in[7];
    assign p[2] = data_in[0] ^ data_in[3] ^ data_in[4] ^ data_in[6] ^ data_in[7];
    assign p[3] = data_in[1] ^ data_in[3] ^ data_in[5] ^ data_in[6];
    assign p[4] = data_in[2] ^ data_in[4] ^ data_in[5] ^ data_in[7];

    // "INV" Algorithm: Invert the parity bits before writing to memory
    // This catches all-zero reads from uninitialized memory addresses.
    assign encoded_out = {~p, data_in};

endmodule


// ============================================================================
// DECODER MODULE
// ============================================================================
module secded_byte_decode (
    input  logic [12:0] encoded_in,
    output logic [7:0]  data_out,
    output logic        single_err_o,
    output logic        double_err_o // Often called 'uncorrectable_err'
);
    logic [7:0] d_in;
    logic [4:0] p_in;
    logic [4:0] p_calc;
    logic [4:0] syndrome;

    // Split encoded word
    assign d_in = encoded_in[7:0];
    // Re-invert the parity bits read from memory
    assign p_in = ~encoded_in[12:8];

    // Recalculate parity based on read data
    assign p_calc[0] = d_in[0] ^ d_in[1] ^ d_in[2] ^ d_in[3] ^ d_in[4] ^ d_in[5];
    assign p_calc[1] = d_in[0] ^ d_in[1] ^ d_in[2] ^ d_in[6] ^ d_in[7];
    assign p_calc[2] = d_in[0] ^ d_in[3] ^ d_in[4] ^ d_in[6] ^ d_in[7];
    assign p_calc[3] = d_in[1] ^ d_in[3] ^ d_in[5] ^ d_in[6];
    assign p_calc[4] = d_in[2] ^ d_in[4] ^ d_in[5] ^ d_in[7];

    // Calculate Syndrome
    assign syndrome = p_calc ^ p_in;

    // ------------------------------------------------------------------------
    // Error Evaluation
    // ------------------------------------------------------------------------
    logic is_odd_weight;
    logic is_even_weight;
    logic is_zero;

    assign is_odd_weight  = ^syndrome; // XOR reduction (1 if odd number of bits flipped)
    assign is_even_weight = ~is_odd_weight;
    assign is_zero        = (syndrome == 5'b00000);

    // Single Error Correction: Check if syndrome matches any data column
    logic [7:0] flip_d;
    assign flip_d[0] = (syndrome == 5'b00111);
    assign flip_d[1] = (syndrome == 5'b01011);
    assign flip_d[2] = (syndrome == 5'b10011);
    assign flip_d[3] = (syndrome == 5'b01101);
    assign flip_d[4] = (syndrome == 5'b10101);
    assign flip_d[5] = (syndrome == 5'b11001);
    assign flip_d[6] = (syndrome == 5'b01110);
    assign flip_d[7] = (syndrome == 5'b10110);

    // Apply correction to data
    assign data_out = d_in ^ flip_d;

    // Check if the syndrome exactly matches a known single-bit error 
    // (either a data bit or one of the 5 parity bits)
    logic valid_single_err;
    assign valid_single_err = is_odd_weight &&
                              ( (syndrome == 5'b00001) || (syndrome == 5'b00010) || 
                                (syndrome == 5'b00100) || (syndrome == 5'b01000) || 
                                (syndrome == 5'b10000) || 
                                flip_d[0] || flip_d[1] || flip_d[2] || flip_d[3] || 
                                flip_d[4] || flip_d[5] || flip_d[6] || flip_d[7] );

    // ------------------------------------------------------------------------
    // Status Flags Output
    // ------------------------------------------------------------------------
    
    // Valid single error (correctable)
    assign single_err_o = valid_single_err;

    // Double error (uncorrectable):
    // 1. Even weight and not zero (standard double error)
    // 2. Odd weight but doesn't match any valid column (e.g. 3 bits flipped, or all zeros read)
    assign double_err_o = (is_even_weight && !is_zero) || (is_odd_weight && !valid_single_err);

endmodule

`default_nettype wire