function [S, Sdata]  = spltestnoise(duration, Fs, low, high, scale)
% function [S, Sdata] = spltestnoise(duration,Fs,low,high,scale)
%
% Input Arguments:
%	dur		= signal duration (ms)
%	Fs 		= output sampling rate
%	low 	= low frequency cutoff
% 	high 	= high frequency cutoff
%	scale	= rms scale factor. 
%
% Returned arguments:
%	S		= [1XN] array 
%	Sdata	= struct
% 		Sdata.mag = Smag;
% 		Sdata.phase = Sphase;
% 		Sdata.Scale = max(S) * sqrt(floor((high-low)/(Fs/(fftlen-1))));
% 		Sdata.F = fft_freqs;
% 

%--------------------------------------------------------------------------
% Sharad J. Shanbhag
% sshanbha@aecom.yu.edu
% 	Code adapted from XDPHYS synth library developed by
% 	Jamie Mazer and Ben Arthur
%--------------------------------------------------------------------------
% Revision History
%	30 November, 2007 (SJS)
% 		-program forked off of synnoise_fft
% 
%--------------------------------------------------------------------------


% do some basic checks on the input arguments
if nargin < 4
	error('flatmononoise: incorrect number of input arguments');
end
if nargin == 4
	scale = 1;
end

if duration <= 0
	error('flatmononoise: duration must be > 0 ms')
end
if low > high
	error('flatmononoise: low freq must be < high freq limit');
end

% convert duration to seconds, compute # of samples in stim
duration = 0.001 * duration;
stimlen = ceil(Fs * duration);

% for speed's sake, get the nearest power of 2 to the desired output length
fftlen = 2.^(nextpow2(stimlen));

% generate the frequency bounds for the FFT
% this saves us from having to use a for loop to 
% assign the values
fstep = Fs/(fftlen-1);
f_start_bin = round(low/fstep);
if f_start_bin == 0
	f_start_bin = 1;
end
f_end_bin = round(high/fstep)-1;
fft_freqs = fstep*(f_start_bin:f_end_bin);
freqbins = length(fft_freqs);

% initialize and assign values to the FFT arrays
fftbins = 1+floor(fftlen/2);
Smag = zeros(1, fftbins);
Sphase = Smag;

% mags = 1 for flat noise
mags = ones(1, freqbins);
	
% assign magnituded data
Smag(f_start_bin:f_end_bin) = scale .* mags;

% assign phases
Sphase(f_start_bin:f_end_bin) = pi * limited_uniform(1, freqbins);

% build the full FFT arrays
% ifft needs complex numbers
Sred = complex(Smag.*cos(Sphase), Smag.*sin(Sphase));
Sfull = buildfft(Sred);

%generate the ifft
Sraw = ifft(Sfull, fftlen);
% get the real part of the stimulus, use only stimlen points
S = real(Sraw(1:stimlen));
% normalize to rms == 1
S = S ./ rms(S);

% return diagnostic data
if nargout == 2
	Sdata.mag = Smag;
	Sdata.phase = Sphase;
	Sdata.Scale = max(S) * sqrt( floor( (high-low) / (Fs / (fftlen -1)) ));
  	Sdata.F = fft_freqs;
end
