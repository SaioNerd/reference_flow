// Copyright 2025 ETH Zurich and University of Bologna.
// Solderpad Hardware License, Version 0.51, see LICENSE for details.
// SPDX-License-Identifier: SHL-0.51
//
// SECDED Testbench (bypass mode)
// Runs secded_testbench.hex with magic-address based timing measurement.
// Monitors writes to ENC_TIMING_ADDR (0x20000000) and DEC_TIMING_ADDR (0x20000004)
// to measure encode and decode cycle counts.
// Requires SECDEDBypass = 1'b1 in croc_pkg.sv (bypass HW codec).

`define TRACE_WAVE

module tb_secded_testbench #(
  parameter int unsigned GpioCount = 32,
  // Number of samples the C code encodes/decodes (must match #define N_SAMPLES in C)
  parameter int unsigned NumSamples = 1
);

  import tb_croc_pkg::*;

  // Signals controlled by the VIP
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

  // Magic addresses for timing & results (past ROM range 0x2000_0000-0x2000_0FFF)
  // These fall past the ROM, hitting the error subordinate, but the OBI signals
  // on user_sbr_obi_req_i are still actively driven through the addr_decode + demux.
  localparam bit [31:0] EncTimingAddr      = 32'h2010_0000;
  localparam bit [31:0] DecTimingAddr      = 32'h2010_0004;
  localparam bit [31:0] ResNumSamplesAddr  = 32'h2010_0008;
  localparam bit [31:0] ResDoubleErrsAddr  = 32'h2010_000C;
  localparam bit [31:0] ResMismatchesAddr  = 32'h2010_0010;
  localparam bit [31:0] ResErrMismatchesAddr = 32'h2010_0014;
  localparam bit [31:0] ResTestPassAddr    = 32'h2010_0018;
  localparam bit [31:0] ProgressAddr       = 32'h2010_001C;

  // Timing metrics
  logic [63:0] enc_start_cycle;
  logic [63:0] enc_end_cycle;
  logic [63:0] dec_start_cycle;
  logic [63:0] dec_end_cycle;
  logic        enc_timing_active;
  logic        dec_timing_active;

  // Result values captured from C code
  logic [31:0] res_num_samples;
  logic [31:0] res_double_errs;
  logic [31:0] res_mismatches;
  logic [31:0] res_err_mismatches;
  logic [31:0] res_test_pass;
  logic        results_valid;

  /////////////////////////////
  //  Command Line Arguments //
  /////////////////////////////

  string binary_path;

  initial begin
    if ($value$plusargs("binary=%s", binary_path)) begin
      $display("Running program: %s", binary_path);
    end else begin
      binary_path = "../sw/bin/secded_testbench.hex";
      $display("Using default binary: %s", binary_path);
    end
  end

  ////////////
  //  VIP   //
  ////////////

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

  ////////////
  //  DUT   //
  ////////////

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

  ///////////////////////////////
  //  SECDEDBypass Check       //
  ///////////////////////////////
  // The C code performs software SECDED encode/decode, so HW codec must be bypassed.
  // Set SECDEDBypass = 1'b1 in croc_pkg.sv.

  initial begin
    if (croc_pkg::SECDEDBypass !== 1'b1) begin
      $display("\n");
      $display("WARNING: croc_pkg::SECDEDBypass is 0 but this testbench requires it to be 1.");
      $display("Set SECDEDBypass = 1'b1 in rtl/croc_pkg.sv before running this testbench.");
      $display("Proceeding anyway (timing measurements may not be meaningful).\n");
    end else begin
      $display("SECDEDBypass = 1 (HW codec bypassed, SW encode/decode only)");
    end
  end

  /////////////////
  //  Cycle Counter  //
  /////////////////

  logic [63:0] cycle_counter;

  always @(posedge sys_clk or negedge rst_n) begin
    if (!rst_n) begin
      cycle_counter <= '0;
    end else begin
      cycle_counter <= cycle_counter + 1;
    end
  end

  ///////////////////////////////////////////////
  //  Magic Address & SRAM Monitoring          //
  ///////////////////////////////////////////////
  // Monitors writes by snooping the OBI subordinate request bus.
  // The OBI signals are visible on the structural wire user_sbr_obi_req
  // inside croc_soc, which carries the OBI transaction from the crossbar
  // to the user domain. Verilator might optimize wdata from user_domain's
  // input port, so we also snoop the SRAM interface signals (sram_req,
  // sram_we, sram_wdata, sram_addr) which connect to tc_sram_impl and are
  // never optimized.

  // Bit [0] of wdata selects start (1) / stop (0) for timing.
  // For result addresses, the full wdata is the value.
  always @(posedge sys_clk or negedge rst_n) begin
    if (!rst_n) begin
      enc_timing_active <= 1'b0;
      dec_timing_active <= 1'b0;
      enc_start_cycle <= '0;
      enc_end_cycle <= '0;
      dec_start_cycle <= '0;
      dec_end_cycle <= '0;
      res_num_samples <= '0;
      res_double_errs <= '0;
      res_mismatches <= '0;
      res_err_mismatches <= '0;
      res_test_pass <= '0;
      results_valid <= 1'b0;
    end else begin
      // Detect write to ENC_TIMING_ADDR on the structural OBI wire
      if (i_croc_soc.user_sbr_obi_req.req &&
          i_croc_soc.user_sbr_obi_req.a.we &&
          i_croc_soc.user_sbr_obi_req.a.addr == EncTimingAddr) begin
        
        if (i_croc_soc.user_sbr_obi_req.a.wdata[0] == 1'b1) begin
          enc_start_cycle <= cycle_counter;
          enc_timing_active <= 1'b1;
        end else begin
          enc_end_cycle <= cycle_counter;
          enc_timing_active <= 1'b0;
        end
      end

      // Detect write to DEC_TIMING_ADDR on the structural OBI wire
      if (i_croc_soc.user_sbr_obi_req.req &&
          i_croc_soc.user_sbr_obi_req.a.we &&
          i_croc_soc.user_sbr_obi_req.a.addr == DecTimingAddr) begin
        
        if (i_croc_soc.user_sbr_obi_req.a.wdata[0] == 1'b1) begin
          dec_start_cycle <= cycle_counter;
          dec_timing_active <= 1'b1;
        end else begin
          dec_end_cycle <= cycle_counter;
          dec_timing_active <= 1'b0;
        end
      end

      // Capture result values from magic address writes
      if (i_croc_soc.user_sbr_obi_req.req &&
          i_croc_soc.user_sbr_obi_req.a.we) begin
        if (i_croc_soc.user_sbr_obi_req.a.addr == ProgressAddr) begin
          $display("@%t | [PROGRESS] Core started execution (wrote 0x%0x to 0x%h)", $time,
            i_croc_soc.user_sbr_obi_req.a.wdata, i_croc_soc.user_sbr_obi_req.a.addr);
        end
        if (i_croc_soc.user_sbr_obi_req.a.addr == ResNumSamplesAddr) begin
          res_num_samples <= i_croc_soc.user_sbr_obi_req.a.wdata;
          results_valid <= 1'b1;
        end
        if (i_croc_soc.user_sbr_obi_req.a.addr == ResDoubleErrsAddr) begin
          res_double_errs <= i_croc_soc.user_sbr_obi_req.a.wdata;
        end
        if (i_croc_soc.user_sbr_obi_req.a.addr == ResMismatchesAddr) begin
          res_mismatches <= i_croc_soc.user_sbr_obi_req.a.wdata;
        end
        if (i_croc_soc.user_sbr_obi_req.a.addr == ResErrMismatchesAddr) begin
          res_err_mismatches <= i_croc_soc.user_sbr_obi_req.a.wdata;
        end
        if (i_croc_soc.user_sbr_obi_req.a.addr == ResTestPassAddr) begin
          res_test_pass <= i_croc_soc.user_sbr_obi_req.a.wdata;
        end
      end
    end
  end

  /////////////////
  //  Testbench  //
  /////////////////

  logic [31:0] tb_data;

  initial begin
    $timeformat(-9, 0, "ns", 12);

    $display("\n");
    $display("============================================================");
    $display("SECDED Testbench (SW encode/decode, bypass mode)");
    $display("============================================================");
    $display("Binary: %s", binary_path);
    $display("NumSamples: %0d", NumSamples);
    $display("============================================================\n");

    // Wait for reset
    #ClkPeriodSys;

    // Initialize JTAG
    $display("@%t | Initializing JTAG...", $time);
    i_vip.jtag_init();

    // Load binary to SRAM
    $display("@%t | Loading binary: %s", $time, binary_path);
    i_vip.jtag_load_hex(binary_path);

    // Wake core via CLINT msip
    $display("@%t | Waking core via CLINT msip", $time);
    i_vip.jtag_write_reg32(ClintBaseAddr, 32'h1);

    // Wait for test to finish by checking if results_valid was set by magic address monitoring
    // (The C code writes to RES_NUM_SAMPLES at 0x20000008 last, setting results_valid)
    $display("@%t | Waiting for test to complete...", $time);
    wait (results_valid);
    $display("@%t | [TEST] Results received from C code", $time);

    // Compute and display timing results
    $display("\n");
    $display("============================================================");
    $display("Timing Results (%0d samples)", results_valid ? res_num_samples : NumSamples);
    $display("============================================================");
    if (enc_end_cycle > enc_start_cycle && dec_end_cycle > dec_start_cycle) begin
      automatic logic [63:0] enc_total = enc_end_cycle - enc_start_cycle;
      automatic logic [63:0] dec_total = dec_end_cycle - dec_start_cycle;
      automatic logic [63:0] samples_used = results_valid ? res_num_samples : NumSamples;
      automatic logic [63:0] enc_avg   = enc_total / samples_used;
      automatic logic [63:0] dec_avg   = dec_total / samples_used;

      $display("Encode total cycles: %0d", enc_total);
      $display("Encode avg cycles/sample: %0d", enc_avg);
      $display("Decode total cycles: %0d", dec_total);
      $display("Decode avg cycles/sample: %0d", dec_avg);
      $display("============================================================");
    end else begin
      $display("WARNING: Timing measurements incomplete!");
      $display("  enc_start=%0d enc_end=%0d", enc_start_cycle, enc_end_cycle);
      $display("  dec_start=%0d dec_end=%0d", dec_start_cycle, dec_end_cycle);
      $display("============================================================");
    end

    // Print validation results from magic addresses
    if (results_valid) begin
      $display("\n=== Results ===");
      $display("Dbl err: %0d", res_double_errs);
      $display("Mismatches: %0d", res_mismatches);
      $display("Err incoherences: %0d", res_err_mismatches);

      if (res_double_errs > 0) begin
        $display("Double error detected");
      end
      if (res_mismatches > 0 || res_err_mismatches > 0) begin
        $display("Mismatch between error detection and data");
      end

      if (res_test_pass !== 0) begin
        $display("All tests PASS");
      end else begin
        $display("Some tests FAIL");
      end
    end else begin
      $display("WARNING: No result data received from C code.");
    end

    $display("\nSimulation completed.");

    // Allow time for final transactions
    repeat(100) @(posedge sys_clk);
    $finish();
  end

  // ////////////////
  // //  Waveform  //
  // ////////////////

  // initial begin
  //   `ifdef TRACE_WAVE
  //     `ifdef VERILATOR
  //       $dumpfile("secded_testbench.fst");
  //       $dumpvars(1, i_croc_soc);
  //       $dumpvars(0, cycle_counter);
  //     `else
  //       $dumpfile("secded_testbench.vcd");
  //       $dumpvars(1, i_croc_soc);
  //       $dumpvars(0, cycle_counter);
  //     `endif
  //   `endif
  // end

  // final begin
  //   `ifdef TRACE_WAVE
  //     $dumpflush;
  //   `endif
  // end

endmodule