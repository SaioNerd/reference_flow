# Copyright (c) 2024 ETH Zurich and University of Bologna.
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0
#
# Published with permission from Siemens. 
# Siemens QuestaSim is available through EDA Higher Education Software Program
# https://www.sw.siemens.com/en-US/academic/educators/eda-higher-education-software/
#
# Authors:
# - Philippe Sauter <phsauter@iis.ee.ethz.ch>

set ROOT ".."

if {[catch { vlog -incr -sv \
    +define+FUNCTIONAL \
    "$ROOT/technology/verilog/sg13cmos5l_stdcell.v" \
    "$ROOT/technology/verilog/ez130_8t.v" \
    "$ROOT/technology/verilog/RM_IHPSG13_1P_512x32_c2_bm_bist.v" \
    "$ROOT/technology/verilog/RM_IHPSG13_1P_512x64_c2_bm_bist.v" \
    "$ROOT/technology/verilog/RM_IHPSG13_1P_core_behavioral_bm_bist.v" \
    "$ROOT/technology/verilog/RM_IHPSG13_1P_core_behavioral.v" \
    "$ROOT/technology/verilog/RM_IHPSG13_2P_core_behavioral_bm_bist_ideal.v" \
    "$ROOT/technology/verilog/RM_IHPSG13_2P_core_behavioral_ideal.v" \
    "$ROOT/technology/verilog/sg13cmos5l_io.v" \
    "$ROOT/ihp13/tc_sram_impl.sv" \
    "$ROOT/ihp13/tc_clk.sv" \
}]} {return 1}
