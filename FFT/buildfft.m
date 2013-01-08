function fftfull = buildfft(fftred)
%-------------------------------------------------------------------------
% fftfull = buildfft(fftred)
%-------------------------------------------------------------------------
% AudioToolbox:FFT
%-------------------------------------------------------------------------
%
%	Given the N points of fftred, buildfft() constructs the 
%  length 2*(N-1) array fftfull
%
%	if y = fft(x):
%		y(1) = constant
%		y(2) = f1
%		y(3) = f2
%		y(N) = fmax
%		y(N+1) = y*(N-1)
%		y(N+2) = y*(N-2)
%		y(2*N) = y*(1)
%
%		where * indicates complex conjugate
%
%	this function is used by the various synthesis routines 
%-------------------------------------------------------------------------
% Input Arguments:
% 	fftred		complex form of the "single-sided spectrum"
% 					should have form:
% 							fftred(1) = freq(0) (constant term)
% 							fftred(2) = freq(1)
% 							fftred(3) = freq(2)
% 							.
% 							.
% 							.
% 							fftred(N) = freq(N-1) (max freq term)
%-------------------------------------------------------------------------
% Output Arguments:
% 	fftfull		complex, 2-sided (MATLAB) format spectrum, useful for ifft
%
%-------------------------------------------------------------------------
% See Also: fft, ifft, syn_headphonenoise, syn_headphonenoise_fft
%-------------------------------------------------------------------------
%	Audio Toolbox
%-------------------------------------------------------------------------

%---------------------------------------------------------------------
%	Sharad Shanbhag
%	sshanbhag@neomed.edu
%
%--Revision History---------------------------------------------------
%	12 Feb, 2008, SJS:	created
%	10 Jan, 2009, SJS:
%		- edit comments to make consistent with rest of package
%	23 August, 2010 (SJS): updated comments & documentation
%	6 Sep 2012 (SJS):
%		- updated comments
% 		- fixed issue with length of final vector
%	17 Sep 2012 (SJS): fixed bug in building fftfull array
%---------------------------------------------------------------------

% N is total number of points in the reduced spectrum
N = length(fftred);
% NFFT is final fft vector length
NFFT = 2*(N-1);
% allocate fftfull output vector
fftfull = zeros(1, NFFT);
% first part of fftfull is fftred
fftfull(1:N) = fftred;
% second section is computed as:
%	(1) take fftred(2:(end-1)), since final point (fftred(end)) 
% 		 is common to both sections
% 	(2) flip the fftred section around using fliplr (reverse order)
% 	(3) take complex conjugate of flipped fftred
fftfull((N+1):end) = conj(fliplr(fftred(2:(end-1))));
