// Copyright 2024 ETH Zurich and University of Bologna.
// Solderpad Hardware License, Version 0.51, see LICENSE for details.
// SPDX-License-Identifier: SHL-0.51
//
// Authors:
// - Philippe Sauter <phsauter@iis.ee.ethz.ch>

// gives us the `FF(...) macro making it easy to have properly defined flip-flops
`include "common_cells/registers.svh"

// Simple OBI sink that accepts all requests and completes the transfer.
// For writes: data is consumed silently.
// For reads: returns zero data.
// This module acknowledges every request immediately (1-cycle latency).
module user_design_sink #(
  /// The OBI configuration for all ports.
  parameter obi_pkg::obi_cfg_t           ObiCfg      = obi_pkg::ObiDefaultConfig,
  /// The request struct.
  parameter type                         obi_req_t   = logic,
  /// The response struct.
  parameter type                         obi_rsp_t   = logic
) (
  /// Clock
  input  logic clk_i,
  /// Active-low reset
  input  logic rst_ni,

  /// OBI request interface
  input  obi_req_t obi_req_i,
  /// OBI response interface
  output obi_rsp_t obi_rsp_o
);

  // Registered request valid and ID for the response
  logic req_q;
  logic [ObiCfg.IdWidth-1:0] id_q;

  // --------------------------------------------------------------------------
  // A Channel: Grant immediately when there is a request
  // --------------------------------------------------------------------------
  assign obi_rsp_o.gnt = obi_req_i.req;

  // --------------------------------------------------------------------------
  // Pipeline registers for the response (1-cycle latency)
  // --------------------------------------------------------------------------
  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      req_q <= '0;
      id_q  <= '0;
    end else begin
      req_q <= obi_req_i.req;
      id_q  <= obi_req_i.a.aid;
    end
  end

  // --------------------------------------------------------------------------
  // R Channel: Respond with valid and zero data/error
  // --------------------------------------------------------------------------
  assign obi_rsp_o.rvalid    = req_q;
  assign obi_rsp_o.r.rdata   = '0;
  assign obi_rsp_o.r.rid     = id_q;
  assign obi_rsp_o.r.err     = 1'b0;
  assign obi_rsp_o.r.r_optional = '0;

endmodule