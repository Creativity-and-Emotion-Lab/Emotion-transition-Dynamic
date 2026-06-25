%% ------------------ Markov Chain------------------
% This script computes individual-level Markov transition matrices
% PA_matrices / NA_matrices:  3x3 
% PageRank: PA_PR / NA_PR
% Density: PA_density / NA_density

clear; clc;
%% ---------------Settings-------------------
file_path = 'usedata_makov-chain.xlsx';
PA_states = {'Low','Medium','High'};
NA_states = {'Low','Medium','High'};
nStates = numel(PA_states);

%% ------------------load data-----------------
data = readtable(file_path);
data.time = datetime(data.time,'InputFormat','yyyy-MM-dd HH:mm:ss');
data = sortrows(data, {'ID','time'});
data.date = dateshift(data.time,'start','day');
subjects = unique(data.ID);
nSubjects = numel(subjects);
PA_matrices = cell(nSubjects,1);
NA_matrices = cell(nSubjects,1);
PA_PR = zeros(nSubjects,nStates);
NA_PR = zeros(nSubjects,nStates);
PA_density = zeros(nSubjects,1);
NA_density = zeros(nSubjects,1);

%% ------------------Main  analysis------------------
for s = 1:nSubjects
    sub_idx = data.ID == subjects(s);
    sub_data = data(sub_idx,:);
    
    PA_total = zeros(nStates,nStates);
    NA_total = zeros(nStates,nStates);
    days = unique(sub_data.date);
    
    for d = 1:numel(days)
        day_idx = sub_data.date == days(d);
        day_seq_PA = cellstr(sub_data.PA_state_tertile(day_idx));
        day_seq_NA = cellstr(sub_data.NA_state_tertile(day_idx));
        
        % PA 
        for t = 1:length(day_seq_PA)-1
            i = find(strcmp(PA_states, day_seq_PA{t}));
            j = find(strcmp(PA_states, day_seq_PA{t+1}));
            PA_total(i,j) = PA_total(i,j) + 1;
        end
        
        % NA 
        for t = 1:length(day_seq_NA)-1
            i = find(strcmp(NA_states, day_seq_NA{t}));
            j = find(strcmp(NA_states, day_seq_NA{t+1}));
            NA_total(i,j) = NA_total(i,j) + 1;
        end
    end
    
    PA_prob = PA_total ./ sum(PA_total,2);
    PA_prob(isnan(PA_prob)) = 0;
    
    NA_prob = NA_total ./ sum(NA_total,2);
    NA_prob(isnan(NA_prob)) = 0;
    
    % save
    PA_matrices{s} = PA_prob;
    NA_matrices{s} = NA_prob;
    
    % PageRank & Density
    G_PA = digraph(PA_prob, PA_states);
    G_NA = digraph(NA_prob, NA_states);
    
    PA_PR(s,:) = centrality(G_PA,'pagerank','Importance',G_PA.Edges.Weight)';
    NA_PR(s,:) = centrality(G_NA,'pagerank','Importance',G_NA.Edges.Weight)';
    
    offdiag = ~eye(nStates);
    PA_density(s) = sum(PA_prob(offdiag), 'all') / (nStates*(nStates-1));
    NA_density(s) = sum(NA_prob(offdiag), 'all') / (nStates*(nStates-1));
      
end

subjects_ID = subjects; 

%% ------------------ PA×NA ------------------
PA_states = {'Low','Medium','High'};
NA_states = {'Low','Medium','High'};
Joint_states = cell(9,1);
idx = 1;
for i = 1:3
    for j = 1:3
        Joint_states{idx} = [PA_states{i} '-' NA_states{j}];
        idx = idx + 1;
    end
end
nJoint = numel(Joint_states);

Joint_matrices = cell(nSubjects,1);
Joint_density = zeros(nSubjects,1);

for s = 1:nSubjects
    sub_idx = data.ID == subjects_ID(s);
    sub_data = data(sub_idx,:);
    sub_data = sortrows(sub_data,'time');
    
    total_matrix = zeros(nJoint,nJoint);
    days = unique(sub_data.date);
    
    for d = 1:numel(days)
        day_idx = sub_data.date == days(d);
        PA_seq = cellstr(sub_data.PA_state_tertile(day_idx));
        NA_seq = cellstr(sub_data.NA_state_tertile(day_idx));
        joint_seq = strcat(PA_seq,'-',NA_seq);
        
        for t = 1:length(joint_seq)-1
            i = find(strcmp(Joint_states, joint_seq{t}));
            j = find(strcmp(Joint_states, joint_seq{t+1}));
            total_matrix(i,j) = total_matrix(i,j) + 1;
        end
    end
        
    row_sum = sum(total_matrix,2);
    prob_matrix = total_matrix ./ row_sum;
    prob_matrix(isnan(prob_matrix)) = 0;
    
    Joint_matrices{s} = prob_matrix;
    
    % Density
    G = digraph(prob_matrix, Joint_states);
    offdiagJ = ~eye(nJoint);
    Joint_density(s) = sum(prob_matrix(offdiagJ), 'all') / (nJoint*(nJoint-1));
     
end
