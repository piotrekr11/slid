function visualizeDOPDifferences(inputMatFile, inputCsvFile, outputDir)

    if nargin < 1
        inputMatFile = 'dop_model_comparison.mat';
    end
    if nargin < 2
        inputCsvFile = 'dop_model_difference_metrics.csv';
    end
    if nargin < 3
        outputDir = 'figures_dop_comparison';
    end

    if ~isfile(inputMatFile)
        runDOPModelComparison();
    end
    if ~isfile(inputCsvFile)
        buildDOPDifferenceMetrics(inputMatFile, inputCsvFile);
    end

    if ~exist(outputDir, 'dir')
        mkdir(outputDir);
    end

    loaded = load(inputMatFile, 'results');
    results = loaded.results;
    metrics = readtable(inputCsvFile);

    systems = {'GPS', 'Galileo', 'BeiDou', 'Combined'};
    dopNames = {'GDOP', 'PDOP', 'HDOP', 'VDOP', 'TDOP'};

    times = results.wgs84.times;

    % 1) Detailed time-series plots for each system and each DOP type
    for s = 1:numel(systems)
        systemName = systems{s};

        for d = 1:numel(dopNames)
            dopName = dopNames{d};
            w = results.wgs84.(systemName).(dopName);
            sph = results.spherical.(systemName).(dopName);
            delta = sph - w;

            fig = figure('Visible', 'off', 'Color', 'w', 'Position', [100 100 1200 700]);
            t = tiledlayout(2, 1, 'TileSpacing', 'compact', 'Padding', 'compact');
            title(t, sprintf('%s - %s: WGS-84 vs Spherical', systemName, dopName));

            nexttile;
            plot(times, w, 'b', 'LineWidth', 1.2); hold on;
            plot(times, sph, 'r--', 'LineWidth', 1.2);
            grid on;
            ylabel(dopName);
            legend('WGS-84', 'Spherical', 'Location', 'best');

            nexttile;
            plot(times, delta, 'k', 'LineWidth', 1.2); hold on;
            yline(0, ':', 'Color', [0.5 0.5 0.5]);
            grid on;
            xlabel('Time');
            ylabel('\Delta (Spherical - WGS-84)');

            outName = sprintf('%s_%s_timeseries.png', lower(systemName), lower(dopName));
            exportgraphics(fig, fullfile(outputDir, outName), 'Resolution', 160);
            close(fig);
        end
    end

    % 2) Summary heatmaps from exported metrics table
    meanAbsMatrix = buildMetricMatrix(metrics, systems, dopNames, 'MeanAbsDiff');
    p95Matrix = buildMetricMatrix(metrics, systems, dopNames, 'P95AbsDiff');
    maxAbsMatrix = buildMetricMatrix(metrics, systems, dopNames, 'MaxAbsDiff');

    fig = figure('Visible', 'off', 'Color', 'w', 'Position', [100 100 1400 500]);
    tl = tiledlayout(1, 3, 'TileSpacing', 'compact', 'Padding', 'compact');
    title(tl, 'Spherical vs WGS-84: summary of absolute DOP differences');

    nexttile;
    imagesc(meanAbsMatrix);
    title('Mean |Δ|');
    formatHeatmapAxes(systems, dopNames);
    colorbar;

    nexttile;
    imagesc(p95Matrix);
    title('P95 |Δ|');
    formatHeatmapAxes(systems, dopNames);
    colorbar;

    nexttile;
    imagesc(maxAbsMatrix);
    title('Max |Δ|');
    formatHeatmapAxes(systems, dopNames);
    colorbar;

    exportgraphics(fig, fullfile(outputDir, 'summary_heatmaps.png'), 'Resolution', 180);
    close(fig);

end

function M = buildMetricMatrix(metricsTable, systems, dopNames, metricField)
    M = nan(numel(systems), numel(dopNames));
    for i = 1:numel(systems)
        for j = 1:numel(dopNames)
            idx = strcmp(metricsTable.System, systems{i}) & strcmp(metricsTable.DOP, dopNames{j});
            if any(idx)
                M(i, j) = metricsTable.(metricField)(find(idx, 1, 'first'));
            end
        end
    end
end

function formatHeatmapAxes(systems, dopNames)
    xticks(1:numel(dopNames));
    xticklabels(dopNames);
    yticks(1:numel(systems));
    yticklabels(systems);
    xlabel('DOP type');
    ylabel('GNSS system');
    axis tight;
end
