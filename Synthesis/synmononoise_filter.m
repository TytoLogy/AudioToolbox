function [S, Smag, Sphase, oStr]  = synmononoise_filter(duration, Fs, low, high, scale, caldata)
% FFCALALGORITHMS [S, Smag, Sphase]  = synmononoise_filter(duration, Fs, low, high, scale, caldata)
%
% Input Arguments:
%	dur		= signal duration (ms)
%	Fs 		= output sampling rate
%	low 	= low frequency cutoff
% 	high 	= high frequency cutoff
%	scale	= rms scale factor.  
%	caldata = caldata structure (caldata.mag, caldata.freq, caldata.phase)
%				if no calibration is desired, replace caldata with value 0
%
% Output arguments:
%	S		= [1XN] array 
% 
% See Also: synmononoise_fft, synmonosine
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
% Sharad J. Shanbhag
% sshanbha@aecom.yu.edu
% 	Some elements adapted from XDPHYS synth library developed by
% 	Jamie Mazer and Ben Arthur in the Konishi Lab at Caltech
%--------------------------------------------------------------------------
% Revision History
%  2 June, 2009 (SJS):
% 		-created from synmononoise_fft
% 		-	major difference is use of full bandwidth from caldata and then
% 			filtering to [low, high] freq limits using a bandpass 
% 			Chebyshev Type II filter. 
%--------------------------------------------------------------------------

% do some basic checks on the input arguments
if nargin ~= 6
	help synmononoise_filter;
	error([mfilename ': incorrect number of input arguments']);
end

if duration <=0
	error([mfilename ': duration must be > 0'])
end
if low >= high
	error([mfilename ': low freq must be < high freq limit']);
end
if (low <= 0) || (high <= 0)
	error([mfilename ': low  & high  must be greater than 0']);
end
if high > Fs / 2
	warning([mfilename ': high is greater than Nyquist freq (Fs/2)']);
end

filtR = 30;
bandwidth = high-low;
if bandwidth < 10
	filtN = 2;
	warning([mfilename ': bandwidth < 10, output filter order is 2']);
elseif between(bandwidth, 10, 100)
	filtN = 3;
	warning([mfilename ': 10 < bandwidth < 50, output filter order is 3']);
elseif between(bandwidth, 100, 500)
	filtN = 4;
	warning([mfilename ': 10 < bandwidth < 50, output filter order is 4']);
else
	filtN = 5;
end

CAL = 0;
if isstruct(caldata)
	CAL = 1;
end

% convert duration to seconds, compute # of samples in stim
stimlen = ceil(ms2bin(duration, Fs));
synthlen = ceil(1.5*stimlen);
stimstart = round(0.25*stimlen);
stimend = stimstart+stimlen;

% for speed's sake, get the nearest power of 2 to the desired output length
NFFT = 2.^(nextpow2(synthlen));

% initialize and assign values to the FFT arrays
fftbins = 1+floor(NFFT/2);
Smag = zeros(1, fftbins);
Sphase = Smag;

% generate the frequency bounds for the FFT
% this saves us from having to use a for loop to 
% assign the values
fstep = Fs/(NFFT);
if CAL
	f_start_bin = round(caldata.freq(1)/fstep) + 1;
	f_end_bin = floor(caldata.freq(end)/fstep);
else
	f_start_bin = round(low/fstep) + 1;
	f_end_bin = round(high/fstep) + 1;
end
f_bins = f_start_bin:f_end_bin;
fft_freqs = fstep*f_bins;
freqbins = length(fft_freqs);

if scale == 0
	S = zeros(1, stimlen);
	return
end

% generate the random phases (for noise)
rand_phases = pi * limited_uniform(1, freqbins);

% get the calibration magnitudes and phases
if CAL
	[mags(1, :), phases(1, :)] = get_cal(fft_freqs, caldata.freq(1, :), caldata.maginv(1, :), caldata.phase(1, :));
else
	mags = (1/freqbins)*ones(1, freqbins);	% mags = 1 for uncalibrated data
	phases = zeros(1, freqbins);		% phases = random for uncalibrated data
end

% Build the magnitude array for the fft of the signal (Smag) and
% scale by 1/frequency_stepsize in order to preserve Parseval's theorem
Smag(1, f_bins) = mags(1, :)/fstep;

% Scale the magnitude data
Smag = 0.5 * Fs * Smag;
	
% assign phases 
Sphase(1, f_bins) = rand_phases(1, :) + phases(1, :);

% build the full FFT arrays
Sred = complex(Smag.*cos(Sphase), Smag.*sin(Sphase));
Sfull = buildfft(Sred(1, :));

%perform the ifft
Sraw = ifft(Sfull, NFFT);

% normalize
Stmp = scale * normalize_rms(real(Sraw));

% create output filter
% n = 3; r = 30;
Wn = 2 * [low high]/Fs;
[b,a] = cheby2(filtN, filtR, Wn);

% filter signal to give proper bandwidth [low high]
S = filtfilt(b, a, Stmp);
S = S(stimstart:stimend);


% Some things for debugging...
% fftplot(Stmp, Fs, figure(31));
% fftplot(S, Fs, figure(32));
% 
oStr = sprintf('scale: %.2f \t max: %.4f \t rms: %.4f',...
					scale, max(S), rms(S));





