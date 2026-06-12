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

  // ---- NEW MEMORY INTEFACE SIGNALS (form croc_domain) ----
  input  logic  sram_impl_i,
  
  // Input signals from OBI Shim
  input  logic [NumSramBanks-1:0]                                               sram_req_i,
  input  logic [NumSramBanks-1:0]                                               sram_we_i,
  input  logic [NumSramBanks-1:0][cf_math_pkg::idx_width(SramBankNumWords)-1:0]  sram_addr_i, // word address
  input  logic [NumSramBanks-1:0][SbrObiCfg.DataWidth-1:0]                      sram_wdata_i,
  input  logic [NumSramBanks-1:0][(SbrObiCfg.DataWidth/8)-1:0]                  sram_be_i,
  
  // Return signals to OBI Shim
  output logic [NumSramBanks-1:0]                                               sram_gnt_o,
  output logic [NumSramBanks-1:0][SbrObiCfg.DataWidth-1:0]                      sram_rdata_o
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

  // ROM Subordinate Bus //Added by Giulio
  sbr_obi_req_t user_rom_obi_req;
  sbr_obi_rsp_t user_rom_obi_rsp;

  // Error Subordinate Bus
  sbr_obi_req_t user_error_obi_req;
  sbr_obi_rsp_t user_error_obi_rsp;

  // Comment by Giulio: We don't have a user design, so we don't need to define the bus for it
  // OBI bus to your design
  // sbr_obi_req_t user_design_obi_req;
  // sbr_obi_rsp_t user_design_obi_rsp;

  // Fanout into more readable signals
  assign user_error_obi_req               = all_user_sbr_obi_req[UserError];
  assign all_user_sbr_obi_rsp[UserError]  = user_error_obi_rsp;

  // Comment by Giulio: We don't have a user design
  // assign user_design_obi_req              = all_user_sbr_obi_req[UserDesign];
  // assign all_user_sbr_obi_rsp[UserDesign] = user_design_obi_rsp;


  //Added by Giulio : Fanout for the ROM subordinate
  assign user_rom_obi_req                = all_user_sbr_obi_req[UserRom];
  assign all_user_sbr_obi_rsp[UserRom]   = user_rom_obi_rsp;


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

  ///////////////////////////////////
  // Replace this with your Design //
  ///////////////////////////////////
  // obi_err_sbr #(
  //   .ObiCfg      ( SbrObiCfg     ),
  //   .obi_req_t   ( sbr_obi_req_t ),
  //   .obi_rsp_t   ( sbr_obi_rsp_t ),
  //   .NumMaxTrans ( 1             ),
  //   .RspData     ( 32'hBADCAB1E  )
  // ) i_your_design_goes_here (
  //   .clk_i,
  //   .rst_ni,
  //   .testmode_i ( testmode_i          ),
  //   .obi_req_i  ( user_design_obi_req ),
  //   .obi_rsp_o  ( user_design_obi_rsp )
  // );

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


  // ---------------------------------------------------------------------------
  // SRAM + SECDED Implementation / Bypass Mode
  // ---------------------------------------------------------------------------
  
  localparam int unsigned SramBankAddrWidth = cf_math_pkg::idx_width(SramBankNumWords);

  logic [NumSramBanks-1:0] bank_double_err;

  generate
    if (croc_pkg::SECDEDBypass == 1'b0) begin : gen_secded_mode
      // ================= HARDWARE SECDED MODE (Current Configuration) =================
      
      for (genvar i = 0; i < NumSramBanks; i++) begin : gen_sram_bank
        
        logic [63:0] sram_wdata_64;
        logic [63:0] sram_rdata_64;
        logic [63:0] sram_be_64; //bit enable

        logic [3:0] byte_double_err;
        
        // --- 1. SECDED: Byte level Encode and Decode ---
        for (genvar b = 0; b < 4; b++) begin : gen_secded_bytes
          logic [12:0] enc_data;
          logic [12:0] dec_data;

          // NEW: Intermediate wires for unsupported EDA compilers features
          logic [7:0] tmp_data_out;
          logic       tmp_single_err;

          // Encoding: Parity bits calculation (13 bit output per byte)
          secded_byte_encode i_encode (
            .data_in     ( sram_wdata_i[i][b*8 +: 8] ),
            .encoded_out ( enc_data                  )
          );
          
          // Mapping of 13 bit bytes to physical SRAM
          assign sram_wdata_64[b*13 +: 13] = enc_data;
          
          // Creating the Bitmask: if the byte needs to be written, enable all 13 corresponding bits!
          assign sram_be_64[b*13 +: 13] = sram_be_i[i][b] ? 13'h1FFF : 13'h0000;

          // In reading: Extract the 13 bits from the physical memory and correct them
          assign dec_data = sram_rdata_64[b*13 +: 13];

          secded_byte_decode i_decode (
            .encoded_in   ( dec_data                  ),
            .data_out     ( tmp_data_out              ), // Safe connection to simple wire
            .single_err_o ( tmp_single_err   /* connectable to a register to monitor errors */), // Safe connection to simple wire 
            .double_err_o ( byte_double_err[b]       ) //capture the DED
          );

          // NEW: Assign the simple wire back to the complex multi-dimensional slice
          assign sram_rdata_o[i][b*8 +: 8] = tmp_data_out;

        end


        //Filling last empty bits with zeros to match the 64 bit interface of the SRAM wrapper
        assign sram_wdata_64[63:52] = '0;
        assign sram_be_64[63:52]    = '0;

        // Combine all 4 bytes in this bank: if any byte has a DED, the bank fails
        assign bank_double_err[i] = |byte_double_err; //OR Reduction




        // --- 2. SRAM Wrapper  ---
        tc_sram_impl #(
          .NumWords  ( SramBankNumWords ), 
          .DataWidth ( 64               ), // Extended for SECDED bits compatibility
          .ByteWidth ( 1                ), // Allow us to control writes bit by bit per encoded data storage
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
          .be_i    ( sram_be_64     ), // New bitmask
          .rdata_o ( sram_rdata_64  )
        );

        // --- 3. Handshake ---
        assign sram_gnt_o[i] = 1'b1; // always ready for request
      end

      // Combine all banks into one global interrupt signal
      assign interrupts_o[0] = |bank_double_err; //OR Reduction
      assign interrupts_o[3:1] = '0; // Tie off the unused ones for now

    end else begin : gen_secded_bypass_mode
      // ================= BYPASS MODE (Direct 32-bit ↔ 64-bit mapping) =================
      // Address bit [2] selects upper/lower 32-bit half of 64-bit SRAM word
      // Effectively doubles addressable memory from software perspective (no ECC)
      
      for (genvar i = 0; i < NumSramBanks; i++) begin : gen_sram_bank

        logic addr_half; // Address bit [2]: 0=lower half, 1=upper half
        logic [63:0] sram_wdata_64;
        logic [63:0] sram_rdata_64;
        logic [7:0]  sram_be_64;   // 8 byte enables for 64-bit word

        assign addr_half = sram_addr_i[i][2];

        // --- WRITE PATH ---
        // Map 32-bit write data and byte enables to appropriate half of 64-bit word
        always_comb begin
          sram_wdata_64 = '0;
          sram_be_64 = '0;
          
          if (addr_half == 1'b0) begin
            // Lower 32-bit half (bits [31:0] of 64-bit word)
            sram_wdata_64[31:0] = sram_wdata_i[i][31:0];
            sram_be_64[3:0] = sram_be_i[i][3:0];
          end else begin
            // Upper 32-bit half (bits [63:32] of 64-bit word)
            sram_wdata_64[63:32] = sram_wdata_i[i][31:0];
            sram_be_64[7:4] = sram_be_i[i][3:0];
          end
        end

        // --- READ PATH ---
        // Select appropriate half of 64-bit read data with pipeline delay
        logic [31:0] rdata_selected;
        logic [31:0] rdata_q;
        logic addr_half_q;

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

        // Physical SRAM address uses all 9 bits [8:0] to address 512 64-bit words
        // Bit [2] is used for half-selection (upper/lower 32-bit half)
        // This allows 1024 addressable 32-bit words (512 64-bit words * 2 halves)
        // without changing CrocAddrMap - software simply uses different values of bit [2]

        // --- 2. SRAM Wrapper (64-bit width) ---
        tc_sram_impl #(
          .NumWords  ( SramBankNumWords ), 
          .DataWidth ( 64               ), // Full 64-bit width for bypass mode
          .ByteWidth ( 8                ), // 8 bytes for 64-bit word
          .NumPorts  ( 1                ),
          .Latency   ( 1                )
        ) i_sram (
          .clk_i,
          .rst_ni,

          .impl_i  ( sram_impl_i           ),
          .impl_o  (                       ),

          .req_i   ( sram_req_i[i]         ),
          .we_i    ( sram_we_i[i]          ),
          .addr_i  ( sram_addr_i[i][8:0]   ), // Use all 9 bits to address all 512 words

          .wdata_i ( sram_wdata_64         ),
          .be_i    ( sram_be_64            ),
          .rdata_o ( sram_rdata_64         )
        );

        // --- 3. Handshake ---
        assign sram_gnt_o[i] = 1'b1; // always ready for request

      end

      // No double error detection in bypass mode (no ECC)
      assign bank_double_err = '0;
      assign interrupts_o = '0;

    end
  endgenerate

  // Combine all banks into one global interrupt signal (SECDED mode only)
  // In bypass mode, interrupts are tied to zero above

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

endmodule


