`define TRACE_WAVE

module tb_fault_injection_croc2 #(
  parameter int unsigned GpioCount = 32
);
  import tb_croc_pkg::*;

  logic rst_n, sys_clk, ref_clk;
  logic jtag_tck, jtag_trst_n, jtag_tms, jtag_tdi, jtag_tdo;
  logic uart_rx, uart_tx;
  logic [GpioCount-1:0] gpio_in, gpio_out, gpio_out_en;

  string binary_path;
  initial begin
    if (!$value$plusargs("binary=%s", binary_path)) begin
      binary_path = "../sw/bin/fault_injection.hex"; // Point to the compiled C code above
    end
  end

  // VIP & DUT Instantiation
  croc_vip #(.GpioCount(GpioCount)) i_vip (
    .rst_no(rst_n), .sys_clk_o(sys_clk), .ref_clk_o(ref_clk),
    .jtag_tck_o(jtag_tck), .jtag_trst_no(jtag_trst_n), .jtag_tms_o(jtag_tms),
    .jtag_tdi_o(jtag_tdi), .jtag_tdo_i(jtag_tdo),
    .uart_rx_o(uart_rx), .uart_tx_i(uart_tx),
    .gpio_out_en_i(gpio_out_en), .gpio_out_i(gpio_out), .gpio_in_o(gpio_in)
  );

  croc_soc #(.GpioCount(GpioCount)) i_croc_soc (
    .clk_i(sys_clk), .rst_ni(rst_n), .ref_clk_i(ref_clk), .testmode_i(1'b0),
    .status_o(), .jtag_tck_i(jtag_tck), .jtag_tdi_i(jtag_tdi),
    .jtag_tdo_o(jtag_tdo), .jtag_tms_i(jtag_tms), .jtag_trst_ni(jtag_trst_n),
    .uart_rx_i(uart_rx), .uart_tx_o(uart_tx),
    .gpio_i(gpio_in), .gpio_o(gpio_out), .gpio_out_en_o(gpio_out_en)
  );

  // -------------------------------------------------------------------------
  // SMART FAULT INJECTOR THREAD
  // -------------------------------------------------------------------------
  localparam bit [31:0] TriggerAddr = 32'h2000_1000;
  
  // Probes for the OBI bus and SRAM Bank 0
  wire        obi_req   = i_croc_soc.i_user.user_sbr_obi_req_i.req;
  wire        obi_we    = i_croc_soc.i_user.user_sbr_obi_req_i.a.we;
  wire [31:0] obi_addr  = i_croc_soc.i_user.user_sbr_obi_req_i.a.addr;
  wire [31:0] obi_wdata = i_croc_soc.i_user.user_sbr_obi_req_i.a.wdata;

  wire bank0_req = i_croc_soc.i_user.gen_sram_bank[0].bank_req;
  wire bank0_we  = i_croc_soc.i_user.gen_sram_bank[0].bank_we;

  int test_case;

  initial begin
    forever begin
      @(posedge sys_clk);
      
      // Wait for the C code to trigger a command
      if (obi_req && obi_we && (obi_addr == TriggerAddr)) begin
        test_case = obi_wdata;
        $display("@%t | [TB] Armed for Test Case %0d", $time, test_case);
        
        // --- CASES 1 & 2: Inject Fault on Write ---
        if (test_case == 1 || test_case == 2) begin
          // Wait for the CPU to actually access Bank 0 for a write
          while (!(bank0_req && bank0_we)) @(posedge sys_clk);
          
          $display("@%t | [TB] Intercepted Write. Flipping Bit 0!", $time);
          `ifndef VERILATOR
          force i_croc_soc.i_user.gen_sram_bank[0].i_sram_macro.gen_secded.sram_wdata_to_macro[0][0] = 
               ~i_croc_soc.i_user.gen_sram_bank[0].i_sram_macro.gen_secded.sram_wdata_to_macro[0][0];
          `endif
          
          @(posedge sys_clk);
          `ifndef VERILATOR
          release i_croc_soc.i_user.gen_sram_bank[0].i_sram_macro.gen_secded.sram_wdata_to_macro[0][0];
          `endif
        end
        
        // --- CASE 3: Inject Faults on Consecutive Reads ---
        else if (test_case == 3) begin
          // Wait for 1st Read
          while (!(bank0_req && !bank0_we)) @(posedge sys_clk);
          @(posedge sys_clk); // Wait 1 cycle for SRAM read latency
          
          $display("@%t | [TB] Intercepted Read 1. Flipping Bit 0!", $time);
          `ifndef VERILATOR
          force i_croc_soc.i_user.gen_sram_bank[0].i_sram_macro.gen_secded.secded_rdata[0][0] = 
               ~i_croc_soc.i_user.gen_sram_bank[0].i_sram_macro.gen_secded.secded_rdata[0][0];
          `endif
          @(posedge sys_clk);
          `ifndef VERILATOR
          release i_croc_soc.i_user.gen_sram_bank[0].i_sram_macro.gen_secded.secded_rdata[0][0];
          `endif

          // Wait for 2nd Read
          while (!(bank0_req && !bank0_we)) @(posedge sys_clk);
          @(posedge sys_clk); // Wait 1 cycle for SRAM read latency
          
          $display("@%t | [TB] Intercepted Read 2. Flipping Bit 1!", $time);
          `ifndef VERILATOR
          force i_croc_soc.i_user.gen_sram_bank[0].i_sram_macro.gen_secded.secded_rdata[0][1] = 
               ~i_croc_soc.i_user.gen_sram_bank[0].i_sram_macro.gen_secded.secded_rdata[0][1];
          `endif
          @(posedge sys_clk);
          `ifndef VERILATOR
          release i_croc_soc.i_user.gen_sram_bank[0].i_sram_macro.gen_secded.secded_rdata[0][1];
          `endif
        end

        // --- CASE 4: Fault injection on the ECC Parity Bits during Write ---
        else if (test_case == 4) begin
          while (!(bank0_req && bank0_we)) @(posedge sys_clk);
          
          $display("@%t | [TB] Case 4: Flipping Parity/ECC bit 8 on Write", $time);
          `ifndef VERILATOR
          // Target Bit 8, which is the first parity bit of Byte 0
          force i_croc_soc.i_user.gen_sram_bank[0].i_sram_macro.gen_secded.sram_wdata_to_macro[0][8] = 
              ~i_croc_soc.i_user.gen_sram_bank[0].i_sram_macro.gen_secded.sram_wdata_to_macro[0][8];
          `endif
          @(posedge sys_clk);
          `ifndef VERILATOR
          release i_croc_soc.i_user.gen_sram_bank[0].i_sram_macro.gen_secded.sram_wdata_to_macro[0][8];
          `endif
        end
      end
    end
  end

  // -------------------------------------------------------------------------
  // Standard Execution Flow
  // -------------------------------------------------------------------------
  logic [31:0] tb_data;
  initial begin
    $timeformat(-9, 0, "ns", 12);
    #ClkPeriodSys;
    i_vip.jtag_init();
    i_vip.jtag_load_hex(binary_path);
    i_vip.jtag_write_reg32(ClintBaseAddr, 32'h1); // Wake core
    i_vip.jtag_halt();
    i_vip.jtag_resume();
    
    i_vip.jtag_wait_for_eoc(tb_data);
    $display("Test finished with exit code: %0d", tb_data);
    repeat(50) @(posedge sys_clk);
    $finish();
  end
  
  initial begin
    $dumpfile("silent_wb_cases.vcd");
    $dumpvars(1, i_croc_soc);
  end
endmodule