function elev = computeElevationAngles(pos_matched, xyz_rec, R_enu)

numSats = size(pos_matched, 1);
elev = zeros(numSats, 1);

for i = 1:numSats
    los = pos_matched(i,:) - xyz_rec;
    los_unit = los / norm(los);
    los_enu = R_enu * los_unit';

    elev(i) = rad2deg(atan2(los_enu(3), hypot(los_enu(1), los_enu(2))));
end

end
