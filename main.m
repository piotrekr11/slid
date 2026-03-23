%% ========================================================================
%  File Name:      main.m
%  Project:        SLID - RINEX Analysis
%  Author:         Adam Szajgin
%  Created:        23/03/2026
%  Last Modified:  23/03/2026
%
%  Description:
%  Main file of RINEX Analiser. 
%
%  Version:
%  v1.0 – Init version
%
%% ========================================================================
clc; clear all; close all;

%% Read Rinex Files
obs = rinexread('CBKA0811/CBKA081I.26o');
nav = rinexread('CBKA0811/CBKA081I.26n');

%% Observable GPS (from navigation & observables RINEX)
obsGPS = obs.GPS;
navGPS = nav.GPS;

%% Get the names of variables
obsGPS.Properties.VariableNames;

%% Retireve basic information
t = obsGPS.Time;                % datetime
sv = obsGPS.SatelliteID;        % NxM

pr = obsGPS.C1C;                % pseudoranges

numEpochs = length(unique(t));  % number of epochs   