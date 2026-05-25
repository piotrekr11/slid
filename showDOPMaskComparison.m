function fig = showDOPMaskComparison(dopName, systems, inputMatFile)

if nargin < 1 || isempty(dopName)
    dopName = 'PDOP';
end
if nargin < 2 || isempty(systems)
    systems = {'GPS', 'GLONASS', 'Galileo', 'BeiDou', 'Combined'};
end
if nargin < 3
    inputMatFile = 'dop_mask_comparison.mat';
end

if ~isfile(inputMatFile)
    runDOPMaskComparison();
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
colors = lines(numel(maskFields));

fig = figure('Color', 'w', 'Name', sprintf('%s comparison for elevation masks', dopName), ...
    'Position', [80, 80, 1280, 780]);
tg = uitabgroup(fig);

for s = 1:numel(systems)
    systemName = systems{s};
    tab = uitab(tg, 'Title', systemName);
    t = tiledlayout(tab, 2, 1, 'TileSpacing', 'compact', 'Padding', 'compact');
    title(t, sprintf('%s - %s for elevation masks', systemName, dopName));

    ax1 = nexttile(t);
    hold(ax1, 'on');
    for m = 1:numel(maskFields)
        res = results.(maskFields{m});
        if ~isfield(res, systemName) || ~isfield(res.(systemName), dopName)
            error('Missing %s/%s data in mask field %s.', systemName, dopName, maskFields{m});
        end
        plot(ax1, res.times, res.(systemName).(dopName), 'LineWidth', 1.3, ...
            'Color', colors(m, :), 'DisplayName', sprintf('Mask %g°', maskValues(m)));
    end
    grid(ax1, 'on');
    ylabel(ax1, dopName);
    ylim(ax1,[0,20]);
    legend(ax1, 'Location', 'best');

    ax2 = nexttile(t);
    hold(ax2, 'on');
    for m = 1:numel(maskFields)
        res = results.(maskFields{m});
        plot(ax2, res.times, res.(systemName).nSats, 'LineWidth', 1.2, ...
            'Color', colors(m, :), 'DisplayName', sprintf('Mask %g°', maskValues(m)));
    end
    grid(ax2, 'on');
    xlabel(ax2, 'Time');
    ylabel(ax2, '# Satellites');
    legend(ax2, 'Location', 'best');
end

end
