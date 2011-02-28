function [S, Smag, Sphi]  = synmonosine(duration, Fs, freq, scale, caldata)
%-------------------------------------------------------------------------
%[S, Smag, Sphase]  = synmonosine(duration, Fs, freq, scale, caldata)
%-------------------------------------------------------------------------
% Synthesis Toolbox
%-------------------------------------------------------------------------
% 
% 	synthesize a single-channel (mono) tone , typically for use with 
% 	free-field array.
% 
%-------------------------------------------------------------------------
% Input Arguments:
%	dur		= signal duration (ms)
%	Fs 		= output sampling rate
%	freq 	= frequency 
%	scale	= rms scale factor.  
%	caldata = caldata structure (caldata.mag, caldata.freq, caldata.phase)
%				if no calibration is desired, replace caldata with value 0
%
% Output arguments:
%	S				[1XN] array, where N = 0.001*dur*Fs
%-------------------------------------------------------------------------
% See Also:
%-------------------------------------------------------------------------


%--------------------------------------------------------------------------
% Sharad J. Shanbhag
% sharad.shanbhag@einstein.yu.edu
% 	Code adapted from XDPHYS synth library developed by
% 	Jamie Mazer and Ben Arthur
%--------------------------------------------------------------------------
% Created: 4 January, 2008 (SJS) from synmononoise_fft
% Revision History:
%	11 March, 2010 (SJS): updated comments
%--------------------------------------------------------------------------

% do some basic checks on the input arguments
if nargin ~= 5
	help synmonosine;
	error('synmonosine: incorrect number of input arguments');
end

if duration <=0
	error('synmonosine: duration must be > 0')
end
if freq <= 0 
	error('synmonosine: freq  must be greater than 0');
end
if freq > Fs ./ 2
	warning('synmonosine: freq is greater than Nyquist freq (Fs/2)');
end

CAL = 0;
if isstruct(caldata)
	CAL = 1;
end

% convert duration to seconds, compute # of samples in stim
duration = 0.001 * duration;
dt = 1/Fs;
tvec = dt*[0:(Fs * duration)-1];
omega = 2 * pi * freq;

% get values for Smag (magnitude) and Sphase (phase), from either the
% calibration data, caldata, or pick a random value for phase and mag = 1
if CAL
	% get the calibration magnitudes and phases
	[Smag(1, 1), Sphi(1, 1)] = get_cal(freq, caldata.freq(1, :), caldata.maginv(1, :), caldata.phase(1, :));
	Sphi(1, 1) = -Sphi(1, 1);
% 	Smag = scale ./ Smag;
	Smag = scale .* Smag;
else
	Smag = scale;
	Sphi = pi * limited_uniform(1, 1);
end
	
S = Smag(1) * sin( omega * tvec + Sphi(1) );
