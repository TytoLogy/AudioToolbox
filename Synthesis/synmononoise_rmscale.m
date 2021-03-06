function [S, Smag, Sphase]  = synmononoise_rmscale(duration, Fs, low, high, scale, caldata)
%-------------------------------------------------------------------------
% [S, Smag, Sphase]  = synmononoise_rmscale(duration, Fs, low, high, scale, caldata)
%-------------------------------------------------------------------------
% Synthesis Toolbox
%-------------------------------------------------------------------------
% 
% 	synthesize a single-channel (mono) stimulus, typically for use with 
% 	free-field array.
% 
%	Similar to synmononoise_fft, except that output signal S is
% 	scaled so that rms(S) = scale
%-------------------------------------------------------------------------
% Input Arguments:
%	dur			signal duration (ms)
%	Fs				output sampling rate
%	low			low frequency cutoff
% 	high			high frequency cutoff
%	scale			rms scale factor.  
%	caldata		caldata structure (caldata.mag, caldata.freq, caldata.phase)
%					***if no calibration is desired, replace caldata with value 0
%
% Output arguments:
%	S				[1XN] array, where N = 0.001*dur*Fs
% 
% 	Optional:
% 		Smag, Sphase	Magnitude and phase spectra used to synthesize signal
% 		oStr				diagnostic output string
% 
%-------------------------------------------------------------------------
% See Also: syn_headphone_noise
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
% Sharad J. Shanbhag
% sshanbhag@neoucom.edu
% 	Some elements adapted from XDPHYS synth library developed by
% 	Jamie Mazer and Ben Arthur in the Konishi Lab at Caltech
%--------------------------------------------------------------------------
% Created 9 February, 2011 from synmononoise_fft.m (SJS)
%
% Revision History
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
if (low <= 0) | (high <= 0)
	error('synmononoise_fft: low  & high  must be greater than 0');
end
if high > Fs / 2
	warning('synmononoise_fft: high is greater than Nyquist freq (Fs/2)');
end

CAL = 0;
if isstruct(caldata)
	CAL = 1;
end

% convert duration to seconds, compute # of samples in stim
stimlen = ceil(ms2bin(duration, Fs));

% if no scaling is desired (scale = 0), then return, since work here is
% done!
if scale == 0
	S = zeros(1, stimlen);
	return
end

% for speed's sake, get the nearest power of 2 to the desired output length
NFFT = 2.^(nextpow2(stimlen));

% initialize and assign values to the FFT arrays
fftbins = 1+floor(NFFT/2);
Smag = zeros(1, fftbins);
Sphase = Smag;

% generate the frequency bounds for the FFT
% this saves us from having to use a for loop to 
% assign the values
fstep = Fs/(NFFT);
f_start_bin = round(low/fstep) + 1;
f_end_bin = round(high/fstep) + 1;
f_bins = f_start_bin:f_end_bin;
fft_freqs = fstep*f_bins;
freqbins = length(fft_freqs);

% generate the random phases (for noise)
rand_phases = pi * limited_uniform(1, freqbins);

% get the calibration magnitudes and phases
if CAL
	[mags(1, :), phases(1, :)] = get_cal(fft_freqs, caldata.freq(1, :), caldata.maginv(1, :), caldata.phase(1, :));
else
	mags = (1/freqbins)*ones(1, freqbins);	% mags = 1 for uncalibrated data
	phases = zeros(1, freqbins);		% phases = random for uncalibrated data
end

% Build the magnitude array for the fft of the signal (Smag)
Smag(1, f_bins) = mags(1, :);
% assign phases 
Sphase(1, f_bins) = rand_phases(1, :) + phases(1, :);
% build the full FFT arrays
Sred = complex(Smag.*cos(Sphase), Smag.*sin(Sphase));
Sfull = buildfft(Sred(1, :));
%generate the ifft
Sraw = ifft(Sfull, NFFT);


% cut out the stimulus from raw vector, scale the IFFT
S = (0.5 * Fs / fstep) *real(Sraw(1:stimlen));

% set rms(S) to desired level by first normalizing and then multiplying
% by scale input parameter
S = scale * normalize_rms(S);

% if needed, build the oStr output string
if nargout == 4
	oStr = sprintf('scale: %.2f \t max: %.4f \t rms: %.4f \t dB: %.4f',...
						scale, max(S), rms(S), ...
						dbspl(get_pa_rms(rms(S), caldata.pa_rms, caldata.v_rms)) );
end




