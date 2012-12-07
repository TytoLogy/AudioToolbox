function S  = synmonosweep(duration, Fs, fmin, fmax, scale, caldata)
%-------------------------------------------------------------------------
%[S, Smag, Sphase]  = synmonosweep(duration, Fs, fmin, fmax, scale, caldata)
%-------------------------------------------------------------------------
% Synthesis Toolbox
%-------------------------------------------------------------------------
% 
% 	synthesize a single-channel (mono) FM sweep.  caldata will be ignored
% 
%-------------------------------------------------------------------------
% Input Arguments:
%	dur		= signal duration (ms)
%	Fs 		= output sampling rate
%	fmin			start frequency (Hz)
%	fmax			end frequency	(Hz) 
%	scale	= rms scale factor.  
%	caldata = caldata structure (caldata.mag, caldata.freq, caldata.phase)
%				if no calibration is desired, replace caldata with value 0
%
% Output arguments:
%	S				[1XN] array, where N = 0.001*dur*Fs
%-------------------------------------------------------------------------
% See Also: synmonosine, synmononoise_fft
%-------------------------------------------------------------------------


%--------------------------------------------------------------------------
% Sharad J. Shanbhag
% sshanbhag@neomed.edu
%--------------------------------------------------------------------------
% Created: 7 December, 2012
%
% Revision History:
%--------------------------------------------------------------------------

% do some basic checks on the input arguments
if nargin ~= 6
	error('%s: incorrect number of input arguments', mfilename);
end

if duration <=0
	error('%s: duration must be > 0', mfilename)
end
if fmin < 0 
	error('%s: fmin  must be greater than 0', mfilename);
end
if (fmax > (Fs / 2))
	error('%s: freq is greater than Nyquist freq (Fs/2, %f)', mfilename, Fs/2);
end
if (fmax <= fmin)
	error('%s: fmax <= fmin!!!', mfilename);
end
CAL = 0;
if isstruct(caldata)
	CAL = 1;
end

% convert duration to seconds, compute # of samples in stim
duration_seconds = 0.001 * duration;
% sample interval
sample_interval = 1/Fs;

% generate time vector
t = 0:sample_interval:duration_seconds;

% generate sweep using chirp() function
S = scale * chirp(t, fmin, duration_seconds, fmax, 'linear', -90);


% unused until calibration stuff gets figured out...
%{
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
%}

