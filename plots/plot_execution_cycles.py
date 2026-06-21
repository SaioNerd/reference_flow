import matplotlib.pyplot as plt
import os
import numpy as np

OUTPUT_DIR = "plots"
os.makedirs(OUTPUT_DIR, exist_ok=True)

# ------------------------------------------------------------------------------
# DUMMY DATA: PLEASE UPDATE THESE CYCLE COUNTS!
# Since simulation logs were not provided, these values are placeholders.
# Replace them with the actual cycles measured from the testbench.
# ------------------------------------------------------------------------------
SW_CORDIC_CYCLES = 1250  # Total execution cycles for SW CORDIC
HW_OFFLOADING_CYCLES = 150 # Cycles spent setting up registers and polling
HW_CORDIC_CYCLES = 45   # Cycles spent by the CORDIC hardware module computing
# ------------------------------------------------------------------------------

def plot_execution_cycles():
    labels = ['Original Croc\n(SW CORDIC)', 'Our Implementation\n(HW CORDIC)']
    
    # Absolute cycles comparison
    cycles = [SW_CORDIC_CYCLES, HW_CORDIC_CYCLES]
    
    fig, ax = plt.subplots(figsize=(7, 6))
    
    width = 0.5
    
    bars = ax.bar(labels, cycles, width, color=['lightcoral', 'mediumseagreen'])
    
    ax.set_ylabel('Total Execution Cycles')
    ax.set_title('CORDIC Execution Time Comparison')
    
    # Add text labels on the bars
    ax.bar_label(bars, fmt='%d', padding=3)

    plt.tight_layout()
    plt.savefig(os.path.join(OUTPUT_DIR, "04b_execution_cycles.pdf"))
    plt.savefig(os.path.join(OUTPUT_DIR, "04b_execution_cycles.png"))
    plt.close()
    print("Generated 04b_execution_cycles.pdf and .png (NOTE: Using dummy placeholder data!)")

if __name__ == "__main__":
    plot_execution_cycles()
