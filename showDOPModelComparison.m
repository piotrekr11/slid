function fig = showDOPModelComparison(dopName, systems, inputMatFile)

if nargin < 1 || isempty(dopName)
    dopName = 'PDOP';
end
if nargin < 2 || isempty(systems)
    systems = {'GPS', 'GLONASS', 'Galileo', 'BeiDou', 'Combined'};
end
if nargin < 3
    inputMatFile = 'dop_model_comparison.mat';
end

if ~isfile(inputMatFile)
    runDOPModelComparison();
end

loaded = load(inputMatFile, 'results');
results = loaded.results;
times = results.wgs84.times;

fig = figure('Color', 'w', 'Name', sprintf('%s comparison: WGS-84 vs Spherical', dopName), ...
    'Position', [80, 80, 1250, 760]);
tg = uitabgroup(fig);

for s = 1:numel(systems)
    systemName = systems{s};

    if ~isfield(results.wgs84, systemName) || ~isfield(results.spherical, systemName)
        error('System %s not found in results structure.', systemName);
    end
    if ~isfield(results.wgs84.(systemName), dopName) || ~isfield(results.spherical.(systemName), dopName)
        error('DOP type %s not found for system %s.', dopName, systemName);
    end

    w = results.wgs84.(systemName).(dopName);
    sph = results.spherical.(systemName).(dopName);
    delta = sph - w;

    tab = uitab(tg, 'Title', systemName);
    t = tiledlayout(tab, 2, 1, 'TileSpacing', 'compact', 'Padding', 'compact');
    title(t, sprintf('%s - %s: WGS-84 vs Spherical', systemName, dopName));

    ax1 = nexttile(t);
    plot(ax1, times, w, 'b', 'LineWidth', 1.3); hold(ax1, 'on');
    plot(ax1, times, sph, 'r--', 'LineWidth', 1.3);
    grid(ax1, 'on');
    ylabel(ax1, dopName);
    legend(ax1, 'WGS-84', 'Spherical', 'Location', 'best');

    ax2 = nexttile(t);
    plot(ax2, times, delta, 'k', 'LineWidth', 1.2); hold(ax2, 'on');
    yline(ax2, 0, ':', 'Color', [0.5 0.5 0.5]);
    grid(ax2, 'on');
    xlabel(ax2, 'Time');
    ylabel(ax2, 'Δ (Spherical - WGS-84)');
end

end