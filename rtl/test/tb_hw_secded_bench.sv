// Copyright (c) 2025 ETH Zurich and University of Bologna.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
//
// HW SECDED Benchmark Testbench.
// Measures encode/store and decode/load cycle counts via hardware SECDED.
// Uses croc_soc_sim to access SRAM fault injection ports.
// Supports FaultType parameter: 0=no error, 1=single, 2=double.
//
// Software writes to:
//   0x20001000 (ENC): non-zero = start, zero = stop
//   0x20001004 (DEC): non-zero = start, zero = stop
//   0x20001008       : NUM_SAMPLES value
//   0x2000100C       : hw_test_mem base address

`define TRACE_WAVE

module tb_hw_secded_bench #(
  parameter int unsigned GpioCount = 32,
  // Fault type: 0=no fault, 1=single-bit, 2=double-bit
  parameter int unsigned FaultType = 1
);

  import tb_croc_pkg::*;
  import croc_pkg::*;
  import user_pkg::*;

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
  logic [GpioCount-1:0] gpio_in_sync;

  ////////////////////////////////////////
  //  GPIO mapping for fault injection  //
  ////////////////////////////////////////

  logic [1:0] sram_fault_inject;
  logic       sram_fault_sel;

  always_comb begin
    gpio_in_sync = gpio_in;
    gpio_in_sync[19] = sram_fault_inject[0];
    gpio_in_sync[16] = sram_fault_inject[1];
    gpio_in_sync[18] = sram_fault_sel;
  end

  /////////////////////////////
  //  Command Line Arguments //
  /////////////////////////////

  string binary_path;

  initial begin
    if ($value$plusargs("binary=%s", binary_path)) begin
      $display("Running program: %s", binary_path);
    end else begin
      $display("No binary path provided. Running hw_secded_bench.");
      binary_path = "../sw/bin/hw_secded_bench.hex";
    end
    case (FaultType)
      0: $display("Fault mode: NO error injection");
      1: $display("Fault mode: SINGLE-bit error injection");
      2: $display("Fault mode: DOUBLE-bit error injection");
      default: $display("Fault mode: UNKNOWN (%0d) — no injection", FaultType);
    endcase
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
  // DUT: croc_soc_sim (has gpio_in_sync port for fault injection)
  // ----------
  `ifdef TARGET_NETLIST_YOSYS
  \croc_soc$croc_chip.i_croc_soc i_croc_soc (
  `else
  croc_soc_sim #(
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
    .gpio_out_en_o ( gpio_out_en ),
    .gpio_in_sync  ( gpio_in_sync )
  );

  // ==================================================================
  // Fault Injection: Address Range Capture & SRAM Corruption
  // ==================================================================

  // Probe OBI bus entering user_domain
  wire        user_design_req   = i_croc_soc.i_user.user_sbr_obi_req_i.req;
  wire        user_design_we    = i_croc_soc.i_user.user_sbr_obi_req_i.a.we;
  wire [31:0] user_design_addr  = i_croc_soc.i_user.user_sbr_obi_req_i.a.addr;
  wire [31:0] user_design_wdata = i_croc_soc.i_user.user_sbr_obi_req_i.a.wdata;

  localparam bit [31:0] EncSignalAddr   = 32'h20001000;
  localparam bit [31:0] DecSignalAddr   = 32'h20001004;
  localparam bit [31:0] NumSamplesAddr  = 32'h20001008;
  localparam bit [31:0] HwMemAddrReg    = 32'h2000100C;

  // Bank base addresses
  localparam bit [31:0] Bank0Base = UserBaseAddr;
  localparam int unsigned BankSize = (SramBankNumWords * (SbrObiCfg.DataWidth / 8));
  localparam bit [31:0] Bank1Base = Bank0Base + BankSize;
  localparam int unsigned SramBankAddrWidth = cf_math_pkg::idx_width(SramBankNumWords);

  // Captured info from C code
  logic [31:0] hwmem_base_addr;
  logic        armed;
  logic        in_bank0;
  logic        in_bank1;

  // Number of 32-bit words to protect
  integer unsigned num_samples_val;
  logic         num_samples_captured;

  // Computed word address range within the target bank
  logic [SramBankAddrWidth-1:0] target_start_word;
  logic [SramBankAddrWidth-1:0] target_end_word;

  always_ff @(posedge sys_clk or negedge rst_n) begin
    if (!rst_n) begin
      armed             <= 1'b0;
      hwmem_base_addr   <= '0;
      in_bank0          <= 1'b0;
      in_bank1          <= 1'b0;
      num_samples_val   <= 0;
      num_samples_captured <= 1'b0;
      target_start_word <= '0;
      target_end_word   <= '0;
    end else begin
      if (user_design_req && user_design_we) begin

        // Capture NUM_SAMPLES (read first so we can compute end_word)
        if (user_design_addr == NumSamplesAddr && !num_samples_captured) begin
          num_samples_val <= unsigned'(user_design_wdata);
          num_samples_captured <= 1'b1;
        end

        // Capture hw_test_mem base address
        if (user_design_addr == HwMemAddrReg && !armed) begin
          armed           <= 1'b1;
          hwmem_base_addr <= user_design_wdata;

          if (user_design_wdata >= Bank0Base && user_design_wdata < Bank0Base + BankSize) begin
            in_bank0 <= 1'b1;
            in_bank1 <= 1'b0;
            target_start_word <= (user_design_wdata - Bank0Base) >> 2;
          end else if (user_design_wdata >= Bank1Base && user_design_wdata < Bank1Base + BankSize) begin
            in_bank0 <= 1'b0;
            in_bank1 <= 1'b1;
            target_start_word <= (user_design_wdata - Bank1Base) >> 2;
          end else begin
            in_bank0 <= 1'b0;
            in_bank1 <= 1'b0;
            $display("@%t | [WARNING] hw_test_mem at 0x%08h is NOT in any SRAM bank!",
                     $time, user_design_wdata);
          end
        end

        // Once NUM_SAMPLES is captured, compute end_word
        if (armed && num_samples_captured && (target_end_word == '0)) begin
          target_end_word <= target_start_word + SramBankAddrWidth'(num_samples_val) - 1;
          $display("@%t | [TB] Armed! hw_test_mem at 0x%08h, %0d words, bank=%s, range=[%0d..%0d]",
                   $time, hwmem_base_addr, num_samples_val,
                   in_bank0 ? "0" : (in_bank1 ? "1" : "NONE"),
                   target_start_word,
                   target_start_word + num_samples_val - 1);
        end

      end
    end
  end

  // ==================================================================
  // Fault Injection: Monitor SRAM write bus
  // ==================================================================

  wire        bank_req    = in_bank0 ? i_croc_soc.i_user.gen_sram_bank[0].i_sram_macro.gen_secded.i_sram.req_i[0] :
                            in_bank1 ? i_croc_soc.i_user.gen_sram_bank[1].i_sram_macro.gen_secded.i_sram.req_i[0] :
                            1'b0;
  wire        bank_we     = in_bank0 ? i_croc_soc.i_user.gen_sram_bank[0].i_sram_macro.gen_secded.i_sram.we_i[0] :
                            in_bank1 ? i_croc_soc.i_user.gen_sram_bank[1].i_sram_macro.gen_secded.i_sram.we_i[0] :
                            1'b0;
  wire [SramBankAddrWidth-1:0] bank_addr = in_bank0 ? i_croc_soc.i_user.gen_sram_bank[0].i_sram_macro.gen_secded.i_sram.addr_i[0] :
                                            in_bank1 ? i_croc_soc.i_user.gen_sram_bank[1].i_sram_macro.gen_secded.i_sram.addr_i[0] :
                                            {SramBankAddrWidth{1'b0}};

  wire bank_write_active = bank_req && bank_we;
  wire bank_in_range     = (bank_addr >= target_start_word) && (bank_addr <= target_end_word);
  wire bank_write_target = bank_write_active && bank_in_range && armed && (FaultType != 0);

  // Track which word addresses have been corrupted
  localparam int unsigned MaxWordAddr = 2**SramBankAddrWidth - 1;
  logic [MaxWordAddr:0] words_corrupted;

  // Inject only on first write to each word (one fault per word)
  wire inject_bank0 = in_bank0 && bank_write_target && !words_corrupted[bank_addr];
  wire inject_bank1 = in_bank1 && bank_write_target && !words_corrupted[bank_addr];

  assign sram_fault_inject = {inject_bank1, inject_bank0};
  assign sram_fault_sel    = (FaultType == 2);

  always_ff @(posedge sys_clk or negedge rst_n) begin
    if (!rst_n) begin
      words_corrupted <= '0;
    end else begin
      if (inject_bank0) begin
        words_corrupted[bank_addr] <= 1'b1;
        $display("@%t | [FAULT] %s-bit error in Bank[0] word_addr=%0d",
                 $time, (FaultType == 2) ? "DOUBLE" : "SINGLE", bank_addr);
      end
      if (inject_bank1) begin
        words_corrupted[bank_addr] <= 1'b1;
        $display("@%t | [FAULT] %s-bit error in Bank[1] word_addr=%0d",
                 $time, (FaultType == 2) ? "DOUBLE" : "SINGLE", bank_addr);
      end
    end
  end

  // ==================================================================
  // SECDED Benchmark Timing Measurement (same as tb_secded_bench)
  // ==================================================================

  logic enc_running_q;
  logic dec_running_q;

  integer unsigned enc_total_cycles;
  integer unsigned dec_total_cycles;
  integer unsigned enc_samples;
  integer unsigned dec_samples;

  always_ff @(posedge sys_clk or negedge rst_n) begin
    if (!rst_n) begin
      enc_running_q <= 1'b0;
      dec_running_q <= 1'b0;
      enc_samples   <= '0;
      dec_samples   <= '0;
    end else begin
      if (user_design_req && user_design_we) begin
        if (user_design_addr == EncSignalAddr) begin
          enc_running_q <= (user_design_wdata != 0);
          if (user_design_wdata != 0)
            enc_samples <= enc_samples + 1;
        end
        if (user_design_addr == DecSignalAddr) begin
          dec_running_q <= (user_design_wdata != 0);
          if (user_design_wdata != 0)
            dec_samples <= dec_samples + 1;
        end
      end
    end
  end

  always_ff @(posedge sys_clk or negedge rst_n) begin
    if (!rst_n) begin
      enc_total_cycles <= '0;
      dec_total_cycles <= '0;
    end else begin
      if (enc_running_q) enc_total_cycles <= enc_total_cycles + 1;
      if (dec_running_q) dec_total_cycles <= dec_total_cycles + 1;
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
    $display("HW SECDED Benchmark Results (TB measured)");
    $display("========================================");
    $display("Fault type: %0d", FaultType);
    if (enc_samples > 0) begin
      $display("Encode+Store: %0d samples, %0d total cycles, avg = %0d cycles",
               enc_samples, enc_total_cycles, enc_total_cycles / enc_samples);
    end
    if (dec_samples > 0) begin
      $display("Decode+Load:  %0d samples, %0d total cycles, avg = %0d cycles",
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
        $dumpfile("hw_secded_bench.fst");
        $dumpvars(1, i_croc_soc);
        $dumpvars(1, tb_hw_secded_bench);
      `else
        $dumpfile("hw_secded_bench.vcd");
        $dumpvars(1, i_croc_soc);
        $dumpvars(1, tb_hw_secded_bench);
      `endif
    `endif
  end

  final begin
    `ifdef TRACE_WAVE
      $dumpflush;
    `endif
  end

endmodule