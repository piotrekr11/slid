function [uniqueTimes, GDOP_all, PDOP_all, HDOP_all, VDOP_all, TDOP_all, nSats_all] = ...
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
    
    for e = 1:numEpochs
        epochTime = uniqueTimes(e);
        sv_epoch  = sv(t == epochTime);
    
        [svPos, ~, svID] = gnssconstellation(epochTime, navData);
    
        % Remove duplicate nav messages - keep first occurrence per satellite
        [svID_unique, uidx] = unique(svID, 'first');
        svPos_unique = svPos(uidx, :);
    
        % Match observed satellites to those with nav data
        [~, ~, ib] = intersect(sv_epoch, svID_unique);
        pos_matched = svPos_unique(ib, :);
    
        % Elevation filter
        numSats = size(pos_matched, 1);
        elev    = zeros(numSats, 1);
        for i = 1:numSats
            [~, elev(i), ~] = ecef2aer( ...
                pos_matched(i,1), pos_matched(i,2), pos_matched(i,3), ...
                lla_rec(1), lla_rec(2), lla_rec(3), wgs84Ellipsoid);
        end
    
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