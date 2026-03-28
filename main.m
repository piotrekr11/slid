%% ========================================================================
%% Main script - Multi-constellation DOP analysis from RINEX data
%% ========================================================================
clc; clear all; close all;

%% Parameters
elevMask = 10; % [degrees] elevation mask

%% Read RINEX files
obs = rinexread('CBKA0811/CBKA081I.26o');
nav_gps = rinexread('CBKA0811/CBKA081I.26n');
nav_glo = rinexread('CBKA0811/CBKA081I.26g');
nav_gal = rinexread('CBKA0811/CBKA081I.26l');
nav_bds = rinexread('CBKA0811/CBKA081I.26c');

%% Receiver position and ENU rotation matrix
[xyz_rec, lla_rec, R_enu] = getReceiverPos();

%% Compute DOP per constellation
[times,     GPS_GDOP, GPS_PDOP, GPS_HDOP, GPS_VDOP, GPS_TDOP, GPS_nSats] = computeDOP(obs.GPS,     nav_gps.GPS,     xyz_rec, lla_rec, R_enu, elevMask);
[~,         GLO_GDOP, GLO_PDOP, GLO_HDOP, GLO_VDOP, GLO_TDOP, GLO_nSats] = computeDOP(obs.GLONASS, nav_glo.GLONASS, xyz_rec, lla_rec, R_enu, elevMask);
[~,         GAL_GDOP, GAL_PDOP, GAL_HDOP, GAL_VDOP, GAL_TDOP, GAL_nSats] = computeDOP(obs.Galileo, nav_gal.Galileo, xyz_rec, lla_rec, R_enu, elevMask);
[~,         BDS_GDOP, BDS_PDOP, BDS_HDOP, BDS_VDOP, BDS_TDOP, BDS_nSats] = computeDOP(obs.BeiDou,  nav_bds.BeiDou,  xyz_rec, lla_rec, R_enu, elevMask);

%% Compute combined multi-constellation DOP
[COM_GDOP, COM_PDOP, COM_HDOP, COM_VDOP, COM_TDOP, COM_nSats] = computeCombinedDOP( ...
    {obs.GPS,    obs.GLONASS, obs.Galileo, obs.BeiDou}, ...
    {nav_gps.GPS, nav_glo.GLONASS, nav_gal.Galileo, nav_bds.BeiDou}, ...
    xyz_rec, lla_rec, R_enu, elevMask, times);

%% ========================================================================
%% Plots

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
legend('GPS', 'GLONASS', 'Galileo', 'BeiDou', 'Combined');
ylabel('PDOP');
title(sprintf('PDOP comparison (elevation mask: %d°)', elevMask));
grid on;

%% HDOP and VDOP
figure;
subplot(2,1,1);
plot(times, GPS_HDOP, 'b', times, GLO_HDOP, 'r', ...
     times, GAL_HDOP, 'g', times, BDS_HDOP, 'm', ...
     times, COM_HDOP, 'k', 'LineWidth', 1.5);
legend('GPS', 'GLONASS', 'Galileo', 'BeiDou', 'Combined');
ylabel('HDOP'); title('Horizontal DOP'); grid on;

subplot(2,1,2);
plot(times, GPS_VDOP, 'b', times, GLO_VDOP, 'r', ...
     times, GAL_VDOP, 'g', times, BDS_VDOP, 'm', ...
     times, COM_VDOP, 'k', 'LineWidth', 1.5);
legend('GPS', 'GLONASS', 'Galileo', 'BeiDou', 'Combined');
ylabel('VDOP'); xlabel('Time'); title('Vertical DOP'); grid on;

%% Visible satellites
figure;
plot(times, GPS_nSats, 'b', times, GLO_nSats, 'r', ...
     times, GAL_nSats, 'g', times, BDS_nSats, 'm', ...
     times, COM_nSats, 'k', 'LineWidth', 1.5);
legend('GPS', 'GLONASS', 'Galileo', 'BeiDou', 'Combined');
ylabel('# Satellites'); xlabel('Time');
title(sprintf('Visible satellites (elevation mask: %d°)', elevMask));
grid on;