function vf = bkV2Pa
% function vf = bkV2Pa
%
% Returned arguments:
%	vf		= factor to convert volts recorded by B&K calibration mic with
%	sensitivity setting of 10V/Pa to Pascal (pressure)
%

% define some constants
% K0 = 11.9; % dB
% Korrection = 10^(K0/20);
% Gain_dB = 0;
% Gain = 10^(Gain_dB/20);
% BK_sense = 10;	% 10 V / Pa
% Pa_SPL = 2e-5;
% 
% determine the V -> Pa conversion factor
%%%%%VtoPa = (BK_sense^-1) * Korrection / Gain;
% VtoPa = (BK_sense^-1) / Gain;

% define some constants
BK_sense = 10;	% 10 V / Pa

vf = (BK_sense^-1);

