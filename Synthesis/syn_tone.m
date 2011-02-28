function [S, Smag, Sphi]  = syn_tone(duration, Fs, freq, usitd, rad_vary, caldata)
%function [S, Smag, Sphi]  = syn_tone(duration, Fs, freq, usitd, rad_vary, caldata)
%	Input Arguments:
%		duration = time of stimulus in ms
%		Fs = output sampling rate
%		freq = tone frequency
%		usitd = ITD in microseconds (+ = right ear leads, - = left ear leads)
%		rad_vary = parameter to vary starting phase (0 = no, 1 = yes)
%		scale = rms scale factor.  if [1X2], a stereo signal is specified,
%					in the form [lscale rscale]
%		caldata = caldata structure (caldata.mag, caldata.freq, caldata.phi)
%		if no calibration is desired, replace caldata with a single numerical value
%	
%	Output Arguments:
%		S = L & R sine data
%		Smag = L & R calibration magnitude
%		Sphi = L & R phase
%

%---------------------------------------------------------------------
%	Sharad Shanbhag
%	sharad@etho.caltech.edu
%
%--Revision History---------------------------------------------------
%	7 March, 2003, SJS:
%		Modified to include ITD in sound output and output 2 
%		channels of data
%	12 Feb, 2008, SJS:	
%		Modified to actually use calibration data
%	4 August, 2008 (SJS):
%		Changed check to examine caldata as struct
%		improved handling of DAscale
%---------------------------------------------------------------------

if nargin ~= 6
	error('syn_tone: incorrect number of input arguments');
end

CAL = 0;
if isstruct(caldata)
	% if calibration data is given, use it
	CAL = 1;
	% check if we're using stereophonic data
	[n, m] = size(caldata.mag);
	STEREO = 0;
	if n == 2
		STEREO = 1;
	end
	DAscale = caldata.DAscale;
else
	% otherwise, just check if stereo or not
	[n, m] = size(caldata);
	STEREO = 0;
	if m == 2
		STEREO = 1;
	end
	DAscale = 1;
end

% generate time vector for sinusoiding
tbins = ms2samples(duration, Fs);
tvec = (1/Fs)*[0:(tbins-1)];

% convert itd from us to phase 
omega = 2 * pi * freq;
itd_phi = (usitd / 1e-6) * omega;

if rad_vary
	rad_vary = pi * rand(1, 1);
end

if CAL
	% get the calibration magnitudes and phases
	[Smag, Sphi] = figure_cal(freq, caldata);
	Sphi(1, 1) = -Sphi(1, 1) + rad_vary;
	if STEREO
		Sphi(2, 1) = -Sphi(2, 1) + rad_vary + itd_phi;
	end
 	Smag = 1 ./ Smag;
else
	Smag = 1;
	Sphi = [0 itd_phi];
end

S(1, :) = DAscale * sin( omega * tvec + Sphi(1) );
if STEREO
	S(2, :) = DAscale * sin( omega * tvec + Sphi(2) );
end


