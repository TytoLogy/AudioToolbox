function [Smag, Sphase, S, F] = FFTscaled(s, Fs)
% [Smag, Sphase, S, F] = FFTscaled(s, Fs)
%
% Scaled FFT (magnitude and phase)
% 
% Input Arguments:
% 	s			input signal
%	Fs			Sampling rate
%
% Output Arguments:
% 	Smag		magnitude
%	Sphase	phase (in radians, unwrapped)
%	S			total FFT vector (complex)
%	F			Frequency vector for Smag and Sphase (useful in plots)
%
% See also: IFFTscaled, buildfft, ifft, fft, fftplot
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%------------------------------------------------------------------------
%  Sharad Shanbhag
%	sshanbha@aecom.yu.edu
%------------------------------------------------------------------------
%	Created: 9 January, 2009
%
%	Revisions:
%------------------------------------------------------------------------

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Check if input arguments are ok
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	if nargin ~= 2
		error([mfilename ': improper input arguments'])
	end

	% Make sure input args are in bounds
	if Fs <= 1
		error([mfilename ': Fs is less than zero']);
	end
	
	[M, N] = size(s);
	if N ~= 1 & M ~= 1
		error([mfilename ': s must be a vector'])
	else
		if N == 1
			s = s';
			[M, N] = size(s);
		end
	end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% FFT the signal
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	% for speed's sake, get the nearest power of 2 to the desired output length
	NFFT = 2.^(nextpow2(N));
	
	% FFT
	S = fft(s, NFFT);

	%non-redundant points are kept
	% S(0) is constant (DC), S(1 + NFFT/2) = Fnyq)
	Nunique = 1:(1 + NFFT/2);
	
	% Scale the magnitude by the # of real points in the vector s
	% since the MATLAB version of FFT doesn't account for the 
	% vector length
	Smag = abs(S(Nunique))/N;
	
	% Then multiply by 2 since 1/2 of the power (at neg. freqs) is being
	% tossed away for the real signal (but avoid multiplying the DC part!)
	Smag(2:end) = 2*Smag(2:end);
	
	% compute the phase
	Sphase = angle(S(Nunique));
	
	if nargout == 4
		% This is an evenly spaced frequency vector with Nunique points.
		% scaled by the Nyquist frequency (Fn ==1/2 sample freq.)	
 		dF = Fs/(NFFT);
		% net frequency vector
 		F = dF * (Nunique-1);
%  		F = (Fs/2)*linspace(0, 1, NFFT/2); % old method
		
		
	end
