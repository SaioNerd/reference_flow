// ============================================================================
// Module: secded_sram_impl
// Description: Drop-in replacement for tc_sram_impl. 
// Transparently adds byte-wise SECDED protection by mapping 32-bit data 
// to an internal 64-bit SRAM (16-bits per byte chunk).
// ============================================================================

`default_nettype none

module secded_sram_impl2 #(
  parameter int unsigned NumWords     = 32'd1024, // Number of words in the SRAM
  parameter int unsigned DataWidth    = 32'd32, // External Data Width (e.g. 32)
  parameter int unsigned ByteWidth    = 32'd8,  // External Byte Width (e.g. 8)
  parameter int unsigned NumPorts     = 32'd1,
  parameter int unsigned Latency      = 32'd1,
  parameter type         impl_in_t    = logic,
  parameter type         impl_out_t   = logic,
  parameter impl_out_t   ImplOutSim   = '0,
  
  // Set default from package, but allow override
  parameter bit          SECDEDBypass = user_pkg::SECDEDBypass, 

  // Derived Parameters (Match external expectations)
  parameter int unsigned AddrWidth    = (NumWords > 32'd1) ? $clog2(NumWords) : 32'd1,
  parameter int unsigned BeWidth      = (DataWidth + ByteWidth - 32'd1) / ByteWidth,
  parameter type         addr_t       = logic [AddrWidth-1:0],
  parameter type         data_t       = logic [DataWidth-1:0],
  parameter type         be_t         = logic [BeWidth-1:0]
) (
  input  logic                 clk_i,
  input  logic                 rst_ni,

  // implementation-related IO
  input  impl_in_t             impl_i,
  output impl_out_t            impl_o,

  // Standard SRAM interface
  input  logic  [NumPorts-1:0] req_i,
  input  logic  [NumPorts-1:0] we_i,
  input  addr_t [NumPorts-1:0] addr_i,
  input  data_t [NumPorts-1:0] wdata_i,
  input  be_t   [NumPorts-1:0] be_i,
  output data_t [NumPorts-1:0] rdata_o,

  // SECDED specific outputs
  output logic  [NumPorts-1:0] single_err_o,
  output logic  [NumPorts-1:0] double_err_o
);

  generate
    if (SECDEDBypass) begin : gen_bypass
      // ====================================================================
      // BYPASS MODE: Instantiate normal 32-bit memory
      // ====================================================================
      tc_sram_impl #(
        .NumWords   (NumWords),
        .DataWidth  (DataWidth),
        .ByteWidth  (ByteWidth),
        .NumPorts   (NumPorts),
        .Latency    (Latency),
        .impl_in_t  (impl_in_t),
        .impl_out_t (impl_out_t),
        .ImplOutSim (ImplOutSim)
      ) i_sram (
        .clk_i,
        .rst_ni,
        .impl_i,
        .impl_o,
        .req_i,
        .we_i,
        .addr_i,
        .wdata_i,
        .be_i,
        .rdata_o
      );

      // Tie off error signals since ECC is disabled
      assign single_err_o = '0;
      assign double_err_o = '0;

    end else begin : gen_secded
      // ====================================================================
      // SECDED MODE: Instantiate 64-bit memory (16-bits per byte chunk)
      // ====================================================================
      localparam int unsigned SecdedByteWidth = 16;
      localparam int unsigned SecdedDataWidth = BeWidth * SecdedByteWidth; // 4 * 16 = 64
      
      typedef logic [SecdedDataWidth-1:0] secded_data_t;
      secded_data_t [NumPorts-1:0] secded_wdata;
      secded_data_t [NumPorts-1:0] secded_rdata;

      // The underlying 64-bit SRAM bank
      tc_sram_impl #(
        .NumWords   (NumWords),
        .DataWidth  (SecdedDataWidth),
        .ByteWidth  (SecdedByteWidth), // Crucial: sets internal BeWidth to exactly 4!
        .NumPorts   (NumPorts),
        .Latency    (Latency),
        .impl_in_t  (impl_in_t),
        .impl_out_t (impl_out_t),
        .ImplOutSim (ImplOutSim)
      ) i_sram (
        .clk_i, 
        .rst_ni,
        .impl_i, 
        .impl_o,
        .req_i   (sram_req_to_macro),
        .we_i    (sram_we_to_macro),
        .addr_i  (sram_addr_to_macro),
        .wdata_i (sram_wdata_to_macro),
        .be_i    (sram_be_to_macro),
        .rdata_o (secded_rdata)
      );
 
      // Added by Ale
      logic [NumPorts-1:0] sram_req_to_macro;
      logic [NumPorts-1:0] sram_we_to_macro;

      // Per-port SECDED Logic
      for (genvar p = 0; p < NumPorts; p++) begin : gen_ports
        logic [BeWidth-1:0] byte_single_err;
        logic [BeWidth-1:0] byte_double_err;

        // Shift register to delay read_valid by `Latency` cycles.
        // This ensures we only report errors when valid data is flowing out.
        logic [Latency:0] rvalid_q;
        assign rvalid_q[0] = req_i[p] & ~we_i[p];

        // Added by Ale
        secded_repair_buffer #(
            .AddrWidth(AddrWidth),
            .DataWidth(SecdedDataWidth),
            .NumBytes (BeWidth) // Note: Buffer uses byte-enables for 16-bit chunks
            ) i_repair_buffer (
            .clk_i, .rst_ni,
            .cpu_req_i(req_i[p]),
            .cpu_we_i(we_i[p]),
            .cpu_addr_i(addr_i[p]),
            .cpu_wdata_i(secded_wdata[p]), // CPU request data
            .cpu_be_i(be_i[p]),
            
            .repair_valid_i(read_valid && (|byte_single_err)),
            .repair_addr_i(addr_i[p]),
            .repair_data_i(secded_wdata_generated), // You need to generate this before
            .repair_be_i(byte_single_err),
            
            .sram_req_o(sram_req_to_macro[p]),
            .sram_we_o(sram_we_to_macro[p]),
            .sram_addr_o(sram_addr_to_macro[p]),
            .sram_wdata_o(sram_wdata_to_macro[p]),
            .sram_be_o(sram_be_to_macro[p]),
            
            .snoop_match_o(snoop_hit[p]),
            .snoop_data_o(snoop_data[p])
        );

        if (Latency > 0) begin : gen_rvalid_delay
          always_ff @(posedge clk_i or negedge rst_ni) begin
            if (!rst_ni) begin
              rvalid_q[Latency:1] <= '0;
            end else begin
              for (int i = 1; i <= Latency; i++) begin
                rvalid_q[i] <= rvalid_q[i-1];
              end
            end
          end
        end
        logic read_valid;
        assign read_valid = rvalid_q[Latency];

        assign rdata_o[p] = (snoop_hit[p]) ? snoop_data[p] : decoder_output_logic;

        // Process each byte independently
        for (genvar b = 0; b < BeWidth; b++) begin : gen_bytes
          
          // --- ENCODER (Write Path) ---
          logic [12:0] enc_out;
          secded_byte_encode i_encode (
            .data_in     (wdata_i[p][b*8 +: 8]),
            .encoded_out (enc_out)
          );
          // Pad 13 bits to 16 bits and map to the 64-bit word
          assign secded_wdata[p][b*16 +: 16] = {3'b000, enc_out};


          // --- DECODER (Read Path) ---
          logic [12:0] dec_in;
          logic [7:0]  dec_out;
          
          assign dec_in = secded_rdata[p][b*16 +: 13];

          secded_byte_decode i_decode (
            .encoded_in   (dec_in),
            .data_out     (dec_out),
            .single_err_o (byte_single_err[b]),
            .double_err_o (byte_double_err[b])
          );

          // Map the corrected 8-bit output back to the external 32-bit word
          assign rdata_o[p][b*8 +: 8] = dec_out;
        end

        // Aggregate Error Flags for this port
        // Only trigger if an error happened AND we are actually doing a read cycle
        assign single_err_o[p] = read_valid ? (|byte_single_err) : 1'b0;
        assign double_err_o[p] = read_valid ? (|byte_double_err) : 1'b0;
      end
    end
  endgenerate

endmodule

`default_nettype wire