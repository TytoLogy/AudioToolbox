function [S, Smag, Sphi]  = synnoise_fft(duration, Fs, low, high, use_cal, cal_freq, cal_mag, cal_phi)
%function [S, Smag, Sphi]  = synnoise_fft(duration, Fs, low, high, caldata)
%	duration = time of stimulus in ms
%	Fs = output sampling rate
%	low = low frequency cutoff
% 	high = high frequency cutoff
%	caldata = caldata structure (caldata.mag, caldata.freq, caldata.phi)
%	if no calibration is desired, replace caldata with a single numerical value
%
%	Sharad Shanbhag
%	sharad@etho.caltech.edu

if nargin ~= 8
	error('synnoise_fft: incorrect number of input arguments');
end

duration = 0.001 * duration;
stimlen = Fs * duration;

%for speed's sake, get the nearest power of 2 to the desired output length
fftexp = ceil(log2(stimlen));
fftlen = 2^fftexp;

% generate the frequency bounds for the FFT
fstep = Fs/(fftlen-1);
f_start_bin = round(low/fstep)+1;
f_end_bin = round(high/fstep)+1;
freqs = fstep*(f_start_bin:f_end_bin);
freqbins = length(freqs);

% initialize and assign values to the FFT arrays
Smag = zeros(1, 1+floor(fftlen/2));
Sphi = Smag;
fftbins = length(Smag);
rand_phis = pi * limited_uniform(1, freqbins);

if use_cal == 1
	% get the calibration magnitudes and phases
	[mags, phis] = get_cal(freqs, cal_freq, cal_mag, cal_phi);
	% apply the correction factors and scale the magnitude data
 	Smag(f_start_bin:f_end_bin) = (mags.^-1) * (2 / fftbins);
	Sphi(f_start_bin:f_end_bin) = rand_phis - phis;
else
	Smag(f_start_bin:f_end_bin) = 2 / fftbins;
	Sphi(f_start_bin:f_end_bin) = rand_phis;
end

% build the full FFT arrays
Sred = complex(Smag.*cos(Sphi), Smag.*sin(Sphi));
Sfull = buildfft(Sred);

%generate the ifft
s_raw = ifft(Sfull, fftlen);
S = normalize(real(s_raw(1:stimlen)));
