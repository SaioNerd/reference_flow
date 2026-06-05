# Copyright (c) 2026 ETH Zurich - Croco Crave

# Run non interactive
# oseda -2026.02 yosys -c scripts/yosys_flow.tcl

# Run interactive (to run scripts sequentially and keep the memory state active)
# oseda -2026.02 yosys -C 
# yosys> source scripts/yosys_flow.tcl

source scripts/init_tech.tcl

# Read Technology Libraries into Yosys
yosys read_liberty -lib /scratch/vlsi2_14fs26/reference_flow/technology/lib/ez130_8t_tt_1p20v_25c.lib
yosys read_liberty -lib /scratch/vlsi2_14fs26/reference_flow/technology/lib/RM_IHPSG13_1P_512x32_c2_bm_bist_typ_1p20V_25C.lib
yosys read_liberty -lib /scratch/vlsi2_14fs26/reference_flow/technology/lib/sg13cmos5l_io_typ_1p2V_3p3V_25C.lib
yosys read_liberty -lib /scratch/vlsi2_14fs26/reference_flow/technology/lib/sg13cmos5l_stdcell_typ_1p20V_25C.lib

# Load the Design
yosys plugin -i slang.so
yosys read_slang --top croc_chip -f src/croc.flist --ignore-unknown-modules --no-proc --keep-hierarchy
# print the report after the Load
yosys stat
yosys tee -q -o "reports/croc_parsed.rpt" stat -width
# export the netlist
# yosys write_verilog "out/croc_analysys.v" 


# Design Elaboration
yosys hierarchy -top croc_chip
yosys check
yosys proc
# print the report after Elaboration
yosys stat
yosys tee -q -o "reports/croc_elaborated.rpt" stat

# Coarse-grain Synthesis and Design Optimization
# for the Design Optimization step is crucial to use properly: "opt", "opt_*" and "clean"
yosys check
yosys opt -noff
yosys fsm
yosys wreduce
yosys peepopt
yosys opt_clean 
yosys opt -full
yosys share
yosys opt
yosys memory
yosys opt -fast
yosys opt_dff -sat -nodffe -nosdff
yosys opt -full
yosys clean -purge
# print the report after Coarse Synthesis
yosys stat
yosys tee -q -o "reports/croc_optimized.rpt" stat

# Synthesis Constraints
# clock frequency = 80 MHz
set period_ps 12500

# Input / Output Constraints are defined in /yosys/src/abc.constr -> driving cell (BUFX2) and output Load

# SELECTIVE FLATTENING 
# Preserve hierarchy for critical core modules
yosys setattr -set keep_hierarchy 1 regfile
yosys setattr -set keep_hierarchy 1 register_file
# Preserve hierarchy for system-level configuration
yosys setattr -set keep_hierarchy 1 soc_ctrl_reg_top
# Preserve hierarchy for clock domain crossings and synchronizers
yosys setattr -set keep_hierarchy 1 cdc_*
yosys setattr -set keep_hierarchy 1 sync_*
# Preserve hierarchy for technology cell wrappers
yosys setattr -set keep_hierarchy 1 tc_clk*
yosys setattr -set keep_hierarchy 1 tc_sram*
# Preserve hierarchy for SECDED/ECC wrappers (data integrity critical)
yosys setattr -set keep_hierarchy 1 secded_*


# Flatten the Design
yosys flatten
yosys clean -purge
# print the report after Flattening
yosys stat
yosys tee -q -o "reports/croc_flattened.rpt" stat

# Cell Substitution
yosys techmap
yosys opt -full
yosys clean
# print the report after Coarse Synthesis
yosys stat
yosys tee -q -o "reports/croc_cellsubstitution.rpt" stat

# Gate-level Technology Mapping
yosys dfflibmap -liberty /scratch/vlsi2_14fs26/reference_flow/technology/lib/sg13cmos5l_stdcell_typ_1p20V_25C.lib
yosys abc -liberty /scratch/vlsi2_14fs26/reference_flow/technology/lib/sg13cmos5l_stdcell_typ_1p20V_25C.lib -D $period_ps -constr src/abc.constr -script scripts/abc-opt.script
yosys clean -purge

# Prepare netlist for OpenROAD
yosys splitnets
yosys setundef -zero
yosys clean -purge
yosys hilomap 
yosys clean -purge

# print the report at the end of the Synthesis
#yosys stat -liberty /scratch/vlsi2_14fs26/reference_flow/technology/lib/sg13cmos5l_stdcell_typ_1p20V_25C.lib
yosys write_verilog out/croc_netlist.v

yosys splitnets -ports -format __v



yosys autoname



yosys setundef -zero



yosys hilomap -singleton -hicell TIEHIX1 Y -locell TIELOX1 Y



yosys clean -purge



yosys write_verilog -noexpr -noattr -nohex