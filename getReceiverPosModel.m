function [xyz_rec, lla_rec, R_enu] = getReceiverPosModel(modelName)

if nargin < 1
    modelName = "wgs84";
end

xyz_rec = [3675710.0, 1383730.0, 5022806.0];  % [m]

switch lower(string(modelName))
    case "wgs84"
        lla_rec = ecef2lla(xyz_rec, 'WGS84');   % [deg, deg, m]
    case "spherical"
        lla_rec = ecef2sphericallla(xyz_rec);   % [deg, deg, m]
    otherwise
        error('Unsupported modelName: %s. Use "wgs84" or "spherical".', modelName);
end

lat = deg2rad(lla_rec(1));
lon = deg2rad(lla_rec(2));

R_enu = [-sin(lon),           cos(lon),          0;
    -sin(lat)*cos(lon), -sin(lat)*sin(lon),  cos(lat);
    cos(lat)*cos(lon),  cos(lat)*sin(lon),  sin(lat)];

end
