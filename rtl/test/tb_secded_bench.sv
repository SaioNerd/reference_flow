// Copyright (c) 2025 ETH Zurich and University of Bologna.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
//
// SECDED Benchmark Testbench.
// Measures encode/decode cycle counts by monitoring OBI writes to UserDesign.
//
// Software writes to:
//   0x20001000 (ENC): non-zero = start, zero = stop
//   0x20001004 (DEC): non-zero = start, zero = stop

`define TRACE_WAVE

module tb_secded_bench #(
  parameter int unsigned GpioCount = 32
);

  import tb_croc_pkg::*;
  import croc_pkg::*;

  logic rst_n;
  logic sys_clk;
  logic ref_clk;

  logic jtag_tck;
  logic jtag_trst_n;
  logic jtag_tms;
  logic jtag_tdi;
  logic jtag_tdo;

  logic uart_rx;
  logic uart_tx;

  logic [GpioCount-1:0] gpio_in;
  logic [GpioCount-1:0] gpio_out;
  logic [GpioCount-1:0] gpio_out_en;

  string binary_path;

  initial begin
    if ($value$plusargs("binary=%s", binary_path)) begin
      $display("Running program: %s", binary_path);
    end else begin
      $display("No binary path provided. Running secded_bench.");
      binary_path = "../sw/bin/secded_bench.hex";
    end
  end

  // ----------
  // VIP
  // ----------
  croc_vip #(
    .GpioCount ( GpioCount )
  ) i_vip (
    .rst_no        ( rst_n       ),
    .sys_clk_o     ( sys_clk     ),
    .ref_clk_o     ( ref_clk     ),
    .jtag_tck_o    ( jtag_tck    ),
    .jtag_trst_no  ( jtag_trst_n ),
    .jtag_tms_o    ( jtag_tms    ),
    .jtag_tdi_o    ( jtag_tdi    ),
    .jtag_tdo_i    ( jtag_tdo    ),
    .uart_rx_o     ( uart_rx     ),
    .uart_tx_i     ( uart_tx     ),
    .gpio_out_en_i ( gpio_out_en ),
    .gpio_out_i    ( gpio_out    ),
    .gpio_in_o     ( gpio_in     )
  );

  // ----------
  // DUT
  // ----------
  `ifdef TARGET_NETLIST_YOSYS
  \croc_soc$croc_chip.i_croc_soc i_croc_soc (
  `else
  croc_soc #(
    .GpioCount ( GpioCount )
  ) i_croc_soc (
  `endif
    .clk_i         ( sys_clk     ),
    .rst_ni        ( rst_n       ),
    .ref_clk_i     ( ref_clk     ),
    .testmode_i    ( 1'b0        ),
    .status_o      (             ),
    .jtag_tck_i    ( jtag_tck    ),
    .jtag_tdi_i    ( jtag_tdi    ),
    .jtag_tdo_o    ( jtag_tdo    ),
    .jtag_tms_i    ( jtag_tms    ),
    .jtag_trst_ni  ( jtag_trst_n ),
    .uart_rx_i     ( uart_rx     ),
    .uart_tx_o     ( uart_tx     ),
    .gpio_i        ( gpio_in     ),
    .gpio_o        ( gpio_out    ),
    .gpio_out_en_o ( gpio_out_en )
  );

  // ==================================================================
  // SECDED Benchmark Timing Measurement
  // ==================================================================
  //
  // Monitor OBI writes going into user_domain (i_croc_soc.i_user).
  // The address decode inside user_domain maps 0x20001000-0x20001FFF
  // to the UserDesign sink.
  //
  // user_sbr_obi_req_i is the input port on user_domain containing
  // the full OBI request from croc_domain.

  localparam bit [31:0] EncSignalAddr = 32'h20001000;
  localparam bit [31:0] DecSignalAddr = 32'h20001004;
  localparam bit [31:0] NumSamplesAddr = 32'h20001008;

  // Persistent flags for benchmark state
  logic enc_running_q;
  logic dec_running_q;

  // Counters
  integer unsigned enc_total_cycles;
  integer unsigned dec_total_cycles;
  integer unsigned enc_samples;
  integer unsigned dec_samples;
  // Number of iterations per benchmark interval (captured from software write to 0x20001008)
  integer unsigned num_samples_val;
  logic num_samples_captured;

  // Access the OBI request port on user_domain
  wire        user_design_req   = i_croc_soc.i_user.user_sbr_obi_req_i.req;
  wire        user_design_we    = i_croc_soc.i_user.user_sbr_obi_req_i.a.we;
  wire [31:0] user_design_addr  = i_croc_soc.i_user.user_sbr_obi_req_i.a.addr;
  wire [31:0] user_design_wdata = i_croc_soc.i_user.user_sbr_obi_req_i.a.wdata;
  // Grant from user_design_sink (combinational: gnt = req)
  wire        user_design_gnt   = user_design_req;

  // 1. Capture events on the OBI bus
  always_ff @(posedge sys_clk or negedge rst_n) begin
    if (!rst_n) begin
      enc_running_q <= 1'b0;
      dec_running_q <= 1'b0;
      enc_samples   <= '0;
      dec_samples   <= '0;
    end else begin
      if (user_design_req && user_design_gnt && user_design_we) begin

        // Monitor writes to ENC_SIGNAL (0x20001000)
        if (user_design_addr == EncSignalAddr) begin
          enc_running_q <= (user_design_wdata != 0);
          if (user_design_wdata != 0) begin
            enc_samples <= enc_samples + 1;
          end
        end

        // Monitor writes to DEC_SIGNAL (0x20001004)
        if (user_design_addr == DecSignalAddr) begin
          dec_running_q <= (user_design_wdata != 0);
          if (user_design_wdata != 0) begin
            dec_samples <= dec_samples + 1;
          end
        end

      end
    end
  end

  // 2. Timer accumulators (run every cycle independent of bus)
  always_ff @(posedge sys_clk or negedge rst_n) begin
    if (!rst_n) begin
      enc_total_cycles <= '0;
      dec_total_cycles <= '0;
    end else begin
      if (enc_running_q) begin
        enc_total_cycles <= enc_total_cycles + 1;
      end
      if (dec_running_q) begin
        dec_total_cycles <= dec_total_cycles + 1;
      end
    end
  end

  // ==================================================================
  // Stimulus
  // ==================================================================
  logic [31:0] tb_data;

  initial begin
    $timeformat(-9, 0, "ns", 12);

    #ClkPeriodSys;

    i_vip.jtag_init();
    i_vip.jtag_load_hex(binary_path);

    $display("@%t | [CORE] Waking core via CLINT msip", $time);
    i_vip.jtag_write_reg32(ClintBaseAddr, 32'h1);

    i_vip.jtag_halt();
    i_vip.jtag_resume();

    $display("@%t | [CORE] Wait for end of code...", $time);
    i_vip.jtag_wait_for_eoc(tb_data);

    $display("");
    $display("========================================");
    $display("SECDED Benchmark Results (TB measured)");
    $display("========================================");
    if (enc_samples > 0) begin
      $display("Encode: %0d samples, %0d total cycles, avg = %0d cycles",
               enc_samples, enc_total_cycles, enc_total_cycles / enc_samples);
    end
    if (dec_samples > 0) begin
      $display("Decode: %0d samples, %0d total cycles, avg = %0d cycles",
               dec_samples, dec_total_cycles, dec_total_cycles / dec_samples);
    end
    $display("System clock period: %0t ps", ClkPeriodSys);
    $display("========================================");

    repeat(50) @(posedge sys_clk);
    $finish();
  end

  // ==================================================================
  // Waveform
  // ==================================================================
  initial begin
    `ifdef TRACE_WAVE
      `ifdef VERILATOR
        $dumpfile("secded_bench.fst");
        $dumpvars(1, i_croc_soc);
        $dumpvars(1, tb_secded_bench);
      `else
        $dumpfile("secded_bench.vcd");
        $dumpvars(1, i_croc_soc);
        $dumpvars(1, tb_secded_bench);
      `endif
    `endif
  end

  final begin
    `ifdef TRACE_WAVE
      $dumpflush;
    `endif
  end

endmodule