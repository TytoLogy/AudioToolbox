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
<<<<<<< HEAD
=======
%		where * indicates complex conjugate
%
>>>>>>> origin/sjs_working
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

<<<<<<< HEAD
=======


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


%{

>>>>>>> origin/sjs_working
% N is total number of points in the reduced spectrum
N = length(fftred);
Nunique = N + 1;
% NFFT is length of full spectrum
NFFT = 2*N;

% allocate the net spectrum fftfull
fftfull = zeros(1, NFFT);

%% assign indices into fftfull for the two "sections"
% first portion of fftfull is same as fftred
% also, leave DC component (fftfull(1)) as 0, since it is
% assumed that fftred has only non-DC components
indx1 = 2:Nunique;
% second portion
indx2 = (Nunique+1):NFFT;
<<<<<<< HEAD

fftfull(indx1) = fftred;

% second section is computed as:
%	(1) take fftred(1:(end-1)), since final point (fftred(end)) 
% 		 is common to both sections
% 	(2) flip the fftred section around using fliplr (reverse order)
% 	(3) take complex conjugate of flipped fftred
fftfull(indx2) = conj(fliplr(fftred(1:(end-1))));
=======

fftfull(indx1) = fftred;
>>>>>>> origin/sjs_working

% second section is computed as:
%	(1) take fftred(1:(end-1)), since final point (fftred(end)) 
% 		 is common to both sections
% 	(2) flip the fftred section around using fliplr (reverse order)
% 	(3) take complex conjugate of flipped fftred
fftfull(indx2) = conj(fliplr(fftred(1:(end-1))));
%}

%---------------------------------------------------------------------
%**** original algorithm
%---------------------------------------------------------------------
%{
% N is total number of points in the spectrum minus DC component 
N = length(fftred) - 1;
% allocate the net spectrum fftfull
fftfull = zeros(1, N*2);
% first portion of fftfull is same as fftred
fftfull(1:(N+1)) = fftred;
% second portion is complex conjugate of Sreduced and in reverse order
% (leaving out DC component which is at Sreduced(1))
fftfull((N+2):(2*N)) = conj(fftred(N:-1:2));
%}

