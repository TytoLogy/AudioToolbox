function [S, Smag, Sphi, F] = fftplot2(s, Fs, f)
% function [S, Smag, Sphi] = fftplot(s, Fs, f)
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
%		F		= frequency vector
%
% Sharad Shanbhag
% sharad@etho.caltech.edu

if nargin < 2
	error('fftplot2: must specify Fs');
end

if min(size(s)) > 1
	error('fftplot2: s must be a vector, not an array')
end
if nargin == 3
	figure(f)
else
	figure
end

N = length(s);

% generate time vector
time = [1:N] / Fs;

subplot(3, 1, 1), plot(time, s);
ylabel('Input Signal'); xlabel('time(s)')

% now compute the FFT with N points
NFFT = N;
S = fft(s, NFFT);

%non-redundant points are kept
%Nunique = ceil((NFFT+1)/2);
Nunique = ceil((NFFT)/2);
Sunique = S(1:Nunique);
Sreal = abs(Sunique);
Sreal(2:Nunique) = Sreal(2:Nunique).*(2/N);
Sphase = angle(Sunique);

% This is an evenly spaced frequency vector with
% Nunique points.
%freq=(0:Nunique-1)*2/NFFT;
freq=(0:Nunique-1)*2/NFFT;
% Multiply this by the Nyquist frequency 
% (Fn ==1/2 sample freq.)
freq=freq.*Fs.*0.5;

subplot(3, 1, 2), plot(freq, 20*log10(Sreal));
ylabel('FFT Magnitude (dB)'); xlabel('Frequency')

subplot(3, 1, 3), plot(freq, rad2deg(unwrap(Sphase)));
ylabel('FFT Phase (deg)'); xlabel('Frequency')


switch nargout
	case 1,
		S = S;
	case 2,
		S = S;
		Smag = Sreal;
	case 3,
		S = S;
		Smag = Sreal;
		Sphi = rad2deg(unwrap(Sphase));
	case 4,
		S = S;
		Smag = Sreal;
		Sphi = rad2deg(unwrap(Sphase));
		F = freq;
	otherwise
		S = S;
end
