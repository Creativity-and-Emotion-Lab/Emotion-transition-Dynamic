varNames = { ...
    'BDI_low_mean_NA', ...
    'BDI_high_mean_NA', ...
    'BDI_low_mean_PA', ...
    'BDI_high_mean_PA', ...
    'BAI_low_mean_NA', ...
    'BAI_high_mean_NA', ...
    'BAI_low_mean_PA', ...
    'BAI_high_mean_PA'};

for i = 1:numel(varNames)
    PA_prob = eval(varNames{i});  
    fig1 = figure('Position',[100 100 500 500], 'Color','w');   
    states = {'L','M','H'};
    G = digraph(PA_prob, states);
 
    coords = [0 0; 0 1; 1 0.5];

   if contains(varNames{i}, 'NA')
        nodeColor = [184 84 65]/255;   
        edgeBase  = [70 149 190]/255;  
    else
        nodeColor = [41 118 84]/255;   
        edgeBase  = [216 176 60]/255; 
    end
    white = [1 1 1];                   
    alpha_min = 0.6; 
   
    h = plot(G,'XData',coords(:,1),'YData',coords(:,2), ...
             'NodeColor',nodeColor, ...
             'MarkerSize',40, ...
             'ArrowSize',15, ...
             'LineWidth',1, ...
             'EdgeColor',0.9*[1 1 1]);

    h.NodeLabel = {};

    for j = 1:numel(states)
        text(coords(j,1)-0.01, coords(j,2), states{j}, ...
             'HorizontalAlignment','center', ...
             'VerticalAlignment','middle', ...
             'FontSize',15, 'FontWeight','bold', 'FontName','Arial');
    end

    lw_min = 0.5; lw_max = 10;
    E = G.Edges;
    for e = 1:height(E)
        s = E.EndNodes(e,1);
        t = E.EndNodes(e,2);
        w = max(0,min(1,E.Weight(e)));

        lw = lw_min + (lw_max - lw_min) * w;

        alpha = alpha_min + (1 - alpha_min) * w;
        col   = edgeBase * alpha + white * (1 - alpha);

        highlight(h, s, t, 'EdgeColor', col, 'LineWidth', lw);
    end
  
    axis equal;
    pbaspect([1 1 1]);
    axis off;

    title(varNames{i}, 'Interpreter','none', ...
          'FontSize',14,'FontWeight','bold','FontName','Arial');
  
    set(gca,'LooseInset',get(gca,'TightInset'));

    exportgraphics(fig1, [varNames{i} '.png'], ...
                   'BackgroundColor','w', 'Resolution',300, 'ContentType','image');
    close(fig1);
end
