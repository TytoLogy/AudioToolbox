function [s, S] = IFFTscaled(Smag, Sphase, StimLength)
% [s, S] = IFFTscaled(Smag, Sphase, StimLength)
%
% Inverse FFT using spectrum (real) specified by Smag and Sphase
% 
% Input Arguments:
% 	Smag			magnitude
%	Sphase		phase (in radians)
%	StimLength	# of points in stimulus
%
% Output Arguments:
% 	s			synthesized signal
%	S			total FFT vector (complex)
%
% See also: FFTscaled, fft, fftplot, buildfft
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%------------------------------------------------------------------------
%  Sharad Shanbhag
%	sshanbha@aecom.yu.edu
%------------------------------------------------------------------------
%	Created: 10 January, 2009
%
%	Revisions:
%		23 January, 2009 (SJS):
% 			-	changed call to ifft, eliminating the NFFT argument, as the
% 				fft vector, S, is already conjugate symmetric
%------------------------------------------------------------------------

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Check if input arguments are ok
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	if nargin ~= 3
		error([mfilename ': improper input arguments'])
	end

	% Make sure input args are in bounds
	if StimLength <= 0
		error([mfilename ': StimLength <= 0']);
	end
	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% first, build the full FFT array, S in Matlab format
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	% Scale the FFT magnitude by 0.5 * (Length of Smag)
 	Smag = 0.5 * length(Smag) * Smag;
	
	% Sreduced is the complex form of the spectrum
	Sreduced = complex(Smag.*cos(Sphase), Smag.*sin(Sphase));
	
	% build the total FFT vector
	S = buildfft(Sreduced);
	
	% NFFT is # of points in the net spectrom
	NFFT = length(S);
	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% then, iFFT the signal
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	s = ifft(S);

	% keep only points we need
	s = s(1:StimLength);
