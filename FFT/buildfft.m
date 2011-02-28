function fftfull = buildfft(fftred)
%-------------------------------------------------------------------------
% fftfull = buildfft(fftred)
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
%	sshanbhag@neoucom.edu
%
%--Revision History---------------------------------------------------
%	12 Feb, 2008, SJS:	created
%	10 Jan, 2009, SJS:
%		- edit comments to make consistent with rest of package
%	23 August, 2010 (SJS): updated comments & documentaiton
%---------------------------------------------------------------------

% N is total number of points in the spectrum minus DC component 
N = length(fftred) - 1;

% allocate the net spectrum fftfull
fftfull = zeros(1, N*2);

% first portion of fftfull is same as fftred
fftfull(1:(N+1)) = fftred;

% second portion is complex conjugate of Sreduced and in reverse order
% (leaving out DC component which is at Sreduced(1))
fftfull((N+2):(2*N)) = conj(fftred(N:-1:2));


