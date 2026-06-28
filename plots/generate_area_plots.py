# Copyright 2025 ETH Zurich and University of Bologna.
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0

# ------------------------------------------------------------------------------
#  Area Comparison Plot
#
#  This script generates two bar charts comparing the physical area of the
#  original Croc design versus our implementation (with larger SRAM macros).
# ------------------------------------------------------------------------------

import matplotlib.pyplot as plt
import numpy as np
import os

# ------------------------------------------------------------------------------
#  Data Preparation (extracted from original_croc.rpt and CrocoKrave_report.rpt)
#  Values are in square micrometers (um^2)
# ------------------------------------------------------------------------------
categories = ['Total Floorplan Area', 'Memory Macros', 'Standard Cells Logic']

# Original design data
original_values = [314200.0, 125400.0, 188800.0]

# Our implementation data (reflecting the significantly larger SRAM macros)
our_values = [861500.0, 529213.0, 332287.0]

# ------------------------------------------------------------------------------
#  Stile grafico accademico e pulito (IEEE/ACM Style)
# ------------------------------------------------------------------------------
plt.rcParams['font.family'] = 'sans-serif'
plt.rcParams['axes.edgecolor'] = '#cccccc'
plt.rcParams['axes.linewidth'] = 0.8

width = 0.35

# ------------------------------------------------------------------------------
#  GRAFICO 1: Total Area Comparison
# ------------------------------------------------------------------------------
fig, ax1 = plt.subplots(figsize=(7.5, 4.5), dpi=300)

labels_total = ['Original Croc', 'Our Implementation']
totals = [original_values[0], our_values[0]]

bars1 = ax1.bar(labels_total, totals, color=['#1f4e79', '#d95f02'], width=0.45, alpha=0.9)

ax1.set_ylabel('Total Silicon Area [$\mu$m$^2$]', fontsize=11, fontweight='bold', color='#333333')
ax1.set_title('Overall Die Area Comparison', fontsize=12, fontweight='bold', pad=15)
ax1.set_ylim(0, 1050000)
ax1.grid(axis='y', linestyle='--', alpha=0.5)
ax1.set_axisbelow(True)

# Add value labels on top of the total bars (formatted in k um^2 for readability)
for bar in bars1:
    height = bar.get_height()
    ax1.text(bar.get_x() + bar.get_width() / 2, height + 10000,
             f'{height:,.0f} $\mu$m$^2$', ha='center', va='bottom',
             fontsize=9, fontweight='bold', color='#333333')

plt.tight_layout()
os.makedirs('plots', exist_ok=True)
plt.savefig('plots/croc_area_total.png', bbox_inches='tight')
plt.close()

# ------------------------------------------------------------------------------
#  GRAFICO 2: Area Breakdown (Macros vs Standard Cells)
# ------------------------------------------------------------------------------
fig, ax2 = plt.subplots(figsize=(7.5, 4.5), dpi=300)

breakdown_labels = ['Memory Macros Area', 'Standard Cells Area']
original_breakdown = [original_values[1], original_values[2]]
our_breakdown = [our_values[1], our_values[2]]

x = np.arange(len(breakdown_labels))

bars_orig = ax2.bar(x - width/2, original_breakdown, width,
                    label='Original Croc', color='#1f4e79', alpha=0.9)
bars_our = ax2.bar(x + width/2, our_breakdown, width,
                   label='Our Implementation', color='#d95f02', alpha=0.9)

ax2.set_ylabel('Occupied Area [$\mu$m$^2$]', fontsize=11, fontweight='bold', color='#333333')
ax2.set_title('Area Breakdown: Macros vs. Core Logic', fontsize=12, fontweight='bold', pad=15)
ax2.set_xticks(x)
ax2.set_xticklabels(breakdown_labels, fontsize=10)
ax2.set_ylim(0, 650000)
ax2.grid(axis='y', linestyle='--', alpha=0.5)
ax2.set_axisbelow(True)
ax2.legend(loc='upper left', frameon=True, facecolor='white', edgecolor='none')

# Add value labels on top of the breakdown bars
for bar in bars_orig:
    height = bar.get_height()
    ax2.text(bar.get_x() + bar.get_width() / 2, height + 6000,
             f'{height:,.0f}', ha='center', va='bottom',
             fontsize=8, color='#1f4e79')

for bar in bars_our:
    height = bar.get_height()
    ax2.text(bar.get_x() + bar.get_width() / 2, height + 6000,
             f'{height:,.0f}', ha='center', va='bottom',
             fontsize=8, color='#d95f02', fontweight='bold')

plt.tight_layout()
plt.savefig('plots/croc_area_breakdown.png', bbox_inches='tight')
plt.close()

print("I grafici di area ('croc_area_total.png' e 'croc_area_breakdown.png') sono pronti!")