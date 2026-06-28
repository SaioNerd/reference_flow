# Copyright 2025 ETH Zurich and University of Bologna.
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0

# ------------------------------------------------------------------------------
#  Power Consumption Comparison Plot
#
#  This script generates a side-by-side bar chart comparing the power
#  consumption of the original Croc design versus our implementation,
#  broken down by design group (Sequential, Combinational, Clock, Macro, Pad).
# ------------------------------------------------------------------------------

import matplotlib.pyplot as plt
import numpy as np
import os

# ------------------------------------------------------------------------------
#  Data Preparation
# ------------------------------------------------------------------------------
# Original Croc data (mW) - from post_layout_statistical_power_tt.rpt
# Our Implementation data (mW) - from the LaTeX table
groups = ['Sequential', 'Combinational', 'Clock', 'Macro', 'Pad']
original_power = [6.79, 1.08, 6.89, 0.065, 3.60]
our_power = [5.43, 0.706, 10.20, 0.0652, 3.58]

total_original = 18.40
total_our = 19.90

# ------------------------------------------------------------------------------
#  Stile grafico accademico e pulito (IEEE/ACM Style)
# ------------------------------------------------------------------------------
plt.rcParams['font.family'] = 'sans-serif'
plt.rcParams['axes.edgecolor'] = '#cccccc'
plt.rcParams['axes.linewidth'] = 0.8

width = 0.35

# ------------------------------------------------------------------------------
#  GRAFICO 1: Total Power Consumption
# ------------------------------------------------------------------------------
fig, ax1 = plt.subplots(figsize=(7.5, 4.5), dpi=300)

labels_total = ['Original Croc', 'Our Implementation']
totals = [total_original, total_our]

bars1 = ax1.bar(labels_total, totals, color=['#1f4e79', '#d95f02'], width=0.45, alpha=0.9)

ax1.set_ylabel('Total Power Consumption [mW]', fontsize=11, fontweight='bold', color='#333333')
ax1.set_title('Overall Power Comparison', fontsize=12, fontweight='bold', pad=15)
ax1.set_ylim(0, 25)
ax1.grid(axis='y', linestyle='--', alpha=0.5)
ax1.set_axisbelow(True)

# Add value labels on top of the total bars
for bar in bars1:
    height = bar.get_height()
    ax1.text(bar.get_x() + bar.get_width() / 2, height + 0.4,
             f'{height:.2f} mW', ha='center', va='bottom',
             fontsize=9, fontweight='bold', color='#333333')

plt.tight_layout()
os.makedirs('plots', exist_ok=True)
plt.savefig('plots/croc_power_total.png', bbox_inches='tight')
plt.close()

# ------------------------------------------------------------------------------
#  GRAFICO 2: Power Breakdown by Design Group
# ------------------------------------------------------------------------------
fig, ax2 = plt.subplots(figsize=(7.5, 4.5), dpi=300)

x = np.arange(len(groups))

bars_orig = ax2.bar(x - width/2, original_power, width,
                    label='Original Croc', color='#1f4e79', alpha=0.9)
bars_our = ax2.bar(x + width/2, our_power, width,
                   label='Our Implementation', color='#d95f02', alpha=0.9)

ax2.set_ylabel('Power Consumption [mW]', fontsize=11, fontweight='bold', color='#333333')
ax2.set_title('Power Consumption Breakdown by Group', fontsize=12, fontweight='bold', pad=15)
ax2.set_xticks(x)
ax2.set_xticklabels(groups, fontsize=10)
ax2.set_ylim(0, 12)
ax2.grid(axis='y', linestyle='--', alpha=0.5)
ax2.set_axisbelow(True)
ax2.legend(loc='upper left', frameon=True, facecolor='white', edgecolor='none')

# Add value labels on top of the breakdown bars
for bar in bars_orig:
    height = bar.get_height()
    label = f'{height:.2f}' if height > 0.1 else f'{height:.3f}'
    ax2.text(bar.get_x() + bar.get_width() / 2, height + 0.15,
             label, ha='center', va='bottom', fontsize=8, color='#1f4e79')

for bar in bars_our:
    height = bar.get_height()
    label = f'{height:.2f}' if height > 0.1 else f'{height:.3f}'
    ax2.text(bar.get_x() + bar.get_width() / 2, height + 0.15,
             label, ha='center', va='bottom', fontsize=8, color='#d95f02', fontweight='bold')

plt.tight_layout()
plt.savefig('plots/croc_power_breakdown.png', bbox_inches='tight')
plt.close()

print("I grafici di potenza ('croc_power_total.png' e 'croc_power_breakdown.png') sono pronti!")