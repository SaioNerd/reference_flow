module secded_repair_buffer #(
  parameter int unsigned AddrWidth = 13,
  parameter int unsigned DataWidth = 32,
  parameter int unsigned NumBytes  = DataWidth / 8
) (
  input  logic clk_i,
  input  logic rst_ni,

  // Interface A: CPU / OBI Interconnect
  input  logic                 cpu_req_i,
  input  logic                 cpu_we_i,
  input  logic [AddrWidth-1:0] cpu_addr_i,
  input  logic [DataWidth-1:0] cpu_wdata_i,
  input  logic [NumBytes-1:0]  cpu_be_i,

  // Interface B: SECDED Decoder (Trigger)
  input  logic                 repair_valid_i,
  input  logic [AddrWidth-1:0] repair_addr_i,
  input  logic [DataWidth-1:0] repair_data_i, // Fully corrected word from decoder
  input  logic [NumBytes-1:0]  repair_be_i,   // Bitmask

  // Interface C: Physical SRAM Macro
  output logic                 sram_req_o,
  output logic                 sram_we_o,
  output logic [AddrWidth-1:0] sram_addr_o,
  output logic [DataWidth-1:0] sram_wdata_o,
  output logic [NumBytes-1:0]  sram_be_o
);

  // --- Internal Buffer State (1-Entry) ---
  logic                 buf_valid_q;
  logic [AddrWidth-1:0] buf_addr_q;
  logic [DataWidth-1:0] buf_data_q;
  logic [NumBytes-1:0]  buf_be_q;

  // --- Collision Detection ---
  logic cpu_addr_match;
  assign cpu_addr_match = buf_valid_q && (cpu_addr_i == buf_addr_q);

  logic cpu_is_writing_match;
  assign cpu_is_writing_match = cpu_req_i && cpu_we_i && cpu_addr_match;

  // =========================================================================
  // Stage 1: The Multiplexer
  // =========================================================================
  // The CPU has strict priority. The buffer only steals cycles when cpu_req_i is 0.
  always_comb begin
    if (cpu_req_i) begin
      sram_req_o   = 1'b1;
      sram_we_o    = cpu_we_i;
      sram_addr_o  = cpu_addr_i;
      sram_wdata_o = cpu_wdata_i;
      sram_be_o    = cpu_be_i;
    end else if (buf_valid_q) begin
      sram_req_o   = 1'b1;
      sram_we_o    = 1'b1; // The buffer is only ever writing data back
      sram_addr_o  = buf_addr_q;
      sram_wdata_o = buf_data_q;
      sram_be_o    = buf_be_q;
    end else begin
      sram_req_o   = 1'b0;
      sram_we_o    = 1'b0;
      sram_addr_o  = '0;
      sram_wdata_o = '0;
      sram_be_o    = '0;
    end
  end

  // =========================================================================
  // Stage 2: Buffer State Machine & Partial Write Logic
  // =========================================================================
  logic [NumBytes-1:0] merged_be;

  always_comb begin
    merged_be = buf_be_q;
    if (cpu_is_writing_match) begin
      // Clear the byte flags that the CPU is actively overwriting right now
      merged_be = buf_be_q & ~cpu_be_i;
    end
  end

  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      buf_valid_q <= 1'b0;
      buf_addr_q  <= '0;
      buf_data_q  <= '0;
      buf_be_q    <= '0;
    end else begin

      // Priority 1: A new error arrives. Overwrite whatever was in the buffer.
      if (repair_valid_i) begin
        buf_valid_q <= 1'b1;
        buf_addr_q  <= repair_addr_i;
        buf_data_q  <= repair_data_i;
        buf_be_q    <= repair_be_i;
      end
      
      // Priority 2: CPU writes to the same address (Write-After-Write Hazard)
      else if (cpu_is_writing_match) begin
        if (merged_be == '0) begin
          // The CPU overwrote all the broken bytes. The problem is gone.
          buf_valid_q <= 1'b0;
        end else begin
          // The CPU only did a partial write (e.g., overwrote Byte 0, but Byte 3 is broken).
          // We must merge the CPU's new data into our buffer and wait to drain.
          buf_be_q <= merged_be;
          for (int i = 0; i < NumBytes; i++) begin
            if (cpu_be_i[i]) begin
              buf_data_q[i*8 +: 8] <= cpu_wdata_i[i*8 +: 8];
            end
          end
        end
      end
      
      // Priority 3: The Idle Drain
      else if (!cpu_req_i && buf_valid_q) begin
        // CPU is doing nothing. The buffer won the arbiter and drained into SRAM.
        buf_valid_q <= 1'b0;
      end

    end
  end

endmodule