###############################################################################
# 1. INITIALIZE DESIGN AND TECHNOLOGY (LOAD ONCE)
###############################################################################
source scripts/init_tech.tcl

read_verilog out/croc.v
link_design croc_chip
read_sdc out/croc.sdc
read_spef out/croc.spef

###############################################################################
# 2. STATISTICAL POWER ANALYSIS
###############################################################################
# Set uniform switching activity rate for all input ports
set_power_activity -input -activity 0.1

# Set known static inputs (e.g., reset) to zero activity
set_power_activity -input_port rst_ni -activity 0

# Generate the statistical power report for the typical corner
report_power -corner tt > reports/post_layout_statistical_power.rpt

###############################################################################
# 3. STIMULI-BASED POWER ANALYSIS
###############################################################################
# Note: The design is already loaded. 
# We update the background activity (if desired) and apply the VCD overlay.
set_power_activity -input -activity 0.01
set_power_activity -input_port rst_ni -activity 0

read_vcd -scope tb_croc_soc/i_croc_soc ../vsim/croc.vcd

report_power -corner tt > reports/post_layout_stimuli_power.rpt

###############################################################################
# 4. IR DROP
###############################################################################
set_pdnsim_net_voltage -net VDD -voltage 1.2
analyze_power_grid -vsrc src/Vsrc_croc_vdd.loc -net VDD -corner tt

# Visualization
gui::set_display_controls "Heat Maps/IR Drop" visible true
gui::set_heatmap IRDrop Layer Metal1
gui::set_heatmap IRDrop ShowLegend 1