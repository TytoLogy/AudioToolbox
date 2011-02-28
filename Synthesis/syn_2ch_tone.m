function S  = syn_2ch_tone(duration, Fs, freq, usitd, rad_vary, varargin)
%---------------------------------------------------------------------
% S  = syn_2ch_tone(duration, Fs, freq, usitd, rad_vary, varargin)
%---------------------------------------------------------------------
% 
%---------------------------------------------------------------------
%	Input Arguments:
%		duration		time of stimulus in ms
%		Fs				output sampling rate
%		freq			tone frequency
%		usitd			ITD in microseconds (+ = right ear leads, - = left ear leads)
%		rad_vary		parameter to vary starting phase (0 = no, 1 = yes)
%		varargin		not used
%	
%	Output Arguments:
%		S				L & R sine data
%---------------------------------------------------------------------

%---------------------------------------------------------------------
%	Sharad Shanbhag
%	sharad.shanbhag@einstein.yu.edu
%
%--Revision History---------------------------------------------------
%	1 December, 2009 (SJS): created from syn_headphone_tone.m
%---------------------------------------------------------------------

if nargin ~= 5
	error([mfilename ': incorrect number of input arguments']);
end

% generate time vector for sinusoiding
tvec = (1/Fs)*[0:(ms2bin(duration, Fs)-1)];

% convert itd from us to phase 
itd_phi = (usitd * 1e-6) *  2 * pi * freq;

if rad_vary
	startPhi = pi * rand(1, 1);
else
	startPhi = 0;
end

% get the phases
Sphi = [startPhi; startPhi + itd_phi];

% sine it!
S(1, :) = sin( 2 * pi * freq * tvec + Sphi(1) );
S(2, :) = sin( 2 * pi * freq * tvec + Sphi(2) );
