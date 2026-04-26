function lla = ecef2sphericallla(xyz)

x = xyz(1);
y = xyz(2);
z = xyz(3);

lon = atan2(y, x);
p = hypot(x, y);
lat = atan2(z, p);

R = 6371000.0;                % [m], mean spherical Earth radius
h = norm(xyz) - R;

lla = [rad2deg(lat), rad2deg(lon), h];

end
