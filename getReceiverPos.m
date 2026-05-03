function [xyz_rec, lla_rec, R_enu] = getReceiverPos(obs_path)

[xyz_rec, lla_rec, R_enu] = getReceiverPosModel("wgs84", obs_path);

end