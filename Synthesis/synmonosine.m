function [S, Smag, Sphi]  = synmonosine(duration, Fs, freq, scale, ...
														caldata, varargin)
%-------------------------------------------------------------------------
% [S, Smag, Sphase]  = synmonosine(duration, Fs, freq, scale, ...
% 																	caldata, rad_vary)
%-------------------------------------------------------------------------
% TytoLogy:AudioToolbox:Synthesis Toolbox
%-------------------------------------------------------------------------
% 
% 	synthesize a single-channel (mono) tone , typically for use with 
% 	free-field array.
% 
%-------------------------------------------------------------------------
% Input Arguments:
%	dur		signal duration (ms)
%	Fs 		output sampling rate
%	freq		frequency 
%	scale		rms scale factor.  
%	caldata	caldata structure (caldata.mag, caldata.freq, caldata.phase)
%				if no calibration is desired, replace caldata with value 0
%	rad_vary if 1, randomize phase, if 0 or not provided use phase = 0
% 				** note different arg order compared to syn_tone!!!!
% 
% Output arguments:
%	S				[1XN] array, where N = 0.001*dur*Fs
%-------------------------------------------------------------------------
% See Also: syn_tone, syn_headphone_tone
%-------------------------------------------------------------------------


%--------------------------------------------------------------------------
% Sharad J. Shanbhag
% sshanbhag@neomed.edu
% 	Code adapted from XDPHYS synth library developed by
% 	Jamie Mazer and Ben Arthur
%--------------------------------------------------------------------------
% Created: 4 January, 2008 (SJS) from synmononoise_fft
% Revision History:
%	11 March, 2010 (SJS): updated comments
%	7 Jun 2016 (SJS): touch up.
%	10 Jan 2019 (SJS): added varargin (for radvary)
%--------------------------------------------------------------------------

% do some basic checks on the input arguments
if nargin < 5
	help synmonosine;
	error('synmonosine: incorrect number of input arguments');
end
if duration <= 0
	error('synmonosine: duration must be > 0')
end
if freq <= 0 
	error('synmonosine: freq must be greater than 0');
end
if freq > Fs / 2
	warning('synmonosine: freq is greater than Nyquist freq (Fs/2)');
end
% vary phase randomly?
rad_vary = 0;
if ~isempty(varargin)
	if numel(varargin{1}) == 1
		rad_vary = pi * rand(1, 1);
	end
end
% calibrate stimulus?
CAL = 0;
if isstruct(caldata)
	CAL = 1;
end

% convert duration to seconds, compute # of samples in stim
duration = 0.001 * duration;
dt = 1/Fs;
% generate time vector
tvec = dt*(0:(Fs * duration)-1);
% convert to angular frequency
omega = 2 * pi * freq;

% get values for Smag (magnitude) and Sphase (phase), from either the
% calibration data, caldata, or pick a random value for phase and mag = 1
if CAL
	% get the calibration magnitudes and phases
	[Smag(1, 1), Sphi(1, 1)] = get_cal(freq, caldata.freq(1, :), ...
															caldata.maginv(1, :), ...
															caldata.phase(1, :));
	Sphi(1, 1) = -Sphi(1, 1);
	Smag = scale .* Smag;
else
	Smag = scale;
	Sphi = pi * limited_uniform(1, 1);
end

% create sinusoid
S = Smag(1) * sin( omega * tvec + Sphi(1) + rad_vary );
% done!

