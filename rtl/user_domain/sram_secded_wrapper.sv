// Copyright 2024 ETH Zurich and University of Bologna.
// Solderpad Hardware License, Version 0.51, see LICENSE for details.
// SPDX-License-Identifier: SHL-0.51
//
// SRAM SECDED/Bypass Wrapper with Multi-Bank Support
// Encapsulates all SRAM + SECDED/Bypass logic, can replace entire SRAM block in user_domain
//
// Supports two modes via croc_pkg::SECDEDBypass flag:
//   - Mode 0 (SECDEDBypass=0): Hardware SECDED encoding/decoding (4 bytes * 13 bits = 52 bits in 64-bit word)
//   - Mode 1 (SECDEDBypass=1): Direct pass-through with address bit [2] mapping (32-bit to upper/lower half of 64-bit word)
//
// This module instantiates all NumSramBanks internally and can be used as a drop-in replacement
// for the entire SRAM + SECDED/Bypass logic block in user_domain.sv by:
//   sram_secded_wrapper #(
//     .NumSramBanks(NumSramBanks),
//     .SramBankNumWords(SramBankNumWords)
//   ) i_sram_wrapper (
//     .clk_i, .rst_ni, .sram_impl_i,
//     .sram_req_i, .sram_we_i, .sram_addr_i,
//     .sram_wdata_i, .sram_be_i,
//     .sram_gnt_o, .sram_rdata_o,
//     .interrupts_o
//   );

`include "common_cells/registers.svh"

module sram_secded_wrapper #(
  parameter int unsigned NumSramBanks = 2,
  parameter int unsigned SramBankNumWords = 512
) (
  input  logic clk_i,
  input  logic rst_ni,
  input  logic testmode_i,
  input  logic sram_impl_i,
  
  // SRAM interface from OBI shim (all banks)
  input  logic [NumSramBanks-1:0]                                               sram_req_i,
  input  logic [NumSramBanks-1:0]                                               sram_we_i,
  input  logic [NumSramBanks-1:0][cf_math_pkg::idx_width(SramBankNumWords)-1:0]  sram_addr_i,
  input  logic [NumSramBanks-1:0][31:0]                                         sram_wdata_i,
  input  logic [NumSramBanks-1:0][3:0]                                          sram_be_i,
  
  output logic [NumSramBanks-1:0]                                               sram_gnt_o,
  output logic [NumSramBanks-1:0][31:0]                                         sram_rdata_o,
  
  output logic [3:0]                                                            interrupts_o
);

  localparam int unsigned SramBankAddrWidth = cf_math_pkg::idx_width(SramBankNumWords);
  logic [NumSramBanks-1:0] bank_double_err;

  generate
    if (croc_pkg::SECDEDBypass == 1'b0) begin : gen_secded_mode
      // ================= HARDWARE SECDED MODE =================
      
      for (genvar i = 0; i < NumSramBanks; i++) begin : gen_sram_bank
        
        logic [63:0] sram_wdata_64;
        logic [63:0] sram_rdata_64;
        logic [63:0] sram_be_64;
        logic [3:0] byte_double_err;
        
        // --- SECDED: Byte level Encode and Decode ---
        for (genvar b = 0; b < 4; b++) begin : gen_secded_bytes
          logic [12:0] enc_data;
          logic [12:0] dec_data;
          logic [7:0] tmp_data_out;
          logic tmp_single_err;

          secded_byte_encode i_encode (
            .data_in     ( sram_wdata_i[i][b*8 +: 8] ),
            .encoded_out ( enc_data                  )
          );
          
          assign sram_wdata_64[b*13 +: 13] = enc_data;
          assign sram_be_64[b*13 +: 13] = sram_be_i[i][b] ? 13'h1FFF : 13'h0000;
          assign dec_data = sram_rdata_64[b*13 +: 13];

          secded_byte_decode i_decode (
            .encoded_in   ( dec_data           ),
            .data_out     ( tmp_data_out       ),
            .single_err_o ( tmp_single_err    ),
            .double_err_o ( byte_double_err[b])
          );

          assign sram_rdata_o[i][b*8 +: 8] = tmp_data_out;
        end

        assign sram_wdata_64[63:52] = '0;
        assign sram_be_64[63:52]    = '0;
        assign bank_double_err[i] = |byte_double_err;

        tc_sram_impl #(
          .NumWords  ( SramBankNumWords ),
          .DataWidth ( 64               ),
          .ByteWidth ( 1                ),
          .NumPorts  ( 1                ),
          .Latency   ( 1                )
        ) i_sram (
          .clk_i,
          .rst_ni,
          .impl_i  ( sram_impl_i    ),
          .impl_o  (                ),
          .req_i   ( sram_req_i[i]  ),
          .we_i    ( sram_we_i[i]   ),
          .addr_i  ( sram_addr_i[i] ),
          .wdata_i ( sram_wdata_64  ),
          .be_i    ( sram_be_64     ),
          .rdata_o ( sram_rdata_64  )
        );

        assign sram_gnt_o[i] = 1'b1;
      end

      assign interrupts_o[0] = |bank_double_err;
      assign interrupts_o[3:1] = '0;

    end else begin : gen_secded_bypass_mode
      // ================= BYPASS MODE (Direct 32-bit ↔ 64-bit mapping) =================
      
      for (genvar i = 0; i < NumSramBanks; i++) begin : gen_sram_bank

        logic addr_half;
        logic [63:0] sram_wdata_64;
        logic [63:0] sram_rdata_64;
        logic [7:0]  sram_be_64;
        logic [31:0] rdata_selected;
        logic [31:0] rdata_q;
        logic addr_half_q;

        assign addr_half = sram_addr_i[i][2];

        always_comb begin
          sram_wdata_64 = '0;
          sram_be_64 = '0;
          
          if (addr_half == 1'b0) begin
            sram_wdata_64[31:0] = sram_wdata_i[i][31:0];
            sram_be_64[3:0] = sram_be_i[i][3:0];
          end else begin
            sram_wdata_64[63:32] = sram_wdata_i[i][31:0];
            sram_be_64[7:4] = sram_be_i[i][3:0];
          end
        end

        assign rdata_selected = (addr_half == 1'b0) ? sram_rdata_64[31:0] : sram_rdata_64[63:32];

        always_ff @(posedge clk_i or negedge rst_ni) begin
          if (!rst_ni) begin
            rdata_q <= '0;
            addr_half_q <= 1'b0;
          end else begin
            rdata_q <= rdata_selected;
            addr_half_q <= addr_half;
          end
        end

        assign sram_rdata_o[i][31:0] = rdata_q;

        tc_sram_impl #(
          .NumWords  ( SramBankNumWords ),
          .DataWidth ( 64               ),
          .ByteWidth ( 8                ),
          .NumPorts  ( 1                ),
          .Latency   ( 1                )
        ) i_sram (
          .clk_i,
          .rst_ni,
          .impl_i  ( sram_impl_i           ),
          .impl_o  (                       ),
          .req_i   ( sram_req_i[i]         ),
          .we_i    ( sram_we_i[i]          ),
          .addr_i  ( sram_addr_i[i][8:0]   ),
          .wdata_i ( sram_wdata_64         ),
          .be_i    ( sram_be_64            ),
          .rdata_o ( sram_rdata_64         )
        );

        assign sram_gnt_o[i] = 1'b1;
      end

      assign bank_double_err = '0;
      assign interrupts_o = '0;
    end
  endgenerate

endmodule

`default_nettype wire
