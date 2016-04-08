function varargout = fftdbplot(s, Fs, f)
% [S, Smag, Sphi, F] = fftplot(s, Fs, f)
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
%		S		= full FFT
%		Smag	= FFT magnitude
%		Sphi	= FFT phase (in unwrapped degrees)
%		F		= frequency vector for Smag, Sphi
%	See Also: fftplot

%
% Sharad Shanbhag
% sshanbhag@neomed.edu

if nargin < 2
	error('fftdbplot: must specify Fs');
end

if min(size(s)) > 1
	error('fftdbplot: s must be a vector, not an array')
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

N = length(s);

% go to next power of 2 for speed's sake
NFFT = 2.^(nextpow2(N));
% run the FFT
S = fft(s, NFFT)/N;

%non-redundant points are kept
Nunique = NFFT/2;
Sunique = S(1:Nunique);

% get the magnitudes of the FFT scale by 2 because we're taking only
% half of the points from the "full" FFT vector S;
Sreal = 2*abs(Sunique); 
Sphase = angle(Sunique);

% This is an evenly spaced frequency vector with Nunique points.
% scaled by the Nyquist frequency (Fn ==1/2 sample freq.)
F = Fs/2*linspace(0,1,NFFT/2);

%non-redundant points are kept
Nunique = NFFT/2;
Sunique = S(1:Nunique);
Sreal = 2*abs(Sunique);
Sphase = angle(Sunique);

% generate time vector
time = ([1:N] - 1) / Fs;

subplot(3, 1, 1), plot(time, s);
ylabel('Input Signal'); xlabel('time(s)')
title(varname);

subplot(3, 1, 2), plot(F, db(Sreal));
ylabel('FFT Magnitude (dB)'); xlabel('Frequency')

subplot(3, 1, 3), plot(F, rad2deg(unwrap(Sphase)));
ylabel('FFT Phase (deg)'); xlabel('Frequency')

if nargout 
	varargout{1} = S;
end
if nargout >= 2
	varargout{2} = Sreal;
end
if nargout >= 3
	varargout{3} = rad2deg(unwrap(Sphase));
end
if nargout == 4
	varargout{4} = F;
end
