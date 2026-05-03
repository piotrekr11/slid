function [uniqueTimes, GDOP_all, PDOP_all, HDOP_all, VDOP_all, TDOP_all, nSats_all, AZ, EL, SVIDs] = ...
    computeDOP(obsData, navData, xyz_rec, lla_rec, R_enu, elevMask)

    t  = obsData.Time;
    sv = obsData.SatelliteID;
    uniqueTimes = unique(t);
    numEpochs   = length(uniqueTimes);

    GDOP_all  = nan(numEpochs, 1);
    PDOP_all  = nan(numEpochs, 1);
    HDOP_all  = nan(numEpochs, 1);
    VDOP_all  = nan(numEpochs, 1);
    TDOP_all  = nan(numEpochs, 1);
    nSats_all = nan(numEpochs, 1);
    AZ    = cell(numEpochs, 1);
    EL    = cell(numEpochs, 1);
    SVIDs = cell(numEpochs, 1);

    for e = 1:numEpochs
        epochTime = uniqueTimes(e);
        sv_epoch  = sv(t == epochTime);

        [svPos, ~, svID] = gnssconstellation(epochTime, navData);

        [svID_unique, uidx] = unique(svID, 'first');
        svPos_unique = svPos(uidx, :);

        [~, ~, ib] = intersect(sv_epoch, svID_unique);
        pos_matched  = svPos_unique(ib, :);
        svID_matched = svID_unique(ib);

        elev = computeElevationAngles(pos_matched, xyz_rec, R_enu);
        az   = computeAzimuthAngles(pos_matched, xyz_rec, R_enu);

        AZ{e}    = az;
        EL{e}    = elev;
        SVIDs{e} = svID_matched;

        pos_vis  = pos_matched(elev >= elevMask, :);
        nVisible = size(pos_vis, 1);
        nSats_all(e) = nVisible;

        if nVisible < 4
            continue;
        end

        [GDOP_all(e), PDOP_all(e), HDOP_all(e), VDOP_all(e), TDOP_all(e)] = ...
            buildHandDOP(pos_vis, xyz_rec, R_enu);
    end
end