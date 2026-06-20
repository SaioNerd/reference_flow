// Copyright 2024 ETH Zurich and University of Bologna.
// Solderpad Hardware License, Version 0.51, see LICENSE for details.
// SPDX-License-Identifier: SHL-0.51
//
// Authors:
// - Philippe Sauter <phsauter@iis.ee.ethz.ch>

module user_domain import user_pkg::*; import croc_pkg::*; #(
  parameter int unsigned GpioCount = 16,
  parameter int unsigned NumExternalIrqs = 4
) (
  input  logic      clk_i,
  input  logic      ref_clk_i,
  input  logic      rst_ni,
  input  logic      testmode_i,

  input  sbr_obi_req_t user_sbr_obi_req_i, // User Sbr (rsp_o), Croc Mgr (req_i)
  output sbr_obi_rsp_t user_sbr_obi_rsp_o,

  output mgr_obi_req_t user_mgr_obi_req_o, // User Mgr (req_o), Croc Sbr (rsp_i)
  input  mgr_obi_rsp_t user_mgr_obi_rsp_i,

  input  logic [      GpioCount-1:0] gpio_in_sync_i, // synchronized GPIO inputs
  output logic [NumExternalIrqs-1:0] interrupts_o,    // interrupts to core

  input  logic      sram_impl_i //Added by Giulio : control signal from croc to user SRAM
);

  assign interrupts_o = '0;


  //////////////////////
  // User Manager MUX //
  /////////////////////

  // No manager so we don't need a obi_mux module and just terminate the request properly
  assign user_mgr_obi_req_o = '0;


  ////////////////////////////
  // User Subordinate DEMUX //
  ////////////////////////////

  // ----------------------------------------------------------------------------------------------
  // User Subordinate Buses
  // ----------------------------------------------------------------------------------------------

  // collection of signals from the demultiplexer
  sbr_obi_req_t [NumDemuxSbr-1:0] all_user_sbr_obi_req;
  sbr_obi_rsp_t [NumDemuxSbr-1:0] all_user_sbr_obi_rsp;

  // Error Subordinate Bus
  sbr_obi_req_t user_error_obi_req;
  sbr_obi_rsp_t user_error_obi_rsp;

  // OBI bus to your design
  sbr_obi_req_t user_design_obi_req;
  sbr_obi_rsp_t user_design_obi_rsp;

  // ROM Subordinate Bus //Added by Giulio
  sbr_obi_req_t user_rom_obi_req;
  sbr_obi_rsp_t user_rom_obi_rsp;

  // SRAM bank buses
  sbr_obi_req_t [NumSramBanks-1:0] user_mem_bank_obi_req;
  sbr_obi_rsp_t [NumSramBanks-1:0] user_mem_bank_obi_rsp;

  // Fanout into more readable signals
  assign user_error_obi_req               = all_user_sbr_obi_req[UserError];
  assign all_user_sbr_obi_rsp[UserError]  = user_error_obi_rsp;
  assign user_design_obi_req              = all_user_sbr_obi_req[UserDesign];
  assign all_user_sbr_obi_rsp[UserDesign] = user_design_obi_rsp;

  //Added by Giulio : Fanout for the ROM subordinate
  assign user_rom_obi_req                = all_user_sbr_obi_req[UserRom];
  assign all_user_sbr_obi_rsp[UserRom]   = user_rom_obi_rsp;

  //Added by Giulio: Fanout of SRAM bank buses
  for (genvar i = 0; i < NumSramBanks; i++) begin : gen_mem_sbr_connect
    assign user_mem_bank_obi_req[i]     = all_user_sbr_obi_req[UserBank0+i];
    assign all_user_sbr_obi_rsp[UserBank0+i] = user_mem_bank_obi_rsp[i];
  end


  //-----------------------------------------------------------------------------------------------
  // Demultiplex to User Subordinates according to address map
  //-----------------------------------------------------------------------------------------------

  logic [cf_math_pkg::idx_width(NumDemuxSbr)-1:0] user_idx;

  addr_decode #(
    .NoIndices ( NumDemuxSbr                    ),
    .NoRules   ( $size(UserAddrMap)             ),
    .addr_t    ( logic[SbrObiCfg.DataWidth-1:0] ),
    .rule_t    ( addr_map_rule_t                ),
    .Napot     ( 1'b0                           )
  ) i_addr_decode_periphs (
    .addr_i           ( user_sbr_obi_req_i.a.addr ),
    .addr_map_i       ( UserAddrMap               ),
    .idx_o            ( user_idx                  ),
    .dec_valid_o      (),
    .dec_error_o      (),
    .en_default_idx_i ( 1'b1      ),
    .default_idx_i    ( UserError )
  );

  obi_demux #(
    .ObiCfg      ( SbrObiCfg     ),
    .obi_req_t   ( sbr_obi_req_t ),
    .obi_rsp_t   ( sbr_obi_rsp_t ),
    .NumMgrPorts ( NumDemuxSbr   ),
    .NumMaxTrans ( 2             )
  ) i_obi_demux (
    .clk_i,
    .rst_ni,

    .sbr_port_select_i ( user_idx             ),
    .sbr_port_req_i    ( user_sbr_obi_req_i   ),
    .sbr_port_rsp_o    ( user_sbr_obi_rsp_o   ),

    .mgr_ports_req_o   ( all_user_sbr_obi_req ),
    .mgr_ports_rsp_i   ( all_user_sbr_obi_rsp )
  );


//-------------------------------------------------------------------------------------------------
// User Subordinates
//-------------------------------------------------------------------------------------------------

  // //////////////////////////////
  // // User Design (OBI Data Sink) //
  // //////////////////////////////
  user_design_sink #(
    .ObiCfg      ( SbrObiCfg     ),
    .obi_req_t   ( sbr_obi_req_t ),
    .obi_rsp_t   ( sbr_obi_rsp_t )
  ) i_user_design_sink (
    .clk_i,
    .rst_ni,
    .obi_req_i  ( user_design_obi_req ),
    .obi_rsp_o  ( user_design_obi_rsp )
  );

  // Added by Giulio
  // User ROM 
  user_rom #(
    .ObiCfg      ( SbrObiCfg     ),
    .obi_req_t   ( sbr_obi_req_t ),
    .obi_rsp_t   ( sbr_obi_rsp_t )
  ) i_user_rom (
    .clk_i,
    .rst_ni,
    .obi_req_i  ( user_rom_obi_req ),
    .obi_rsp_o  ( user_rom_obi_rsp )
  );

  // Error Subordinate
  obi_err_sbr #(
    .ObiCfg      ( SbrObiCfg     ),
    .obi_req_t   ( sbr_obi_req_t ),
    .obi_rsp_t   ( sbr_obi_rsp_t ),
    .NumMaxTrans ( 1             ),
    .RspData     ( 32'hBADCAB1E  )
  ) i_user_err (
    .clk_i,
    .rst_ni,
    .testmode_i ( testmode_i         ),
    .obi_req_i  ( user_error_obi_req ),
    .obi_rsp_o  ( user_error_obi_rsp )
  );

  // -----------------
  // Memories
  // -----------------
  localparam int unsigned SramBankAddrWidth = cf_math_pkg::idx_width(SramBankNumWords);

  // =========================================================================
  // SRAM SECDED Error Aggregation Buses
  // =========================================================================
  logic [NumSramBanks-1:0] all_banks_single_err;
  logic [NumSramBanks-1:0] all_banks_double_err;

  // Route any error from any bank to the CPU interrupts.
  // IRQ0 = Single Error (Correctable)
  // IRQ1 = Double Error (Uncorrectable/Fatal)
  always_comb begin
    interrupts_o = '0;
    //interrupts_o[0] = |all_banks_single_err;
    interrupts_o[0] = |all_banks_double_err;
  end

  for (genvar i = 0; i < NumSramBanks; i++) begin : gen_sram_bank
    logic bank_req, bank_we, bank_gnt;
    logic [SbrObiCfg.AddrWidth-1:0] bank_byte_addr;
    logic [SramBankAddrWidth-1:0] bank_word_addr;
    logic [SbrObiCfg.DataWidth-1:0] bank_wdata, bank_rdata;
    logic [SbrObiCfg.DataWidth/8-1:0] bank_be;

    obi_sram_shim #(
      .ObiCfg    ( SbrObiCfg     ),
      .obi_req_t ( sbr_obi_req_t ),
      .obi_rsp_t ( sbr_obi_rsp_t )
    ) i_sram_shim (
      .clk_i,
      .rst_ni,

      .obi_req_i ( user_mem_bank_obi_req[i] ),
      .obi_rsp_o ( user_mem_bank_obi_rsp[i] ),

      .req_o   ( bank_req       ),
      .we_o    ( bank_we        ),
      .addr_o  ( bank_byte_addr ),
      .wdata_o ( bank_wdata     ),
      .be_o    ( bank_be        ),

      .gnt_i   ( bank_gnt   ),
      .rdata_i ( bank_rdata )
    );

    assign bank_word_addr = (bank_byte_addr - i * SramBankNumWords * (SbrObiCfg.DataWidth/8))[SbrObiCfg.AddrWidth-1:2];


    // Error signals for this specific bank
    logic bank_double_err, bank_single_err;

    // Map this bank's errors to the global error aggregation buses
    assign all_banks_single_err[i] = bank_single_err;
    assign all_banks_double_err[i] = bank_double_err;

    // SECDED SRAM Implementation wrapper
    secded_sram_impl #(
      .NumWords   ( SramBankNumWords    ),
      .DataWidth  ( SbrObiCfg.DataWidth ), // 32 bits
      .ByteWidth  ( 8                   ),
      .NumPorts   ( 1                   ),
      .Latency    ( 1                   )
    ) i_sram_macro (
      .clk_i        ( clk_i           ),
      .rst_ni       ( rst_ni          ),
      .impl_i       ( sram_impl_i     ), // Passed from user_domain inputs
      .impl_o       ( /* unused */    ),
      .req_i        ( bank_req        ),
      .we_i         ( bank_we         ),
      .addr_i       ( bank_word_addr  ),
      .wdata_i      ( bank_wdata      ),
      .be_i         ( bank_be         ),
      .rdata_o      ( bank_rdata      ),
      .single_err_o ( bank_single_err ),
      .double_err_o ( bank_double_err )
    );
    // tc_sram_impl #(
    //   .NumWords  ( SramBankNumWords ),
    //   .DataWidth ( 32 ),
    //   .NumPorts  (  1 ),
    //   .Latency   (  1 )
    // ) i_sram (
    //   .clk_i,
    //   .rst_ni,

    //   .impl_i  ( sram_impl_i    ),
    //   .impl_o  (),

    //   .req_i   ( bank_req       ),
    //   .we_i    ( bank_we        ),
    //   .addr_i  ( bank_word_addr ),

    //   .wdata_i ( bank_wdata ),
    //   .be_i    ( bank_be    ),
    //   .rdata_o ( bank_rdata )
    // );

    assign bank_gnt = 1'b1; // always ready for request
  end


endmodule
