function [GDOP, PDOP, HDOP, VDOP, TDOP] = buildHandDOP(pos_vis, xyz_rec, R_enu)

nVisible = size(pos_vis, 1);
H = zeros(nVisible, 4);

for i = 1:nVisible
    los      = pos_vis(i,:) - xyz_rec;
    los_unit = los / norm(los);
    los_enu  = R_enu * los_unit';
    H(i,:)   = [-los_enu', 1];
end

Q    = inv(H' * H);
GDOP = sqrt(trace(Q));
PDOP = sqrt(Q(1,1) + Q(2,2) + Q(3,3));
HDOP = sqrt(Q(1,1) + Q(2,2));
VDOP = sqrt(Q(3,3));
TDOP = sqrt(Q(4,4));

end