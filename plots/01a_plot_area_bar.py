# Copyright 2025 ETH Zurich and University of Bologna.
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0
#
# Philip Wiese <wiesep@iis.ee.ethz.ch>

# ------------------------------------------------------------------------------
#  STUDENT TASK 1a:
#
#  In this exercise, you will visualize the area breakdown of the i_croc module
#  using a bar plot. You will learn common tasks such as scaling axes, setting
#  titles, and customizing the appearance of the plot.
#
#  The code below extracts the hierarchical area data. Your task is to visualize
#  the area breakdown of the i_croc module as a bar plot and customize the plot
#  to improve its readability.
#
#  Follow the instructions in the code comments to complete the exercise.
# ------------------------------------------------------------------------------

# Import the modules to extract hierarchical area data and plot the results
from area import extract_areas, get_path

# Argparse is a module that allows you to parse command-line arguments
# See https://docs.python.org/3/library/argparse.html for more information
import argparse

# Import the matplotlib library for plotting
# See https://matplotlib.org/stable/gallery/index.html for examples
from matplotlib import pyplot as plt

# Import the os module to create directories
import os

# IHP-130 sg13g2_stdcell library (1 GE = 7.25 um^2)
# See http://eda.ee.ethz.ch/index.php?title=Ihp13#What_is_one_gate_equivalent_?
AREA_PER_GE = 7.25

if __name__ == "__main__":
    # Usage: python 01a_plot_area_bar.py <area_report_file>
    parser = argparse.ArgumentParser(description="Extract hierarchical areas from an OpenROAD area report.")
    parser.add_argument("file", type=str, help="Path to the area report file")
    args = parser.parse_args()

    # Extract the hierarchical area data
    area_tree = extract_areas(args.file)

    if area_tree is None:
        print("No hierarchical area data found.")
        exit(-1)

    # Extract the hierarchical area data
    node_i_croc = get_path(area_tree, ["<top>", "i_croc_soc", "i_croc"])
    node_i_user = get_path(area_tree, ["<top>", "i_croc_soc", "i_user"])


    # Extract names and convert areas to kGE
    names = []
    areas_kge = []

    for node in node_i_croc.children:
        print(node)
        # Convert area from um^2 to kGE
        area_kge = node.area / (AREA_PER_GE * 1e3)
        areas_kge.append(area_kge)
        names.append(node.name)

    for node in node_i_user.children:
        print(node)
        area_kge = node.area / (AREA_PER_GE * 1e3)
        areas_kge.append(area_kge)
        names.append(node.name)

    # ==========================================================================
    #  STUDENT TASKS - MODIFY THE CODE BELOW TO COMPLETE THE EXERCISE
    # ==========================================================================

    # --------------------------------------------------------------------------
    #  STUDENT TASK 1a.1: Create a bar plot
    # --------------------------------------------------------------------------
    # Use `plt.bar(...)` to create a bar chart.
    #
    # - The x-axis should represent the component names.
    # - The y-axis should represent the area values.
    # - Set a reasonable title for the plot.
    # - Set a reasonable x-axis label.
    # - Set a reasonable y-axis label.
    # --------------------------------------------------------------------------

    # Set the figure size
    plt.figure(figsize=(10, 5))

    # Label for y-axis
    plt.ylabel("Area [kGE]")

    # Label for x-axis
    plt.xlabel("Component")

    # Title
    plt.title("Area Breakdown: i_croc", fontsize=12, fontweight="bold")

    # --------------------------------------------------------------------------
    #  STUDENT TASK 1a.2: Improve the readability of the plot
    # --------------------------------------------------------------------------
    # Improve the visualization by:
    # - Rotating x-axis labels if they overlap
    # - Adding grid lines for better readability
    # - Use distinct colors for each bar
    #
    #  HINT: Use `plt.xticks(...)` for better readability.
    #        You can also use `plt.yscale('log')` if areas vary significantly.
    # --------------------------------------------------------------------------

    # Rotate x-axis labels for better readability
    plt.xticks(rotation=45, ha="right")

    # Add grid lines for better readability
    plt.grid(axis="y", linestyle="--", alpha=0.6)

    # Use distinct colors for each bar
    cmap = plt.get_cmap("tab10")
    # colors = [cmap(i) for i in range(len(names))]
    colors = [plt.cm.tab20.colors[i % 20] for i in range(len(names))]


    # --------------------------------------------------------------------------
    #  STUDENT TASK 1a.3: Remap the names of the components
    # --------------------------------------------------------------------------
    # Remap the names of the components for better readability.
    # Remember to move the remapping code before the `plt.bar(...)` command.
    #
    #  HINT: Use the `names` list to remap the names of the components.
    # --------------------------------------------------------------------------

    # Remap the names of the components for better readability
    name_mapping = {
        # Keys must exactly match the node.name parsed from the OpenROAD report
        "gen_sram_bank\\[0\\].i_sram_macro": "SRAM\nBank 0",
        "gen_sram_bank\\[1\\].i_sram_macro": "SRAM\nBank 1",
        "gen_sram_bank\\[0\\].i_repair_buffer": "Repair\nBuffer 0",
        "gen_sram_bank\\[1\\].i_repair_buffer": "Repair\nBuffer 1",
        "i_user_rom": "ROM",
        "i_user_design_sink": "Data\nSink",
        "i_bootrom": "Bootrom",
        "i_clint": "CLINT",
        "i_core_wrap": "Core",
        "i_dm_top.i_dm_top": "Debug\nModule",
        "i_dmi_jtag": "JTAG",
        "i_gpio": "GPIO",
        "i_obi_timer": "Timer",
        "i_soc_ctrl": "SoC\nControl",
        "i_uart": "UART"
    }

    # Apply the mapping: look up the raw name in the dictionary, 
    # and if it is not found, default back to the raw name.
    names = [name_mapping.get(name, name) for name in names]

    # --------------------------------------------------------------------------
    #  STUDENT TASK 1a.4: Save and display the plot
    # --------------------------------------------------------------------------
    # Save the figure as a high-quality PDF and display the plot.
    #
    #  HINT: Use `plt.tight_layout()` to adjust the layout for better
    #        readability.
    #        Save the figure using `plt.savefig(...)
    # --------------------------------------------------------------------------

    # Create a bar chart
    plt.bar(names, areas_kge, color=colors)

    # Adjust layout for better
    plt.tight_layout()

    # Create a directory if it does not exist
    os.makedirs("plots", exist_ok=True)

    # Save figure
    plt.savefig("plots/area_breakdown_bar.pdf")
    plt.savefig("plots/area_breakdown_bar.png")

    # Display the plot
    plt.show()
