// ============================================================================
// Module: secded_repair_buffer
// Description:
//   Detects single-bit SECDED errors on read responses and schedules a
//   corrective write‑back to the affected SRAM word.
//
//   Byte‑level tracking ensures that only bytes which actually suffered a
//   single‑error are written back. If the CPU subsequently writes to the
//   same address (any byte(s)), the pending repair for those bytes is
//   cancelled because the CPU's write has already re‑encoded correct data.
//
//   The module controls a simple 2:1 mux placed between the CPU/shimbus
//   interface and the secded_sram_impl port.  Priority is always given to
//   the CPU — the repair write‑back only claims an otherwise idle cycle.
// ============================================================================

`default_nettype none

module secded_repair_buffer #(
  parameter int unsigned AddrWidth = 13,
  parameter int unsigned DataWidth = 32,
  parameter int unsigned BeWidth   = DataWidth / 8   // derived, 4 for 32‑bit
) (
  input  logic                     clk_i,
  input  logic                     rst_ni,

  // ------ SECDED decoder side (delayed by read latency) ------------
  input  logic                     sec_read_valid_i,
  input  logic [BeWidth-1:0]       sec_byte_single_err_i,
  input  logic [DataWidth-1:0]     sec_rdata_i,
  input  logic [AddrWidth-1:0]     sec_raddr_i,

  // ------ CPU / OBI shim side -------------------------------------
  input  logic                     cpu_req_i,
  input  logic                     cpu_we_i,
  input  logic [AddrWidth-1:0]     cpu_addr_i,
  input  logic [DataWidth-1:0]     cpu_wdata_i,
  input  logic [BeWidth-1:0]       cpu_be_i,

  // ------ Mux control outputs -> secded_sram_impl -----------------
  output logic                     sram_req_o,
  output logic                     sram_we_o,
  output logic [AddrWidth-1:0]     sram_addr_o,
  output logic [DataWidth-1:0]     sram_wdata_o,
  output logic [BeWidth-1:0]       sram_be_o
);

  // =========================================================================
  // Internal buffer – holds the pending repair request (1 entry deep)
  // =========================================================================
  logic                     buf_valid_q;
  logic [AddrWidth-1:0]     buf_addr_q;
  logic [DataWidth-1:0]     buf_data_q;
  logic [BeWidth-1:0]       buf_be_q;

  // =========================================================================
  // Concurrent address‑match detection (combinational)
  // =========================================================================
  logic cpu_addr_match;         // CPU request targets the buffered address
  logic cpu_repair_addr_match;  // CPU request targets the incoming repair addr

  assign cpu_addr_match        = buf_valid_q && cpu_req_i && cpu_we_i
                                 && (cpu_addr_i == buf_addr_q);
  assign cpu_repair_addr_match = cpu_req_i && cpu_we_i
                                 && (cpu_addr_i == sec_raddr_i);

  // =========================================================================
  // MUX — CPU has unconditional priority; repair only steals idle cycles
  // =========================================================================
  always_comb begin
    if (cpu_req_i) begin
      sram_req_o   = 1'b1;
      sram_we_o    = cpu_we_i;
      sram_addr_o  = cpu_addr_i;
      sram_wdata_o = cpu_wdata_i;
      sram_be_o    = cpu_be_i;
    end else if (buf_valid_q) begin
      sram_req_o   = 1'b1;               // write‑back requires a request
      sram_we_o    = 1'b1;
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
  // Buffer state machine — byte‑accurate merge / cancel logic
  // =========================================================================
  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      buf_valid_q <= 1'b0;
      buf_addr_q  <= '0;
      buf_data_q  <= '0;
      buf_be_q    <= '0;
    end else begin

      // --- Priority 1 : new single‑error repair arrives -------------------
      if (sec_read_valid_i && (sec_byte_single_err_i != '0)) begin
        buf_addr_q  <= sec_raddr_i;
        buf_be_q    <= sec_byte_single_err_i;

        // If the CPU is also writing to the very same address *this cycle*,
        // we must merge / cancel before the value even reaches the buffer.
        if (cpu_repair_addr_match) begin
          // Bytes the CPU is NOT overwriting are the ones remaining to repair
          buf_be_q <= sec_byte_single_err_i & ~cpu_be_i;

          for (int i = 0; i < BeWidth; i++) begin
            if (cpu_be_i[i])
              buf_data_q[i*8 +: 8] <= cpu_wdata_i[i*8 +: 8];
            else
              buf_data_q[i*8 +: 8] <= sec_rdata_i[i*8 +: 8];
          end

          // If every broken byte was simultaneously overwritten, discard
          buf_valid_q <= (sec_byte_single_err_i & ~cpu_be_i) != '0;
        end else begin
          // No same‑cycle CPU conflict — store the full corrected word
          buf_data_q  <= sec_rdata_i;
          buf_valid_q <= 1'b1;
        end

      // --- Priority 2 : CPU writes to the buffered address -----------------
      end else if (cpu_addr_match) begin
        buf_be_q <= buf_be_q & ~cpu_be_i;

        for (int i = 0; i < BeWidth; i++) begin
          if (cpu_be_i[i])
            buf_data_q[i*8 +: 8] <= cpu_wdata_i[i*8 +: 8];
        end

        // Discard pending repair if all broken bytes have been overwritten
        if ((buf_be_q & ~cpu_be_i) == '0)
          buf_valid_q <= 1'b0;

      // --- Priority 3 : idle drain — write‑back completes -----------------
      end else if (!cpu_req_i && buf_valid_q) begin
        buf_valid_q <= 1'b0;
      end

    end
  end

endmodule

`default_nettype wire