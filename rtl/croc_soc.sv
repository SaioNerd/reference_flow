// Copyright 2024 ETH Zurich and University of Bologna.
// Solderpad Hardware License, Version 0.51, see LICENSE for details.
// SPDX-License-Identifier: SHL-0.51
//
// Authors:
// - Philippe Sauter <phsauter@iis.ee.ethz.ch>

module croc_soc import croc_pkg::*; #(
  parameter int unsigned GpioCount = 16
) (
  input  logic clk_i,
  input  logic rst_ni,
  input  logic ref_clk_i,
  input  logic testmode_i,
  output logic status_o,

  input  logic jtag_tck_i,
  input  logic jtag_tdi_i,
  output logic jtag_tdo_o,
  input  logic jtag_tms_i,
  input  logic jtag_trst_ni,

  input  logic uart_rx_i,
  output logic uart_tx_o,

  input  logic [GpioCount-1:0] gpio_i,       // Input from GPIO pins
  output logic [GpioCount-1:0] gpio_o,       // Output to GPIO pins
  output logic [GpioCount-1:0] gpio_out_en_o // Output enable signal; 0 -> input, 1 -> output
);

  logic synced_rst_n;

  rstgen i_rstgen (
    .clk_i,
    .rst_ni,
    .test_mode_i ( testmode_i ),
    .rst_no      ( synced_rst_n ),
    .init_no     ()
  );

// Connection between Croc_domain and User_domain: User Sbr, Croc Mgr
sbr_obi_req_t user_sbr_obi_req;
sbr_obi_rsp_t user_sbr_obi_rsp;

// Connection between Croc_domain and User_domain: Croc Sbr, User Mgr
mgr_obi_req_t user_mgr_obi_req;
mgr_obi_rsp_t user_mgr_obi_rsp;

localparam int unsigned NumExternalIrqs = 4;
logic [NumExternalIrqs-1:0] interrupts;
logic [      GpioCount-1:0] gpio_in_sync;

// ---- NEW MEMORY INTERFACE SIGNALS (Connecting Croc and User Domains) ----
  logic                                                                  sram_impl;
  logic [NumSramBanks-1:0]                                               sram_req;
  logic [NumSramBanks-1:0]                                               sram_we;
  logic [NumSramBanks-1:0][cf_math_pkg::idx_width(SramBankNumWords)-1:0] sram_addr;
  logic [NumSramBanks-1:0][SbrObiCfg.DataWidth-1:0]                      sram_wdata;
  logic [NumSramBanks-1:0][(SbrObiCfg.DataWidth/8)-1:0]                  sram_be;
  logic [NumSramBanks-1:0]                                               sram_gnt;
  logic [NumSramBanks-1:0][SbrObiCfg.DataWidth-1:0]                      sram_rdata;

croc_domain #(
  .GpioCount       ( GpioCount       ),
  .NumExternalIrqs ( NumExternalIrqs )
) i_croc (
  .clk_i,
  .rst_ni ( synced_rst_n ),
  .ref_clk_i,
  .testmode_i,

  .jtag_tck_i,
  .jtag_tdi_i,
  .jtag_tdo_o,
  .jtag_tms_i,
  .jtag_trst_ni,

  .uart_rx_i,
  .uart_tx_o,

  .gpio_i,
  .gpio_o,
  .gpio_out_en_o,

  .gpio_in_sync_o ( gpio_in_sync ),

  .user_sbr_obi_req_o  ( user_sbr_obi_req ),
  .user_sbr_obi_rsp_i  ( user_sbr_obi_rsp ),

  .user_mgr_obi_req_i  ( user_mgr_obi_req ),
  .user_mgr_obi_rsp_o  ( user_mgr_obi_rsp ),

  .interrupts_i ( interrupts ),
  .core_busy_o  ( status_o   ),

  // Memory Interface Output to User Domain
  .sram_impl    ( sram_impl    ),
  .sram_req_o   ( sram_req     ),
  .sram_we_o    ( sram_we      ),
  .sram_addr_o  ( sram_addr    ),
  .sram_wdata_o ( sram_wdata   ),
  .sram_be_o    ( sram_be      ),

  // Memory Interface Return from User Domain
  .sram_gnt_i   ( sram_gnt     ),
  .sram_rdata_i ( sram_rdata   )

);

user_domain #(
  .GpioCount       ( GpioCount       ),
  .NumExternalIrqs ( NumExternalIrqs )
) i_user (
  .clk_i,
  .rst_ni ( synced_rst_n ),
  .ref_clk_i,
  .testmode_i,

  .user_sbr_obi_req_i ( user_sbr_obi_req ),
  .user_sbr_obi_rsp_o ( user_sbr_obi_rsp ),

  .user_mgr_obi_req_o ( user_mgr_obi_req ),
  .user_mgr_obi_rsp_i ( user_mgr_obi_rsp ),

  .gpio_in_sync_i ( gpio_in_sync ),
  .interrupts_o   ( interrupts   ),

  // Memory Interface Input from Croc Domain
  .sram_impl_i  ( sram_impl    ),
  .sram_req_i   ( sram_req     ),
  .sram_we_i    ( sram_we      ),
  .sram_addr_i  ( sram_addr    ),
  .sram_wdata_i ( sram_wdata   ),
  .sram_be_i    ( sram_be      ),

  // Memory Interface Return to Croc Domain
  .sram_gnt_o   ( sram_gnt     ),
  .sram_rdata_o ( sram_rdata   )
);

endmodule
