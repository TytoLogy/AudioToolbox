function [S, Smag, Sphase]  = synmononoise_fft(duration, Fs, low, high, scale, caldata)
% function [S, Smag, Sphase]  = synmononoise_fft(duration, Fs, low, high, scale, caldata)
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
% Returned arguments:
%	S		= [1XN] array 
%


%--------------------------------------------------------------------------
% Sharad J. Shanbhag
% sshanbha@aecom.yu.edu
% 	Code adapted from XDPHYS synth library developed by
% 	Jamie Mazer and Ben Arthur
%--------------------------------------------------------------------------
% Revision History
%	21 December, 2007 (SJS)
% 		-created from synnoise_fft
% 
%--------------------------------------------------------------------------

% do some basic checks on the input arguments
if nargin ~= 6
	help synmononoise_fft;
	error('synmononoise_fft: incorrect number of input arguments');
end

if duration <=0
	error('synmononoise_fft: duration must be > 0')
end
if low >= high
	error('synmononoise_fft: low freq must be < high freq limit');
end
if low <= 0 | high <= 0
	error('synmononoise_fft: low  & high  must be greater than 0');
end
if high > Fs ./ 2
	warning('synmononoise_fft: high is greater than Nyquist freq (Fs/2)');
end

CAL = 0;
if isstruct(caldata)
	CAL = 1;
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
f_end_bin = round(high/fstep)-1;
fft_freqs = fstep*(f_start_bin:f_end_bin);
freqbins = length(fft_freqs);

% initialize and assign values to the FFT arrays
fftbins = 1+floor(fftlen/2);
Smag = zeros(1, fftbins);
Sphase = Smag;

% compute the phases
rand_phases = pi * limited_uniform(1, freqbins);
itd_phases = 2 * pi * fft_freqs;

% get the calibration magnitudes and phases
if CAL
	[mags(1, :), phases(1, :)] = get_cal(fft_freqs, caldata.freq(1, :), caldata.mag(1, :), caldata.phase(1, :));
else
	mags = ones(1, freqbins);	% mags = 1 for uncalibrated data
	phases = 0.0*mags;				% phases = 0 for uncalibrated data
end
	
% apply the correction factors (if CAL is spec'd) and scale the magnitude data
% 	Smag(f_start_bin:f_end_bin) = (mags.^-1) * (2 / fftbins);
Smag(1, f_start_bin:f_end_bin) = fftbins * 0.5 * mags;
	
% assign phases 
Sphase(1, f_start_bin:f_end_bin) = rand_phases(1, :) + phases(1, :);

% build the full FFT arrays
Sred = complex(Smag.*cos(Sphase), Smag.*sin(Sphase));
Sfull_L = buildfft(Sred(1, :));

%generate the ifft
Sraw_L = ifft(Sfull_L, fftlen);
S = scale * normalize_rms(real(Sraw_L(1:stimlen)));



