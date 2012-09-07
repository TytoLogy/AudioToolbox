function fftfull = buildfft(fftred)
%-------------------------------------------------------------------------
% fftfull = buildfft(fftred)
%-------------------------------------------------------------------------
% AudioToolbox:FFT
%-------------------------------------------------------------------------
%
%	Given the N+1 points of fftred, buildfft() constructs the length 2N
%	array fftfull
%
%	if y = fft(x):
%		y(1) = constant
%		y(2) = f1
%		y(3) = f2
%		y(1 + N/2) = fmax
%		y(N) = y*(2)
%		y(N-1) = y*(3)
%
%-------------------------------------------------------------------------
% Input Arguments:
% 	fftred		complex form of the "single-sided spectrum"
%
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
%---------------------------------------------------------------------

% N is total number of points in the spectrum
N = length(fftred);

% allocate the net spectrum fftfull
fftfull = zeros(1, 2*N);

% first portion of fftfull is same as fftred
% leave out the DC component (fftred(1))
fftfull(2:N) = fftred(2:N);

% second portion is complex conjugate of Sreduced and in reverse order
% (setting  DC component to zero which is at fftreduced(1) and fftfull(end))

fftfull((N+1):((2*N)-1)) = conj(fftred(N:-1:2));



