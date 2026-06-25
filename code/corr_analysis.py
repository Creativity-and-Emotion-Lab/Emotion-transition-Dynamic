# -*- coding: utf-8 -*-
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
from scipy import stats

file_path =  'makov-chain-match-behavior.xlsx'
sheet_name = 'Sheet1'

groupA = ['CFS','BDI-II','BAI']
groupB = ['PAPR_L','PAPR_M','PAPR_H','NAPR_L','NAPR_M','NAPR_H',
          'PA_Dens','NA_Dens','Joint_Dens']

data_raw = pd.read_excel(file_path, sheet_name=sheet_name)
data = data_raw[groupA + groupB].apply(pd.to_numeric, errors='coerce')

corr = pd.DataFrame(index=groupA, columns=groupB, dtype=float)
for a in groupA:
    for b in groupB:
        x, y = data[a], data[b]
        mask = x.notna() & y.notna()
        if mask.sum() >= 3:
            corr.loc[a, b] = stats.pearsonr(x[mask], y[mask])[0]
        else:
            corr.loc[a, b] = np.nan


rmin, rmax = -0.6, 0.6
grid_r = np.arange(-0.6, 0.61, 0.3)


def plot_radar(ax, values, title, n_labels,
               rmin=-0.6, rmax=0.6, grid_r=None,
               fill=True, linewidth=2.0, alpha_fill=0.12,
               label_radius_factor=1.15):  
    n = len(values)
    theta = np.linspace(0.0, 2.0*np.pi, n, endpoint=False)
    vals = np.asarray(values, dtype=float)

    theta_closed = np.concatenate([theta, theta[:1]])
    vals_closed  = np.concatenate([vals,  vals[:1]])

    ax.plot(theta_closed, vals_closed, linewidth=linewidth, color='C0')
    if fill:
        ax.fill(theta_closed, vals_closed, color='C0', alpha=alpha_fill)

    ax.set_title(title, fontsize=11, fontfamily='Arial', fontweight='normal', pad=20)  
    ax.set_ylim(rmin, rmax)
    ax.set_yticks(grid_r)
    ax.set_yticklabels([f"{r:.1f}" for r in grid_r], fontsize=8, color='#808080')
    ax.grid(True, linestyle='--', linewidth=1, alpha=0.6)
    ax.set_xticks([])

    ax.set_theta_offset(np.pi/2)
    ax.set_theta_direction(-1)

    # r=0 红线
    ax.plot(np.linspace(0, 2*np.pi, 360),
            np.zeros(360), color='darkred', linewidth=1.2, alpha=0.7)

   
    ax.spines['polar'].set_linewidth(0.8)  

    for ang in theta:
        ax.plot([ang, ang], [rmin, rmax], color='gray', linestyle=':', linewidth=0.8, alpha=0.6)

    for i, ang in enumerate(theta, start=1):
        ax.text(ang, rmax * label_radius_factor, str(i),
                fontsize=9, ha='center', va='center', weight='normal')

# ==========plot ==========
fig, axes = plt.subplots(
    1, 3,
    subplot_kw={'projection':'polar'},
    figsize=(7, 3.5),
    dpi=300
)

titles = {
    'CFS':    'Coping Flexibility',
    'BDI-II': 'Depression',
    'BAI':    'Anxiety',
}

for ax, target in zip(axes, groupA):
    r_vals = corr.loc[target, groupB].values.astype(float)
    plot_radar(ax, r_vals, titles[target], len(groupB),
               rmin=rmin, rmax=rmax, grid_r=grid_r,
               fill=True, linewidth=1.5, alpha_fill=0.12,
               label_radius_factor=1.15)

plt.subplots_adjust(left=0.06, right=0.95, top=0.88, bottom=0.12, wspace=0.2)
plt.show()
