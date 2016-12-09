function [S, Smag, Sphi]  = synmonotone(duration, Fs, freq, scale, rad_vary, caldata)
%-------------------------------------------------------------------------
%[S, Smag, Sphase]  = synmonotone(duration, Fs, freq, scale, rad_vary, caldata)
%-------------------------------------------------------------------------
% AudioToolbox:Synthesis
%-------------------------------------------------------------------------
% 
% 	synthesize a single-channel (mono) tone , typically for use with 
% 	free-field stimulation.
% 
%-------------------------------------------------------------------------
% Input Arguments:
%	dur			signal duration (ms)
%	Fs				output sampling rate (samples/s)
%	freq			frequency 
%	scale			scale factor
%	rad_vary		vary starting phase? (0 = no, 1 = yes)
%	caldata		caldata struct (caldata.mag, caldata.freq, caldata.phase)
%					if no calibration is desired, replace caldata with value 0
%
% Output arguments:
%	S				[1XN] array, where N = 0.001*dur*Fs
%-------------------------------------------------------------------------
% See Also: synmonosine, synmononoise_fft
%-------------------------------------------------------------------------


%--------------------------------------------------------------------------
% Sharad J. Shanbhag
% sshanbhag@neomed.edu
% 	Code adapted from XDPHYS synth library developed by
% 	Jamie Mazer and Ben Arthur at Caltech
%--------------------------------------------------------------------------
% Created: 24 May, 2016 (SJS) from synmonosine
% 	synmonosine does not have an input for rad_vary. Rather than modifying
% 	synmonosine and breaking things in other functions that call
% 	it, I decided to just create a new function.
%
% Revision History:
%--------------------------------------------------------------------------

% do some basic checks on the input arguments
if nargin ~= 6
	help synmonosine;
	error('%s: incorrect number of input arguments (need 6)', mfilename);
end
if duration <=0
	error('%s: duration must be > 0', mfilename);
end
if freq <= 0 
	error('%s: freq  must be greater than 0', mfilename);
elseif freq > (Fs / 2)
	warning('%s: freq is greater than Nyquist freq (Fs/2)', mfilename);
end
CAL = 0;
if isstruct(caldata)
	CAL = 1;
end
if rad_vary
	startPhi = pi * rand(1, 1);
else
	startPhi = 0;
end

% convert duration to seconds, compute # of samples in stim
duration = 0.001 * duration;
dt = 1/Fs;
tvec = dt*(0:(Fs * duration)-1);
omega = 2 * pi * freq;

% get values for Smag (magnitude) and Sphase (phase), from either the
% calibration data, caldata, or pick a random value for phase and mag = 1
if CAL
	% get the calibration magnitudes and phases
	[Smag(1, 1), Sphi(1, 1)] = get_cal(freq, ...
													caldata.freq(1, :), ...
													caldata.maginv(1, :), ...
													caldata.phase(1, :));
	Smag = scale .* Smag;
	Sphi(1, 1) = -Sphi(1, 1) + startPhi;
else
	Smag = scale;
	Sphi = startPhi;
end
	
S = Smag(1) * sin( omega * tvec + Sphi(1));
