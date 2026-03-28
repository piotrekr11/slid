function [GDOP_all, PDOP_all, HDOP_all, VDOP_all, TDOP_all, nSats_all] = ...
    computeCombinedDOP(obsCell, navCell, xyz_rec, lla_rec, R_enu, elevMask, uniqueTimes)
    
    numEpochs  = length(uniqueTimes);
    numSystems = length(obsCell);
    
    GDOP_all  = nan(numEpochs, 1);
    PDOP_all  = nan(numEpochs, 1);
    HDOP_all  = nan(numEpochs, 1);
    VDOP_all  = nan(numEpochs, 1);
    TDOP_all  = nan(numEpochs, 1);
    nSats_all = nan(numEpochs, 1);
    
    for e = 1:numEpochs
        epochTime   = uniqueTimes(e);
        pos_all_vis = []; % accumulate visible sat positions across all constellations
    
        for s = 1:numSystems
            obsData = obsCell{s};
            navData = navCell{s};
    
            t  = obsData.Time;
            sv = obsData.SatelliteID;
    
            % Find epochs in this constellation close to epochTime (within 1s)
            % since constellations may not share identical epoch timestamps
            dt       = abs(t - epochTime);
            matchIdx = dt < seconds(1);
    
            if ~any(matchIdx)
                continue;
            end
    
            sv_epoch = sv(matchIdx);
    
            [svPos, ~, svID] = gnssconstellation(epochTime, navData);
    
            [svID_unique, uidx] = unique(svID, 'first');
            svPos_unique = svPos(uidx, :);
    
            [~, ~, ib] = intersect(sv_epoch, svID_unique);
            if isempty(ib)
                continue;
            end
            pos_matched = svPos_unique(ib, :);
    
            % Elevation filter
            numSats = size(pos_matched, 1);
            elev    = zeros(numSats, 1);
            for i = 1:numSats
                [~, elev(i), ~] = ecef2aer( ...
                    pos_matched(i,1), pos_matched(i,2), pos_matched(i,3), ...
                    lla_rec(1), lla_rec(2), lla_rec(3), wgs84Ellipsoid);
            end
    
            pos_all_vis = [pos_all_vis; pos_matched(elev >= elevMask, :)];
        end
    
        nVisible      = size(pos_all_vis, 1);
        nSats_all(e)  = nVisible;
    
        if nVisible < 4
            continue;
        end
    
        [GDOP_all(e), PDOP_all(e), HDOP_all(e), VDOP_all(e), TDOP_all(e)] = ...
            buildHandDOP(pos_all_vis, xyz_rec, R_enu);
    end

end