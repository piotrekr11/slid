function visualizeDOPMaskComparison(inputMatFile, outputDir)

if nargin < 1
    inputMatFile = 'dop_mask_comparison.mat';
end
if nargin < 2
    outputDir = 'figures_dop_mask_comparison';
end

if ~isfile(inputMatFile)
    runDOPMaskComparison();
end
if ~exist(outputDir, 'dir')
    mkdir(outputDir);
end

loaded = load(inputMatFile, 'results');
results = loaded.results;
maskFields = fieldnames(results);

if isempty(maskFields)
    error('No mask results found in %s.', inputMatFile);
end

maskValues = nan(numel(maskFields), 1);
for i = 1:numel(maskFields)
    maskValues(i) = results.(maskFields{i}).meta.elevMask;
end
[maskValues, sortIdx] = sort(maskValues);
maskFields = maskFields(sortIdx);

systems = {'GPS', 'GLONASS', 'Galileo', 'BeiDou', 'Combined'};
dopNames = {'GDOP', 'PDOP', 'HDOP', 'VDOP', 'TDOP'};
colors = lines(numel(maskFields));

for s = 1:numel(systems)
    systemName = systems{s};

    for d = 1:numel(dopNames)
        dopName = dopNames{d};

        fig = figure('Visible', 'off', 'Color', 'w', 'Position', [100 100 1200 700]);
        tl = tiledlayout(2, 1, 'TileSpacing', 'compact', 'Padding', 'compact');
        title(tl, sprintf('%s - %s for different elevation masks', systemName, dopName));

        nexttile;
        hold on;
        for m = 1:numel(maskFields)
            res = results.(maskFields{m});
            plot(res.times, res.(systemName).(dopName), 'LineWidth', 1.2, 'Color', colors(m, :), ...
                'DisplayName', sprintf('Mask %g°', maskValues(m)));
        end
        grid on;
        ylabel(dopName);
        legend('Location', 'best');

        nexttile;
        hold on;
        for m = 1:numel(maskFields)
            res = results.(maskFields{m});
            plot(res.times, res.(systemName).nSats, 'LineWidth', 1.2, 'Color', colors(m, :), ...
                'DisplayName', sprintf('Mask %g°', maskValues(m)));
        end
        grid on;
        xlabel('Time');
        ylabel('# Satellites');
        legend('Location', 'best');

        outName = sprintf('%s_%s_mask_comparison.png', lower(systemName), lower(dopName));
        exportgraphics(fig, fullfile(outputDir, outName), 'Resolution', 160);
        close(fig);
    end
end

fig = figure('Visible', 'off', 'Color', 'w', 'Position', [100 100 1200 700]);
tl = tiledlayout(numel(dopNames), 1, 'TileSpacing', 'compact', 'Padding', 'compact');
title(tl, 'Combined DOP summary for elevation masks');

for d = 1:numel(dopNames)
    dopName = dopNames{d};
    ax = nexttile;
    hold(ax, 'on');

    for m = 1:numel(maskFields)
        res = results.(maskFields{m});
        y = res.Combined.(dopName);
        valid = ~isnan(y);

        if any(valid)
            p50 = prctile(y(valid), 50);
            p95 = prctile(y(valid), 95);
            yMax = max(y(valid));
        else
            p50 = NaN;
            p95 = NaN;
            yMax = NaN;
        end

        plot([1 2 3], [p50 p95 yMax], '-o', 'LineWidth', 1.2, 'Color', colors(m, :), ...
            'DisplayName', sprintf('Mask %g°', maskValues(m)));
    end

    grid(ax, 'on');
    xticks(ax, [1 2 3]);
    xticklabels(ax, {'P50', 'P95', 'MAX'});
    ylabel(ax, dopName);
    if d == 1
        legend(ax, 'Location', 'bestoutside');
    end
end
xlabel(tl, 'Statistic');

exportgraphics(fig, fullfile(outputDir, 'combined_dop_statistics_by_mask.png'), 'Resolution', 180);
close(fig);

end
