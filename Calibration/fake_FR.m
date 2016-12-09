function out = fake_FR(varargin)
%------------------------------------------------------------------------
% out = fake_FR(varargin)
%------------------------------------------------------------------------
% AudioToolbox:Calibration
%------------------------------------------------------------------------
% Sets FR data for unused side
% 				- OR -
% for use when calibration mic is used directly
%------------------------------------------------------------------------

%------------------------------------------------------------------------
% Go Ashida
% ashida@umd.edu
% Sharad Shanbhag
% sshanbhag@neomed.edu
%------------------------------------------------------------------------
% Created: November, 2011 by GA
% Renamed fake_FR (from HeadphoneCal2_dummyFR), 2 May 2016, SJS
%
% Revisions: 
%	2 May 2016 (SJS): changed version to 2.2
%------------------------------------------------------------------------

out.version = '2.2';
out.F = [0,100000,200000];  % Fmin=0, Fstep=100000, Fmax=200000;
out.Freqs = out.F(1):out.F(2):out.F(3);
out.Nfreqs = length(out.Freqs);
out.DAlevel = 0; 
out.adjmag = ones(1, out.Nfreqs);
out.adjphi = zeros(1, out.Nfreqs); 
out.cal = struct();
out.cal.RefMicSens = 1;
out.cal.MicGain_dB = 0;
