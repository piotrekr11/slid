function metrics = buildDOPDifferenceMetrics(inputMatFile, outputCsvFile)

if nargin < 1
    inputMatFile = 'dop_model_comparison.mat';
end
if nargin < 2
    outputCsvFile = 'dop_model_difference_metrics.csv';
end

if ~isfile(inputMatFile)
    runDOPModelComparison();
end

loaded = load(inputMatFile, 'results');
results = loaded.results;

systems = {'GPS', 'GLONASS', 'Galileo', 'BeiDou', 'Combined'};
dopNames = {'GDOP', 'PDOP', 'HDOP', 'VDOP', 'TDOP'};

rows = {};

for s = 1:numel(systems)
    systemName = systems{s};

    for d = 1:numel(dopNames)
        dopName = dopNames{d};
        w = results.wgs84.(systemName).(dopName);
        sph = results.spherical.(systemName).(dopName);

        delta = sph - w;
        absDelta = abs(delta);
        valid = ~isnan(absDelta);

        if any(valid)
            p50 = prctile(absDelta(valid), 50);
            p95 = prctile(absDelta(valid), 95);
            maxAbs = max(absDelta(valid));
            meanDiff = mean(delta(valid));
            meanAbsDiff = mean(absDelta(valid));
            nEpochs = sum(valid);
        else
            p50 = NaN;
            p95 = NaN;
            maxAbs = NaN;
            meanDiff = NaN;
            meanAbsDiff = NaN;
            nEpochs = 0;
        end

        rows(end+1, :) = {systemName, dopName, meanDiff, meanAbsDiff, maxAbs, p50, p95, nEpochs}; %#ok<AGROW>
    end
end

metrics = cell2table(rows, 'VariableNames', ...
    {'System', 'DOP', 'MeanDiff_SphMinusWGS84', 'MeanAbsDiff', 'MaxAbsDiff', 'P50AbsDiff', 'P95AbsDiff', 'ValidEpochs'});

writetable(metrics, outputCsvFile);
disp(metrics);

end
