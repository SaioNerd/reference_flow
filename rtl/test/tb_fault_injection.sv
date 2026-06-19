module tb_fault_injector;

    // Address mapping parameters matching user_pkg & croc_pkg
    localparam bit [31:0] Bank0Start   = 32'h1000_0000; 
    localparam bit [31:0] TriggerAddr  = 32'h1000_1000;
    localparam int unsigned NumBanks   = user_domain.NumSramBanks; // Automatically pulls parameter from design

    // -------------------------------------------------------------------------
    // 1. Monitor OBI Transactions & Identify the Correct Active SRAM Bank
    // -------------------------------------------------------------------------
    initial begin
        forever begin
            @(posedge tb_top.clk_i); // Synchronize to your main system clock
            
            // Iterate through every instantiated bank to catch where the write occurs
            for (int b = 0; b < NumBanks; b++) begin
                if (tb_top.i_chip.i_user_domain.gen_sram_banks[b].i_sram_macro.req_i[0] && 
                    tb_top.i_chip.i_user_domain.gen_sram_banks[b].i_sram_macro.we_i[0]) begin
                    
                    // Reconstruct address accessed within this specific bank frame
                    bit [31:0] current_access_addr = Bank0Start + 
                        (tb_top.i_chip.i_user_domain.gen_sram_banks[b].i_sram_macro.addr_i[0] << 2);
                    
                    if (current_access_addr == TriggerAddr) begin
                        logic [31:0] mode_val = tb_top.i_chip.i_user_domain.gen_sram_banks[b].i_sram_macro.wdata_i[0];
                        $display("[TB FAULT INJECTOR] Intercepted trigger at Bank [%0d], Address: 0x%0h. Mode: %0d", b, current_access_addr, mode_val);
                        
                        // Execute the full safety fault-injection procedure
                        execute_safe_injection(b, mode_val);
                    end
                end
            end
        end
    end

    // -------------------------------------------------------------------------
    // 2. Safe Injection Sequence: Halt Core -> Force Arrays -> Resume
    // -------------------------------------------------------------------------
    task execute_safe_injection(input int bank_idx, input logic [31:0] mode);
        $display("[TB FAULT INJECTOR] --- Starting Safe Corruption Sequence ---");

        // Step A: Stall the CPU core execution immediately to prevent any racing conditions
        // We use a hierarchical reference to halt or freeze processing inside your VIP architecture
        // (Adjust the reference path below to match where your croc_vip module instance sits)
        force tb_top.i_croc_vip.sys_clk_o = 1'b0; 
        $display("[TB FAULT INJECTOR] Core CPU clock successfully frozen.");

        // Step B: Ensure the SRAM write pipeline commits the trigger before altering contents
        #10ns; 

        // Step C: Corrupt target words inside the specific decoded bank array
        // SRC_ARRAY_ADDR (0x1000_0000) occupies 256 bytes = 64 words inside Bank 0
        $display("[TB FAULT INJECTOR] Injecting bit flips into Bank [%0d] storage arrays...", bank_idx);
        
        for (int word_idx = 0; word_idx < 64; word_idx++) begin
            
            // Pull the uncorrupted 64-bit protected layout line
            // Checks the inner generic tc_sram behavioral module storage block
            logic [63:0] clean_word = tb_top.i_chip.i_user_domain.gen_sram_banks[bank_idx].i_sram_macro.gen_secded.i_sram.i_tc_sram.mem[word_idx];
            logic [63:0] corrupted_word = clean_word;

            // Process all 4 internal SECDED byte-lanes (Each lane is spaced 16-bits apart)
            for (int byte_lane = 0; byte_lane < 4; byte_lane++) begin
                int bit_offset = byte_lane * 16;
                
                if (mode == 1) begin
                    // Single Error Correction (SEC): Flip exactly 1 bit per byte chunk
                    corrupted_word[bit_offset + 0] = ~corrupted_word[bit_offset + 0];
                end else if (mode == 2) begin
                    // Double Error Detection (DED): Flip 2 adjacent bits per byte chunk
                    corrupted_word[bit_offset + 0] = ~corrupted_word[bit_offset + 0];
                    corrupted_word[bit_offset + 1] = ~corrupted_word[bit_offset + 1];
                end
            end

            // Use a simulator force directive to guarantee overwrite without requiring write enables
            force tb_top.i_chip.i_user_domain.gen_sram_banks[bank_idx].i_sram_macro.gen_secded.i_sram.i_tc_sram.mem[word_idx] = corrupted_word;
            
            // Immediately release back control so standard architectural reads work correctly later
            release tb_top.i_chip.i_user_domain.gen_sram_banks[bank_idx].i_sram_macro.gen_secded.i_sram.i_tc_sram.mem[word_idx];
        end

        $display("[TB FAULT INJECTOR] Memory modifications locked. Releasing CPU clock wrapper...");

        // Step D: Restart the CPU execution by releasing the VIP clock source
        release tb_top.i_croc_vip.sys_clk_o;
        $display("[TB FAULT INJECTOR] --- Sequence Complete. CPU execution resumed. ---");
    endtask

endmodule