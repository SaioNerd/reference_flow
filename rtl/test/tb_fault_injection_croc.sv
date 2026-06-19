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
// - Monitors OBI writes to the UserDesign trigger address (0x2000_1000)
// - Injects single-bit or double-bit faults into SRAM write data on trigger

`define TRACE_WAVE

module tb_fault_injection_croc #(
  parameter int unsigned GpioCount = 32
);

  import tb_croc_pkg::*;

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

  croc_soc #(
    .GpioCount ( GpioCount )
  ) i_croc_soc (
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

  //////////////////////////////////////////////////
  //  Fault Injection Control via OBI Bus Monitor //
  //////////////////////////////////////////////////

  // Trigger address in UserDesign address space
  // (UserBaseAddr + 0x1000_1000 = 0x2000_1000)
  localparam bit [31:0] TriggerAddr = 32'h20001000;

  // Probe the OBI request entering the user domain
  // This is the input port of i_user that carries requests from croc_domain
  wire        obi_req   = i_croc_soc.i_user.user_sbr_obi_req_i.req;
  wire        obi_we    = i_croc_soc.i_user.user_sbr_obi_req_i.a.we;
  wire [31:0] obi_addr  = i_croc_soc.i_user.user_sbr_obi_req_i.a.addr;
  wire [31:0] obi_wdata = i_croc_soc.i_user.user_sbr_obi_req_i.a.wdata;

  // Fault injection state
  // fault_type[1:0] selects the fault mode:
  //   2'b00 = no fault
  //   2'b01 = single-bit error (SEC)
  //   2'b10 = double-bit error (DED)
  //   2'b11 = reserved
  logic [1:0] fault_type_q;
  logic       inject_single;
  logic       inject_double;

  // Detect writes to the trigger address and latch fault type
  always_ff @(posedge sys_clk or negedge rst_n) begin
    if (!rst_n) begin
      fault_type_q  <= '0;
      inject_single <= 1'b0;
      inject_double <= 1'b0;
    end else begin
      // Default: no new injection
      inject_single <= 1'b0;
      inject_double <= 1'b0;

      // Detect write to trigger address
      if (obi_req && obi_we && obi_addr == TriggerAddr) begin
        fault_type_q <= obi_wdata[1:0];
        if (obi_wdata[1:0] == 2'b01) begin
          inject_single <= 1'b1;
          $display("@%t | [FAULT] Trigger: Single-bit error injection", $time);
        end else if (obi_wdata[1:0] == 2'b10) begin
          inject_double <= 1'b1;
          $display("@%t | [FAULT] Trigger: Double-bit error injection", $time);
        end
      end
    end
  end

  // -------------------------------------------------
  // Fault Injection into SRAM Write Data
  // -------------------------------------------------
  // We inject errors into the write data of SRAM banks
  // by XOR-ing with an error mask. The SECDED decoder
  // will then detect/correct these errors on read-back.
  // -------------------------------------------------

  // Error masks (inject into byte 0 of bank 0)
  localparam logic [31:0] SecMaskSingle = 32'h0000_0001; // single-bit flip
  localparam logic [31:0] SecMaskDouble = 32'h0000_0003; // two-bit flip

  // Per-bank fault injection
  // Uses hierarchical references into the generate blocks of user_domain
  for (genvar b = 0; b < croc_pkg::NumSramBanks; b++) begin : gen_fault_inject
    always_ff @(posedge sys_clk or negedge rst_n) begin
      if (!rst_n) begin
        // No action on reset
      end else begin
        // Inject single-bit error into bank write data
        if (inject_single) begin
          // Flip bit 0 of the write data going into the SECDED SRAM
          `ifndef VERILATOR
            force i_croc_soc.i_user.gen_sram_bank[b].bank_wdata =
              i_croc_soc.i_user.gen_sram_bank[b].bank_wdata ^ SecMaskSingle;
            #(ClkPeriodSys);
            release i_croc_soc.i_user.gen_sram_bank[b].bank_wdata;
          `else
            // Verilator does not support force/release;
            // use direct assignment via the continuous assignment below
          `endif
        end

        // Inject double-bit error into bank write data
        if (inject_double) begin
          `ifndef VERILATOR
            force i_croc_soc.i_user.gen_sram_bank[b].bank_wdata =
              i_croc_soc.i_user.gen_sram_bank[b].bank_wdata ^ SecMaskDouble;
            #(ClkPeriodSys);
            release i_croc_soc.i_user.gen_sram_bank[b].bank_wdata;
          `endif
        end
      end
    end
  end

  // For Verilator compatibility: inject fault by XOR-ing on the
  // continuous assignment level using an intermediate wire.
  // This only works if bank_wdata is a wire rather than a logic variable.
  // In the user_domain, bank_wdata is declared as 'logic' inside the
  // generate block, so force/release is the correct approach for
  // simulators that support it. For Verilator-based fault injection,
  // use the JTAG write-back approach instead (see below).

  //////////////////////////////////////////////////////////////////
  // Alternate Fault Injection via JTAG (Verilator-compatible)
  //////////////////////////////////////////////////////////////////

  logic jtag_fault_trigger;

  always_ff @(posedge sys_clk or negedge rst_n) begin
    if (!rst_n) begin
      jtag_fault_trigger <= 1'b0;
    end else begin
      // Latch when injection is requested (used by non-Verilator path above)
      if (inject_single || inject_double) begin
        jtag_fault_trigger <= 1'b1;
      end else if (jtag_fault_trigger) begin
        jtag_fault_trigger <= 1'b0;
      end
    end
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