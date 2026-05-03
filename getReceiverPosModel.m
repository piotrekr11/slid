function [xyz_rec, lla_rec, R_enu] = getReceiverPosModel(modelName, obs_path)

if nargin < 1
    modelName = "wgs84";
end

xyz_rec = getRinexPosition(obs_path); % (ECEF)

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
