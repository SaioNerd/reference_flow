// ============================================================================
// Module: secded_sram_impl
// Description: Drop-in replacement for tc_sram_impl. 
// Transparently adds byte-wise SECDED protection by mapping 32-bit data 
// to an internal 64-bit SRAM (16-bits per byte chunk).
// ============================================================================

`default_nettype none

module secded_sram_impl #(
  parameter int unsigned NumWords     = 32'd1024,
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
  output logic  [NumPorts-1:0] double_err_o,

  // Fault injection ports (combinational, for testbench use)
  // When fault_inject_i is high, the encoded write data is XORed with
  // the selected mask before being stored in the 64-bit SRAM.
  input  logic                 fault_inject_i,  // 0=normal, 1=inject fault on write
  input  logic                 fault_sel_i      // 0=single-bit error, 1=double-bit error
);

  // Fixed error masks for the 64-bit encoded data
  // Single-bit: flips one bit in each 16-bit chunk
  // Double-bit: flips two bits in each 16-bit chunk
  localparam logic [63:0] SecMaskSingle = 64'h0008_0004_0002_0001;
  localparam logic [63:0] SecMaskDouble = 64'h00c0_0030_000c_0003;

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
        .req_i,
        .we_i,
        .addr_i,
        .wdata_i    (secded_wdata),
        .be_i       (be_i),         // Passthrough (4 bits) seamlessly maps to 16-bit blocks
        .rdata_o    (secded_rdata)
      );

      // Per-port SECDED Logic
      for (genvar p = 0; p < NumPorts; p++) begin : gen_ports
        logic [BeWidth-1:0] byte_single_err;
        logic [BeWidth-1:0] byte_double_err;

        // Shift register to delay read_valid by `Latency` cycles.
        // This ensures we only report errors when valid data is flowing out.
        logic [Latency:0] rvalid_q;
        assign rvalid_q[0] = req_i[p] & ~we_i[p];

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

        // Intermediate signal for raw (uncorrupted) encoded data
        // (one per port, inside gen_ports[p])
        secded_data_t raw_secded_wdata;

        // Process each byte independently
        for (genvar b = 0; b < BeWidth; b++) begin : gen_bytes
          
          // --- ENCODER (Write Path) ---
          logic [12:0] enc_out;
          secded_byte_encode i_encode (
            .data_in     (wdata_i[p][b*8 +: 8]),
            .encoded_out (enc_out)
          );
          // Pad 13 bits to 16 bits and map to the 64-bit word
          // raw_secded_wdata is already inside gen_ports[p], so no [p] needed
          assign raw_secded_wdata[b*16 +: 16] = {3'b000, enc_out};


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

        // Apply fault injection: XOR the encoded data with the selected mask
        // This is combinational, so it happens in the same delta cycle as the
        // encoder output. The SRAM's always_ff sees the corrupted value.
        assign secded_wdata[p] = fault_inject_i ? 
          (raw_secded_wdata ^ (fault_sel_i ? SecMaskDouble : SecMaskSingle)) :
          raw_secded_wdata;

        // Aggregate Error Flags for this port
        // Only trigger if an error happened AND we are actually doing a read cycle
        assign single_err_o[p] = read_valid ? (|byte_single_err) : 1'b0;
        assign double_err_o[p] = read_valid ? (|byte_double_err) : 1'b0;
      end
    end
  endgenerate

endmodule

`default_nettype wire