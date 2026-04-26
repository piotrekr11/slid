function [xyz_rec, lla_rec, R_enu] = getReceiverPos()

[xyz_rec, lla_rec, R_enu] = getReceiverPosModel("wgs84");

lat = deg2rad(lla_rec(1));
lon = deg2rad(lla_rec(2));

R_enu = [-sin(lon),           cos(lon),          0;
         -sin(lat)*cos(lon), -sin(lat)*sin(lon),  cos(lat);
          cos(lat)*cos(lon),  cos(lat)*sin(lon),  sin(lat)];

end