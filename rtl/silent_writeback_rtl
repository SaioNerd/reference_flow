  // ---------------------------------------------------------------------------
  // SRAM + SECDED Implementation
  // ---------------------------------------------------------------------------
  
  localparam int unsigned SramBankAddrWidth = cf_math_pkg::idx_width(SramBankNumWords);

  logic [NumSramBanks-1:0] bank_double_err;

  for (genvar i = 0; i < NumSramBanks; i++) begin : gen_sram_banks
    
    logic [63:0] sram_wdata_64;
    logic [63:0] sram_rdata_64;
    logic [63:0] sram_be_64;

    logic [3:0] byte_single_err;
    logic [3:0] byte_double_err;

    // --- Repair Registers ---
    logic        repair_pending;
    logic [12:0] repair_addr;
    logic [31:0] repair_data;
    logic [3:0]  repair_be; 
    logic [12:0] addr_q;
    
    // --- NEW: Cleaned Bank-Level Repair Flags ---
    logic is_standalone_repair;
    logic is_merged_repair;
    logic bank_repair_active;

    // 1. Standalone: CPU is idle, so we steal the cycle to repair.
    assign is_standalone_repair = repair_pending && !sram_req_i[i];
    
    // 2. Merged: CPU is writing to the exact address that needs repair.
    assign is_merged_repair     = repair_pending && sram_req_i[i] && sram_we_i[i] && (sram_addr_i[i] == repair_addr);
    
    // 3. Active: A repair operation of either type is happening THIS cycle.
    assign bank_repair_active   = is_standalone_repair || is_merged_repair;

    // --- 1. SECDED: Byte level Encode and Decode ---
    for (genvar b = 0; b < 4; b++) begin : gen_secded_bytes
      logic [12:0] enc_data;
      logic [12:0] dec_data;
      logic [7:0]  tmp_data_out;

      // Cleaned Byte-Level CPU Write Flag
      logic cpu_byte_we;
      assign cpu_byte_we = sram_req_i[i] && sram_we_i[i] && sram_be_i[i][b];

      // Cleaned Byte-Level Repair Flag
      logic do_byte_repair;
      // We repair this specific byte IF: 
      // The bank is repairing AND this byte is broken AND the CPU isn't overwriting it right now.
      assign do_byte_repair = bank_repair_active && repair_be[b] && !cpu_byte_we;

      // Data Routing
      logic [7:0] data_to_encode;
      assign data_to_encode = do_byte_repair ? repair_data[b*8 +: 8] : sram_wdata_i[i][b*8 +: 8];

      // Encoder
      secded_byte_encode i_encode (
        .data_in     ( data_to_encode ),
        .encoded_out ( enc_data       )
      );
      
      assign sram_wdata_64[b*13 +: 13] = enc_data;
      
      // The bitmask allows the write if the CPU requested it OR if we are doing a silent repair
      logic byte_write_enable;
      assign byte_write_enable = cpu_byte_we || do_byte_repair;
      assign sram_be_64[b*13 +: 13] = byte_write_enable ? 13'h1FFF : 13'h0000;

      // Decoder
      assign dec_data = sram_rdata_64[b*13 +: 13];
      secded_byte_decode i_decode (
        .encoded_in   ( dec_data           ),
        .data_out     ( tmp_data_out       ), 
        .single_err_o ( byte_single_err[b] ), 
        .double_err_o ( byte_double_err[b] )
      );

      assign sram_rdata_o[i][b*8 +: 8] = tmp_data_out;
    end

    // Error Combination
    assign bank_single_err[i] = |byte_single_err;
    assign bank_double_err[i] = |byte_double_err;

    // State Machine
    always_ff @(posedge clk_i or negedge rst_ni) begin
      if (!rst_ni) begin
        repair_pending <= 1'b0;
        repair_addr    <= '0;
        repair_data    <= '0;
        repair_be      <= '0;
        addr_q         <= '0;
      end else begin
        addr_q <= sram_addr_i[i];

        // Clear repair if executed this cycle
        if (bank_repair_active) begin
            repair_pending <= 1'b0;
            repair_be      <= '0;
        end 
        // Latch new error state
        else if (bank_single_err && !bank_double_err[i]) begin
            repair_pending <= 1'b1;
            repair_addr    <= addr_q;          
            repair_data    <= sram_rdata_o[i]; 
            repair_be      <= byte_single_err;
        end
      end
    end

    // Padding
    assign sram_wdata_64[63:52] = '0;
    assign sram_be_64[63:52]    = '0;

    // SRAM Request Multiplexing
    logic        mux_req;
    logic        mux_we;
    logic [12:0] mux_addr;

    // The wrapper receives a request if the CPU wants one OR if we are doing a standalone repair.
    // (If it's a merged repair, sram_req_i is already high, so this still works perfectly).
    assign mux_req  = is_standalone_repair ? 1'b1 : sram_req_i[i];
    assign mux_we   = is_standalone_repair ? 1'b1 : sram_we_i[i];
    assign mux_addr = is_standalone_repair ? repair_addr : sram_addr_i[i];

    // --- 2. SRAM Wrapper  ---
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

      .req_i   ( mux_req  ),
      .we_i    ( mux_we   ),
      .addr_i  ( mux_addr ),

      .wdata_i ( sram_wdata_64  ),
      .be_i    ( sram_be_64     ), 
      .rdata_o ( sram_rdata_64  )
    );

    // --- 3. Handshake ---
    assign sram_gnt_o[i] = 1'b1; 
  end
