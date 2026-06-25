%%
BDI_high_mean_Joint = zeros(9,9);
for i = 1:length(BDI_high_idx)
    BDI_high_mean_Joint = BDI_high_mean_Joint + Joint_matrices{BDI_high_idx(i)};
end
BDI_high_mean_Joint = BDI_high_mean_Joint / length(BDI_high_idx);

BDI_low_mean_Joint = zeros(9,9);
for i = 1:length(BDI_low_idx)
    BDI_low_mean_Joint = BDI_low_mean_Joint + Joint_matrices{BDI_low_idx(i)};
end
BDI_low_mean_Joint = BDI_low_mean_Joint / length(BDI_low_idx);

BAI_high_mean_Joint = zeros(9,9);
for i = 1:length(BAI_high_idx)
    BAI_high_mean_Joint = BAI_high_mean_Joint + Joint_matrices{BAI_high_idx(i)};
end
BAI_high_mean_Joint = BAI_high_mean_Joint / length(BAI_high_idx);

BAI_low_mean_Joint = zeros(9,9);
for i = 1:length(BAI_low_idx)
    BAI_low_mean_Joint = BAI_low_mean_Joint + Joint_matrices{BAI_low_idx(i)};
end
BAI_low_mean_Joint = BAI_low_mean_Joint / length(BAI_low_idx);
%% ===== 2) BAI high：Joint_matrices  =====
BAI_high_mean_Joint = avg_joint(BAI_high_idx);
BAI_low_mean_Joint  = avg_joint(BAI_low_idx);

%% 
varNames = { ...
    'BDI_low_mean_Joint', ...
    'BDI_high_mean_Joint', ...
    'BAI_low_mean_Joint', ...
    'BAI_high_mean_Joint'};

for vi = 1:numel(varNames)
   
    PA_prob = eval(varNames{vi});                 % 9x9 
    states  = arrayfun(@num2str, 1:9, 'UniformOutput', false);
    G = digraph(PA_prob, states);

    fig1 = figure('Position',[100 100 600 600], 'Color','w', 'Renderer','opengl');
    ax = axes('Parent',fig1); hold(ax,'on'); axis(ax,'equal'); axis(ax,'off');

    N = numel(states);
    theta = linspace(0, 2*pi, N+1)'; theta(end) = [];
    theta = theta + pi;                           
    coords = [cos(theta), sin(theta)];

    if contains(varNames{vi}, 'BDI','IgnoreCase',true)
        nodeColor = [173 216 230]/255;            % BDI
        edgeBase  = [112 190  68]/255;            % BDI
        paleBase  = [210 235 210]/255;            
    else
        nodeColor = [232 203 153]/255;            % BAI
        edgeBase  = [70 149 190]/255;             % BAI
        paleBase  = [220 235 245]/255;            
    end

    h = plot(G, 'XData',coords(:,1), 'YData',coords(:,2), ...
               'NodeColor', nodeColor, ...
               'MarkerSize', 40, ...
               'EdgeColor', [1 1 1], ...       
               'LineWidth', 0.5, ...
               'ArrowSize', 12);
    h.NodeLabel = {};

    for j = 1:N
        text(coords(j,1), coords(j,2), states{j}, ...
            'HorizontalAlignment','center', 'VerticalAlignment','middle', ...
            'FontSize',15, 'FontWeight','bold', 'Color','w', 'FontName','Arial');
    end

    W = abs(PA_prob);
%     W(eye(size(W))==1) = 0;                
    nz = W(W > 0);

    w_rel = zeros(size(W));
    if ~isempty(nz)
        lo = min(nz); hi = max(nz);
        span = max(hi - lo, eps);
        tmp = (W - lo) / span;           
        tmp(W==0) = 0;
        w_rel = max(0, min(1, tmp));
    end
    gamma  = 0.7;                           
    w_show = w_rel.^gamma;

    E = G.Edges;
    lw_min = 0.9; lw_max = 5.0;

    m = height(E);
    s_idx = zeros(m,1); t_idx = zeros(m,1); w_vec = zeros(m,1);
    for e = 1:m
        s_idx(e) = findnode(G, E.EndNodes(e,1));
        t_idx(e) = findnode(G, E.EndNodes(e,2));
        w_vec(e) = w_show(s_idx(e), t_idx(e));
    end
    [~, ord] = sort(w_vec, 'ascend');

    for k = 1:m
        e = ord(k);
        s = s_idx(e);  t = t_idx(e);
        w = w_vec(e);
        if w <= 0, continue; end         

        lw  = lw_min + (lw_max - lw_min) * w;
        col = edgeBase * w + paleBase * (1 - w); 

        highlight(h, s, t, 'EdgeColor', col, 'LineWidth', lw);
    end

    title(varNames{vi}, 'Interpreter','none', ...
          'FontSize',14,'FontWeight','bold','FontName','Arial');

    exportgraphics(fig1, [varNames{vi} '_circle.png'], ...
                   'BackgroundColor','w', 'Resolution',300, 'ContentType','image');
    close(fig1);
end
