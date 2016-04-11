function [S, Smag, Sphase, oStr]  = synmononoise_fft(duration, Fs, low, high, scale, caldata)
%-------------------------------------------------------------------------
% [S, Smag, Sphase, oStr]  = synmononoise_fft(duration, Fs, low, high, scale, caldata)
%-------------------------------------------------------------------------
%	Audio Toolbox: Synthesis
%-------------------------------------------------------------------------
% 
% 	synthesize a single-channel (mono) stimulus, typically for use with 
% 	free-field array.
% 
%-------------------------------------------------------------------------
% Input Arguments:
%	dur			signal duration (ms)
%	Fs				output sampling rate
%	low			low frequency cutoff
% 	high			high frequency cutoff
%	scale			rms scale factor.  
%	caldata		caldata structure (caldata.mag, caldata.freq, caldata.phase)
%					***if no calibration is desired, replace 
%						caldata with value 0
%
% Output arguments:
%	S				[1XN] array, where N = 0.001*dur*Fs
% 
% 	Optional:
% 		Smag, Sphase	Magnitude and phase spectra used to synthesize signal
% 		oStr				diagnostic output string
% 
%-------------------------------------------------------------------------
% See Also: syn_headphone_noise, syn_headphonenoise_fft
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
% Sharad J. Shanbhag
% sshanbhag@neomed.edu
% 	Some elements adapted from XDPHYS synth library developed by
% 	Jamie Mazer and Ben Arthur in the Konishi Lab at Caltech
%--------------------------------------------------------------------------
% Revision History
%	21 December, 2007 (SJS)
% 		-created from synnoise_fft
%  1 June, 2009 (SJS):
%		- fixed scaling issues!  
%		- added computation of Scale values by rms() function, removed old
%		  broken-down code that was incorrect (normalization)
%		- added division of mags by 1/freqstep in order to preserve
%		  Parseval's theorem
%	11 March, 2010 (SJS): updated comments
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
% do some basic checks on the input arguments
%--------------------------------------------------------------------------
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
if (low <= 0) || (high <= 0)
	error('synmononoise_fft: low  & high  must be greater than 0');
end
if high > Fs / 2
	warning('synmononoise_fft: high is greater than Nyquist freq (Fs/2)');
	high = floor(Fs/2);
	fprintf('\tUsing highest possible frequency (%d Hz)\n', high);
end

CAL = 0;
if isstruct(caldata)
	CAL = 1;
end

%--------------------------------------------------------------------------
% convert duration to seconds, compute # of samples in stim
%--------------------------------------------------------------------------
stimsamples = ceil(ms2bin(duration, Fs));

%--------------------------------------------------------------------------
% forget going ahead if scale is 0
%--------------------------------------------------------------------------
if scale == 0
	S = zeros(1, stimsamples);
	return
end

%--------------------------------------------------------------------------
% for speed's sake, get the nearest power of 2 to the desired output length
%--------------------------------------------------------------------------
NFFT = 2.^(nextpow2(stimsamples));

%--------------------------------------------------------------------------
% initialize and assign values to the FFT arrays
%--------------------------------------------------------------------------
% # of bins for the 1 sided FFT magnitude and phase vectors (Smag, Sphase)
% add 1 bin for DC component (1st bin) and reduce by factor of 2 since
% Matlab will want a 2-sided FFT for inverse (which will be built by the 
% call to buildfft later on)
fftbins = 1+floor(NFFT/2);
% allocate FFT arrays
Smag = zeros(1, fftbins);
Sphase = Smag;

%--------------------------------------------------------------------------
% generate the frequency bounds for the FFT
% this saves us from having to use a for loop to 
% assign the values
%
% 	fstep		frequency steps between each point in freq vector
% 	fft_freqs	list of frequencies for magnitude data
% 	freqbins	# of frequencies with non-zero magnitude
%--------------------------------------------------------------------------
fstep = Fs/(NFFT);
f_start_bin = round(low/fstep) + 1;
f_end_bin = round(high/fstep) + 1;
f_bins = f_start_bin:f_end_bin;
fft_freqs = fstep*f_bins;
freqbins = length(fft_freqs);

%--------------------------------------------------------------------------
% get the calibration magnitudes and phases
%--------------------------------------------------------------------------
if CAL
	% use the calibration information (get_cal will perform the
	% required interpolation)
	[mags(1, :), phases(1, :)] = get_cal(fft_freqs, ...
														caldata.freq(1, :), ...
														caldata.maginv(1, :), ...
														caldata.phase(1, :));
else
	% generate flat spectrum
	% mags = 0.7071
	% phases = random for uncalibrated data (will be added later)
	mags = (sqrt(2)/2) * ones(1, freqbins);
	phases = zeros(1, freqbins);
end

%--------------------------------------------------------------------------
% Build the magnitude array for the fft of the signal (Smag) and
% scale by 1/frequency_stepsize in order to preserve Parseval's theorem
%--------------------------------------------------------------------------
Smag(1, f_bins) = mags(1, :);
	
%--------------------------------------------------------------------------
% generate the random phases (for noise), add compensatory phase shifts 
%--------------------------------------------------------------------------
Sphase(1, f_bins) = pi * limited_uniform(1, freqbins) + phases(1, :);

%--------------------------------------------------------------------------
% build the full FFT arrays
%--------------------------------------------------------------------------
Sred = complex(Smag.*cos(Sphase), Smag.*sin(Sphase));
Sfull = buildfft(Sred(1, :));

%--------------------------------------------------------------------------
% generate the ifft
%--------------------------------------------------------------------------
Sraw = ifft(Sfull, NFFT);

%--------------------------------------------------------------------------
% compute the scale factor
%--------------------------------------------------------------------------
if CAL
	scale_f = scale * caldata.DAscale * sqrt(freqbins);
else
	scale_f = scale * sqrt(freqbins);
end

%--------------------------------------------------------------------------
% cut out the stimulus from raw vector
%--------------------------------------------------------------------------
% S = stimsamples * scale_f *real(Sraw(1:stimsamples));
S = scale_f *real(Sraw(1:stimsamples));


if nargout == 4
	oStr = sprintf('scale: %.2f \t max: %.4f \t rms: %.4f \t dB: %.4f',...
						scale, max(S), rms(S), ...
						dbspl(get_pa_rms(rms(S), caldata.pa_rms, caldata.v_rms)) );
end




