###############################################################################
# Created by write_sdc
# Sun Jun 28 15:02:36 2026
###############################################################################
current_design croc_chip
###############################################################################
# Timing Constraints
###############################################################################
create_clock -name clk_sys -period 13.7000 [get_ports {clk_i}]
set_clock_transition 0.2000 [get_clocks {clk_sys}]
set_clock_uncertainty 0.1000 clk_sys
set_propagated_clock [get_clocks {clk_sys}]
create_clock -name clk_jtg -period 25.0000 [get_ports {jtag_tck_i}]
set_clock_transition 0.2000 [get_clocks {clk_jtg}]
set_clock_uncertainty 0.1000 clk_jtg
set_propagated_clock [get_clocks {clk_jtg}]
create_clock -name clk_rtc -period 50.0000 [get_ports {ref_clk_i}]
set_clock_transition 0.2000 [get_clocks {clk_rtc}]
set_clock_uncertainty 0.1000 clk_rtc
set_propagated_clock [get_clocks {clk_rtc}]
set_clock_groups -name clk_groups_async -asynchronous \
 -group [get_clocks {clk_jtg}]\
 -group [get_clocks {clk_rtc}]\
 -group [get_clocks {clk_sys}]
set_input_delay 1.3700 -clock [get_clocks {clk_sys}] -min -add_delay [get_ports {gpio0_io}]
set_input_delay 4.1100 -clock [get_clocks {clk_sys}] -max -add_delay [get_ports {gpio0_io}]
set_input_delay 1.3700 -clock [get_clocks {clk_sys}] -min -add_delay [get_ports {gpio10_io}]
set_input_delay 4.1100 -clock [get_clocks {clk_sys}] -max -add_delay [get_ports {gpio10_io}]
set_input_delay 1.3700 -clock [get_clocks {clk_sys}] -min -add_delay [get_ports {gpio11_io}]
set_input_delay 4.1100 -clock [get_clocks {clk_sys}] -max -add_delay [get_ports {gpio11_io}]
set_input_delay 1.3700 -clock [get_clocks {clk_sys}] -min -add_delay [get_ports {gpio12_io}]
set_input_delay 4.1100 -clock [get_clocks {clk_sys}] -max -add_delay [get_ports {gpio12_io}]
set_input_delay 1.3700 -clock [get_clocks {clk_sys}] -min -add_delay [get_ports {gpio13_io}]
set_input_delay 4.1100 -clock [get_clocks {clk_sys}] -max -add_delay [get_ports {gpio13_io}]
set_input_delay 1.3700 -clock [get_clocks {clk_sys}] -min -add_delay [get_ports {gpio14_io}]
set_input_delay 4.1100 -clock [get_clocks {clk_sys}] -max -add_delay [get_ports {gpio14_io}]
set_input_delay 1.3700 -clock [get_clocks {clk_sys}] -min -add_delay [get_ports {gpio15_io}]
set_input_delay 4.1100 -clock [get_clocks {clk_sys}] -max -add_delay [get_ports {gpio15_io}]
set_input_delay 1.3700 -clock [get_clocks {clk_sys}] -min -add_delay [get_ports {gpio16_io}]
set_input_delay 4.1100 -clock [get_clocks {clk_sys}] -max -add_delay [get_ports {gpio16_io}]
set_input_delay 1.3700 -clock [get_clocks {clk_sys}] -min -add_delay [get_ports {gpio17_io}]
set_input_delay 4.1100 -clock [get_clocks {clk_sys}] -max -add_delay [get_ports {gpio17_io}]
set_input_delay 1.3700 -clock [get_clocks {clk_sys}] -min -add_delay [get_ports {gpio18_io}]
set_input_delay 4.1100 -clock [get_clocks {clk_sys}] -max -add_delay [get_ports {gpio18_io}]
set_input_delay 1.3700 -clock [get_clocks {clk_sys}] -min -add_delay [get_ports {gpio19_io}]
set_input_delay 4.1100 -clock [get_clocks {clk_sys}] -max -add_delay [get_ports {gpio19_io}]
set_input_delay 1.3700 -clock [get_clocks {clk_sys}] -min -add_delay [get_ports {gpio1_io}]
set_input_delay 4.1100 -clock [get_clocks {clk_sys}] -max -add_delay [get_ports {gpio1_io}]
set_input_delay 1.3700 -clock [get_clocks {clk_sys}] -min -add_delay [get_ports {gpio20_io}]
set_input_delay 4.1100 -clock [get_clocks {clk_sys}] -max -add_delay [get_ports {gpio20_io}]
set_input_delay 1.3700 -clock [get_clocks {clk_sys}] -min -add_delay [get_ports {gpio21_io}]
set_input_delay 4.1100 -clock [get_clocks {clk_sys}] -max -add_delay [get_ports {gpio21_io}]
set_input_delay 1.3700 -clock [get_clocks {clk_sys}] -min -add_delay [get_ports {gpio22_io}]
set_input_delay 4.1100 -clock [get_clocks {clk_sys}] -max -add_delay [get_ports {gpio22_io}]
set_input_delay 1.3700 -clock [get_clocks {clk_sys}] -min -add_delay [get_ports {gpio23_io}]
set_input_delay 4.1100 -clock [get_clocks {clk_sys}] -max -add_delay [get_ports {gpio23_io}]
set_input_delay 1.3700 -clock [get_clocks {clk_sys}] -min -add_delay [get_ports {gpio24_io}]
set_input_delay 4.1100 -clock [get_clocks {clk_sys}] -max -add_delay [get_ports {gpio24_io}]
set_input_delay 1.3700 -clock [get_clocks {clk_sys}] -min -add_delay [get_ports {gpio25_io}]
set_input_delay 4.1100 -clock [get_clocks {clk_sys}] -max -add_delay [get_ports {gpio25_io}]
set_input_delay 1.3700 -clock [get_clocks {clk_sys}] -min -add_delay [get_ports {gpio26_io}]
set_input_delay 4.1100 -clock [get_clocks {clk_sys}] -max -add_delay [get_ports {gpio26_io}]
set_input_delay 1.3700 -clock [get_clocks {clk_sys}] -min -add_delay [get_ports {gpio27_io}]
set_input_delay 4.1100 -clock [get_clocks {clk_sys}] -max -add_delay [get_ports {gpio27_io}]
set_input_delay 1.3700 -clock [get_clocks {clk_sys}] -min -add_delay [get_ports {gpio28_io}]
set_input_delay 4.1100 -clock [get_clocks {clk_sys}] -max -add_delay [get_ports {gpio28_io}]
set_input_delay 1.3700 -clock [get_clocks {clk_sys}] -min -add_delay [get_ports {gpio29_io}]
set_input_delay 4.1100 -clock [get_clocks {clk_sys}] -max -add_delay [get_ports {gpio29_io}]
set_input_delay 1.3700 -clock [get_clocks {clk_sys}] -min -add_delay [get_ports {gpio2_io}]
set_input_delay 4.1100 -clock [get_clocks {clk_sys}] -max -add_delay [get_ports {gpio2_io}]
set_input_delay 1.3700 -clock [get_clocks {clk_sys}] -min -add_delay [get_ports {gpio30_io}]
set_input_delay 4.1100 -clock [get_clocks {clk_sys}] -max -add_delay [get_ports {gpio30_io}]
set_input_delay 1.3700 -clock [get_clocks {clk_sys}] -min -add_delay [get_ports {gpio31_io}]
set_input_delay 4.1100 -clock [get_clocks {clk_sys}] -max -add_delay [get_ports {gpio31_io}]
set_input_delay 1.3700 -clock [get_clocks {clk_sys}] -min -add_delay [get_ports {gpio3_io}]
set_input_delay 4.1100 -clock [get_clocks {clk_sys}] -max -add_delay [get_ports {gpio3_io}]
set_input_delay 1.3700 -clock [get_clocks {clk_sys}] -min -add_delay [get_ports {gpio4_io}]
set_input_delay 4.1100 -clock [get_clocks {clk_sys}] -max -add_delay [get_ports {gpio4_io}]
set_input_delay 1.3700 -clock [get_clocks {clk_sys}] -min -add_delay [get_ports {gpio5_io}]
set_input_delay 4.1100 -clock [get_clocks {clk_sys}] -max -add_delay [get_ports {gpio5_io}]
set_input_delay 1.3700 -clock [get_clocks {clk_sys}] -min -add_delay [get_ports {gpio6_io}]
set_input_delay 4.1100 -clock [get_clocks {clk_sys}] -max -add_delay [get_ports {gpio6_io}]
set_input_delay 1.3700 -clock [get_clocks {clk_sys}] -min -add_delay [get_ports {gpio7_io}]
set_input_delay 4.1100 -clock [get_clocks {clk_sys}] -max -add_delay [get_ports {gpio7_io}]
set_input_delay 1.3700 -clock [get_clocks {clk_sys}] -min -add_delay [get_ports {gpio8_io}]
set_input_delay 4.1100 -clock [get_clocks {clk_sys}] -max -add_delay [get_ports {gpio8_io}]
set_input_delay 1.3700 -clock [get_clocks {clk_sys}] -min -add_delay [get_ports {gpio9_io}]
set_input_delay 4.1100 -clock [get_clocks {clk_sys}] -max -add_delay [get_ports {gpio9_io}]
set_input_delay 2.5000 -clock [get_clocks {clk_jtg}] -min -add_delay [get_ports {jtag_tdi_i}]
set_input_delay 7.5000 -clock [get_clocks {clk_jtg}] -max -add_delay [get_ports {jtag_tdi_i}]
set_input_delay 2.5000 -clock [get_clocks {clk_jtg}] -min -add_delay [get_ports {jtag_tms_i}]
set_input_delay 7.5000 -clock [get_clocks {clk_jtg}] -max -add_delay [get_ports {jtag_tms_i}]
set_input_delay 2.5000 -rise -max -add_delay [get_ports {jtag_trst_ni}]
set_input_delay 2.5000 -fall -max -add_delay [get_ports {jtag_trst_ni}]
set_input_delay 2.5000 -rise -max -add_delay [get_ports {rst_ni}]
set_input_delay 2.5000 -fall -max -add_delay [get_ports {rst_ni}]
set_input_delay 2.5000 -rise -max -add_delay [get_ports {testmode_i}]
set_input_delay 2.5000 -fall -max -add_delay [get_ports {testmode_i}]
set_input_delay 1.3700 -clock [get_clocks {clk_sys}] -min -add_delay [get_ports {uart_rx_i}]
set_input_delay 4.1100 -clock [get_clocks {clk_sys}] -max -add_delay [get_ports {uart_rx_i}]
set_output_delay 1.3700 -clock [get_clocks {clk_sys}] -min -add_delay [get_ports {gpio0_io}]
set_output_delay 4.1100 -clock [get_clocks {clk_sys}] -max -add_delay [get_ports {gpio0_io}]
set_output_delay 1.3700 -clock [get_clocks {clk_sys}] -min -add_delay [get_ports {gpio10_io}]
set_output_delay 4.1100 -clock [get_clocks {clk_sys}] -max -add_delay [get_ports {gpio10_io}]
set_output_delay 1.3700 -clock [get_clocks {clk_sys}] -min -add_delay [get_ports {gpio11_io}]
set_output_delay 4.1100 -clock [get_clocks {clk_sys}] -max -add_delay [get_ports {gpio11_io}]
set_output_delay 1.3700 -clock [get_clocks {clk_sys}] -min -add_delay [get_ports {gpio12_io}]
set_output_delay 4.1100 -clock [get_clocks {clk_sys}] -max -add_delay [get_ports {gpio12_io}]
set_output_delay 1.3700 -clock [get_clocks {clk_sys}] -min -add_delay [get_ports {gpio13_io}]
set_output_delay 4.1100 -clock [get_clocks {clk_sys}] -max -add_delay [get_ports {gpio13_io}]
set_output_delay 1.3700 -clock [get_clocks {clk_sys}] -min -add_delay [get_ports {gpio14_io}]
set_output_delay 4.1100 -clock [get_clocks {clk_sys}] -max -add_delay [get_ports {gpio14_io}]
set_output_delay 1.3700 -clock [get_clocks {clk_sys}] -min -add_delay [get_ports {gpio15_io}]
set_output_delay 4.1100 -clock [get_clocks {clk_sys}] -max -add_delay [get_ports {gpio15_io}]
set_output_delay 1.3700 -clock [get_clocks {clk_sys}] -min -add_delay [get_ports {gpio16_io}]
set_output_delay 4.1100 -clock [get_clocks {clk_sys}] -max -add_delay [get_ports {gpio16_io}]
set_output_delay 1.3700 -clock [get_clocks {clk_sys}] -min -add_delay [get_ports {gpio17_io}]
set_output_delay 4.1100 -clock [get_clocks {clk_sys}] -max -add_delay [get_ports {gpio17_io}]
set_output_delay 1.3700 -clock [get_clocks {clk_sys}] -min -add_delay [get_ports {gpio18_io}]
set_output_delay 4.1100 -clock [get_clocks {clk_sys}] -max -add_delay [get_ports {gpio18_io}]
set_output_delay 1.3700 -clock [get_clocks {clk_sys}] -min -add_delay [get_ports {gpio19_io}]
set_output_delay 4.1100 -clock [get_clocks {clk_sys}] -max -add_delay [get_ports {gpio19_io}]
set_output_delay 1.3700 -clock [get_clocks {clk_sys}] -min -add_delay [get_ports {gpio1_io}]
set_output_delay 4.1100 -clock [get_clocks {clk_sys}] -max -add_delay [get_ports {gpio1_io}]
set_output_delay 1.3700 -clock [get_clocks {clk_sys}] -min -add_delay [get_ports {gpio20_io}]
set_output_delay 4.1100 -clock [get_clocks {clk_sys}] -max -add_delay [get_ports {gpio20_io}]
set_output_delay 1.3700 -clock [get_clocks {clk_sys}] -min -add_delay [get_ports {gpio21_io}]
set_output_delay 4.1100 -clock [get_clocks {clk_sys}] -max -add_delay [get_ports {gpio21_io}]
set_output_delay 1.3700 -clock [get_clocks {clk_sys}] -min -add_delay [get_ports {gpio22_io}]
set_output_delay 4.1100 -clock [get_clocks {clk_sys}] -max -add_delay [get_ports {gpio22_io}]
set_output_delay 1.3700 -clock [get_clocks {clk_sys}] -min -add_delay [get_ports {gpio23_io}]
set_output_delay 4.1100 -clock [get_clocks {clk_sys}] -max -add_delay [get_ports {gpio23_io}]
set_output_delay 1.3700 -clock [get_clocks {clk_sys}] -min -add_delay [get_ports {gpio24_io}]
set_output_delay 4.1100 -clock [get_clocks {clk_sys}] -max -add_delay [get_ports {gpio24_io}]
set_output_delay 1.3700 -clock [get_clocks {clk_sys}] -min -add_delay [get_ports {gpio25_io}]
set_output_delay 4.1100 -clock [get_clocks {clk_sys}] -max -add_delay [get_ports {gpio25_io}]
set_output_delay 1.3700 -clock [get_clocks {clk_sys}] -min -add_delay [get_ports {gpio26_io}]
set_output_delay 4.1100 -clock [get_clocks {clk_sys}] -max -add_delay [get_ports {gpio26_io}]
set_output_delay 1.3700 -clock [get_clocks {clk_sys}] -min -add_delay [get_ports {gpio27_io}]
set_output_delay 4.1100 -clock [get_clocks {clk_sys}] -max -add_delay [get_ports {gpio27_io}]
set_output_delay 1.3700 -clock [get_clocks {clk_sys}] -min -add_delay [get_ports {gpio28_io}]
set_output_delay 4.1100 -clock [get_clocks {clk_sys}] -max -add_delay [get_ports {gpio28_io}]
set_output_delay 1.3700 -clock [get_clocks {clk_sys}] -min -add_delay [get_ports {gpio29_io}]
set_output_delay 4.1100 -clock [get_clocks {clk_sys}] -max -add_delay [get_ports {gpio29_io}]
set_output_delay 1.3700 -clock [get_clocks {clk_sys}] -min -add_delay [get_ports {gpio2_io}]
set_output_delay 4.1100 -clock [get_clocks {clk_sys}] -max -add_delay [get_ports {gpio2_io}]
set_output_delay 1.3700 -clock [get_clocks {clk_sys}] -min -add_delay [get_ports {gpio30_io}]
set_output_delay 4.1100 -clock [get_clocks {clk_sys}] -max -add_delay [get_ports {gpio30_io}]
set_output_delay 1.3700 -clock [get_clocks {clk_sys}] -min -add_delay [get_ports {gpio31_io}]
set_output_delay 4.1100 -clock [get_clocks {clk_sys}] -max -add_delay [get_ports {gpio31_io}]
set_output_delay 1.3700 -clock [get_clocks {clk_sys}] -min -add_delay [get_ports {gpio3_io}]
set_output_delay 4.1100 -clock [get_clocks {clk_sys}] -max -add_delay [get_ports {gpio3_io}]
set_output_delay 1.3700 -clock [get_clocks {clk_sys}] -min -add_delay [get_ports {gpio4_io}]
set_output_delay 4.1100 -clock [get_clocks {clk_sys}] -max -add_delay [get_ports {gpio4_io}]
set_output_delay 1.3700 -clock [get_clocks {clk_sys}] -min -add_delay [get_ports {gpio5_io}]
set_output_delay 4.1100 -clock [get_clocks {clk_sys}] -max -add_delay [get_ports {gpio5_io}]
set_output_delay 1.3700 -clock [get_clocks {clk_sys}] -min -add_delay [get_ports {gpio6_io}]
set_output_delay 4.1100 -clock [get_clocks {clk_sys}] -max -add_delay [get_ports {gpio6_io}]
set_output_delay 1.3700 -clock [get_clocks {clk_sys}] -min -add_delay [get_ports {gpio7_io}]
set_output_delay 4.1100 -clock [get_clocks {clk_sys}] -max -add_delay [get_ports {gpio7_io}]
set_output_delay 1.3700 -clock [get_clocks {clk_sys}] -min -add_delay [get_ports {gpio8_io}]
set_output_delay 4.1100 -clock [get_clocks {clk_sys}] -max -add_delay [get_ports {gpio8_io}]
set_output_delay 1.3700 -clock [get_clocks {clk_sys}] -min -add_delay [get_ports {gpio9_io}]
set_output_delay 4.1100 -clock [get_clocks {clk_sys}] -max -add_delay [get_ports {gpio9_io}]
set_output_delay 2.5000 -clock [get_clocks {clk_jtg}] -min -add_delay [get_ports {jtag_tdo_o}]
set_output_delay 5.0000 -clock [get_clocks {clk_jtg}] -max -add_delay [get_ports {jtag_tdo_o}]
set_output_delay 1.3700 -clock [get_clocks {clk_sys}] -add_delay [get_ports {status_o}]
set_output_delay 1.3700 -clock [get_clocks {clk_sys}] -min -add_delay [get_ports {uart_tx_o}]
set_output_delay 4.1100 -clock [get_clocks {clk_sys}] -max -add_delay [get_ports {uart_tx_o}]
set_output_delay 1.3700 -clock [get_clocks {clk_sys}] -add_delay [get_ports {unused0_o}]
set_output_delay 1.3700 -clock [get_clocks {clk_sys}] -add_delay [get_ports {unused1_o}]
set_output_delay 1.3700 -clock [get_clocks {clk_sys}] -add_delay [get_ports {unused2_o}]
set_output_delay 1.3700 -clock [get_clocks {clk_sys}] -add_delay [get_ports {unused3_o}]
set_max_delay -ignore_clock_latency\
    -from [list [get_cells {i_croc_soc/i_croc/i_dmi_jtag/i_dmi_cdc.i_cdc_resp/i_cdc_reset_ctrlr/i_cdc_reset_ctrlr_half_a/i_state_transition_cdc_dst/async_ack_o_reg}]\
           [get_cells {i_croc_soc/i_croc/i_dmi_jtag/i_dmi_cdc.i_cdc_resp/i_cdc_reset_ctrlr/i_cdc_reset_ctrlr_half_a/i_state_transition_cdc_src/async_data_o[0]_reg}]\
           [get_cells {i_croc_soc/i_croc/i_dmi_jtag/i_dmi_cdc.i_cdc_resp/i_cdc_reset_ctrlr/i_cdc_reset_ctrlr_half_a/i_state_transition_cdc_src/async_data_o[1]_reg}]\
           [get_cells {i_croc_soc/i_croc/i_dmi_jtag/i_dmi_cdc.i_cdc_resp/i_cdc_reset_ctrlr/i_cdc_reset_ctrlr_half_a/i_state_transition_cdc_src/async_req_o_reg}]\
           [get_cells {i_croc_soc/i_croc/i_dmi_jtag/i_dmi_cdc.i_cdc_resp/i_cdc_reset_ctrlr/i_cdc_reset_ctrlr_half_b/i_state_transition_cdc_dst/async_ack_o_reg}]\
           [get_cells {i_croc_soc/i_croc/i_dmi_jtag/i_dmi_cdc.i_cdc_resp/i_cdc_reset_ctrlr/i_cdc_reset_ctrlr_half_b/i_state_transition_cdc_src/async_data_o[0]_reg}]\
           [get_cells {i_croc_soc/i_croc/i_dmi_jtag/i_dmi_cdc.i_cdc_resp/i_cdc_reset_ctrlr/i_cdc_reset_ctrlr_half_b/i_state_transition_cdc_src/async_data_o[1]_reg}]\
           [get_cells {i_croc_soc/i_croc/i_dmi_jtag/i_dmi_cdc.i_cdc_resp/i_cdc_reset_ctrlr/i_cdc_reset_ctrlr_half_b/i_state_transition_cdc_src/async_req_o_reg}]\
           [get_cells {i_croc_soc/i_croc/i_dmi_jtag/i_dmi_cdc.i_cdc_resp/i_dst/async_ack_o_reg}]\
           [get_cells {i_croc_soc/i_croc/i_dmi_jtag/i_dmi_cdc.i_cdc_resp/i_src/async_data_o[0]_reg}]\
           [get_cells {i_croc_soc/i_croc/i_dmi_jtag/i_dmi_cdc.i_cdc_resp/i_src/async_data_o[10]_reg}]\
           [get_cells {i_croc_soc/i_croc/i_dmi_jtag/i_dmi_cdc.i_cdc_resp/i_src/async_data_o[11]_reg}]\
           [get_cells {i_croc_soc/i_croc/i_dmi_jtag/i_dmi_cdc.i_cdc_resp/i_src/async_data_o[12]_reg}]\
           [get_cells {i_croc_soc/i_croc/i_dmi_jtag/i_dmi_cdc.i_cdc_resp/i_src/async_data_o[13]_reg}]\
           [get_cells {i_croc_soc/i_croc/i_dmi_jtag/i_dmi_cdc.i_cdc_resp/i_src/async_data_o[14]_reg}]\
           [get_cells {i_croc_soc/i_croc/i_dmi_jtag/i_dmi_cdc.i_cdc_resp/i_src/async_data_o[15]_reg}]\
           [get_cells {i_croc_soc/i_croc/i_dmi_jtag/i_dmi_cdc.i_cdc_resp/i_src/async_data_o[16]_reg}]\
           [get_cells {i_croc_soc/i_croc/i_dmi_jtag/i_dmi_cdc.i_cdc_resp/i_src/async_data_o[17]_reg}]\
           [get_cells {i_croc_soc/i_croc/i_dmi_jtag/i_dmi_cdc.i_cdc_resp/i_src/async_data_o[18]_reg}]\
           [get_cells {i_croc_soc/i_croc/i_dmi_jtag/i_dmi_cdc.i_cdc_resp/i_src/async_data_o[19]_reg}]\
           [get_cells {i_croc_soc/i_croc/i_dmi_jtag/i_dmi_cdc.i_cdc_resp/i_src/async_data_o[1]_reg}]\
           [get_cells {i_croc_soc/i_croc/i_dmi_jtag/i_dmi_cdc.i_cdc_resp/i_src/async_data_o[20]_reg}]\
           [get_cells {i_croc_soc/i_croc/i_dmi_jtag/i_dmi_cdc.i_cdc_resp/i_src/async_data_o[21]_reg}]\
           [get_cells {i_croc_soc/i_croc/i_dmi_jtag/i_dmi_cdc.i_cdc_resp/i_src/async_data_o[22]_reg}]\
           [get_cells {i_croc_soc/i_croc/i_dmi_jtag/i_dmi_cdc.i_cdc_resp/i_src/async_data_o[23]_reg}]\
           [get_cells {i_croc_soc/i_croc/i_dmi_jtag/i_dmi_cdc.i_cdc_resp/i_src/async_data_o[24]_reg}]\
           [get_cells {i_croc_soc/i_croc/i_dmi_jtag/i_dmi_cdc.i_cdc_resp/i_src/async_data_o[25]_reg}]\
           [get_cells {i_croc_soc/i_croc/i_dmi_jtag/i_dmi_cdc.i_cdc_resp/i_src/async_data_o[26]_reg}]\
           [get_cells {i_croc_soc/i_croc/i_dmi_jtag/i_dmi_cdc.i_cdc_resp/i_src/async_data_o[27]_reg}]\
           [get_cells {i_croc_soc/i_croc/i_dmi_jtag/i_dmi_cdc.i_cdc_resp/i_src/async_data_o[28]_reg}]\
           [get_cells {i_croc_soc/i_croc/i_dmi_jtag/i_dmi_cdc.i_cdc_resp/i_src/async_data_o[29]_reg}]\
           [get_cells {i_croc_soc/i_croc/i_dmi_jtag/i_dmi_cdc.i_cdc_resp/i_src/async_data_o[2]_reg}]\
           [get_cells {i_croc_soc/i_croc/i_dmi_jtag/i_dmi_cdc.i_cdc_resp/i_src/async_data_o[30]_reg}]\
           [get_cells {i_croc_soc/i_croc/i_dmi_jtag/i_dmi_cdc.i_cdc_resp/i_src/async_data_o[31]_reg}]\
           [get_cells {i_croc_soc/i_croc/i_dmi_jtag/i_dmi_cdc.i_cdc_resp/i_src/async_data_o[32]_reg}]\
           [get_cells {i_croc_soc/i_croc/i_dmi_jtag/i_dmi_cdc.i_cdc_resp/i_src/async_data_o[33]_reg}]\
           [get_cells {i_croc_soc/i_croc/i_dmi_jtag/i_dmi_cdc.i_cdc_resp/i_src/async_data_o[3]_reg}]\
           [get_cells {i_croc_soc/i_croc/i_dmi_jtag/i_dmi_cdc.i_cdc_resp/i_src/async_data_o[4]_reg}]\
           [get_cells {i_croc_soc/i_croc/i_dmi_jtag/i_dmi_cdc.i_cdc_resp/i_src/async_data_o[5]_reg}]\
           [get_cells {i_croc_soc/i_croc/i_dmi_jtag/i_dmi_cdc.i_cdc_resp/i_src/async_data_o[6]_reg}]\
           [get_cells {i_croc_soc/i_croc/i_dmi_jtag/i_dmi_cdc.i_cdc_resp/i_src/async_data_o[7]_reg}]\
           [get_cells {i_croc_soc/i_croc/i_dmi_jtag/i_dmi_cdc.i_cdc_resp/i_src/async_data_o[8]_reg}]\
           [get_cells {i_croc_soc/i_croc/i_dmi_jtag/i_dmi_cdc.i_cdc_resp/i_src/async_data_o[9]_reg}]\
           [get_cells {i_croc_soc/i_croc/i_dmi_jtag/i_dmi_cdc.i_cdc_resp/i_src/async_req_o_reg}]]\
    -to [list [get_cells {i_croc_soc/i_croc/i_dmi_jtag/data_q_0__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dmi_jtag/data_q_10__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dmi_jtag/data_q_11__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dmi_jtag/data_q_12__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dmi_jtag/data_q_13__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dmi_jtag/data_q_14__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dmi_jtag/data_q_15__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dmi_jtag/data_q_16__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dmi_jtag/data_q_17__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dmi_jtag/data_q_18__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dmi_jtag/data_q_19__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dmi_jtag/data_q_1__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dmi_jtag/data_q_20__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dmi_jtag/data_q_21__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dmi_jtag/data_q_22__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dmi_jtag/data_q_23__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dmi_jtag/data_q_24__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dmi_jtag/data_q_25__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dmi_jtag/data_q_26__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dmi_jtag/data_q_27__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dmi_jtag/data_q_28__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dmi_jtag/data_q_29__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dmi_jtag/data_q_2__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dmi_jtag/data_q_30__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dmi_jtag/data_q_31__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dmi_jtag/data_q_3__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dmi_jtag/data_q_4__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dmi_jtag/data_q_5__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dmi_jtag/data_q_6__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dmi_jtag/data_q_7__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dmi_jtag/data_q_8__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dmi_jtag/data_q_9__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dmi_jtag/dmi_10__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dmi_jtag/dmi_11__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dmi_jtag/dmi_12__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dmi_jtag/dmi_13__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dmi_jtag/dmi_14__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dmi_jtag/dmi_15__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dmi_jtag/dmi_16__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dmi_jtag/dmi_17__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dmi_jtag/dmi_18__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dmi_jtag/dmi_19__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dmi_jtag/dmi_1__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dmi_jtag/dmi_20__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dmi_jtag/dmi_21__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dmi_jtag/dmi_22__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dmi_jtag/dmi_23__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dmi_jtag/dmi_24__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dmi_jtag/dmi_25__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dmi_jtag/dmi_26__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dmi_jtag/dmi_27__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dmi_jtag/dmi_28__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dmi_jtag/dmi_29__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dmi_jtag/dmi_2__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dmi_jtag/dmi_30__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dmi_jtag/dmi_31__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dmi_jtag/dmi_32__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dmi_jtag/dmi_33__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dmi_jtag/dmi_34__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dmi_jtag/dmi_35__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dmi_jtag/dmi_36__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dmi_jtag/dmi_37__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dmi_jtag/dmi_38__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dmi_jtag/dmi_39__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dmi_jtag/dmi_3__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dmi_jtag/dmi_40__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dmi_jtag/dmi_4__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dmi_jtag/dmi_5__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dmi_jtag/dmi_6__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dmi_jtag/dmi_7__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dmi_jtag/dmi_8__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dmi_jtag/dmi_9__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dmi_jtag/error_q_0__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dmi_jtag/error_q_1__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dmi_jtag/i_dmi_cdc.i_cdc_resp/i_cdc_reset_ctrlr/i_cdc_reset_ctrlr_half_a/i_state_transition_cdc_src/_20_}]\
           [get_cells {i_croc_soc/i_croc/i_dmi_jtag/i_dmi_cdc.i_cdc_resp/i_cdc_reset_ctrlr/i_cdc_reset_ctrlr_half_a/i_state_transition_cdc_src/_21_}]\
           [get_cells {i_croc_soc/i_croc/i_dmi_jtag/i_dmi_cdc.i_cdc_resp/i_cdc_reset_ctrlr/i_cdc_reset_ctrlr_half_a/i_state_transition_cdc_src/async_data_o[0]_reg}]\
           [get_cells {i_croc_soc/i_croc/i_dmi_jtag/i_dmi_cdc.i_cdc_resp/i_cdc_reset_ctrlr/i_cdc_reset_ctrlr_half_a/i_state_transition_cdc_src/async_data_o[1]_reg}]\
           [get_cells {i_croc_soc/i_croc/i_dmi_jtag/i_dmi_cdc.i_cdc_resp/i_cdc_reset_ctrlr/i_cdc_reset_ctrlr_half_b/i_state_transition_cdc_dst/async_ack_o_reg}]\
           [get_cells {i_croc_soc/i_croc/i_dmi_jtag/i_dmi_cdc.i_cdc_resp/i_cdc_reset_ctrlr/i_cdc_reset_ctrlr_half_b/i_state_transition_cdc_dst/state_q_0__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dmi_jtag/i_dmi_cdc.i_cdc_resp/i_cdc_reset_ctrlr/i_cdc_reset_ctrlr_half_b/i_state_transition_cdc_dst/state_q_1__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dmi_jtag/i_dmi_cdc.i_cdc_resp/i_cdc_reset_ctrlr/i_cdc_reset_ctrlr_half_b/receiver_phase_q_0__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dmi_jtag/i_dmi_cdc.i_cdc_resp/i_cdc_reset_ctrlr/i_cdc_reset_ctrlr_half_b/receiver_phase_q_1__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dmi_jtag/i_dmi_cdc.i_cdc_resp/i_dst/_046_}]\
           [get_cells {i_croc_soc/i_croc/i_dmi_jtag/i_dmi_cdc.i_cdc_resp/i_dst/_054_}]\
           [get_cells {i_croc_soc/i_croc/i_dmi_jtag/i_dmi_cdc.i_cdc_resp/i_dst/_055_}]\
           [get_cells {i_croc_soc/i_croc/i_dmi_jtag/i_dmi_cdc.i_cdc_resp/i_dst/_056_}]\
           [get_cells {i_croc_soc/i_croc/i_dmi_jtag/i_dmi_cdc.i_cdc_resp/i_dst/_057_}]\
           [get_cells {i_croc_soc/i_croc/i_dmi_jtag/i_dmi_cdc.i_cdc_resp/i_dst/_058_}]\
           [get_cells {i_croc_soc/i_croc/i_dmi_jtag/i_dmi_cdc.i_cdc_resp/i_dst/_059_}]\
           [get_cells {i_croc_soc/i_croc/i_dmi_jtag/i_dmi_cdc.i_cdc_resp/i_dst/_060_}]\
           [get_cells {i_croc_soc/i_croc/i_dmi_jtag/i_dmi_cdc.i_cdc_resp/i_dst/_061_}]\
           [get_cells {i_croc_soc/i_croc/i_dmi_jtag/i_dmi_cdc.i_cdc_resp/i_dst/_062_}]\
           [get_cells {i_croc_soc/i_croc/i_dmi_jtag/i_dmi_cdc.i_cdc_resp/i_dst/_063_}]\
           [get_cells {i_croc_soc/i_croc/i_dmi_jtag/i_dmi_cdc.i_cdc_resp/i_dst/_065_}]\
           [get_cells {i_croc_soc/i_croc/i_dmi_jtag/i_dmi_cdc.i_cdc_resp/i_dst/_066_}]\
           [get_cells {i_croc_soc/i_croc/i_dmi_jtag/i_dmi_cdc.i_cdc_resp/i_dst/_067_}]\
           [get_cells {i_croc_soc/i_croc/i_dmi_jtag/i_dmi_cdc.i_cdc_resp/i_dst/_068_}]\
           [get_cells {i_croc_soc/i_croc/i_dmi_jtag/i_dmi_cdc.i_cdc_resp/i_dst/_069_}]\
           [get_cells {i_croc_soc/i_croc/i_dmi_jtag/i_dmi_cdc.i_cdc_resp/i_dst/_070_}]\
           [get_cells {i_croc_soc/i_croc/i_dmi_jtag/i_dmi_cdc.i_cdc_resp/i_dst/_071_}]\
           [get_cells {i_croc_soc/i_croc/i_dmi_jtag/i_dmi_cdc.i_cdc_resp/i_dst/_072_}]\
           [get_cells {i_croc_soc/i_croc/i_dmi_jtag/i_dmi_cdc.i_cdc_resp/i_dst/_073_}]\
           [get_cells {i_croc_soc/i_croc/i_dmi_jtag/i_dmi_cdc.i_cdc_resp/i_dst/_074_}]\
           [get_cells {i_croc_soc/i_croc/i_dmi_jtag/i_dmi_cdc.i_cdc_resp/i_dst/_076_}]\
           [get_cells {i_croc_soc/i_croc/i_dmi_jtag/i_dmi_cdc.i_cdc_resp/i_dst/_077_}]\
           [get_cells {i_croc_soc/i_croc/i_dmi_jtag/i_dmi_cdc.i_cdc_resp/i_dst/_078_}]\
           [get_cells {i_croc_soc/i_croc/i_dmi_jtag/i_dmi_cdc.i_cdc_resp/i_dst/_079_}]\
           [get_cells {i_croc_soc/i_croc/i_dmi_jtag/i_dmi_cdc.i_cdc_resp/i_dst/_080_}]\
           [get_cells {i_croc_soc/i_croc/i_dmi_jtag/i_dmi_cdc.i_cdc_resp/i_dst/_081_}]\
           [get_cells {i_croc_soc/i_croc/i_dmi_jtag/i_dmi_cdc.i_cdc_resp/i_dst/_082_}]\
           [get_cells {i_croc_soc/i_croc/i_dmi_jtag/i_dmi_cdc.i_cdc_resp/i_dst/_083_}]\
           [get_cells {i_croc_soc/i_croc/i_dmi_jtag/i_dmi_cdc.i_cdc_resp/i_dst/_084_}]\
           [get_cells {i_croc_soc/i_croc/i_dmi_jtag/i_dmi_cdc.i_cdc_resp/i_dst/_085_}]\
           [get_cells {i_croc_soc/i_croc/i_dmi_jtag/i_dmi_cdc.i_cdc_resp/i_dst/_087_}]\
           [get_cells {i_croc_soc/i_croc/i_dmi_jtag/i_dmi_cdc.i_cdc_resp/i_dst/_088_}]\
           [get_cells {i_croc_soc/i_croc/i_dmi_jtag/i_dmi_cdc.i_cdc_resp/i_dst/_089_}]\
           [get_cells {i_croc_soc/i_croc/i_dmi_jtag/i_dmi_cdc.i_cdc_resp/i_dst/_090_}]\
           [get_cells {i_croc_soc/i_croc/i_dmi_jtag/i_dmi_cdc.i_cdc_resp/i_dst/async_ack_o_reg}]\
           [get_cells {i_croc_soc/i_croc/i_dmi_jtag/i_dmi_cdc.i_cdc_resp/s_dst_clear_ack_q_reg}]\
           [get_cells {i_croc_soc/i_croc/i_dmi_jtag/i_dmi_cdc.i_cdc_resp/s_dst_isolate_ack_q_reg}]\
           [get_cells {i_croc_soc/i_croc/i_dmi_jtag/i_dmi_jtag_tap.dmi_tdo_i_reg}]\
           [get_cells {i_croc_soc/i_croc/i_dmi_jtag/state_q_0__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dmi_jtag/state_q_1__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dmi_jtag/state_q_2__reg}]] 3.0000
set_max_delay -ignore_clock_latency\
    -from [list [get_cells {i_croc_soc/i_croc/i_dmi_jtag/i_dmi_cdc.i_cdc_req/i_cdc_reset_ctrlr/i_cdc_reset_ctrlr_half_a/i_state_transition_cdc_dst/async_ack_o_reg}]\
           [get_cells {i_croc_soc/i_croc/i_dmi_jtag/i_dmi_cdc.i_cdc_req/i_cdc_reset_ctrlr/i_cdc_reset_ctrlr_half_a/i_state_transition_cdc_src/async_data_o[0]_reg}]\
           [get_cells {i_croc_soc/i_croc/i_dmi_jtag/i_dmi_cdc.i_cdc_req/i_cdc_reset_ctrlr/i_cdc_reset_ctrlr_half_a/i_state_transition_cdc_src/async_data_o[1]_reg}]\
           [get_cells {i_croc_soc/i_croc/i_dmi_jtag/i_dmi_cdc.i_cdc_req/i_cdc_reset_ctrlr/i_cdc_reset_ctrlr_half_a/i_state_transition_cdc_src/async_req_o_reg}]\
           [get_cells {i_croc_soc/i_croc/i_dmi_jtag/i_dmi_cdc.i_cdc_req/i_cdc_reset_ctrlr/i_cdc_reset_ctrlr_half_b/i_state_transition_cdc_dst/async_ack_o_reg}]\
           [get_cells {i_croc_soc/i_croc/i_dmi_jtag/i_dmi_cdc.i_cdc_req/i_cdc_reset_ctrlr/i_cdc_reset_ctrlr_half_b/i_state_transition_cdc_src/async_data_o[0]_reg}]\
           [get_cells {i_croc_soc/i_croc/i_dmi_jtag/i_dmi_cdc.i_cdc_req/i_cdc_reset_ctrlr/i_cdc_reset_ctrlr_half_b/i_state_transition_cdc_src/async_data_o[1]_reg}]\
           [get_cells {i_croc_soc/i_croc/i_dmi_jtag/i_dmi_cdc.i_cdc_req/i_cdc_reset_ctrlr/i_cdc_reset_ctrlr_half_b/i_state_transition_cdc_src/async_req_o_reg}]\
           [get_cells {i_croc_soc/i_croc/i_dmi_jtag/i_dmi_cdc.i_cdc_req/i_dst/async_ack_o_reg}]\
           [get_cells {i_croc_soc/i_croc/i_dmi_jtag/i_dmi_cdc.i_cdc_req/i_src/async_data_o[0]_reg}]\
           [get_cells {i_croc_soc/i_croc/i_dmi_jtag/i_dmi_cdc.i_cdc_req/i_src/async_data_o[10]_reg}]\
           [get_cells {i_croc_soc/i_croc/i_dmi_jtag/i_dmi_cdc.i_cdc_req/i_src/async_data_o[11]_reg}]\
           [get_cells {i_croc_soc/i_croc/i_dmi_jtag/i_dmi_cdc.i_cdc_req/i_src/async_data_o[12]_reg}]\
           [get_cells {i_croc_soc/i_croc/i_dmi_jtag/i_dmi_cdc.i_cdc_req/i_src/async_data_o[13]_reg}]\
           [get_cells {i_croc_soc/i_croc/i_dmi_jtag/i_dmi_cdc.i_cdc_req/i_src/async_data_o[14]_reg}]\
           [get_cells {i_croc_soc/i_croc/i_dmi_jtag/i_dmi_cdc.i_cdc_req/i_src/async_data_o[15]_reg}]\
           [get_cells {i_croc_soc/i_croc/i_dmi_jtag/i_dmi_cdc.i_cdc_req/i_src/async_data_o[16]_reg}]\
           [get_cells {i_croc_soc/i_croc/i_dmi_jtag/i_dmi_cdc.i_cdc_req/i_src/async_data_o[17]_reg}]\
           [get_cells {i_croc_soc/i_croc/i_dmi_jtag/i_dmi_cdc.i_cdc_req/i_src/async_data_o[18]_reg}]\
           [get_cells {i_croc_soc/i_croc/i_dmi_jtag/i_dmi_cdc.i_cdc_req/i_src/async_data_o[19]_reg}]\
           [get_cells {i_croc_soc/i_croc/i_dmi_jtag/i_dmi_cdc.i_cdc_req/i_src/async_data_o[1]_reg}]\
           [get_cells {i_croc_soc/i_croc/i_dmi_jtag/i_dmi_cdc.i_cdc_req/i_src/async_data_o[20]_reg}]\
           [get_cells {i_croc_soc/i_croc/i_dmi_jtag/i_dmi_cdc.i_cdc_req/i_src/async_data_o[21]_reg}]\
           [get_cells {i_croc_soc/i_croc/i_dmi_jtag/i_dmi_cdc.i_cdc_req/i_src/async_data_o[22]_reg}]\
           [get_cells {i_croc_soc/i_croc/i_dmi_jtag/i_dmi_cdc.i_cdc_req/i_src/async_data_o[23]_reg}]\
           [get_cells {i_croc_soc/i_croc/i_dmi_jtag/i_dmi_cdc.i_cdc_req/i_src/async_data_o[24]_reg}]\
           [get_cells {i_croc_soc/i_croc/i_dmi_jtag/i_dmi_cdc.i_cdc_req/i_src/async_data_o[25]_reg}]\
           [get_cells {i_croc_soc/i_croc/i_dmi_jtag/i_dmi_cdc.i_cdc_req/i_src/async_data_o[26]_reg}]\
           [get_cells {i_croc_soc/i_croc/i_dmi_jtag/i_dmi_cdc.i_cdc_req/i_src/async_data_o[27]_reg}]\
           [get_cells {i_croc_soc/i_croc/i_dmi_jtag/i_dmi_cdc.i_cdc_req/i_src/async_data_o[28]_reg}]\
           [get_cells {i_croc_soc/i_croc/i_dmi_jtag/i_dmi_cdc.i_cdc_req/i_src/async_data_o[29]_reg}]\
           [get_cells {i_croc_soc/i_croc/i_dmi_jtag/i_dmi_cdc.i_cdc_req/i_src/async_data_o[2]_reg}]\
           [get_cells {i_croc_soc/i_croc/i_dmi_jtag/i_dmi_cdc.i_cdc_req/i_src/async_data_o[30]_reg}]\
           [get_cells {i_croc_soc/i_croc/i_dmi_jtag/i_dmi_cdc.i_cdc_req/i_src/async_data_o[31]_reg}]\
           [get_cells {i_croc_soc/i_croc/i_dmi_jtag/i_dmi_cdc.i_cdc_req/i_src/async_data_o[32]_reg}]\
           [get_cells {i_croc_soc/i_croc/i_dmi_jtag/i_dmi_cdc.i_cdc_req/i_src/async_data_o[33]_reg}]\
           [get_cells {i_croc_soc/i_croc/i_dmi_jtag/i_dmi_cdc.i_cdc_req/i_src/async_data_o[34]_reg}]\
           [get_cells {i_croc_soc/i_croc/i_dmi_jtag/i_dmi_cdc.i_cdc_req/i_src/async_data_o[35]_reg}]\
           [get_cells {i_croc_soc/i_croc/i_dmi_jtag/i_dmi_cdc.i_cdc_req/i_src/async_data_o[36]_reg}]\
           [get_cells {i_croc_soc/i_croc/i_dmi_jtag/i_dmi_cdc.i_cdc_req/i_src/async_data_o[37]_reg}]\
           [get_cells {i_croc_soc/i_croc/i_dmi_jtag/i_dmi_cdc.i_cdc_req/i_src/async_data_o[38]_reg}]\
           [get_cells {i_croc_soc/i_croc/i_dmi_jtag/i_dmi_cdc.i_cdc_req/i_src/async_data_o[39]_reg}]\
           [get_cells {i_croc_soc/i_croc/i_dmi_jtag/i_dmi_cdc.i_cdc_req/i_src/async_data_o[3]_reg}]\
           [get_cells {i_croc_soc/i_croc/i_dmi_jtag/i_dmi_cdc.i_cdc_req/i_src/async_data_o[40]_reg}]\
           [get_cells {i_croc_soc/i_croc/i_dmi_jtag/i_dmi_cdc.i_cdc_req/i_src/async_data_o[4]_reg}]\
           [get_cells {i_croc_soc/i_croc/i_dmi_jtag/i_dmi_cdc.i_cdc_req/i_src/async_data_o[5]_reg}]\
           [get_cells {i_croc_soc/i_croc/i_dmi_jtag/i_dmi_cdc.i_cdc_req/i_src/async_data_o[6]_reg}]\
           [get_cells {i_croc_soc/i_croc/i_dmi_jtag/i_dmi_cdc.i_cdc_req/i_src/async_data_o[7]_reg}]\
           [get_cells {i_croc_soc/i_croc/i_dmi_jtag/i_dmi_cdc.i_cdc_req/i_src/async_data_o[8]_reg}]\
           [get_cells {i_croc_soc/i_croc/i_dmi_jtag/i_dmi_cdc.i_cdc_req/i_src/async_data_o[9]_reg}]\
           [get_cells {i_croc_soc/i_croc/i_dmi_jtag/i_dmi_cdc.i_cdc_req/i_src/async_req_o_reg}]]\
    -to [list [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/cmd_0__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/cmd_10__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/cmd_11__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/cmd_12__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/cmd_14__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/cmd_15__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/cmd_16__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/cmd_17__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/cmd_18__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/cmd_19__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/cmd_1__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/cmd_20__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/cmd_21__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/cmd_22__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/cmd_24__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/cmd_25__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/cmd_26__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/cmd_27__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/cmd_28__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/cmd_29__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/cmd_2__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/cmd_30__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/cmd_31__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/cmd_3__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/cmd_4__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/cmd_5__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/cmd_6__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/cmd_7__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/cmd_8__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/cmd_9__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/cmd_valid_reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/data_csrs_mem_0__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/data_csrs_mem_10__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/data_csrs_mem_11__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/data_csrs_mem_12__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/data_csrs_mem_13__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/data_csrs_mem_14__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/data_csrs_mem_15__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/data_csrs_mem_16__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/data_csrs_mem_17__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/data_csrs_mem_18__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/data_csrs_mem_19__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/data_csrs_mem_1__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/data_csrs_mem_20__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/data_csrs_mem_21__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/data_csrs_mem_22__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/data_csrs_mem_23__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/data_csrs_mem_24__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/data_csrs_mem_25__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/data_csrs_mem_26__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/data_csrs_mem_27__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/data_csrs_mem_28__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/data_csrs_mem_29__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/data_csrs_mem_2__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/data_csrs_mem_30__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/data_csrs_mem_31__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/data_csrs_mem_32__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/data_csrs_mem_33__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/data_csrs_mem_34__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/data_csrs_mem_35__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/data_csrs_mem_36__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/data_csrs_mem_37__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/data_csrs_mem_38__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/data_csrs_mem_39__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/data_csrs_mem_3__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/data_csrs_mem_40__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/data_csrs_mem_41__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/data_csrs_mem_42__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/data_csrs_mem_43__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/data_csrs_mem_44__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/data_csrs_mem_45__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/data_csrs_mem_46__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/data_csrs_mem_47__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/data_csrs_mem_48__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/data_csrs_mem_49__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/data_csrs_mem_4__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/data_csrs_mem_50__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/data_csrs_mem_51__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/data_csrs_mem_52__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/data_csrs_mem_53__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/data_csrs_mem_54__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/data_csrs_mem_55__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/data_csrs_mem_56__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/data_csrs_mem_57__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/data_csrs_mem_58__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/data_csrs_mem_59__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/data_csrs_mem_5__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/data_csrs_mem_60__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/data_csrs_mem_61__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/data_csrs_mem_62__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/data_csrs_mem_63__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/data_csrs_mem_6__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/data_csrs_mem_7__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/data_csrs_mem_8__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/data_csrs_mem_9__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/debug_req_o_reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/dmactive_o_reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.abstractauto_q_0__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.abstractauto_q_16__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.abstractauto_q_17__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.abstractauto_q_18__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.abstractauto_q_19__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.abstractauto_q_1__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.abstractauto_q_20__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.abstractauto_q_21__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.abstractauto_q_22__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.abstractauto_q_23__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.cmderr_q_0__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.cmderr_q_1__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.cmderr_q_2__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.havereset_q_reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.i_fifo.mem_q_0__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.i_fifo.mem_q_10__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.i_fifo.mem_q_11__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.i_fifo.mem_q_12__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.i_fifo.mem_q_13__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.i_fifo.mem_q_14__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.i_fifo.mem_q_15__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.i_fifo.mem_q_16__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.i_fifo.mem_q_17__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.i_fifo.mem_q_18__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.i_fifo.mem_q_19__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.i_fifo.mem_q_1__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.i_fifo.mem_q_20__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.i_fifo.mem_q_21__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.i_fifo.mem_q_22__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.i_fifo.mem_q_23__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.i_fifo.mem_q_24__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.i_fifo.mem_q_25__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.i_fifo.mem_q_26__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.i_fifo.mem_q_27__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.i_fifo.mem_q_28__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.i_fifo.mem_q_29__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.i_fifo.mem_q_2__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.i_fifo.mem_q_30__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.i_fifo.mem_q_31__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.i_fifo.mem_q_32__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.i_fifo.mem_q_33__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.i_fifo.mem_q_34__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.i_fifo.mem_q_35__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.i_fifo.mem_q_36__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.i_fifo.mem_q_37__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.i_fifo.mem_q_38__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.i_fifo.mem_q_39__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.i_fifo.mem_q_3__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.i_fifo.mem_q_40__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.i_fifo.mem_q_41__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.i_fifo.mem_q_42__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.i_fifo.mem_q_43__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.i_fifo.mem_q_44__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.i_fifo.mem_q_45__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.i_fifo.mem_q_46__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.i_fifo.mem_q_47__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.i_fifo.mem_q_48__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.i_fifo.mem_q_49__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.i_fifo.mem_q_4__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.i_fifo.mem_q_50__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.i_fifo.mem_q_51__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.i_fifo.mem_q_52__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.i_fifo.mem_q_53__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.i_fifo.mem_q_54__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.i_fifo.mem_q_55__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.i_fifo.mem_q_56__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.i_fifo.mem_q_57__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.i_fifo.mem_q_58__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.i_fifo.mem_q_59__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.i_fifo.mem_q_5__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.i_fifo.mem_q_60__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.i_fifo.mem_q_61__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.i_fifo.mem_q_62__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.i_fifo.mem_q_63__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.i_fifo.mem_q_64__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.i_fifo.mem_q_65__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.i_fifo.mem_q_66__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.i_fifo.mem_q_67__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.i_fifo.mem_q_6__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.i_fifo.mem_q_7__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.i_fifo.mem_q_8__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.i_fifo.mem_q_9__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.i_fifo.status_cnt_q_1__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.i_fifo.usage_o_reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.i_fifo.write_pointer_q_reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.progbuf_o_0__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.progbuf_o_100__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.progbuf_o_101__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.progbuf_o_102__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.progbuf_o_103__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.progbuf_o_104__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.progbuf_o_105__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.progbuf_o_106__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.progbuf_o_107__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.progbuf_o_108__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.progbuf_o_109__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.progbuf_o_10__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.progbuf_o_110__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.progbuf_o_111__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.progbuf_o_112__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.progbuf_o_113__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.progbuf_o_114__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.progbuf_o_115__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.progbuf_o_116__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.progbuf_o_117__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.progbuf_o_118__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.progbuf_o_119__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.progbuf_o_11__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.progbuf_o_120__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.progbuf_o_121__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.progbuf_o_122__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.progbuf_o_123__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.progbuf_o_124__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.progbuf_o_125__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.progbuf_o_126__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.progbuf_o_127__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.progbuf_o_128__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.progbuf_o_129__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.progbuf_o_12__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.progbuf_o_130__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.progbuf_o_131__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.progbuf_o_132__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.progbuf_o_133__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.progbuf_o_134__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.progbuf_o_135__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.progbuf_o_136__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.progbuf_o_137__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.progbuf_o_138__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.progbuf_o_139__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.progbuf_o_13__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.progbuf_o_140__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.progbuf_o_141__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.progbuf_o_142__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.progbuf_o_143__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.progbuf_o_144__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.progbuf_o_145__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.progbuf_o_146__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.progbuf_o_147__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.progbuf_o_148__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.progbuf_o_149__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.progbuf_o_14__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.progbuf_o_150__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.progbuf_o_151__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.progbuf_o_152__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.progbuf_o_153__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.progbuf_o_154__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.progbuf_o_155__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.progbuf_o_156__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.progbuf_o_157__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.progbuf_o_158__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.progbuf_o_159__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.progbuf_o_15__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.progbuf_o_160__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.progbuf_o_161__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.progbuf_o_162__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.progbuf_o_163__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.progbuf_o_164__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.progbuf_o_165__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.progbuf_o_166__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.progbuf_o_167__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.progbuf_o_168__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.progbuf_o_169__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.progbuf_o_16__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.progbuf_o_170__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.progbuf_o_171__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.progbuf_o_172__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.progbuf_o_173__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.progbuf_o_174__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.progbuf_o_175__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.progbuf_o_176__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.progbuf_o_177__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.progbuf_o_178__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.progbuf_o_179__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.progbuf_o_17__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.progbuf_o_180__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.progbuf_o_181__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.progbuf_o_182__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.progbuf_o_183__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.progbuf_o_184__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.progbuf_o_185__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.progbuf_o_186__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.progbuf_o_187__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.progbuf_o_188__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.progbuf_o_189__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.progbuf_o_18__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.progbuf_o_190__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.progbuf_o_191__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.progbuf_o_192__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.progbuf_o_193__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.progbuf_o_194__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.progbuf_o_195__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.progbuf_o_196__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.progbuf_o_197__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.progbuf_o_198__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.progbuf_o_199__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.progbuf_o_19__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.progbuf_o_1__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.progbuf_o_200__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.progbuf_o_201__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.progbuf_o_202__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.progbuf_o_203__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.progbuf_o_204__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.progbuf_o_205__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.progbuf_o_206__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.progbuf_o_207__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.progbuf_o_208__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.progbuf_o_209__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.progbuf_o_20__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.progbuf_o_210__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.progbuf_o_211__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.progbuf_o_212__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.progbuf_o_213__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.progbuf_o_214__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.progbuf_o_215__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.progbuf_o_216__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.progbuf_o_217__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.progbuf_o_218__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.progbuf_o_219__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.progbuf_o_21__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.progbuf_o_220__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.progbuf_o_221__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.progbuf_o_222__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.progbuf_o_223__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.progbuf_o_224__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.progbuf_o_225__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.progbuf_o_226__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.progbuf_o_227__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.progbuf_o_228__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.progbuf_o_229__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.progbuf_o_22__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.progbuf_o_230__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.progbuf_o_231__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.progbuf_o_232__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.progbuf_o_233__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.progbuf_o_234__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.progbuf_o_235__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.progbuf_o_236__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.progbuf_o_237__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.progbuf_o_238__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.progbuf_o_239__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.progbuf_o_23__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.progbuf_o_240__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.progbuf_o_241__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.progbuf_o_242__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.progbuf_o_243__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.progbuf_o_244__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.progbuf_o_245__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.progbuf_o_246__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.progbuf_o_247__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.progbuf_o_248__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.progbuf_o_249__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.progbuf_o_24__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.progbuf_o_250__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.progbuf_o_251__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.progbuf_o_252__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.progbuf_o_253__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.progbuf_o_254__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.progbuf_o_255__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.progbuf_o_25__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.progbuf_o_26__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.progbuf_o_27__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.progbuf_o_28__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.progbuf_o_29__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.progbuf_o_2__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.progbuf_o_30__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.progbuf_o_31__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.progbuf_o_32__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.progbuf_o_33__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.progbuf_o_34__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.progbuf_o_35__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.progbuf_o_36__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.progbuf_o_37__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.progbuf_o_38__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.progbuf_o_39__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.progbuf_o_3__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.progbuf_o_40__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.progbuf_o_41__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.progbuf_o_42__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.progbuf_o_43__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.progbuf_o_44__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.progbuf_o_45__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.progbuf_o_46__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.progbuf_o_47__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.progbuf_o_48__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.progbuf_o_49__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.progbuf_o_4__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.progbuf_o_50__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.progbuf_o_51__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.progbuf_o_52__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.progbuf_o_53__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.progbuf_o_54__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.progbuf_o_55__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.progbuf_o_56__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.progbuf_o_57__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.progbuf_o_58__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.progbuf_o_59__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.progbuf_o_5__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.progbuf_o_60__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.progbuf_o_61__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.progbuf_o_62__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.progbuf_o_63__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.progbuf_o_64__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.progbuf_o_65__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.progbuf_o_66__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.progbuf_o_67__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.progbuf_o_68__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.progbuf_o_69__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.progbuf_o_6__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.progbuf_o_70__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.progbuf_o_71__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.progbuf_o_72__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.progbuf_o_73__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.progbuf_o_74__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.progbuf_o_75__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.progbuf_o_76__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.progbuf_o_77__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.progbuf_o_78__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.progbuf_o_79__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.progbuf_o_7__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.progbuf_o_80__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.progbuf_o_81__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.progbuf_o_82__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.progbuf_o_83__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.progbuf_o_84__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.progbuf_o_85__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.progbuf_o_86__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.progbuf_o_87__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.progbuf_o_88__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.progbuf_o_89__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.progbuf_o_8__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.progbuf_o_90__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.progbuf_o_91__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.progbuf_o_92__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.progbuf_o_93__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.progbuf_o_94__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.progbuf_o_95__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.progbuf_o_96__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.progbuf_o_97__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.progbuf_o_98__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.progbuf_o_99__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.progbuf_o_9__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.resumeack_i_reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.resumereq_o_reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.sbaccess_o_0__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.sbaccess_o_1__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.sbaccess_o_2__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.sbaddr_q_32__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.sbaddr_q_33__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.sbaddr_q_34__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.sbaddr_q_35__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.sbaddr_q_36__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.sbaddr_q_37__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.sbaddr_q_38__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.sbaddr_q_39__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.sbaddr_q_40__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.sbaddr_q_41__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.sbaddr_q_42__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.sbaddr_q_43__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.sbaddr_q_44__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.sbaddr_q_45__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.sbaddr_q_46__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.sbaddr_q_47__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.sbaddr_q_48__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.sbaddr_q_49__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.sbaddr_q_50__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.sbaddr_q_51__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.sbaddr_q_52__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.sbaddr_q_53__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.sbaddr_q_54__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.sbaddr_q_55__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.sbaddr_q_56__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.sbaddr_q_57__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.sbaddr_q_58__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.sbaddr_q_59__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.sbaddr_q_60__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.sbaddr_q_61__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.sbaddr_q_62__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.sbaddr_q_63__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.sbautoincrement_o_reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.sbcs_q_12__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.sbcs_q_13__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.sbcs_q_14__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.sbcs_q_22__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.sbcs_q_23__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.sbcs_q_24__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.sbcs_q_25__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.sbcs_q_26__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.sbcs_q_27__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.sbcs_q_28__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.sbdata_o_0__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.sbdata_o_10__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.sbdata_o_11__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.sbdata_o_12__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.sbdata_o_13__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.sbdata_o_14__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.sbdata_o_15__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.sbdata_o_16__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.sbdata_o_17__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.sbdata_o_18__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.sbdata_o_19__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.sbdata_o_1__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.sbdata_o_20__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.sbdata_o_21__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.sbdata_o_22__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.sbdata_o_23__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.sbdata_o_24__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.sbdata_o_25__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.sbdata_o_26__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.sbdata_o_27__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.sbdata_o_28__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.sbdata_o_29__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.sbdata_o_2__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.sbdata_o_30__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.sbdata_o_31__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.sbdata_o_3__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.sbdata_o_4__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.sbdata_o_5__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.sbdata_o_6__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.sbdata_o_7__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.sbdata_o_8__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.sbdata_o_9__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.sbdata_q_32__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.sbdata_q_33__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.sbdata_q_34__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.sbdata_q_35__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.sbdata_q_36__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.sbdata_q_37__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.sbdata_q_38__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.sbdata_q_39__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.sbdata_q_40__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.sbdata_q_41__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.sbdata_q_42__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.sbdata_q_43__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.sbdata_q_44__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.sbdata_q_45__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.sbdata_q_46__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.sbdata_q_47__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.sbdata_q_48__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.sbdata_q_49__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.sbdata_q_50__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.sbdata_q_51__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.sbdata_q_52__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.sbdata_q_53__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.sbdata_q_54__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.sbdata_q_55__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.sbdata_q_56__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.sbdata_q_57__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.sbdata_q_58__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.sbdata_q_59__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.sbdata_q_60__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.sbdata_q_61__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.sbdata_q_62__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.sbdata_q_63__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.sbreadonaddr_o_reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_csrs.sbreadondata_o_reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_sba.state_q_0__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/i_dm_sba.state_q_1__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/master_add_o[0]_reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/master_add_o[10]_reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/master_add_o[11]_reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/master_add_o[12]_reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/master_add_o[13]_reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/master_add_o[14]_reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/master_add_o[15]_reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/master_add_o[16]_reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/master_add_o[17]_reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/master_add_o[18]_reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/master_add_o[19]_reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/master_add_o[1]_reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/master_add_o[20]_reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/master_add_o[21]_reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/master_add_o[22]_reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/master_add_o[23]_reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/master_add_o[24]_reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/master_add_o[25]_reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/master_add_o[26]_reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/master_add_o[27]_reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/master_add_o[28]_reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/master_add_o[29]_reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/master_add_o[2]_reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/master_add_o[30]_reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/master_add_o[31]_reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/master_add_o[3]_reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/master_add_o[4]_reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/master_add_o[5]_reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/master_add_o[6]_reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/master_add_o[7]_reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/master_add_o[8]_reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/master_add_o[9]_reg}]\
           [get_cells {i_croc_soc/i_croc/i_dm_top.i_dm_top/ndmreset_o_reg}]\
           [get_cells {i_croc_soc/i_croc/i_dmi_jtag/dmi_rst_no_reg}]\
           [get_cells {i_croc_soc/i_croc/i_dmi_jtag/i_dmi_cdc.core_clear_pending_q_reg}]\
           [get_cells {i_croc_soc/i_croc/i_dmi_jtag/i_dmi_cdc.i_cdc_req/i_cdc_reset_ctrlr/i_cdc_reset_ctrlr_half_a/i_state_transition_cdc_src/_20_}]\
           [get_cells {i_croc_soc/i_croc/i_dmi_jtag/i_dmi_cdc.i_cdc_req/i_cdc_reset_ctrlr/i_cdc_reset_ctrlr_half_a/i_state_transition_cdc_src/_21_}]\
           [get_cells {i_croc_soc/i_croc/i_dmi_jtag/i_dmi_cdc.i_cdc_req/i_cdc_reset_ctrlr/i_cdc_reset_ctrlr_half_a/i_state_transition_cdc_src/async_data_o[0]_reg}]\
           [get_cells {i_croc_soc/i_croc/i_dmi_jtag/i_dmi_cdc.i_cdc_req/i_cdc_reset_ctrlr/i_cdc_reset_ctrlr_half_a/i_state_transition_cdc_src/async_data_o[1]_reg}]\
           [get_cells {i_croc_soc/i_croc/i_dmi_jtag/i_dmi_cdc.i_cdc_req/i_cdc_reset_ctrlr/i_cdc_reset_ctrlr_half_b/i_state_transition_cdc_dst/async_ack_o_reg}]\
           [get_cells {i_croc_soc/i_croc/i_dmi_jtag/i_dmi_cdc.i_cdc_req/i_cdc_reset_ctrlr/i_cdc_reset_ctrlr_half_b/i_state_transition_cdc_dst/state_q_0__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dmi_jtag/i_dmi_cdc.i_cdc_req/i_cdc_reset_ctrlr/i_cdc_reset_ctrlr_half_b/i_state_transition_cdc_dst/state_q_1__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dmi_jtag/i_dmi_cdc.i_cdc_req/i_cdc_reset_ctrlr/i_cdc_reset_ctrlr_half_b/receiver_phase_q_0__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dmi_jtag/i_dmi_cdc.i_cdc_req/i_cdc_reset_ctrlr/i_cdc_reset_ctrlr_half_b/receiver_phase_q_1__reg}]\
           [get_cells {i_croc_soc/i_croc/i_dmi_jtag/i_dmi_cdc.i_cdc_req/i_dst/_055_}]\
           [get_cells {i_croc_soc/i_croc/i_dmi_jtag/i_dmi_cdc.i_cdc_req/i_dst/_063_}]\
           [get_cells {i_croc_soc/i_croc/i_dmi_jtag/i_dmi_cdc.i_cdc_req/i_dst/_064_}]\
           [get_cells {i_croc_soc/i_croc/i_dmi_jtag/i_dmi_cdc.i_cdc_req/i_dst/_065_}]\
           [get_cells {i_croc_soc/i_croc/i_dmi_jtag/i_dmi_cdc.i_cdc_req/i_dst/_066_}]\
           [get_cells {i_croc_soc/i_croc/i_dmi_jtag/i_dmi_cdc.i_cdc_req/i_dst/_067_}]\
           [get_cells {i_croc_soc/i_croc/i_dmi_jtag/i_dmi_cdc.i_cdc_req/i_dst/_068_}]\
           [get_cells {i_croc_soc/i_croc/i_dmi_jtag/i_dmi_cdc.i_cdc_req/i_dst/_069_}]\
           [get_cells {i_croc_soc/i_croc/i_dmi_jtag/i_dmi_cdc.i_cdc_req/i_dst/_070_}]\
           [get_cells {i_croc_soc/i_croc/i_dmi_jtag/i_dmi_cdc.i_cdc_req/i_dst/_071_}]\
           [get_cells {i_croc_soc/i_croc/i_dmi_jtag/i_dmi_cdc.i_cdc_req/i_dst/_072_}]\
           [get_cells {i_croc_soc/i_croc/i_dmi_jtag/i_dmi_cdc.i_cdc_req/i_dst/_074_}]\
           [get_cells {i_croc_soc/i_croc/i_dmi_jtag/i_dmi_cdc.i_cdc_req/i_dst/_075_}]\
           [get_cells {i_croc_soc/i_croc/i_dmi_jtag/i_dmi_cdc.i_cdc_req/i_dst/_076_}]\
           [get_cells {i_croc_soc/i_croc/i_dmi_jtag/i_dmi_cdc.i_cdc_req/i_dst/_077_}]\
           [get_cells {i_croc_soc/i_croc/i_dmi_jtag/i_dmi_cdc.i_cdc_req/i_dst/_078_}]\
           [get_cells {i_croc_soc/i_croc/i_dmi_jtag/i_dmi_cdc.i_cdc_req/i_dst/_079_}]\
           [get_cells {i_croc_soc/i_croc/i_dmi_jtag/i_dmi_cdc.i_cdc_req/i_dst/_080_}]\
           [get_cells {i_croc_soc/i_croc/i_dmi_jtag/i_dmi_cdc.i_cdc_req/i_dst/_081_}]\
           [get_cells {i_croc_soc/i_croc/i_dmi_jtag/i_dmi_cdc.i_cdc_req/i_dst/_082_}]\
           [get_cells {i_croc_soc/i_croc/i_dmi_jtag/i_dmi_cdc.i_cdc_req/i_dst/_083_}]\
           [get_cells {i_croc_soc/i_croc/i_dmi_jtag/i_dmi_cdc.i_cdc_req/i_dst/_085_}]\
           [get_cells {i_croc_soc/i_croc/i_dmi_jtag/i_dmi_cdc.i_cdc_req/i_dst/_086_}]\
           [get_cells {i_croc_soc/i_croc/i_dmi_jtag/i_dmi_cdc.i_cdc_req/i_dst/_087_}]\
           [get_cells {i_croc_soc/i_croc/i_dmi_jtag/i_dmi_cdc.i_cdc_req/i_dst/_088_}]\
           [get_cells {i_croc_soc/i_croc/i_dmi_jtag/i_dmi_cdc.i_cdc_req/i_dst/_089_}]\
           [get_cells {i_croc_soc/i_croc/i_dmi_jtag/i_dmi_cdc.i_cdc_req/i_dst/_090_}]\
           [get_cells {i_croc_soc/i_croc/i_dmi_jtag/i_dmi_cdc.i_cdc_req/i_dst/_091_}]\
           [get_cells {i_croc_soc/i_croc/i_dmi_jtag/i_dmi_cdc.i_cdc_req/i_dst/_092_}]\
           [get_cells {i_croc_soc/i_croc/i_dmi_jtag/i_dmi_cdc.i_cdc_req/i_dst/_093_}]\
           [get_cells {i_croc_soc/i_croc/i_dmi_jtag/i_dmi_cdc.i_cdc_req/i_dst/_094_}]\
           [get_cells {i_croc_soc/i_croc/i_dmi_jtag/i_dmi_cdc.i_cdc_req/i_dst/_096_}]\
           [get_cells {i_croc_soc/i_croc/i_dmi_jtag/i_dmi_cdc.i_cdc_req/i_dst/_097_}]\
           [get_cells {i_croc_soc/i_croc/i_dmi_jtag/i_dmi_cdc.i_cdc_req/i_dst/_098_}]\
           [get_cells {i_croc_soc/i_croc/i_dmi_jtag/i_dmi_cdc.i_cdc_req/i_dst/_099_}]\
           [get_cells {i_croc_soc/i_croc/i_dmi_jtag/i_dmi_cdc.i_cdc_req/i_dst/_100_}]\
           [get_cells {i_croc_soc/i_croc/i_dmi_jtag/i_dmi_cdc.i_cdc_req/i_dst/_101_}]\
           [get_cells {i_croc_soc/i_croc/i_dmi_jtag/i_dmi_cdc.i_cdc_req/i_dst/_102_}]\
           [get_cells {i_croc_soc/i_croc/i_dmi_jtag/i_dmi_cdc.i_cdc_req/i_dst/_103_}]\
           [get_cells {i_croc_soc/i_croc/i_dmi_jtag/i_dmi_cdc.i_cdc_req/i_dst/_104_}]\
           [get_cells {i_croc_soc/i_croc/i_dmi_jtag/i_dmi_cdc.i_cdc_req/i_dst/_105_}]\
           [get_cells {i_croc_soc/i_croc/i_dmi_jtag/i_dmi_cdc.i_cdc_req/i_dst/_107_}]\
           [get_cells {i_croc_soc/i_croc/i_dmi_jtag/i_dmi_cdc.i_cdc_req/i_dst/async_ack_o_reg}]\
           [get_cells {i_croc_soc/i_croc/i_dmi_jtag/i_dmi_cdc.i_cdc_req/s_dst_clear_ack_q_reg}]\
           [get_cells {i_croc_soc/i_croc/i_dmi_jtag/i_dmi_cdc.i_cdc_req/s_dst_isolate_ack_q_reg}]] 3.0000
set_max_delay\
    -from [get_ports {jtag_trst_ni}] 25.0000
set_max_delay\
    -from [list [get_ports {rst_ni}]\
           [get_ports {testmode_i}]] 13.7000
set_false_path -hold\
    -from [list [get_ports {jtag_trst_ni}]\
           [get_ports {rst_ni}]\
           [get_ports {testmode_i}]]
###############################################################################
# Environment
###############################################################################
set_load -pin_load 15.0000 [get_ports {VDD}]
set_load -pin_load 15.0000 [get_ports {VDDIO}]
set_load -pin_load 15.0000 [get_ports {VSS}]
set_load -pin_load 15.0000 [get_ports {VSSIO}]
set_load -pin_load 15.0000 [get_ports {gpio0_io}]
set_load -pin_load 15.0000 [get_ports {gpio10_io}]
set_load -pin_load 15.0000 [get_ports {gpio11_io}]
set_load -pin_load 15.0000 [get_ports {gpio12_io}]
set_load -pin_load 15.0000 [get_ports {gpio13_io}]
set_load -pin_load 15.0000 [get_ports {gpio14_io}]
set_load -pin_load 15.0000 [get_ports {gpio15_io}]
set_load -pin_load 15.0000 [get_ports {gpio16_io}]
set_load -pin_load 15.0000 [get_ports {gpio17_io}]
set_load -pin_load 15.0000 [get_ports {gpio18_io}]
set_load -pin_load 15.0000 [get_ports {gpio19_io}]
set_load -pin_load 15.0000 [get_ports {gpio1_io}]
set_load -pin_load 15.0000 [get_ports {gpio20_io}]
set_load -pin_load 15.0000 [get_ports {gpio21_io}]
set_load -pin_load 15.0000 [get_ports {gpio22_io}]
set_load -pin_load 15.0000 [get_ports {gpio23_io}]
set_load -pin_load 15.0000 [get_ports {gpio24_io}]
set_load -pin_load 15.0000 [get_ports {gpio25_io}]
set_load -pin_load 15.0000 [get_ports {gpio26_io}]
set_load -pin_load 15.0000 [get_ports {gpio27_io}]
set_load -pin_load 15.0000 [get_ports {gpio28_io}]
set_load -pin_load 15.0000 [get_ports {gpio29_io}]
set_load -pin_load 15.0000 [get_ports {gpio2_io}]
set_load -pin_load 15.0000 [get_ports {gpio30_io}]
set_load -pin_load 15.0000 [get_ports {gpio31_io}]
set_load -pin_load 15.0000 [get_ports {gpio3_io}]
set_load -pin_load 15.0000 [get_ports {gpio4_io}]
set_load -pin_load 15.0000 [get_ports {gpio5_io}]
set_load -pin_load 15.0000 [get_ports {gpio6_io}]
set_load -pin_load 15.0000 [get_ports {gpio7_io}]
set_load -pin_load 15.0000 [get_ports {gpio8_io}]
set_load -pin_load 15.0000 [get_ports {gpio9_io}]
set_load -pin_load 15.0000 [get_ports {jtag_tdo_o}]
set_load -pin_load 15.0000 [get_ports {status_o}]
set_load -pin_load 15.0000 [get_ports {uart_tx_o}]
set_load -pin_load 15.0000 [get_ports {unused0_o}]
set_load -pin_load 15.0000 [get_ports {unused1_o}]
set_load -pin_load 15.0000 [get_ports {unused2_o}]
set_load -pin_load 15.0000 [get_ports {unused3_o}]
set_driving_cell -lib_cell sg13cmos5l_IOPadOut16mA -pin {pad} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {VDD}]
set_driving_cell -lib_cell sg13cmos5l_IOPadOut16mA -pin {pad} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {VDDIO}]
set_driving_cell -lib_cell sg13cmos5l_IOPadOut16mA -pin {pad} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {VSS}]
set_driving_cell -lib_cell sg13cmos5l_IOPadOut16mA -pin {pad} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {VSSIO}]
set_driving_cell -lib_cell sg13cmos5l_IOPadOut16mA -pin {pad} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {clk_i}]
set_driving_cell -lib_cell sg13cmos5l_IOPadOut16mA -pin {pad} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {gpio0_io}]
set_driving_cell -lib_cell sg13cmos5l_IOPadOut16mA -pin {pad} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {gpio10_io}]
set_driving_cell -lib_cell sg13cmos5l_IOPadOut16mA -pin {pad} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {gpio11_io}]
set_driving_cell -lib_cell sg13cmos5l_IOPadOut16mA -pin {pad} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {gpio12_io}]
set_driving_cell -lib_cell sg13cmos5l_IOPadOut16mA -pin {pad} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {gpio13_io}]
set_driving_cell -lib_cell sg13cmos5l_IOPadOut16mA -pin {pad} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {gpio14_io}]
set_driving_cell -lib_cell sg13cmos5l_IOPadOut16mA -pin {pad} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {gpio15_io}]
set_driving_cell -lib_cell sg13cmos5l_IOPadOut16mA -pin {pad} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {gpio16_io}]
set_driving_cell -lib_cell sg13cmos5l_IOPadOut16mA -pin {pad} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {gpio17_io}]
set_driving_cell -lib_cell sg13cmos5l_IOPadOut16mA -pin {pad} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {gpio18_io}]
set_driving_cell -lib_cell sg13cmos5l_IOPadOut16mA -pin {pad} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {gpio19_io}]
set_driving_cell -lib_cell sg13cmos5l_IOPadOut16mA -pin {pad} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {gpio1_io}]
set_driving_cell -lib_cell sg13cmos5l_IOPadOut16mA -pin {pad} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {gpio20_io}]
set_driving_cell -lib_cell sg13cmos5l_IOPadOut16mA -pin {pad} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {gpio21_io}]
set_driving_cell -lib_cell sg13cmos5l_IOPadOut16mA -pin {pad} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {gpio22_io}]
set_driving_cell -lib_cell sg13cmos5l_IOPadOut16mA -pin {pad} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {gpio23_io}]
set_driving_cell -lib_cell sg13cmos5l_IOPadOut16mA -pin {pad} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {gpio24_io}]
set_driving_cell -lib_cell sg13cmos5l_IOPadOut16mA -pin {pad} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {gpio25_io}]
set_driving_cell -lib_cell sg13cmos5l_IOPadOut16mA -pin {pad} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {gpio26_io}]
set_driving_cell -lib_cell sg13cmos5l_IOPadOut16mA -pin {pad} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {gpio27_io}]
set_driving_cell -lib_cell sg13cmos5l_IOPadOut16mA -pin {pad} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {gpio28_io}]
set_driving_cell -lib_cell sg13cmos5l_IOPadOut16mA -pin {pad} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {gpio29_io}]
set_driving_cell -lib_cell sg13cmos5l_IOPadOut16mA -pin {pad} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {gpio2_io}]
set_driving_cell -lib_cell sg13cmos5l_IOPadOut16mA -pin {pad} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {gpio30_io}]
set_driving_cell -lib_cell sg13cmos5l_IOPadOut16mA -pin {pad} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {gpio31_io}]
set_driving_cell -lib_cell sg13cmos5l_IOPadOut16mA -pin {pad} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {gpio3_io}]
set_driving_cell -lib_cell sg13cmos5l_IOPadOut16mA -pin {pad} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {gpio4_io}]
set_driving_cell -lib_cell sg13cmos5l_IOPadOut16mA -pin {pad} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {gpio5_io}]
set_driving_cell -lib_cell sg13cmos5l_IOPadOut16mA -pin {pad} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {gpio6_io}]
set_driving_cell -lib_cell sg13cmos5l_IOPadOut16mA -pin {pad} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {gpio7_io}]
set_driving_cell -lib_cell sg13cmos5l_IOPadOut16mA -pin {pad} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {gpio8_io}]
set_driving_cell -lib_cell sg13cmos5l_IOPadOut16mA -pin {pad} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {gpio9_io}]
set_driving_cell -lib_cell sg13cmos5l_IOPadOut16mA -pin {pad} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {jtag_tck_i}]
set_driving_cell -lib_cell sg13cmos5l_IOPadOut16mA -pin {pad} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {jtag_tdi_i}]
set_driving_cell -lib_cell sg13cmos5l_IOPadOut16mA -pin {pad} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {jtag_tms_i}]
set_driving_cell -lib_cell sg13cmos5l_IOPadOut16mA -pin {pad} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {jtag_trst_ni}]
set_driving_cell -lib_cell sg13cmos5l_IOPadOut16mA -pin {pad} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {ref_clk_i}]
set_driving_cell -lib_cell sg13cmos5l_IOPadOut16mA -pin {pad} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {rst_ni}]
set_driving_cell -lib_cell sg13cmos5l_IOPadOut16mA -pin {pad} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {testmode_i}]
set_driving_cell -lib_cell sg13cmos5l_IOPadOut16mA -pin {pad} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {uart_rx_i}]
###############################################################################
# Design Rules
###############################################################################
set_max_fanout 16.0000 [current_design]
