function [S, Smag, Sphi, Freq] = fftanalyze(s, Fs)
% [S, Smag, Sphi, Freq] = fftanalyze(s, Fs)
%
%  computes the FFT magnitude (Smag), and FFT phase (Sphi) of 
%	signal (s) sampled at rate Fs
%
%	Input:
%		s		= signal vector
%		Fs		= sampling rate
%
%	Output:
%		S		= full FFT (a +_ ib)
%		Smag	= FFT magnitude
%		Sphi	= FFT phase (in unwrapped degrees)
%		Freq	= Freq vector (used for plot)
%
%	See Also: fftplot, fftdbplot

%------------------------------------------------------------------------
%  Sharad Shanbhag
%	sshanbha@aecom.yu.edu
%------------------------------------------------------------------------
% Created: 27 October, 2008
%		- adapted from fftplot
%
% Revisions:
%------------------------------------------------------------------------

	if nargin < 2
		error('fftanalyze: must specify Fs');
	end
	if min(size(s)) > 1
		error('analyze: s must be a vector, not an array')
	end

	varname = inputname(1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% OLD ALGORITHM
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 	% now compute the FFT with NFFT points
% 	NFFT = 2^nextpow2(N);
% 	S = fft(s, NFFT);
% 
% 	%non-redundant points are kept
% 	Nunique = ceil((NFFT+1)/2);
% 	Sunique = S(1:Nunique);
% 	Sreal = abs(Sunique).*(2/N);
% 	Sphase = angle(Sunique);

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

	if nargout == 2
		Smag = Sreal;
	elseif nargout == 3
		Smag = Sreal;
		Sphi = rad2deg(unwrap(Sphase));
	elseif nargout == 4
		Smag = Sreal;
		Sphi = rad2deg(unwrap(Sphase));
		Freq = F;
	end
