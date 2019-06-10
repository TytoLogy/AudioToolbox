function varargout = fftdbmagplot(s, Fs, varargin)
%--------------------------------------------------------------------------
% [S, Smag, Sphi, F] = fftdbmagplot(s, Fs, f)
%--------------------------------------------------------------------------
%	Audio Toolbox: FFT
%-------------------------------------------------------------------------
%  plots the signal, FFT magnitude, and FFT phase
%-------------------------------------------------------------------------
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
%		F		= frequency vector for Smag, Sphi
%-------------------------------------------------------------------------
%	See Also: fftplot
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
%  Sharad Shanbhag
%	sshanbhag@neomed.edu
%-------------------------------------------------------------------------
% Created: 10 Jun 2019 from fftdbplot, SJS
%
% Revisions:
%--------------------------------------------------------------------------

%------------------------------------------------------------------------
% Check Inputs
%------------------------------------------------------------------------
if nargin < 2
	error('%s: must specify Fs', mfilename);
end

if min(size(s)) > 1
	error('%s: s must be a vector, not an array', mfilename)
end
if nargin == 3
	f = varargin{1};
	figure(f);
else
	figure;
end

%------------------------------------------------------------------------
% now compute the FFT with NFFT points
%------------------------------------------------------------------------
N = length(s);

% go to next power of 2 for speed's sake
NFFT = 2.^(nextpow2(N));
% run the FFT
S = fft(s, NFFT);

%non-redundant points are kept
Nunique = NFFT/2 + 1;
Sunique = S(1:Nunique);

% get the magnitudes of the FFT scale by 2 because we're taking only
% half of the points from the "full" FFT vector S;
Sreal = abs(Sunique)/N; 
Sreal(2:end) = 2*Sreal(2:end);
% This is an evenly spaced frequency vector with Nunique points.
% scaled by the Nyquist frequency (Fn ==1/2 sample freq.)
F = (Fs/2)*linspace(0, 1, Nunique);
plot(F, db(Sreal));
ylabel('FFT Magnitude (dB)'); xlabel('Frequency')

if nargout 
	varargout{1} = S;
end
if nargout >= 2
	varargout{2} = Sreal;
end
if nargout >= 3
	varargout{4} = F;
end
