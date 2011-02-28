function [S, Smag, Sphase]  = synnoise_fft(duration, Fs, low, high, usitd, scale, caldata)
%[S, Smag, Sphase]  = synnoise_fft(duration, Fs, low, high, usitd, scale, caldata)
%
% Input Arguments:
%	dur		= signal duration (ms)
%	Fs 		= output sampling rate
%	low 	= low frequency cutoff
% 	high 	= high frequency cutoff
%	usitd 	= interaural time difference in us (ignored if mono signal)
%	scale	= rms scale factor.  if [1X2], a stereo signal is specified,
%				in the form [lscale rscale]
%	caldata = caldata structure (caldata.mag, caldata.freq, caldata.phase)
%				if no calibration is desired, replace caldata with value 0
%
% Returned arguments:
%	S		= [1XN] array for mono signals, [2XN] for stereo
%				L channel is row 1, R channel is row 2
%

%-----------------------------------------------------------------------------
% Sharad J. Shanbhag
% sshanbhag@aecom.yu.edu
%
% 	Algorithm and code adapted from synth library of XDPHYS project, 
%	developed in Mark Konishi's lab at Caltech 
%	by Jamie Mazer and Ben Arthur.
%-----------------------------------------------------------------------------
% Revision History
%	19 September, 2002 (SJS):
%		-modified to include support for 2-channels of audio (i.e., stereo)
%		-Note that it is assumed that the bandwidth for both audio channels
%		 will be identical (fft_freqs passed get_cal for L and R channels is 
%		 identical
%--------------------------------------------------------------------------

% do some basic checks on the input arguments
if nargin ~= 7
	error('synnoise_fft: incorrect number of input arguments');
end

if duration <=0
	error('synnoise_fft: duration must be > 0')
end
if low > high
	error('synnoise_fft: low freq must be < high freq limit');
end

CAL = 0;
if isstruct(caldata)
	CAL = 1;
end

STEREO = 1;
if sum(size(scale)) ~= 2
	STEREO = 2;
end

% compute # of samples in stim
stimlen = ms2bin(duration, Fs);

% for speed's sake, get the nearest power of 2 to the desired output length
fftlen = 2.^(nextpow2(stimlen));

% generate the frequency bounds for the FFT
% this saves us from having to use a for loop to 
% assign the values
fstep = Fs/(fftlen-1);
f_start_bin = round(low/fstep);
f_end_bin = round(high/fstep)-1;
f_bins = f_start_bin:f_end_bin;
fft_freqs = fstep*(f_start_bin:f_end_bin);
freqbins = length(fft_freqs);

% initialize and assign values to the FFT arrays
fftbins = 1+floor(fftlen/2);
Smag = zeros(STEREO, fftbins);
Sphase = Smag;

% compute the phases
% rand_phases = pi * limited_uniform(STEREO, freqbins);
rand_phases = pi * limited_uniform(1, freqbins);
itd_phases = (usitd/1e6) * 2 * pi * fft_freqs;

% get the calibration magnitudes and phases
if CAL
	[mags(1, :), phases(1, :)] = get_cal(fft_freqs, caldata.freq(1, :), caldata.mag(1, :), caldata.phase(1, :));
	if STEREO
		[mags(2, :), phases(2, :)] = get_cal(fft_freqs, caldata.freq(1, :), caldata.mag(2, :), caldata.phase(2, :));
	end		
else
	mags = ones(STEREO, freqbins);	% mags = 1 for uncalibrated data
	phases = 0.0*mags;				% phases = 0 for uncalibrated data
end
	
% apply the correction factors (if CAL is spec'd) and scale the magnitude data
% 	Smag(f_start_bin:f_end_bin) = (mags.^-1) * (2 / fftbins);
Smag(:, f_start_bin:f_end_bin) = fftbins * 0.5 * mags;
	
% assign phases for left (mono) channel
Sphase(1, f_start_bin:f_end_bin) = rand_phases + phases(1, :);

% assign phases for right channel and apply the itd phase adjustment
if STEREO == 2
% 	Sphase(2, f_start_bin:f_end_bin) = rand_phases(1, :) + phases(2, :) - itd_phases;
	Sphase(2, f_start_bin:f_end_bin) = rand_phases(1, :) + phases(2, :) + itd_phases;
end

% build the full FFT arrays
Sred = complex(Smag.*cos(Sphase), Smag.*sin(Sphase));
Sfull_L = buildfft(Sred(1, :));
if STEREO ==2
	Sfull_R = buildfft(Sred(2, :));
end

%generate the ifft
Sraw_L = ifft(Sfull_L, fftlen);
S = normalize(real(Sraw_L(1:stimlen)));
if STEREO == 2
	Sraw_R = ifft(Sfull_R, fftlen);
	S = [S; normalize(real(Sraw_R(1:stimlen)))];
end



