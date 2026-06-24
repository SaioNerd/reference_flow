// Copyright 2024 ETH Zurich and University of Bologna.
// Solderpad Hardware License, Version 0.51, see LICENSE for details.
// SPDX-License-Identifier: SHL-0.51
//
// Authors:
// - Philippe Sauter <phsauter@iis.ee.ethz.ch>
// - Enrico Zelioli <ezelioli@iis.ee.ethz.ch>

// Testbench for SECDED SRAM Fault Injection
// - Uses croc_vip for clock/reset generation, JTAG, UART, and GPIO
// - Instantiates croc_soc with SECDED-protected SRAM banks
// - The C code passes the faulty array address via MMIO write to 0x2000_1000
// - The testbench captures this address, determines which bank it's in,
//   computes the word address range, and injects faults into the 64-bit
//   encoded data on writes to that range.

`define TRACE_WAVE

module tb_fault_injection_croc #(
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
  logic [GpioCount-1:0] gpio_in_sync;

  ////////////////////////////////////////
  //  GPIO mapping for fault injection  //
  ////////////////////////////////////////

  always_comb begin : fault_injeciton_assignment
    gpio_in_sync = gpio_in;
    gpio_in_sync[19] = sram_fault_inject[0]; // Bank 0 fault injection
    gpio_in_sync[16] = sram_fault_inject[1]; // Bank 1 fault injection
    gpio_in_sync[18] = sram_fault_sel;        // Fault type: 0=single, 1=double
  end

  /////////////////////////////
  //  Command Line Arguments //
  /////////////////////////////

  string binary_path;

  initial begin
    if ($value$plusargs("binary=%s", binary_path)) begin
      $display("Running program: %s", binary_path);
    end else begin
      $display("No binary path provided. Running bitflip_verify.");
      binary_path = "../sw/bin/bitflip_verify.hex";
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
    .gpio_in_o     ( gpio_in     )
  );

  ////////////
  //  DUT   //
  ////////////

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

  //////////////////////////////////////////////////////////////////
  // OBI Bus Monitor: Capture Faulty Array Address from C Code
  //////////////////////////////////////////////////////////////////
  // The C code writes the address of its faulty array to 0x2000_1000
  // (UserDesign space) before writing any data. The testbench captures
  // this address, determines which bank it's in, computes the word
  // address range, and starts fault injection on writes to that range.
  //////////////////////////////////////////////////////////////////

  // Probe the OBI request entering the user domain (from croc_domain)
  wire        obi_arm_req   = i_croc_soc.i_user.user_sbr_obi_req_i.req;
  wire        obi_arm_we    = i_croc_soc.i_user.user_sbr_obi_req_i.a.we;
  wire [31:0] obi_arm_addr  = i_croc_soc.i_user.user_sbr_obi_req_i.a.addr;
  wire [31:0] obi_arm_wdata = i_croc_soc.i_user.user_sbr_obi_req_i.a.wdata;

  // Address where the C code writes the faulty array pointer to arm the TB
  localparam bit [31:0] ArmAddr = 32'h2000_1000;

  // Bank base addresses (derived from croc_pkg and user_pkg)
  localparam bit [31:0] Bank0Base = UserBaseAddr;
  localparam int unsigned BankSize = (SramBankNumWords * (SbrObiCfg.DataWidth / 8)); // 1024 * 4 = 0x1000
  localparam bit [31:0] Bank1Base = Bank0Base + BankSize;
  // Word address width (dynamically sized from SramBankNumWords)
  localparam int unsigned SramBankAddrWidth = cf_math_pkg::idx_width(SramBankNumWords);
  // Array max size in bytes
  localparam int unsigned ArrayMaxBytes = 256;
  // Number of 64-bit words for the array (each 64-bit word = 8 bytes)
  localparam int unsigned ArrayNumWords = ArrayMaxBytes / (SbrObiCfg.DataWidth / 8); // 256/4 = 64

  // Captured faulty array info from the C code
  logic [31:0] faulty_base_addr;
  logic        armed;
  logic        in_bank0;
  logic        in_bank1;

  // Computed word address range within the target bank
  logic [SramBankAddrWidth-1:0] target_start_word;
  logic [SramBankAddrWidth-1:0] target_end_word;

  always_ff @(posedge sys_clk or negedge rst_n) begin
    if (!rst_n) begin
      armed            <= 1'b0;
      faulty_base_addr <= '0;
      in_bank0         <= 1'b0;
      in_bank1         <= 1'b0;
      target_start_word <= '0;
      target_end_word   <= '0;
    end else begin
      if (!armed && obi_arm_req && obi_arm_we && (obi_arm_addr == ArmAddr)) begin
        armed            <= 1'b1;
        faulty_base_addr <= obi_arm_wdata;

        // Determine which bank and compute word address range
        if (obi_arm_wdata >= Bank0Base && obi_arm_wdata < Bank0Base + BankSize) begin
          in_bank0 <= 1'b1;
          in_bank1 <= 1'b0;
          // Word address = (byte_addr - bank_base) >> 2 (32-bit words)
          // But the 64-bit SRAM uses the same address, so each 64-bit word
          // corresponds to one 32-bit word (4 bytes → 64-bit encoded)
          target_start_word <= (obi_arm_wdata - Bank0Base) >> 2;
          target_end_word   <= ((obi_arm_wdata - Bank0Base) >> 2) + ArrayNumWords - 1;
          $display("@%t | [TB] Armed! Array at 0x%08h in BANK 0, words [%0d..%0d]",
                   $time, obi_arm_wdata,
                   (obi_arm_wdata - Bank0Base) >> 2,
                   ((obi_arm_wdata - Bank0Base) >> 2) + ArrayNumWords - 1);
        end else if (obi_arm_wdata >= Bank1Base && obi_arm_wdata < Bank1Base + BankSize) begin
          in_bank0 <= 1'b0;
          in_bank1 <= 1'b1;
          target_start_word <= (obi_arm_wdata - Bank1Base) >> 2;
          target_end_word   <= ((obi_arm_wdata - Bank1Base) >> 2) + ArrayNumWords - 1;
          $display("@%t | [TB] Armed! Array at 0x%08h in BANK 1, words [%0d..%0d]",
                   $time, obi_arm_wdata,
                   (obi_arm_wdata - Bank1Base) >> 2,
                   ((obi_arm_wdata - Bank1Base) >> 2) + ArrayNumWords - 1);
        end else begin
          in_bank0 <= 1'b0;
          in_bank1 <= 1'b0;
          $display("@%t | [WARNING] Array at 0x%08h is NOT in any SRAM bank! No faults injected.",
                   $time, obi_arm_wdata);
        end
      end
    end
  end

  //////////////////////////////////////////////////////////////////
  // Fault Injection: Direct SRAM Bus Monitoring
  //////////////////////////////////////////////////////////////////
  // We monitor the correct bank's internal 64-bit SRAM signals.
  // When a write occurs with address in the target word range,
  // we inject a single-bit or double-bit error into the encoded
  // 64-bit data word.
  //
  // The 64-bit word layout (from secded_sram_impl.sv):
  //   bits 0:15   = encoded byte 0 (13-bit SECDED code in bits 0:12)
  //   bits 16:31  = encoded byte 1 (13-bit SECDED code in bits 16:28)
  //   bits 32:47  = encoded byte 2 (13-bit SECDED code in bits 32:44)
  //   bits 48:63  = encoded byte 3 (13-bit SECDED code in bits 48:60)
  //////////////////////////////////////////////////////////////////

  // Select the correct bank signals based on where the array is
  wire        bank_req    = in_bank0 ? i_croc_soc.i_user.gen_sram_bank[0].i_sram_macro.gen_secded.i_sram.req_i[0] :
                           in_bank1 ? i_croc_soc.i_user.gen_sram_bank[1].i_sram_macro.gen_secded.i_sram.req_i[0] :
                           1'b0;
  wire        bank_we     = in_bank0 ? i_croc_soc.i_user.gen_sram_bank[0].i_sram_macro.gen_secded.i_sram.we_i[0] :
                           in_bank1 ? i_croc_soc.i_user.gen_sram_bank[1].i_sram_macro.gen_secded.i_sram.we_i[0] :
                           1'b0;
  wire [SramBankAddrWidth-1:0] bank_addr = in_bank0 ? i_croc_soc.i_user.gen_sram_bank[0].i_sram_macro.gen_secded.i_sram.addr_i[0] :
                                           in_bank1 ? i_croc_soc.i_user.gen_sram_bank[1].i_sram_macro.gen_secded.i_sram.addr_i[0] :
                                           {SramBankAddrWidth{1'b0}};
  wire [63:0] bank_wdata  = in_bank0 ? i_croc_soc.i_user.gen_sram_bank[0].i_sram_macro.gen_secded.i_sram.wdata_i[0] :
                           in_bank1 ? i_croc_soc.i_user.gen_sram_bank[1].i_sram_macro.gen_secded.i_sram.wdata_i[0] :
                           64'd0;

  // Trigger when writing to the target bank with address in the target range
  wire bank_write_active = bank_req && bank_we;
  wire bank_in_range     = (bank_addr >= target_start_word) && (bank_addr <= target_end_word);
  wire bank_write_target = bank_write_active && bank_in_range && armed;

  // Fault injection signals: driven combinatorially into the RTL
  // (via croc_soc → user_domain → secded_sram_impl ports)
  logic [1:0] sram_fault_inject;  // bit0=bank0, bit1=bank1
  logic       sram_fault_sel;     // 0=single, 1=double

  // Track which addresses have been corrupted per chunk (4 chunks per word)
  localparam int unsigned MaxWordAddr = 2**SramBankAddrWidth - 1;
  logic [MaxWordAddr:0][3:0] chunks_corrupted;

  // Combinational fault injection activation
  wire inject_bank0 = in_bank0 && bank_write_target &&
                      (|((in_bank0 ? i_croc_soc.i_user.gen_sram_bank[0].bank_be : 4'd0) &
                         ~chunks_corrupted[bank_addr]));
  wire inject_bank1 = in_bank1 && bank_write_target &&
                      (|((in_bank1 ? i_croc_soc.i_user.gen_sram_bank[1].bank_be : 4'd0) &
                         ~chunks_corrupted[bank_addr]));

  assign sram_fault_inject = {inject_bank1, inject_bank0};
  assign sram_fault_sel    = (FaultType == 2);

  // Track corrupted chunks (registered on posedge)
  always_ff @(posedge sys_clk or negedge rst_n) begin
    if (!rst_n) begin
      chunks_corrupted <= '0;
    end else begin
      if (inject_bank0) begin
        automatic logic [3:0] be_val = i_croc_soc.i_user.gen_sram_bank[0].bank_be;
        chunks_corrupted[bank_addr] <= chunks_corrupted[bank_addr] | be_val;
        $display("@%t | [FAULT] %s-bit error in Bank[0] addr=%0d be=0x%01x",
                 $time, (FaultType == 2) ? "DOUBLE" : "SINGLE",
                 i_croc_soc.i_user.gen_sram_bank[0].i_sram_macro.gen_secded.i_sram.addr_i[0],
                 be_val);
      end
      if (inject_bank1) begin
        automatic logic [3:0] be_val = i_croc_soc.i_user.gen_sram_bank[1].bank_be;
        chunks_corrupted[bank_addr] <= chunks_corrupted[bank_addr] | be_val;
        $display("@%t | [FAULT] %s-bit error in Bank[1] addr=%0d be=0x%01x",
                 $time, (FaultType == 2) ? "DOUBLE" : "SINGLE",
                 i_croc_soc.i_user.gen_sram_bank[1].i_sram_macro.gen_secded.i_sram.addr_i[0],
                 be_val);
      end
    end
  end

  //////////////////////////////////////////////////////////////////
  // Error Flag Assertions: Display if flags are raised after corruption
  //////////////////////////////////////////////////////////////////

  assert_bank0_double_err: assert property (
    @(posedge sys_clk) (|chunks_corrupted) |-> !$rose(i_croc_soc.all_banks_double_err_o_q[0])
  ) else $display("@%t | [DOUBLE_ERR] Bank[0] double-bit error detected via SVA after injection!", $time);

  assert_bank1_double_err: assert property (
    @(posedge sys_clk) (|chunks_corrupted) |-> !$rose(i_croc_soc.all_banks_double_err_o_q[1])
  ) else $display("@%t | [DOUBLE_ERR] Bank[1] double-bit error detected via SVA after injection!", $time);

  assert_bank0_single_err: assert property (
    @(posedge sys_clk) (|chunks_corrupted) |-> !$rose(i_croc_soc.all_banks_single_err_o[0])
  ) else $display("@%t | [SINGLE_ERR] Bank[0] single-bit error detected via SVA after injection!", $time);

  assert_bank1_single_err: assert property (
    @(posedge sys_clk) (|chunks_corrupted) |-> !$rose(i_croc_soc.all_banks_single_err_o[1])
  ) else $display("@%t | [SINGLE_ERR] Bank[1] single-bit error detected via SVA after injection!", $time);

  
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
        $dumpfile("fault_injection.fst");
        $dumpvars(1, i_croc_soc);
        $dumpvars(1, tb_fault_injection_croc);
      `else
        $dumpfile("fault_injection.vcd");
        $dumpvars(1, i_croc_soc);
        $dumpvars(1, tb_fault_injection_croc);
      `endif
    `endif
  end

  final begin
    `ifdef TRACE_WAVE
      $dumpflush;
    `endif
  end

endmodule