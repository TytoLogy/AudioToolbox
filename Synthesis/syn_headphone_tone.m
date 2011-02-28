function [S, Smag, Sphi]  = syn_headphone_tone(duration, Fs, freq, usitd, rad_vary, caldata)
%function [S, Smag, Sphi]  = syn_headphone_tone(duration, Fs, freq, usitd, rad_vary, caldata)
%---------------------------------------------------------------------
%	Synthesize calibrated tone for headphone output
%---------------------------------------------------------------------
%	Input Arguments:
%		duration		time of stimulus in ms
%		Fs				output sampling rate
%		freq			tone frequency
%		usitd			ITD in microseconds (+ = right ear leads, - = left ear leads)
%		rad_vary		parameter to vary starting phase (0 = no, 1 = yes)
%		caldata		caldata structure (caldata.mag, caldata.freq, caldata.phi)
%						if no calibration is desired, replace caldata with a 
% 						single numerical value
%		
%	Output Arguments:
%		S		L & R sine data
%		Smag	L & R calibration magnitude
%		Sphi	L & R phase
%---------------------------------------------------------------------
%	See Also:	syn_headphone_noise
%---------------------------------------------------------------------

%---------------------------------------------------------------------
%	Sharad Shanbhag
%	sharad.shanbhag@einstein.yu.edu
%
%--Revision History---------------------------------------------------
%	7 March, 2003, SJS:
%		Modified to include ITD in sound output and output 2 
%		channels of data
%	12 Feb, 2008, SJS:	
%		Modified to actually use calibration data
% 	6 March, 2008 (SJS):
% 		- added scaling factor from caldata to multiply stimulus signal
%	1 December, 2009 (SJS):
% 		- fixed incorrect conversion from usec to seconds for ITD
%		- updated documentation
%---------------------------------------------------------------------

if nargin ~= 6
	error([mfilename ': incorrect number of input arguments']);
end

% generate time vector for sinusoiding
tvec = (1/Fs)*[0:(ms2bin(duration, Fs)-1)];

% convert itd from us to phase 
itd_phi = (usitd * 1e-6) * 2 * pi * freq;

if rad_vary
	startPhi = pi * rand(1, 1);
else
	startPhi = 0;
end

% get the calibration magnitudes and phases
[Smag, Sphi] = figure_cal(freq, caldata);
Sphi(1, 1) = -Sphi(1, 1) + startPhi;
Sphi(2, 1) = -Sphi(2, 1) + startPhi + itd_phi;
Smag = 1 ./ Smag;

S(1, :) = caldata.DAscale * sin( 2 * pi * freq * tvec + Sphi(1) );
S(2, :) = caldata.DAscale * sin( 2 * pi * freq * tvec + Sphi(2) );
