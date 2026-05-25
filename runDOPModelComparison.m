function results = runDOPModelComparison(elevMask, datasetDir)

if nargin < 1
    elevMask = 10; % in degrees
end
if nargin < 2
    datasetDir = 'CBKA0910';
end

obsFile = dir(fullfile(datasetDir, '*.26o'));
if isempty(obsFile)
    error('No observation file (*.26o) found in datasetDir: %s', datasetDir);
end
baseName = erase(obsFile(1).name, '.26o');

obs = rinexread(fullfile(datasetDir, [baseName '.26o']));
nav_gps = rinexread(fullfile(datasetDir, [baseName '.26n']));
nav_glo = rinexread(fullfile(datasetDir, [baseName '.26g']));
nav_gal = rinexread(fullfile(datasetDir, [baseName '.26l']));
nav_bds = rinexread(fullfile(datasetDir, [baseName '.26c']));

modelNames = ["wgs84", "spherical"];

for m = 1:numel(modelNames)
    modelName = modelNames(m);
    [xyz_rec, lla_rec, R_enu] = getReceiverPosModel(modelName, fullfile(datasetDir, [baseName '.26o']));

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

    modelResult.meta.elevMask = elevMask;
    modelResult.meta.datasetDir = datasetDir;
    modelResult.times = times;

    modelResult.GPS = packSystemResult(GPS_GDOP, GPS_PDOP, GPS_HDOP, GPS_VDOP, GPS_TDOP, GPS_nSats);
    modelResult.GLONASS = packSystemResult(GLO_GDOP, GLO_PDOP, GLO_HDOP, GLO_VDOP, GLO_TDOP, GLO_nSats);
    modelResult.Galileo = packSystemResult(GAL_GDOP, GAL_PDOP, GAL_HDOP, GAL_VDOP, GAL_TDOP, GAL_nSats);
    modelResult.BeiDou = packSystemResult(BDS_GDOP, BDS_PDOP, BDS_HDOP, BDS_VDOP, BDS_TDOP, BDS_nSats);
    modelResult.Combined = packSystemResult(COM_GDOP, COM_PDOP, COM_HDOP, COM_VDOP, COM_TDOP, COM_nSats);

    results.(modelName) = modelResult;
end

save('dop_model_comparison.mat', 'results');

end

function systemResult = packSystemResult(GDOP, PDOP, HDOP, VDOP, TDOP, nSats)
systemResult.GDOP = GDOP;
systemResult.PDOP = PDOP;
systemResult.HDOP = HDOP;
systemResult.VDOP = VDOP;
systemResult.TDOP = TDOP;
systemResult.nSats = nSats;
end
