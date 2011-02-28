function [S, Smag, Sphase, Freq] = fftbinauralplot(s, Fs, f)
%[S, Smag, Sphase, Freq] = fftbinauralplot(s, Fs, f)
%
% plots the signal, FFT magnitude, and FFT phase for binaural sounds s
%
%------------------------------------------------------------------------
%	Input:
%		s		signal vector
%		Fs		sampling rate
%		f		figure number 
%					optional, will generate new figure if
%					not specified
%------------------------------------------------------------------------
%	Output:
%		S		 full FFT
%		Smag	 FFT magnitude
%		Sphase FFT phase (in unwrapped radians)
%		Freq	 Freq vector (used for plot)
%
%------------------------------------------------------------------------
%	See Also: fftplot, fftdbplot
%------------------------------------------------------------------------

%------------------------------------------------------------------------
%  Sharad Shanbhag
%	sharad.shanbhag@einstein.yu.edu
%------------------------------------------------------------------------
% Created: 16 November, 2009
%
% Revisions:
%------------------------------------------------------------------------

if nargin < 2
	error([mfilename ': must specify Fs']);
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
[n, m] = size(s);

% make sure dimensions are correct
if n > m
	s = s';
end


% go to next power of 2 for speed's sake
N = length(s);
NFFT = 2.^(nextpow2(N));
% run the FFT
S(1, :) = fft(s(1, :), NFFT);
S(2, :) = fft(s(2, :), NFFT);

%non-redundant points are kept
Nunique = NFFT/2;
Sunique(:, 1:Nunique) = S(:, 1:Nunique);

% get the magnitudes of the FFT scale by 2 because we're taking only
% half of the points from the "full" FFT vector S;
Smag = abs(Sunique)/N;
Smag(:, 2:end) = 2*Smag(:, 2:end);
Sphase = angle(Sunique);

% This is an evenly spaced frequency vector with Nunique points.
% scaled by the Nyquist frequency (Fn ==1/2 sample freq.)
F = (Fs/2)*linspace(0, 1, NFFT/2);

% generate time vector
time = ([1:N]-1) / Fs;

subplot(3, 1, 1)
plot(time, s(1, :), 'g', time, s(2, :), 'r');
ylabel('Input Signal'); xlabel('time(s)')
title(varname);

subplot(3, 1, 2)
plot(F, Smag(1, :), 'g', F, Smag(2, :), 'r');
ylabel('FFT Magnitude'); xlabel('Frequency')

subplot(3, 1, 3), plot(F, unwrap(Sphase));
plot(F, unwrap(Sphase(1, :)), 'g', F, unwrap(Sphase(2, :)), 'r');
ylabel('FFT Phase (deg)'); xlabel('Frequency')

Sphase = unwrap(Sphase);
