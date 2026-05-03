function az = computeAzimuthAngles(svPos, xyz_rec, R_enu)
    n  = size(svPos, 1);
    az = zeros(n, 1);
    for i = 1:n
        dxyz = svPos(i,:)' - xyz_rec(:);
        enu  = R_enu * dxyz;
        az(i) = mod(rad2deg(atan2(enu(1), enu(2))), 360);
    end
end