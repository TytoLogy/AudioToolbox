function [H, I, Freq] = golay_impulse(A, B, Ar, Br, Fs)
%------------------------------------------------------------------------
% [H, I, Freq] = golay_impulse(A, B, Ar, Br, Fs)
%------------------------------------------------------------------------
% Algorithm:
%
% barring some adjustments for real-world data, 
%
% 	H = {FFT(Ar)*conj(FFT(A)) + FFT(Br)*conj(FFT(B))}
% 	    ---------------------------------------------
% 		                     2*L
%	I = iFFT(H)
% 
% Based on technique described in Zhou, et al., J Acoust Soc Am.  (1992) 
% 92(2 Pt 1):1169-71 "Characterization of external ear impulse 
% responses using Golay codes."
% 
%------------------------------------------------------------------------
% Input arguments:
% 	A, B		complementary pairs
% 	Ar, Br	responses to pairs
% 	Fs			sampling rate for data
% 
% Output arguments:
%	H			tranfer function (complex)
%	I			impulse response
%	Freq		frequency vector for plotting
%
%------------------------------------------------------------------------
% See also:	golay_pair, golay_tfe
%------------------------------------------------------------------------

%------------------------------------------------------------------------
%  Sharad Shanbhag
%	sharad.shanbhag@einstein.yu.edu
%------------------------------------------------------------------------
% Created:	10 October, 2007
%			adapted from golay_tfe(..)
% Revisions:
%	9 June, 2009:	profiled with mlint (SJS)	
% 	18 March, 2010 (SJS): updated comments/documentation
%------------------------------------------------------------------------

global DEBUG;

%define some variables/constants
% **should probably check that length of Ar == Br but I'm lazy
L = length(A);
N = length(Ar);
M = 1 + L/2;

% pad the pairs to a power of 2 to speed up the FFT
nfft = 2^nextpow2(L);

% de-mean data (as suggested by Anthony Leonardo)
% to remove potentially confusing DC offsets
Ai = A - mean(A);
Bi = B - mean(B);
Ao = Ar - mean(Ar);
Bo = Br - mean(Br);

%FFT of sequences a & b
ffta = fft(Ai, nfft);
fftb = fft(Bi, nfft);

%get the FFTs of the responses
fftar = fft(Ar, nfft);
fftbr = fft(Br, nfft);

size(fftar)
size(ffta)

%multiply the response and the conjugate of the raw sequence ffts
AHw = fftar .* conj(ffta);
BHw = fftbr .* conj(fftb);

%transfer function 
H = (AHw + BHw) ./ (2*L);

% impuse response
I = real(ifft(H, nfft));

%freq vector
Freq = (0:M-1) * Fs/L;	



