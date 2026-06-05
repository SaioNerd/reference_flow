# Could not find the specific file so I created one

# Load Liberty library (technology library with cell definitions)
yosys read_liberty -lib /scratch/vlsi2_14fs26/reference_flow/technology/lib/sg13cmos5l_stdcell_typ_1p20V_25C.lib

# Read the synthesized Verilog netlist from Yosys
# Replace with your actual Yosys output file path
yosys read_verilog ../yosys/out/croc.optimizednetlist.v

# Read timing constraints (SDC format)
yosys read_sdc /scratch/vlsi2_14fs26/reference_flow/openroad/src/constraints.sdc
# Note that the read_sdc is not supported by Yosys but only by OpenRoad



# Set the top-level module name (replace 'top' with your design's top module)
set_top_cell top

# Link the design
link_design

# Update timing analysis
update_timing

# Generate timing reports
report_check_types
report_tns
report_wns

# Detailed timing report (adjust max_paths as needed)
report_timing -max_paths 10 -sort_by_slack

exit