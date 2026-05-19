function results = runDOPMaskComparison(elevMasks, datasetDir, outputMatFile, outputCsvFile)

if nargin < 1 || isempty(elevMasks)
    elevMasks = [0 10 20];
end
if nargin < 2
    datasetDir = 'CBKA0910';
end
if nargin < 3
    outputMatFile = 'dop_mask_comparison.mat';
end
if nargin < 4
    outputCsvFile = 'dop_mask_comparison_metrics.csv';
end

obsFile = dir(fullfile(datasetDir, '*.26o'));
if isempty(obsFile)
    error('No observation file (*.26o) found in datasetDir: %s', datasetDir);
end
baseName = erase(obsFile(1).name, '.26o');

obs_path = fullfile(datasetDir, [baseName '.26o']);
obs = rinexread(obs_path);
nav_gps = rinexread(fullfile(datasetDir, [baseName '.26n']));
nav_glo = rinexread(fullfile(datasetDir, [baseName '.26g']));
nav_gal = rinexread(fullfile(datasetDir, [baseName '.26l']));
nav_bds = rinexread(fullfile(datasetDir, [baseName '.26c']));

[xyz_rec, lla_rec, R_enu] = getReceiverPos(obs_path);

for k = 1:numel(elevMasks)
    elevMask = elevMasks(k);

    [times, GPS_GDOP, GPS_PDOP, GPS_HDOP, GPS_VDOP, GPS_TDOP, GPS_nSats] = ...
        computeDOP(obs.GPS, nav_gps.GPS, xyz_rec, lla_rec, R_enu, elevMask);
    [~, GLO_GDOP, GLO_PDOP, GLO_HDOP, GLO_VDOP, GLO_TDOP, GLO_nSats] = ...
        computeDOP(obs.GLONASS, nav_glo.GLONASS, xyz_rec, lla_rec, R_enu, elevMask);
    [~, GAL_GDOP, GAL_PDOP, GAL_HDOP, GAL_VDOP, GAL_TDOP, GAL_nSats] = ...
        computeDOP(obs.Galileo, nav_gal.Galileo, xyz_rec, lla_rec, R_enu, elevMask);
    [~, BDS_GDOP, BDS_PDOP, BDS_HDOP, BDS_VDOP, BDS_TDOP, BDS_nSats] = ...
        computeDOP(obs.BeiDou, nav_bds.BeiDou, xyz_rec, lla_rec, R_enu, elevMask);

    [COM_GDOP, COM_PDOP, COM_HDOP, COM_VDOP, COM_TDOP, COM_nSats] = computeCombinedDOP( ...
        {obs.GPS, obs.GLONASS, obs.Galileo, obs.BeiDou}, ...
        {nav_gps.GPS, nav_glo.GLONASS, nav_gal.Galileo, nav_bds.BeiDou}, ...
        xyz_rec, lla_rec, R_enu, elevMask, times);

    maskResult.meta.elevMask = elevMask;
    maskResult.meta.datasetDir = datasetDir;
    maskResult.times = times;

    maskResult.GPS = packSystemResult(GPS_GDOP, GPS_PDOP, GPS_HDOP, GPS_VDOP, GPS_TDOP, GPS_nSats);
    maskResult.GLONASS = packSystemResult(GLO_GDOP, GLO_PDOP, GLO_HDOP, GLO_VDOP, GLO_TDOP, GLO_nSats);
    maskResult.Galileo = packSystemResult(GAL_GDOP, GAL_PDOP, GAL_HDOP, GAL_VDOP, GAL_TDOP, GAL_nSats);
    maskResult.BeiDou = packSystemResult(BDS_GDOP, BDS_PDOP, BDS_HDOP, BDS_VDOP, BDS_TDOP, BDS_nSats);
    maskResult.Combined = packSystemResult(COM_GDOP, COM_PDOP, COM_HDOP, COM_VDOP, COM_TDOP, COM_nSats);

    fieldName = sprintf('mask_%d', round(elevMask));
    results.(fieldName) = maskResult;
end

save(outputMatFile, 'results');
metrics = buildDOPMaskMetrics(results, elevMasks);
writetable(metrics, outputCsvFile);

end

function systemResult = packSystemResult(GDOP, PDOP, HDOP, VDOP, TDOP, nSats)
systemResult.GDOP = GDOP;
systemResult.PDOP = PDOP;
systemResult.HDOP = HDOP;
systemResult.VDOP = VDOP;
systemResult.TDOP = TDOP;
systemResult.nSats = nSats;
end

function metrics = buildDOPMaskMetrics(results, elevMasks)
systems = {'GPS', 'GLONASS', 'Galileo', 'BeiDou', 'Combined'};
dopNames = {'GDOP', 'PDOP', 'HDOP', 'VDOP', 'TDOP'};
rows = {};

for k = 1:numel(elevMasks)
    maskValue = elevMasks(k);
    fieldName = sprintf('mask_%d', round(maskValue));

    for s = 1:numel(systems)
        systemName = systems{s};

        for d = 1:numel(dopNames)
            dopName = dopNames{d};
            y = results.(fieldName).(systemName).(dopName);
            valid = ~isnan(y);

            if any(valid)
                meanVal = mean(y(valid));
                p50 = prctile(y(valid), 50);
                p95 = prctile(y(valid), 95);
                maxVal = max(y(valid));
                validEpochs = sum(valid);
            else
                meanVal = NaN;
                p50 = NaN;
                p95 = NaN;
                maxVal = NaN;
                validEpochs = 0;
            end

            nSats = results.(fieldName).(systemName).nSats;
            meanNSats = mean(nSats(~isnan(nSats)));

            rows(end+1, :) = {maskValue, systemName, dopName, meanVal, p50, p95, maxVal, meanNSats, validEpochs}; %#ok<AGROW>
        end
    end
end

metrics = cell2table(rows, 'VariableNames', ...
    {'MaskDeg', 'System', 'DOP', 'MeanDOP', 'P50DOP', 'P95DOP', 'MaxDOP', 'MeanNSats', 'ValidEpochs'});
end