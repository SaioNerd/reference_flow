// Copyright 2024 ETH Zurich and University of Bologna.
// Solderpad Hardware License, Version 0.51, see LICENSE for details.
// SPDX-License-Identifier: SHL-0.51
//
// Authors:
// - Philippe Sauter <phsauter@iis.ee.ethz.ch>

module user_domain import user_pkg::*; import croc_pkg::*; #(
  parameter int unsigned GpioCount = 32,
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

  input  logic      sram_impl_i, //Added by Giulio : control signal from croc to user SRAM

  // Ouutput error flags
  output logic [NumSramBanks-1:0] all_banks_single_err_o,
  output logic [NumSramBanks-1:0] all_banks_double_err_o

);

  //////////////////////
  // GPIO mapping //
  /////////////////////
  logic [NumSramBanks-1:0] sram_fault_inject_i;  // per-bank fault inject
  logic                    sram_fault_sel_i;      // 0=single, 1=double

  // assign sram_fault_inject_i[0] = gpio_in_sync_i[19];
  // assign sram_fault_inject_i[1] = gpio_in_sync_i[16];

  // assign sram_fault_sel_i       = gpio_in_sync_i[18];

 
  // Prova per fixare tempo di hold
  // Yosys should not optmize these signals to make sure to place a logic gate
  (* keep = "true" *) logic [1:0] delay_stage1_inject;
  (* keep = "true" *) logic [1:0] delay_stage2_inject;
  (* keep = "true" *) logic [1:0] delay_stage3_inject;
  (* keep = "true" *) logic [1:0] delay_stage4_inject;
  
  (* keep = "true" *) logic       delay_stage1_sel;
  (* keep = "true" *) logic       delay_stage2_sel;
  (* keep = "true" *) logic       delay_stage3_sel;
  (* keep = "true" *) logic       delay_stage4_sel;

  // Fault Inject [0]
  assign delay_stage1_inject[0] = ~gpio_in_sync_i[19];
  assign delay_stage2_inject[0] = ~delay_stage1_inject[0];
  assign delay_stage3_inject[0] = ~delay_stage2_inject[0];
  assign delay_stage4_inject[0] = ~delay_stage3_inject[0];
  assign sram_fault_inject_i[0] =  delay_stage4_inject[0];

  // Fault Inject [1]
  assign delay_stage1_inject[1] = ~gpio_in_sync_i[16];
  assign delay_stage2_inject[1] = ~delay_stage1_inject[1];
  assign delay_stage3_inject[1] = ~delay_stage2_inject[1];
  assign delay_stage4_inject[1] = ~delay_stage3_inject[1];
  assign sram_fault_inject_i[1] =  delay_stage4_inject[1];

  // Fault Sel
  assign delay_stage1_sel       = ~gpio_in_sync_i[18];
  assign delay_stage2_sel       = ~delay_stage1_sel;
  assign delay_stage3_sel       = ~delay_stage2_sel;
  assign delay_stage4_sel       = ~delay_stage3_sel;
  assign sram_fault_sel_i       =  delay_stage4_sel;


  //////////////////////
  // User Manager MUX //
  /////////////////////

  // No manager so we don't need a obi_mux module and just terminate the request properly
  assign user_mgr_obi_req_o = '0;


  //////////////////////
  //    INTERRUPTS    //
  /////////////////////
  // Route any error from any bank to the CPU interrupts.
  // IRQ0 = Double Error (Uncorrectable/Fatal)
  // IRQ1 = Single Error (Correctable)
  always_comb begin
    interrupts_o = '0;
    interrupts_o[0] = |all_banks_double_err_o;
    // interrupts_o[1] = |all_banks_single_err_o;  //No interrupt for single error
  end

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
  sbr_obi_req_t [NumSramBanks-1:0] user_mem_bank_obi_req_xbar, user_mem_bank_obi_req_sram;
  sbr_obi_rsp_t [NumSramBanks-1:0] user_mem_bank_obi_rsp_sram, user_mem_bank_obi_rsp_xbar;

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
    assign user_mem_bank_obi_req_xbar[i]     = all_user_sbr_obi_req[UserBank0+i];
    assign all_user_sbr_obi_rsp[UserBank0+i] = user_mem_bank_obi_rsp_xbar[i];
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

  // =========================================================================
  // MEMORY
  // =========================================================================
  localparam int unsigned SramBankAddrWidth = cf_math_pkg::idx_width(SramBankNumWords);

  // =========================================================================
  // MEMORY BANKS and WRITEBACK gen loop
  // =========================================================================

  for (genvar i = 0; i < NumSramBanks; i++) begin : gen_sram_bank

    //EXTRA PIPELINE STAGE TO CUT PROPAGATION DELAY FROM OBI DEMUX TO SRAM MACRO
    // obi_cut #(
    // .ObiCfg    ( SbrObiCfg     ),
    // .obi_req_t ( sbr_obi_req_t ),
    // .obi_rsp_t ( sbr_obi_rsp_t ),
    // .Bypass    ( 1'b0          ),
    // .obi_a_chan_t(sbr_obi_a_chan_t),
    // .obi_r_chan_t(sbr_obi_r_chan_t)
    //   ) i_obi_cut_mux2sram (
    // .clk_i          ( clk_i                 ),
    // .rst_ni         ( synced_rst_n          ),
    // .sbr_port_req_i ( user_mem_bank_obi_req_xbar[i] ), // From Xbar
    // .sbr_port_rsp_o ( user_mem_bank_obi_rsp_xbar[i] ), // To Xbar
    // .mgr_port_req_o ( user_mem_bank_obi_req_sram[i] ), // To Sram
    // .mgr_port_rsp_i ( user_mem_bank_obi_rsp_sram[i] )  // From Sram [cite: 4]
    // );

    assign user_mem_bank_obi_rsp_xbar[i] = user_mem_bank_obi_rsp_sram[i];  // NO PIPELINE DELAY
    assign user_mem_bank_obi_req_sram[i] = user_mem_bank_obi_req_xbar[i];

    logic bank_req, bank_we, bank_gnt;
    logic [SbrObiCfg.AddrWidth-1:0] bank_byte_addr;
    logic [SramBankAddrWidth-1:0]   bank_word_addr;
    logic [SbrObiCfg.DataWidth-1:0] bank_wdata, bank_rdata;
    logic [SbrObiCfg.DataWidth/8-1:0] bank_be;

    obi_sram_shim #(
      .ObiCfg    ( SbrObiCfg     ),
      .obi_req_t ( sbr_obi_req_t ),
      .obi_rsp_t ( sbr_obi_rsp_t )
    ) i_sram_shim (
      .clk_i,
      .rst_ni,

      .obi_req_i ( user_mem_bank_obi_req_sram[i] ),
      .obi_rsp_o ( user_mem_bank_obi_rsp_sram[i] ),

      .req_o   ( bank_req       ),
      .we_o    ( bank_we        ),
      .addr_o  ( bank_byte_addr ),
      .wdata_o ( bank_wdata     ),
      .be_o    ( bank_be        ),

      .gnt_i   ( bank_gnt   ),
      .rdata_i ( bank_rdata )
    );

    // Subtract the bank's base address offset, then convert byte address to word address
    logic [SbrObiCfg.AddrWidth-1:0] bank_byte_offset;
    assign bank_byte_offset = bank_byte_addr - i * SramBankNumWords * (SbrObiCfg.DataWidth/8);
    assign bank_word_addr    = bank_byte_offset[SbrObiCfg.AddrWidth-1:2];

    // =========================================================================
    // REPAIR MODULE Signal Instantiation
    // ========================================================================= 

    // -------------------------------------------------------------------------
    // Read-address delay register (align with SECDED read latency = 1 cycle)
    // -------------------------------------------------------------------------
    logic [SramBankAddrWidth-1:0] bank_word_addr_q;

    always_ff @(posedge clk_i or negedge rst_ni) begin
      if (!rst_ni) begin
        bank_word_addr_q <= '0;
      end else begin
        bank_word_addr_q <= bank_word_addr;
      end
    end

    // -------------------------------------------------------------------------
    // Per-bank SECDED status signals
    // -------------------------------------------------------------------------
    logic [SbrObiCfg.DataWidth/8-1:0] bank_byte_single_err;
    logic                             bank_read_valid;

    // -------------------------------------------------------------------------
    // Muxed signals between shim (CPU) and secded_sram_impl
    // -------------------------------------------------------------------------
    logic                         bank_sram_req;
    logic                         bank_sram_we;
    logic [SramBankAddrWidth-1:0] bank_sram_addr;
    logic [SbrObiCfg.DataWidth-1:0] bank_sram_wdata;
    logic [SbrObiCfg.DataWidth/8-1:0] bank_sram_be;

    // =========================================================================
    // SECDED Repair Buffer — detects single-bit errors and schedules write‑back
    // =========================================================================
    secded_repair_buffer #(
      .AddrWidth ( SramBankAddrWidth      ),
      .DataWidth ( SbrObiCfg.DataWidth    ),
      .BeWidth   ( SbrObiCfg.DataWidth / 8 )
    ) i_repair_buffer (
      .clk_i,
      .rst_ni,

      // SECDED decoder side (delayed signals)
      .sec_read_valid_i     ( bank_read_valid       ),
      .sec_byte_single_err_i( bank_byte_single_err  ),
      .sec_rdata_i          ( bank_rdata            ),
      .sec_raddr_i          ( bank_word_addr_q      ),

      // CPU / shim side
      .cpu_req_i   ( bank_req       ),
      .cpu_we_i    ( bank_we        ),
      .cpu_addr_i  ( bank_word_addr ),
      .cpu_wdata_i ( bank_wdata     ),
      .cpu_be_i    ( bank_be        ),

      // Mux control outputs -> secded_sram_impl
      .sram_req_o   ( bank_sram_req   ),
      .sram_we_o    ( bank_sram_we    ),
      .sram_addr_o  ( bank_sram_addr  ),
      .sram_wdata_o ( bank_sram_wdata ),
      .sram_be_o    ( bank_sram_be    )
    );

    // -------------------------------------------------------------------------
    // ERROR status signals routing
    // -------------------------------------------------------------------------
    logic                             bank_double_err, bank_single_err;

    assign all_banks_single_err_o[i] = bank_single_err;
    assign all_banks_double_err_o[i] = bank_double_err;


    // =========================================================================
    // SECDED SRAM Implementation wrapper
    // =========================================================================
    secded_sram_impl #(
      .NumWords   ( SramBankNumWords    ),
      .DataWidth  ( SbrObiCfg.DataWidth ),
      .ByteWidth  ( 8                   ),
      .NumPorts   ( 1                   ),
      .Latency    ( 1                   )
    ) i_sram_macro (
      .clk_i              ( clk_i                 ),
      .rst_ni             ( rst_ni                ),
      .impl_i             ( sram_impl_i           ),
      .impl_o             ( /* unused */          ),
      .req_i              ( bank_sram_req         ),
      .we_i               ( bank_sram_we          ),
      .addr_i             ( bank_sram_addr        ),
      .wdata_i            ( bank_sram_wdata       ),
      .be_i               ( bank_sram_be          ),
      .rdata_o            ( bank_rdata            ),
      .single_err_o       ( bank_single_err       ),
      .double_err_o       ( bank_double_err       ),
      .byte_single_err_o  ( bank_byte_single_err  ),
      .read_valid_o       ( bank_read_valid       ),
      .fault_inject_i     ( sram_fault_inject_i[i] ),
      .fault_sel_i        ( sram_fault_sel_i       )
    );

    assign bank_gnt = 1'b1; // always ready for request
  end

endmodule
