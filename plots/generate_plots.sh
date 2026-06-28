#!/bin/bash

# Wrapper script to run all the area breakdown Python plotting scripts
# using the backend data from CrocCante instead of the reference flow.

echo "Starting plot generation for Croco Krave..."

# The scripts will save to "plots/" in the current directory.
# Let's run this from the main CrocCante folder so plots go to CrocCante/plots/
cd /scratch/vlsi2_14fs26/Croco_Krave || { echo "Croco_Krave directory not found!"; exit 1; }

# Create plots directory if it doesn't exist
mkdir -p plots

# The path to the python scripts that we locally modified!
PYTHON_SCRIPTS_DIR="/scratch/vlsi2_14fs26/Croco_Krave/plots"

# We use the final routed report which contains the Hierarchical Area Report
AREA_REPORT="/scratch/vlsi2_14fs26/Croco_Krave/openroad/reports/04_croc.routed.rpt"

if [ ! -f "$AREA_REPORT" ]; then
    echo "Error: Area report $AREA_REPORT not found!"
    exit 1
fi

export PYTHONPATH="$PYTHON_SCRIPTS_DIR:$PYTHONPATH"

# Run python using the Apptainer environment provided by oseda -2026.04
# to make sure matplotlib and other dependencies are available!
echo "Running 01a_plot_area_bar.py..."
oseda -2026.04 python3 $PYTHON_SCRIPTS_DIR/01a_plot_area_bar.py "$AREA_REPORT"

echo "Running plot_area_pie.py..."
oseda -2026.04 python3 $PYTHON_SCRIPTS_DIR/01b_plot_area_pie.py "$AREA_REPORT"

# The output of 02a is not great at all
# echo "Running 02a_plot_area_stacked_bar.py..."
# oseda -2026.04 python3 $PYTHON_SCRIPTS_DIR/02a_plot_area_stacked_bar.py "$AREA_REPORT"

echo "Running 02b_plot_area_stacked_bar.py..."
oseda -2026.04 python3 $PYTHON_SCRIPTS_DIR/02b_plot_area_stacked_bar.py "$AREA_REPORT"

echo "Running 03_plot_die_area_breakdown.py..."
oseda -2026.04 python3 $PYTHON_SCRIPTS_DIR/03_plot_die_area_breakdown.py "$AREA_REPORT"

echo "Running generate_power_plots.py..."
oseda -2026.04 python3 $PYTHON_SCRIPTS_DIR/generate_power_plots.py

echo "Running generate_area_plots.py..."
oseda -2026.04 python3 $PYTHON_SCRIPTS_DIR/generate_area_plots.py

echo ""
echo "Done! All plots have been generated."
echo "You can find them in: /scratch/vlsi2_14fs26/Croco_Krave/plots/"

# echo "Running plot_power_comparison.py..."
# oseda -2026.04 python3 $PYTHON_SCRIPTS_DIR/plot_power_comparison.py
# echo "Running plot_area_comparison.py..."
# oseda -2026.04 python3 $PYTHON_SCRIPTS_DIR/plot_area_comparison.py
# echo "Done! All extended plots have been generated."
