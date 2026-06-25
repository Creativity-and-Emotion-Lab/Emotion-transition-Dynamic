mask_path = 'E:\Analysis\EMA\Reslice_Schaefer2018_400Parcels_7Networks_order_FSLMNI152_2mm.nii';
mask = spm_data_read(mask_path);
savepath = 'E:\Analysis\EMA\TS400-7net';
cd('E:\Analysis\EMA\braindata');
f = dir('s6_sub*.nii');
for i = 1:length(f)
    disp(['Subject ',num2str(i),' computing']);
    nii_v = spm_vol(fullfile(f(i).folder,f(i).name));
    % node_bold = zeros(max(max(max(mask))), length(nii_v));
    for x = 1:length(nii_v)
        bold = spm_data_read(nii_v(x));
        for node = 1:max(max(max(mask)))
               node_bold(node,x) = mean(bold(mask == node));
        end
    end
    X = node_bold';
    save(fullfile(savepath,['sub',f(i).name(8:12),'.mat']),'X');
    clear node_bold X;
end

%% get data matrix
datafile_path = 'E:\Analysis\EMA\TS400-7net';
list = dir(fullfile(datafile_path,'*.mat'));
cd(datafile_path);

for a = 1:length(list) 
    load(list(a).name);
    time_series(:,:,a) = X;
 end

constant_columns = zeros(size(time_series, 2), 1);
for s = 1:size(time_series,3)
    timedata = time_series(:,:,s);
    col_var = var(timedata);
   constant_columns = constant_columns + (col_var == 0)';
end

ind_clear = find(constant_columns > 3);
time_series(:, ind_clear, :) = [];

data = time_series;
win = 20:2:40; 
[v_mean, v_cell] = func_arch_var(data, win);

node_match =  readmatrix('E:\Analysis\EMA\7netID.csv');
node_match(ind_clear,:) =[];
node_match(:,1) = [1:1:size(node_match,1)];
regionlist = node_match;

[with_net_mean, with_net_cell] = within_allnetwork_func(data, win, regionlist);