function [S, Smag, Sphase, Freq] = fftplot(s, Fs, f)
% [S, Smag, Sphase, Freq] = fftplot(s, Fs, f)
%
%  plots the signal, FFT magnitude, and FFT phase
%
%	Input:
%		s		= signal vector
%		Fs		= sampling rate
%		f		= figure number 
%					optional, will generate new figure if
%					not specified
%
%	Output:
%		S		 = full FFT
%		Smag	 = FFT magnitude
%		Sphase = FFT phase (in unwrapped radians)
%		Freq	 = Freq vector (used for plot)
%
%	See Also: fftdbplot
%------------------------------------------------------------------------

%------------------------------------------------------------------------
%  Sharad Shanbhag
%	sshanbhag@neomed.edu
%------------------------------------------------------------------------
% Created: ?????
%
% Revisions:
% 	2 Jan 2009, SJS:
% 		- revised scaling of Smag
% 		- cleaned up some messy code
% 		- cleaned up comments
%	7 Sep 2012 (SJS):
%	 -	changed email address
% 	 -	fixed FFT length issue in freq and spectra
% 			length should be (NFFT/2) + 1, not NFFT/2
%------------------------------------------------------------------------

if nargin < 2
	error('fftplot: must specify Fs');
end
if min(size(s)) > 1
	error('fftplot: s must be a vector, not an array')
end
if nargin == 3
	figure(f)
else
	figure
end

varname = inputname(1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% OLD ALGORITHM
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % now compute the FFT with NFFT points
% NFFT = 2^nextpow2(N);
% S = fft(s, NFFT);
% 
% %non-redundant points are kept
% Nunique = ceil((NFFT+1)/2);
% Sunique = S(1:Nunique);
% Sreal = abs(Sunique).*(2/N);
% Sphase = angle(Sunique);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% now compute the FFT with NFFT points
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% length of signal
N = length(s);

% go to next power of 2 for speed's sake
NFFT = 2.^(nextpow2(N));
% run the FFT
S = fft(s, NFFT);

%non-redundant points are kept
% 7 sep 2012 (SJS): changed from nfft/2 into (nfft/2) + 1
Nunique = (NFFT/2) + 1;
Sunique = S(1:Nunique);

% get the magnitudes of the FFT, divide by N (length of input signal) &
% scale by 2 because we're taking only
% half of the points from the "full" FFT vector S;
Smag = abs(Sunique)/N;
Smag(2:end) = 2*Smag(2:end);
Sphase = angle(Sunique);

% This is an evenly spaced frequency vector with Nunique points.
% scaled by the Nyquist frequency (Fn ==1/2 sample freq.)
Freq = (Fs/2)*linspace(0, 1, Nunique);

% generate time vector
time = ([1:N]-1) / Fs;

subplot(3, 1, 1), plot(time, s);
ylabel('Input Signal'); xlabel('time(s)')
title(varname);

subplot(3, 1, 2), plot(Freq, Smag);
ylabel('FFT Magnitude'); xlabel('Frequency')

subplot(3, 1, 3), plot(Freq, unwrap(Sphase));
ylabel('FFT Phase (rad)'); xlabel('Frequency')

Sphase = unwrap(Sphase);
