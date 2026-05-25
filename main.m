%% ========================================================================
%% Main script - Multi-constellation DOP analysis from RINEX data
%% ========================================================================
clc; clear all; close all;

%% Parameters
elevMask = 10; %[deg]

%% Read RINEX files
obs_path = 'CBKA0910/CBKA0910.26o';

obs = rinexread(obs_path);
nav_gps = rinexread('CBKA0910/CBKA0910.26n');
nav_glo = rinexread('CBKA0910/CBKA0910.26g');
nav_gal = rinexread('CBKA0910/CBKA0910.26l');
nav_bds = rinexread('CBKA0910/CBKA0910.26c');

%% Receiver position and ENU rotation matrix
[xyz_rec, lla_rec, R_enu] = getReceiverPos(obs_path);

%% Compute DOP per constellation
[times,     GPS_GDOP, GPS_PDOP, GPS_HDOP, GPS_VDOP, GPS_TDOP, GPS_nSats, GPS_AZ, GPS_EL, GPS_SV] = computeDOP(obs.GPS,     nav_gps.GPS,     xyz_rec, lla_rec, R_enu, elevMask);
[~,         GLO_GDOP, GLO_PDOP, GLO_HDOP, GLO_VDOP, GLO_TDOP, GLO_nSats, GLO_AZ, GLO_EL, GLO_SV] = computeDOP(obs.GLONASS, nav_glo.GLONASS, xyz_rec, lla_rec, R_enu, elevMask);
[~,         GAL_GDOP, GAL_PDOP, GAL_HDOP, GAL_VDOP, GAL_TDOP, GAL_nSats, GAL_AZ, GAL_EL, GAL_SV] = computeDOP(obs.Galileo, nav_gal.Galileo, xyz_rec, lla_rec, R_enu, elevMask);
[~,         BDS_GDOP, BDS_PDOP, BDS_HDOP, BDS_VDOP, BDS_TDOP, BDS_nSats, BDS_AZ, BDS_EL, BDS_SV] = computeDOP(obs.BeiDou,  nav_bds.BeiDou,  xyz_rec, lla_rec, R_enu, elevMask);

%% Compute combined multi-constellation DOP
[COM_GDOP, COM_PDOP, COM_HDOP, COM_VDOP, COM_TDOP, COM_nSats] = computeCombinedDOP( ...
    {obs.GPS,    obs.GLONASS, obs.Galileo, obs.BeiDou}, ...
    {nav_gps.GPS, nav_glo.GLONASS, nav_gal.Galileo, nav_bds.BeiDou}, ...
    xyz_rec, lla_rec, R_enu, elevMask, times);

%% =======================================================================
%% GDOP comparison
figure;
plot(times, GPS_GDOP, 'b', times, GLO_GDOP, 'r', ...
     times, GAL_GDOP, 'g', times, BDS_GDOP, 'm', ...
     times, COM_GDOP, 'k', 'LineWidth', 1.5);
legend('GPS', 'GLONASS', 'Galileo', 'BeiDou', 'Combined');
ylabel('GDOP');
title(sprintf('GDOP comparison (elevation mask: %d°)', elevMask));
grid on;

%% PDOP comparison
figure;
plot(times, GPS_PDOP, 'b', times, GLO_PDOP, 'r', ...
     times, GAL_PDOP, 'g', times, BDS_PDOP, 'm', ...
     times, COM_PDOP, 'k', 'LineWidth', 1.5);
legend('GPS','GLONASS', 'Galileo', 'BeiDou', 'Combined');
ylabel('PDOP');
title(sprintf('PDOP comparison (elevation mask: %d°)', elevMask));
grid on;

%% HDOP comparison
figure;
plot(times, GPS_HDOP, 'b', times, GLO_HDOP, 'r', ...
     times, GAL_HDOP, 'g', times, BDS_HDOP, 'm', ...
     times, COM_HDOP, 'k', 'LineWidth', 1.5);
legend('GPS','GLONASS', 'Galileo', 'BeiDou', 'Combined');
ylabel('HDOP');
title(sprintf('HDOP comparison (elevation mask: %d°)', elevMask));
grid on;
%% VDOP comparison
figure;
plot(times, GPS_VDOP, 'b', times, GLO_VDOP, 'r', ...
    times, GAL_VDOP, 'g', times, BDS_VDOP, 'm', ...
    times, COM_VDOP, 'k', 'LineWidth', 1.5);
legend('GPS','GLONASS', 'Galileo', 'BeiDou', 'Combined');
ylabel('VDOP');
title(sprintf('VDOP comparison (elevation mask: %d°)', elevMask));
grid on;
%% TDOP comparison
figure;
plot(times, GPS_TDOP, 'b', times, GLO_TDOP, 'r', ...
    times, GAL_TDOP, 'g', times, BDS_TDOP, 'm', ...
    times, COM_TDOP, 'k', 'LineWidth', 1.5);
legend('GPS','GLONASS', 'Galileo', 'BeiDou', 'Combined');
ylabel('TDOP');
title(sprintf('TDOP comparison (elevation mask: %d°)', elevMask));
grid on;

%% Visible satellites
figure;
plot(times, GPS_nSats, 'b', times, GLO_nSats, 'r', ...
     times, GAL_nSats, 'g', times, BDS_nSats, 'm', ...
     times, COM_nSats, 'k', 'LineWidth', 1.5);
legend('GPS','GLONASS', 'Galileo', 'BeiDou', 'Combined');
ylabel('# Satellites'); xlabel('Time');
title(sprintf('Visible satellites (elevation mask: %d°)', elevMask));
grid on;

%% Sky plot
plotSkyPlot( ...
    {GPS_AZ,  GLO_AZ,  GAL_AZ,  BDS_AZ}, ...
    {GPS_EL,  GLO_EL,  GAL_EL,  BDS_EL}, ...
    {GPS_SV,  GLO_SV,  GAL_SV,  BDS_SV}, ...
    times, {'GPS','GLONASS','Galileo','BeiDou'}, {'b','r','g','m'}, ...
    elevMask, '22.03.2026 10:26');