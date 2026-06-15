// ============================================================================
// Testbench for secded_byte_encode and secded_byte_decode
// Tests:
//   1. Roundtrip: encode then decode gives back original data
//   2. Single Error Correction: inject 1-bit errors in all 13 positions
//   3. Double Error Detection: inject 2-bit errors in multiple combinations
//   4. Zero data (catches uninitialized memory issues with inverted parity)
// ============================================================================

`default_nettype none

module tb_secded_byte;

    // -------------------------------------------------------------------------
    // DUT signals
    // -------------------------------------------------------------------------
     logic [7:0]  test_data;
     logic [12:0] encoded, decoder_in;
     logic [7:0]  decoded_data;
     logic        single_err, double_err;

     // CLEAN FIX: Error mask handles injection automatically via continuous assignment
     // This avoids multi-driver compilation errors on decoder_in.
     logic [12:0] error_mask;
     assign decoder_in = encoded ^ error_mask;

    // -------------------------------------------------------------------------
    // Test tracking variables
    // -------------------------------------------------------------------------
    int total_tests  = 0;
    int passed_tests = 0;
    int failed_tests = 0;

    // -------------------------------------------------------------------------
    // Test Patterns Array (FIXED)
    // -------------------------------------------------------------------------
    logic [7:0] test_patterns [8] = '{
        8'h00, 8'hFF, 8'h55, 8'hAA, 
        8'h0F, 8'hF0, 8'hA5, 8'h5A
    };

    // -------------------------------------------------------------------------
    // DUT instances
    // -------------------------------------------------------------------------
    secded_byte_encode i_encode (
        .data_in     ( test_data   ),
        .encoded_out ( encoded     )
    );

    secded_byte_decode i_decode (
        .encoded_in  ( decoder_in   ),
        .data_out    ( decoded_data ),
        .single_err_o( single_err   ),
        .double_err_o( double_err   )
    );

    // -------------------------------------------------------------------------
    // Helper Task: Check and log results
    // -------------------------------------------------------------------------
    task check(input string name, input logic condition);
        total_tests++;
        if (condition) begin
            passed_tests++;
            $display("[PASS] %s", name);
        end else begin
            failed_tests++;
            $display("[FAIL] %s", name);
        end
    endtask

    // -------------------------------------------------------------------------
    // Main Simulation Block
    // -------------------------------------------------------------------------
    initial begin
        // Initialize mask to 0 (clean, uncorrupted data)
        error_mask = 13'b0;
        
        $display("Starting SECDED Byte Testbench...");

        // =====================================================================
        // Test 1: Roundtrip (No Errors)
        // =====================================================================
        $display("\n--- Test 1: Roundtrip ---");
        foreach (test_patterns[i]) begin
            test_data = test_patterns[i];
            #1; // Wait for combinational logic to propagate
            check($sformatf("Roundtrip pattern 8'h%h", test_data), 
                  (decoded_data == test_data) && !single_err && !double_err);
        end

        // =====================================================================
        // Test 2: Single Error Correction - inject error in each of 13 bit positions
        //          for multiple data patterns
        // =====================================================================
        $display("");
        $display("--- Test 2: Single Error Correction ---");

        for (int p = 0; p < 8; p++) begin
            test_data = test_patterns[p];
            #1;  // let encoder settle

            // Inject error in each of the 13 bits
            for (int b = 0; b < 13; b++) begin
                // Drive the mask to flip exactly one bit
                error_mask = (13'b1 << b);
                #1; // Wait for decoder combinational logic to evaluate

                check($sformatf("Single-bit error pos=%0d, data=0x%02x: data corrected", b, test_data),
                      (decoded_data == test_data));
                check($sformatf("Single-bit error pos=%0d, data=0x%02x: single_err asserted", b, test_data),
                      (single_err == 1'b1));
                check($sformatf("Single-bit error pos=%0d, data=0x%02x: double_err not asserted", b, test_data),
                      (double_err == 1'b0));
            end
        end
        
        // Clear the error mask after the loop
        error_mask = 13'b0;

        // =====================================================================
        // Test 3: Double Error Detection - inject 2-bit errors
        // =====================================================================
        $display("");
        $display("--- Test 3: Double Error Detection ---");

        // Test double-bit errors on several data patterns
        for (int p = 0; p < 4; p++) begin
            test_data = test_patterns[p];
            #1;

            // Test several double-bit combinations
            for (int b0 = 0; b0 < 12; b0++) begin
                for (int b1 = b0+1; b1 < 13; b1++) begin
                    // Drive the mask to flip two distinct bits
                    error_mask = (13'b1 << b0) ^ (13'b1 << b1);
                    #1; // Wait for decoder combinational logic to evaluate

                    // Must detect double error: either data mismatch or double_err asserted
                    if (decoded_data != test_data) begin
                        // Data corrupted — double_err must be asserted
                        check($sformatf("Double-bit error bits=(%0d,%0d) data=0x%02x: mismatch + double_err", b0, b1, test_data),
                              (double_err == 1'b1));
                    end else begin
                        // Data matches by chance — double_err must be asserted
                        check($sformatf("Double-bit error bits=(%0d,%0d) data=0x%02x: double_err flagged", b0, b1, test_data),
                              (double_err == 1'b1));
                    end
                end
            end
        end
        
        // Clear the error mask after the loop
        error_mask = 13'b0;

        // =====================================================================
        // Test 4: Edge Cases
        // =====================================================================
        $display("\n--- Test 4: Edge Cases ---");

        // All zeros (check inverted parity handles this)
        test_data = 8'h00;
        #1;
        check("Zero data roundtrip", (decoded_data == 8'h00));

        // All ones
        test_data = 8'hFF;
        #1;
        check("All-ones data roundtrip", (decoded_data == 8'hFF));

        // Alternating
        test_data = 8'hAA;
        #1;
        check("Alternating data (AA) roundtrip", (decoded_data == 8'hAA));

        // =====================================================================
        // Summary
        // =====================================================================
        $display("\n==============================================");
        $display("  RESULTS");
        $display("    Total:  %0d", total_tests);
        $display("    Passed: %0d", passed_tests);
        $display("    Failed: %0d", failed_tests);
        $display("==============================================");

        if (failed_tests == 0) begin
            $display("\n  *** ALL TESTS PASSED ***\n");
        end else begin
            $display("\n  *** SOME TESTS FAILED ***\n");
        end

        $finish;
    end

endmodule

`default_nettype wire