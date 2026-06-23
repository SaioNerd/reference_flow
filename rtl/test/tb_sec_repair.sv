// Copyright 2024 ETH Zurich and University of Bologna.
// Solderpad Hardware License, Version 0.51, see LICENSE for details.
// SPDX-License-Identifier: SHL-0.51
//
// Authors:
// - Philippe Sauter <phsauter@iis.ee.ethz.ch>
// - Enrico Zelioli <ezelioli@iis.ee.ethz.ch>

// Testbench for 32-bit Word Memory Access with Data Corruption
// - Uses croc_vip for clock/reset generation, JTAG, UART, and GPIO
// - Instantiates croc_soc with SECDED-protected SRAM banks
// - The C code passes the target address via MMIO write to 0x2000_1000
// - The testbench captures this address, determines which bank it's in,
//   and corrupts the 64-bit encoded data on writes to that address

`define TRACE_WAVE

module tb_sec_repair #(
  parameter int unsigned GpioCount = 32,
  // Fault type: 1 = single-bit error, 2 = double-bit error
  parameter int unsigned FaultType = 1
);

  import tb_croc_pkg::*;
  import croc_pkg::*;
  import user_pkg::*;

  // Signals fully controlled by the VIP
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

  // Signals partially controlled by the VIP
  logic [GpioCount-1:0] gpio_in;
  logic [GpioCount-1:0] gpio_out;
  logic [GpioCount-1:0] gpio_out_en;

  // VIP‑driven GPIO defaults; testbench overrides bits 16,18,19 for fault injection
  logic [GpioCount-1:0] vip_gpio_in;

  /////////////////////////////
  //  Command Line Arguments //
  /////////////////////////////

  string binary_path;

  initial begin
    if ($value$plusargs("binary=%s", binary_path)) begin
      $display("Running program: %s", binary_path);
    end else begin
      $display("No binary path provided. Running memory_access_test.");
      binary_path = "../sw/bin/memory_access_test.hex";
    end
    if (FaultType == 2) begin
      $display("Fault mode: DOUBLE-bit error injection");
    end else begin
      $display("Fault mode: SINGLE-bit error injection");
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
    .gpio_in_o     ( vip_gpio_in )
  );

  // Fault injection signals driven by testbench, routed into
  // croc_soc via gpio_i[16] (bank1), gpio_i[18] (sel), gpio_i[19] (bank0).
  // All other GPIO bits pass through from the VIP unchanged.
  logic [1:0] sram_fault_inject;  // bit0=bank0, bit1=bank1
  logic       sram_fault_sel;     // 0=single, 1=double

  always_comb begin
    gpio_in = vip_gpio_in;
    gpio_in[16] = sram_fault_inject[1];  // bank1
    gpio_in[18] = sram_fault_sel;        // fault type
    gpio_in[19] = sram_fault_inject[0];  // bank0
  end

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

  //////////////////////////////////////////////////////////////////
  // OBI Bus Monitor: Capture Target Address from C Code
  //////////////////////////////////////////////////////////////////
  // The C code writes the address of its 32-bit word to 0x2000_1000
  // (UserDesign space) before writing any data. The testbench captures
  // this address, determines which bank it's in, and injects faults
  // on writes to that specific address.
  //////////////////////////////////////////////////////////////////

  // Probe the OBI request entering the user domain (from croc_domain)
  wire        obi_arm_req   = i_croc_soc.i_user.user_sbr_obi_req_i.req;
  wire        obi_arm_we    = i_croc_soc.i_user.user_sbr_obi_req_i.a.we;
  wire [31:0] obi_arm_addr  = i_croc_soc.i_user.user_sbr_obi_req_i.a.addr;
  wire [31:0] obi_arm_wdata = i_croc_soc.i_user.user_sbr_obi_req_i.a.wdata;

  // Address where the C code writes the target pointer to arm the TB
  localparam bit [31:0] ArmAddr = 32'h2000_1000;

  // Bank base addresses (derived from croc_pkg and user_pkg)
  // Bank0 starts at UserBaseAddr (0x1000_0000), Bank1 starts at offset 0x1000
  localparam bit [31:0] Bank0Base = UserBaseAddr;
  localparam int unsigned BankSize = (SramBankNumWords * (SbrObiCfg.DataWidth / 8)); // 1024 * 4 = 0x1000
  localparam bit [31:0] Bank1Base = Bank0Base + BankSize;

  // Captured target info from the C code
  logic [31:0] target_base_addr;
  logic        armed;
  logic        in_bank0;
  logic        in_bank1;

  // Computed word address within the target bank (dynamically sized from SramBankNumWords)
  localparam int unsigned SramBankAddrWidth = cf_math_pkg::idx_width(SramBankNumWords);
  logic [SramBankAddrWidth-1:0] target_word_addr;

  always_ff @(posedge sys_clk or negedge rst_n) begin
    if (!rst_n) begin
      armed            <= 1'b0;
      target_base_addr <= '0;
      in_bank0         <= 1'b0;
      in_bank1         <= 1'b0;
      target_word_addr <= '0;
    end else begin
      if (!armed && obi_arm_req && obi_arm_we && (obi_arm_addr == ArmAddr)) begin
        armed            <= 1'b1;
        target_base_addr <= obi_arm_wdata;
        $display("@%t | [TB] obi_arm_wdata = 0x%h", $time, obi_arm_wdata);

        // Determine which bank and compute word address
        if (obi_arm_wdata >= Bank0Base && obi_arm_wdata < Bank0Base + BankSize) begin
          in_bank0 <= 1'b1;
          in_bank1 <= 1'b0;
          target_word_addr <= (obi_arm_wdata - Bank0Base) >> 2;
          $display("@%t | [TB] Armed! Target at 0x%08h in BANK 0, word addr %0d",
                   $time, obi_arm_wdata, (obi_arm_wdata - Bank0Base) >> 2);
        end else if (obi_arm_wdata >= Bank1Base && obi_arm_wdata < Bank1Base + BankSize) begin
          in_bank0 <= 1'b0;
          in_bank1 <= 1'b1;
          target_word_addr <= (obi_arm_wdata - Bank1Base) >> 2;
          $display("@%t | [TB] Armed! Target at 0x%08h in BANK 1, word addr %0d",
                   $time, obi_arm_wdata, (obi_arm_wdata - Bank1Base) >> 2);
        end else begin
          in_bank0 <= 1'b0;
          in_bank1 <= 1'b0;
          $display("@%t | [WARNING] Target at 0x%08h is NOT in any SRAM bank! No faults injected.",
                   $time, obi_arm_wdata);
        end
      end
    end
  end

  //////////////////////////////////////////////////////////////////
  // Fault Injection: Direct SRAM Bus Monitoring
  //////////////////////////////////////////////////////////////////
  // We monitor the correct bank's internal 64-bit SRAM signals.
  // When a write occurs with address matching the target word address,
  // we inject a single-bit or double-bit error into the encoded
  // 64-bit data word.
  //
  // The 64-bit word layout (from secded_sram_impl.sv):
  //   bits 0:15   = encoded byte 0 (13-bit SECDED code in bits 0:12)
  //   bits 16:31  = encoded byte 1 (13-bit SECDED code in bits 16:28)
  //   bits 32:47  = encoded byte 2 (13-bit SECDED code in bits 32:44)
  //   bits 48:63  = encoded byte 3 (13-bit SECDED code in bits 48:60)
  //////////////////////////////////////////////////////////////////

  // Select the correct bank signals based on where the target is
  wire        bank_req    = in_bank0 ? i_croc_soc.i_user.gen_sram_bank[0].i_sram_macro.gen_secded.i_sram.req_i[0] :
                           in_bank1 ? i_croc_soc.i_user.gen_sram_bank[1].i_sram_macro.gen_secded.i_sram.req_i[0] :
                           1'b0;
  wire        bank_we     = in_bank0 ? i_croc_soc.i_user.gen_sram_bank[0].i_sram_macro.gen_secded.i_sram.we_i[0] :
                           in_bank1 ? i_croc_soc.i_user.gen_sram_bank[1].i_sram_macro.gen_secded.i_sram.we_i[0] :
                           1'b0;
  wire [SramBankAddrWidth-1:0] bank_addr   = in_bank0 ? i_croc_soc.i_user.gen_sram_bank[0].i_sram_macro.gen_secded.i_sram.addr_i[0] :
                                             in_bank1 ? i_croc_soc.i_user.gen_sram_bank[1].i_sram_macro.gen_secded.i_sram.addr_i[0] :
                                             {SramBankAddrWidth{1'b0}};
  wire [63:0] bank_wdata  = in_bank0 ? i_croc_soc.i_user.gen_sram_bank[0].i_sram_macro.gen_secded.i_sram.wdata_i[0] :
                           in_bank1 ? i_croc_soc.i_user.gen_sram_bank[1].i_sram_macro.gen_secded.i_sram.wdata_i[0] :
                           64'd0;

  // Trigger when writing to the target bank with address matching the target word
  wire bank_write_active = bank_req && bank_we;
  wire bank_addr_match   = (bank_addr == target_word_addr);
  wire bank_write_target = bank_write_active && bank_addr_match && armed;

  // Track whether the target word has already been corrupted
  logic word_corrupted;

  // Combinational fault injection: sram_fault_inject and sram_fault_sel
  // are driven combinatorially. The secded_sram_impl module XORs the
  // encoded data with the error mask before the SRAM captures it on posedge.
  wire inject_now = bank_write_target && !word_corrupted;

  assign sram_fault_inject = {in_bank1 && inject_now, in_bank0 && inject_now};
  assign sram_fault_sel    = (FaultType == 2);

  // Track corruption on posedge and display both clean (pre-fault)
  // and final (post-fault) 64-bit encoded data.
  // bank_wdata already probes i_sram.wdata_i[0] (= secded_wdata[0], post-fault).
  always_ff @(posedge sys_clk or negedge rst_n) begin
    if (!rst_n) begin
      word_corrupted <= 1'b0;
    end else if (inject_now) begin
      word_corrupted <= 1'b1;
      $display("@%t | [FAULT] %s-bit error injected at Bank[%0d] addr=%0d",
               $time, (FaultType == 2) ? "DOUBLE" : "SINGLE",
               in_bank1 ? 1 : 0, bank_addr);
      $display("@%t | [FAULT]   64-bit encoded wdata (post-fault) = 0x%016h", $time, bank_wdata);
    end
  end

  //////////////////////////////////////////////////////////////////
  // Single-Error Monitor: Detect single-bit errors via GPIO outputs
  // gpio_o[12] = bank0_single_err (pipelined)
  // gpio_o[13] = bank1_single_err (pipelined)
  // These are top-level ports of croc_soc — Verilator cannot optimize them away
  //////////////////////////////////////////////////////////////////
  logic gpio12_q, gpio13_q;

  always_ff @(posedge sys_clk) begin
    gpio12_q <= gpio_out[12];
    gpio13_q <= gpio_out[13];
    if (gpio_out[12] && !gpio12_q)
      $display("@%t | [SINGLE_ERR] Bank[0] single-bit error detected!", $time);
    if (gpio_out[13] && !gpio13_q)
      $display("@%t | [SINGLE_ERR] Bank[1] single-bit error detected!", $time);
  end

  ////////////////////
  //  Testbench     //
  ////////////////////

  logic [31:0] tb_data;

  initial begin
    $timeformat(-9, 0, "ns", 12);

    // Wait for reset
    #ClkPeriodSys;

    // Initialize JTAG
    i_vip.jtag_init();

    // Write test value to SRAM (debug)
    i_vip.jtag_write_reg32(SramBaseAddr, 32'h1234_5678, 1'b1);

    // Load binary to SRAM
    i_vip.jtag_load_hex(binary_path);

    // Wake core from WFI by writing to CLINT msip
    $display("@%t | [CORE] Waking core via CLINT msip", $time);
    i_vip.jtag_write_reg32(ClintBaseAddr, 32'h1);

    // Halt core
    i_vip.jtag_halt();

    // Resume core
    i_vip.jtag_resume();

    // Wait for non-zero return value (written into core status register)
    $display("@%t | [CORE] Wait for end of code...", $time);
    i_vip.jtag_wait_for_eoc(tb_data);

    // Finish simulation
    repeat(50) @(posedge sys_clk);
    $finish();
  end

  ////////////////
  //  Waveform  //
  ////////////////

  initial begin
    `ifdef TRACE_WAVE
      `ifdef VERILATOR
        $dumpfile("memory_access.fst");
        $dumpvars(1, i_croc_soc);
        $dumpvars(1, tb_sec_repair);
      `else
        $dumpfile("memory_access.vcd");
        $dumpvars(1, i_croc_soc);
        $dumpvars(1, tb_sec_repair);
      `endif
    `endif
  end

  final begin
    `ifdef TRACE_WAVE
      $dumpflush;
    `endif
  end

endmodule