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
sbr_obi_req_t user_sbr_obi_req_croc;
sbr_obi_rsp_t user_sbr_obi_rsp_croc;
sbr_obi_req_t user_sbr_obi_req_user;
sbr_obi_rsp_t user_sbr_obi_rsp_user;

// Connection between Croc_domain and User_domain: Croc Sbr, User Mgr
mgr_obi_req_t user_mgr_obi_req;
mgr_obi_rsp_t user_mgr_obi_rsp;

localparam int unsigned NumExternalIrqs = 4;
logic [NumExternalIrqs-1:0] interrupts;
logic [      GpioCount-1:0] gpio_in_sync;

//Added by Giulio: control signal from croc to user SRAM
logic sram_impl;

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

  .user_sbr_obi_req_o  ( user_sbr_obi_req_croc ),
  .user_sbr_obi_rsp_i  ( user_sbr_obi_rsp_croc ),

  .user_mgr_obi_req_i  ( user_mgr_obi_req ),
  .user_mgr_obi_rsp_o  ( user_mgr_obi_rsp ),

  .interrupts_i ( interrupts ),
  .core_busy_o  ( status_o   ),
  .sram_impl_o  ( sram_impl  ) // Not connected to anything, but we need to connect it to avoid an error
);


// Cut for Croc (Manager) to User (Subordinate)
obi_cut #(
  .obi_req_t ( sbr_obi_req_t ),
  .obi_rsp_t ( sbr_obi_rsp_t )
  // Note: If obi_a_chan_t and obi_r_chan_t are defined in croc_pkg, 
  // assign them here to override the default 'logic' type. 
) i_obi_cut_croc2user (
  .clk_i          ( clk_i                 ),
  .rst_ni         ( synced_rst_n          ),
  .sbr_port_req_i ( user_sbr_obi_req_croc ), // From Croc
  .sbr_port_rsp_o ( user_sbr_obi_rsp_croc ), // To Croc
  .mgr_port_req_o ( user_sbr_obi_req_user ), // To User
  .mgr_port_rsp_i ( user_sbr_obi_rsp_user )  // From User [cite: 4]
);


user_domain #(
  .GpioCount       ( GpioCount       ),
  .NumExternalIrqs ( NumExternalIrqs )
) i_user (
  .clk_i,
  .rst_ni ( synced_rst_n ),
  .ref_clk_i,
  .testmode_i,

  .user_sbr_obi_req_i ( user_sbr_obi_req_user ),
  .user_sbr_obi_rsp_o ( user_sbr_obi_rsp_user ),

  .user_mgr_obi_req_o ( user_mgr_obi_req ),
  .user_mgr_obi_rsp_i ( user_mgr_obi_rsp ),

  .gpio_in_sync_i ( gpio_in_sync ),
  .interrupts_o   ( interrupts   ),
  .sram_impl_i    ( sram_impl    ) // Not connected to anything, but we need to connect it to avoid an error
);

endmodule
