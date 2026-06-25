"""
Heatmap with FDR-corrected p-values (compact version, no colorbar border)
"""
import pandas as pd
import seaborn as sns
import matplotlib.pyplot as plt
import numpy as np
from scipy import stats
from matplotlib.colors import LinearSegmentedColormap
from statsmodels.stats.multitest import multipletests
from mpl_toolkits.axes_grid1 import make_axes_locatable

# ========== load data ==========
file_path = 'makov-chain-match-Behavior.xlsx'
sheet_name = 'Sheet1'
data = pd.read_excel(file_path, sheet_name=sheet_name)

groupA = ['CFS','BDI-II','BAI']
groupB = ['PAPR_L','PAPR_M','PAPR_H',
          'NAPR_L','NAPR_M','NAPR_H',
          'PA_Dens','NA_Dens','Joint_Dens']

# ========== corr==========
corr = pd.DataFrame(index=groupA, columns=groupB, dtype=float)
pval = pd.DataFrame(index=groupA, columns=groupB, dtype=float)
for a in groupA:
    for b in groupB:
        x, y = data[a], data[b]
        mask = (~x.isna()) & (~y.isna()) & (~np.isinf(x)) & (~np.isinf(y))
        if mask.sum() > 1:
            r, p = stats.pearsonr(x[mask], y[mask])
            corr.loc[a, b] = r
            pval.loc[a, b] = p
        else:
            corr.loc[a, b] = np.nan
            pval.loc[a, b] = np.nan

# ========== FDR ==========
p_flat = pval.values.flatten()
valid_idx = ~np.isnan(p_flat)
fdrp_flat = np.full_like(p_flat, np.nan, dtype=float)
if valid_idx.sum() > 0:
    _, fdrp_vals, _, _ = multipletests(p_flat[valid_idx], method='fdr_bh')
    fdrp_flat[valid_idx] = fdrp_vals

fdrp = pd.DataFrame(fdrp_flat.reshape(pval.shape), index=pval.index, columns=pval.columns)

# ========== *** ==========
annot = pd.DataFrame(index=groupA, columns=groupB, dtype=str)
for a in groupA:
    for b in groupB:
        q = fdrp.loc[a, b]
        if pd.isna(q):
            annot.loc[a, b] = ""
        elif q < 0.001:
            annot.loc[a, b] = "***"
        elif q < 0.01:
            annot.loc[a, b] = "**"
        elif q < 0.05:
            annot.loc[a, b] = "*"
        else:
            annot.loc[a, b] = ""

# ========== save ==========
out = pd.concat({'r': corr, 'p': pval, 'fdrp': fdrp}, axis=1)
out.to_excel('corr_FDR_results.xlsx')

# ========== plot ==========
colors = ["#197ec6", "#f6f3ef", "#d17d3d"]
cmap = LinearSegmentedColormap.from_list("RdYlBu", colors)

plt.rcParams['font.sans-serif'] = ['Arial']
plt.rcParams['axes.unicode_minus'] = False

fig, ax = plt.subplots(figsize=(8, 4.5), dpi=300)  

sns.heatmap(
    corr.astype(float),
    annot=annot, fmt="",
    cmap=cmap, center=0,
    vmin=-0.4, vmax=0.4,
    cbar=False,                    
    linewidths=1, linecolor='black',
    square=True,
    annot_kws={"color": "white", "weight": "bold", "fontsize": 15}
)


ax.set_yticklabels(['Coping Flexibility', 'Depression', 'Anxiety'], fontsize=16, fontfamily='Arial')
ax.set_xticklabels(range(1, len(groupB)+1), fontsize=14, fontfamily='Arial')
plt.xticks(rotation=0)
plt.yticks(rotation=0)
ax.tick_params(axis='both', length=0)


divider = make_axes_locatable(ax)
cax = divider.append_axes("right", size="3%", pad=0.15)   
norm = plt.Normalize(vmin=-0.4, vmax=0.4)
sm = plt.cm.ScalarMappable(cmap=cmap, norm=norm)
sm.set_array([])

cbar = fig.colorbar(sm, cax=cax, ticks=[-0.4, -0.2, 0, 0.2, 0.4])
cbar.outline.set_visible(False)   
cbar.ax.tick_params(length=0, labelsize=11)

plt.tight_layout()
plt.show()
