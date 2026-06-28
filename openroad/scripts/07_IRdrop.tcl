###############################################################################
# INITIALIZE DESIGN AND TECHNOLOGY (LOAD ONCE)
###############################################################################
source scripts/init_tech.tcl

read_db out/croc.odb
# read_verilog out/croc.v
# link_design croc_chip

read_sdc out/croc.sdc
read_spef out/croc.spef

###############################################################################
# 1. ANALISI VDD (IR Drop)
###############################################################################
utl::report "Running IR Drop analysis for VDD..."
set_pdnsim_net_voltage -net VDD -voltage 1.2
analyze_power_grid -vsrc src/Vsrc_croc_vdd.loc -net VDD -corner tt

# ###############################################################################
# # 2. ANALISI VSS (Ground Bounce)
# ###############################################################################
utl::report "Running IR Drop analysis for VSS..."
set_pdnsim_net_voltage -net VSS -voltage 0.0
analyze_power_grid -vsrc src/Vsrc_croc_vss.loc -net VSS -corner tt

# # Visualization (must be done inside openroad to make the map show)
gui::set_display_controls "Heat Maps/IR Drop" visible true
gui::set_heatmap IRDrop Layer Metal1
gui::set_heatmap IRDrop ShowLegend 1