// Copyright 2024 ETH Zurich and University of Bologna.
// Solderpad Hardware License, Version 0.51, see LICENSE for details.
// SPDX-License-Identifier: SHL-0.51
//
// Authors:
// - Philippe Sauter <phsauter@iis.ee.ethz.ch>

module croc_soc import croc_pkg::*; #(
  parameter int unsigned GpioCount = 32
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

// Internal wires to capture the core's original GPIO outputs
logic [GpioCount-1:0] croc_gpio_o;
logic [GpioCount-1:0] croc_gpio_out_en_o;

logic bank0_double_err;
logic bank1_double_err;

// Fault injection signals extracted from GPIO inputs
// gpio_i[16] = bank1 fault inject, gpio_i[18] = fault sel, gpio_i[19] = bank0 fault inject
wire [1:0] sram_fault_inject_i = {gpio_i[16], gpio_i[19]};  // {bank1, bank0}
wire       sram_fault_sel_i    = gpio_i[18];                  // 0=single, 1=double

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

  // Added by Ale: for PIN
  .gpio_i         ( gpio_i ),
  .gpio_o         ( croc_gpio_o ),
  .gpio_out_en_o  ( croc_gpio_out_en_o ),

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
  .ObiCfg    ( SbrObiCfg     ),
  .obi_req_t ( sbr_obi_req_t ),
  .obi_rsp_t ( sbr_obi_rsp_t ),
  .Bypass    ( 1'b0          ),
  .obi_a_chan_t(sbr_obi_a_chan_t),
  .obi_r_chan_t(sbr_obi_r_chan_t)
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

// assign user_sbr_obi_req_user = user_sbr_obi_req_croc;
// assign user_sbr_obi_rsp_croc = user_sbr_obi_rsp_user;
// assign user_sbr_obi_req_user = user_sbr_obi_req_croc;
// assign user_sbr_obi_rsp_croc = user_sbr_obi_rsp_user;

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
  .sram_impl_i    ( sram_impl    ),

  // Fault injection ports
  .sram_fault_inject_i ( sram_fault_inject_i ),
  .sram_fault_sel_i    ( sram_fault_sel_i    ),

// Added by Ale: for PIN
  .bank0_double_err_o ( bank0_double_err ),
  .bank1_double_err_o ( bank1_double_err )
);

logic bank0_double_err_o;
logic bank1_double_err_o;

// Added by Ale: Pipeline registers
always_ff @(posedge clk_i or negedge rst_ni) begin
  if (!rst_ni) begin
    bank0_double_err_o <= 1'b0;
    bank1_double_err_o <= 1'b0;
  end else begin
    bank0_double_err_o <= bank0_double_err;
    bank1_double_err_o <= bank1_double_err;
  end
end

// Added by Ale: for PIN
always_comb begin
  gpio_o        = croc_gpio_o;
  gpio_out_en_o = croc_gpio_out_en_o;

  // Override Bank 0 pins
  gpio_o[20]        = bank0_double_err_o;
  gpio_out_en_o[20] = 1'b1; 

  // Override Bank 1 pins
  gpio_o[15]        = bank1_double_err_o;
  gpio_out_en_o[15] = 1'b1; 
end

endmodule
