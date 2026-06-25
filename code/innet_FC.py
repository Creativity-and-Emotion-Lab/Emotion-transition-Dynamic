from nilearn import plotting, image
import numpy as np
import matplotlib.pyplot as plt
import os

atlas_img = 'Reslice_Schaefer2018_400Parcels_7Networks_order_FSLMNI152_2mm.nii'
labels_file = '7networks_order.txt'
network_file = 'schaefer400x7CommunityAffiliation.1D.txt'

with open(labels_file, 'r') as f:
    labels = [line.strip() for line in f.readlines()]

data = np.loadtxt(network_file)  # 1*400 文件
coords = plotting.find_parcellation_cut_coords(atlas_img)
target_network = 6
network_indices = [i for i, net in enumerate(data) if net == target_network]
roi_coords = [coords[i] for i in network_indices]

node_colors = ['#3D9F3C'] * len(roi_coords)  # 点的颜色
node_sizes = [40] * len(roi_coords)  # 点的大小

connectivity_matrix = np.ones((len(roi_coords), len(roi_coords))) - np.eye(len(roi_coords))

fig = plotting.plot_connectome(
    connectivity_matrix,
    roi_coords,
    node_color=node_colors,  
    node_size=node_sizes,   
    edge_kwargs={'color': '#9ED17B', 'linewidth': 0.5},  
    display_mode='r',    
    annotate=False,
    colorbar=False)

# fig.savefig(output_file, dpi=600)  # 使用Nilearn对象保存高分辨率图像
plotting.show()


