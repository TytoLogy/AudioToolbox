function varargout = fftdbplot(s, Fs, varargin)
%--------------------------------------------------------------------------
% [S, Smag, Sphi, F] = fftplot(s, Fs, f, <<options>>)
%--------------------------------------------------------------------------
%	Audio Toolbox: FFT
%-------------------------------------------------------------------------
%  plots the signal, FFT magnitude, and FFT phase
%-------------------------------------------------------------------------
%
%	Input:
%		s		= signal vector
%		Fs		= sampling rate
%		f		= figure number 
%					optional, will generate new figure if
%					not specified
%		Options:
%			'PHASE'			plot phase data
%			'NO_PHASE'		will not plot phase data
%			'UNWRAP'			unwrap phases in plot
%			'NO_UNWRAP'		do not unwrap phases
%
%	Output:
%		S		= full FFT
%		Smag	= FFT magnitude
%		Sphi	= FFT phase (in unwrapped degrees)
%		F		= frequency vector for Smag, Sphi
%-------------------------------------------------------------------------
%	See Also: fftplot, unwrap, fft
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
%  Sharad Shanbhag
%	sshanbhag@neomed.edu
%-------------------------------------------------------------------------
% Created: ?????
%
% Revisions:
%	12 Apr 2016, SJS:
%	 Cleaning up, tidying, modifying
%	10 Jun 2019 (SJS): added 'NO_PHASE' option
%  26 Oct 2020 (SJS): added PHASE and UNWRAP/NO_UNWRAP options
%--------------------------------------------------------------------------

%------------------------------------------------------------------------
% Check Inputs
%------------------------------------------------------------------------
if nargin < 2
	error('fftdbplot: must specify Fs');
end

if min(size(s)) > 1
	error('fftdbplot: s must be a vector, not an array')
end
if nargin >= 3
	f = varargin{1};
	figure(f);
else
	figure;
end

PLOT_PHASE = true;
UNWRAP_PHASE = true;
FREQ_KHZ = true;

if nargin > 3
	argN = 2;
	while argN <= length(varargin)
		switch upper(varargin{argN})
			case 'PHASE'
				PLOT_PHASE = true;
				argN = argN + 1;
			case 'NO_PHASE'
				PLOT_PHASE = false;
				argN = argN + 1;
			case {'UNWRAP', 'UNWRAP_PHASE'}
				UNWRAP_PHASE = true;
				argN = argN + 1;
			case 'NO_UNWRAP'
				UNWRAP_PHASE = false;
				argN = argN + 1;
			case 'FREQ_HZ'
				FREQ_KHZ = false;
				argN = argN + 1;
			case 'FREQ_KHZ'
				FREQ_KHZ = true;
				argN = argN + 1;				
			otherwise
				error('%s: unknown option %s', mfilename, varargin{argN});
		end
	end
end
% get variable name
varname = inputname(1);

%------------------------------------------------------------------------
% now compute the FFT with NFFT points
%------------------------------------------------------------------------
N = length(s);

% go to next power of 2 for speed's sake
NFFT = 2.^(nextpow2(N));
% run the FFT
S = fft(s, NFFT);

%non-redundant points are kept
Nunique = NFFT/2 + 1;
Sunique = S(1:Nunique);

% get the magnitudes of the FFT scale by 2 because we're taking only
% half of the points from the "full" FFT vector S;
Sreal = abs(Sunique)/N; 
Sreal(2:end) = 2*Sreal(2:end);
Sphase = angle(Sunique);
if UNWRAP_PHASE
	Sphase_deg = rad2deg(unwrap(Sphase, 2*pi));
else
	Sphase_deg = rad2deg(Sphase);
end
	

% This is an evenly spaced frequency vector with Nunique points.
% scaled by the Nyquist frequency (Fn ==1/2 sample freq.)
F = (Fs/2)*linspace(0, 1, Nunique);
% rescale if FREQ_KHZ set
if FREQ_KHZ
	F = 0.001 * F;
end

% generate time vector
time = ((1:N) - 1) / Fs;

% plot setup
if PLOT_PHASE
	nplots = 3;
else
	nplots = 2;
end

subplot(nplots, 1, 1), plot(time, s);
ylabel('Input Signal'); xlabel('time(s)')
title(varname, 'Interpreter', 'none');

subplot(nplots, 1, 2), plot(F, db(Sreal));
ylabel('FFT Magnitude (dB)');
if FREQ_KHZ
	xlabel('Frequency (Khz)');
else
	xlabel('Frequency (Hz)');
end

if PLOT_PHASE
	subplot(nplots, 1, 3), plot(F, Sphase_deg);
	ylabel('FFT Phase (deg)'); xlabel('Frequency')
end

if nargout 
	varargout{1} = S;
end
if nargout >= 2
	varargout{2} = Sreal;
end
if nargout >= 3
	varargout{3} = Sphase_deg;
end
if nargout == 4
	varargout{4} = F;
end
