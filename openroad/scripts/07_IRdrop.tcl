###############################################################################
# INITIALIZE DESIGN AND TECHNOLOGY (LOAD ONCE)
###############################################################################
source scripts/init_tech.tcl

read_verilog out/croc.v
link_design croc_chip
read_sdc out/croc.sdc
read_spef out/croc.spef

###############################################################################
# IR DROP
###############################################################################
# VDD analysis
set_pdnsim_net_voltage -net VDD -voltage 1.2
analyze_power_grid -vsrc src/Vsrc_croc_vdd.loc -net VDD -corner tt

# VSS analysis to evaluate ground bounce.
set_pdnsim_net_voltage -net VSS -voltage 0.0
analyze_power_grid -vsrc src/Vsrc_croc_vss.loc -net VSS -corner tt

# Visualization
gui::set_display_controls "Heat Maps/IR Drop" visible true
gui::set_heatmap IRDrop Layer Metal1
gui::set_heatmap IRDrop ShowLegend 1