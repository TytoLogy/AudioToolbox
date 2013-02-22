<<<<<<< HEAD
function [S, Scale, Smag, Sphase] = syn_headphonenoise_fft(duration, Fs, low, high, usitd, caldata, Smag, Sphase)
%-------------------------------------------------------------------------
% [S, Scale, Smag, Sphase]  = syn_headphonenoise_fft(duration, Fs, low,
%												high, usitd, caldata, Smag, Sphase)
%-------------------------------------------------------------------------
%	Audio Toolbox: Synthesis
%-------------------------------------------------------------------------
%
% Using inverse FFT, Synthesize broadband noise for headphone presentation
% Normally, this function is not called directly, but is accessed through 
% syn_headphone_noise().  As such, it performs no checks on the input
% arguments or their values.  Use with caution!
%   
%-------------------------------------------------------------------------
% Input Arguments:
%	duration		signal duration (ms)
%	Fs				output sampling rate
%	low			low frequency cutoff
% 	high			high frequency cutoff
%	usitd			interaural time difference in us (ignored if mono signal)
%	caldata		caldata structure (caldata.mag, caldata.freq, caldata.phase)
%					*if no calibration is desired, replace caldata with value 0
% 
% 	Optional:
% 		Smag, Sphase	Magnitude and phase spectra for generating frozen or
% 							pre-specified noise
% 
% 	***Important***
% 
% 	For proper ITD with frozen/pre-specified noise, Sphase array must be 
% 	provided with ITD=0 usec
% 
% 	Example:
% 							
% 	- first synthesize noise with ITD = 0:
% 	
% 		[s, r, smag, sphase] = syn_headphonenoise_fft(100, 44100, 100, ...
% 																1000, 0, caldata)
% 
% 	- then synthesize with desired ITD, providing the smag and sphase arrays
% 							
% 		[s, r] = syn_headphonenoise_fft(100, 44100, 100, ...
% 													1000, -100, caldata, smag, sphase)
%  							
%-------------------------------------------------------------------------
% Output Arguments:
%	S			[2XN] array for stereo stimulus
%						L channel is row 1, R channel is row 2
%	Scale		rms scale factor in the form [lscale rscale]
%	Smag		FFT magnitudes
%	Sphase	FFT phases
%
%-------------------------------------------------------------------------
% See Also: syn_headphone_noise, syn_headphone_tone, figure_headphone_atten
%-------------------------------------------------------------------------
%	Audio Toolbox
%-------------------------------------------------------------------------

%-------------------------------------------------------------------------
% Sharad J. Shanbhag
% sshanbhag@neomed.edu
%
% 	Code adapted from synth library developed by
% 	Ben Arthur, Chris Malek & Jamie Mazer in the Konishi lab at Caltech
%-------------------------------------------------------------------------
% Revision History
%	19 September, 2002 (SJS):
%		-modified to include support for 2-channels of audio (i.e., stereo)
%		-Note that it is assumed that the bandwidth for both audio channels
%		 will be identical (fft_freqs passed get_cal for L and R channels is 
%		 identical
%	1 March, 2008 (SJS):
%		- created from syn_noise_fft.m.  syn_headphone_noise explicitly
%		expects stereo (2 channel) signal parameters for headphone
%		(dichotic) stimulus presentation.
%	24 March, 2008 (SJS):
%		- made some changes to scaling factors in attempt to resolve the
%		strange behavior in the output Scale values used to set the
%		attenuators - R channel is consistently louder than L channel
%	19 January, 2009 (SJS): still working on scaling...
%	23 January, 2009 (SJS):
%		- fixed scaling issues!  
%		- added computatation of Scale values by rms() function, removed old
%		  broken-down code that was incorrect (normalization)
%		- added division of mags by 1/freqstep in order to preserve
%		  Parseval's theorem
%	12 June, 2009 (SJS):
%		- fixed idiotic error that use the L output signal in both channels
%		  of the S array...
%	25 June 2009 (SJS): more scale factor silliness
%  30 October, 2009 (SJS): documentation updates
%	16 November, 2009 (SJS): added Smag and Sphase inputs to allow synthesis
%										of frozen or pre-specified noise
%	23 August, 2010 (SJS):
% 		-	another fix for scale_f computation.
% 		-	still need to fix some other components/functions, but this
% 			should take care of the scaling factor/stimulus length
% 			issues that have been resulting in clipping
%	30 Jan 2013 (SJS): fixed DAscale error if caldata is provided as 0
%-----------------------------------------------------------------------------

% compute # of samples in stim
stimlen = ms2bin(duration, Fs);

% for speed's sake, get the nearest power of 2 to the desired output length
NFFT = 2.^(nextpow2(stimlen));
% length of real part of FFT
fftbins = 1+floor(NFFT/2);

% generate the frequency bounds for the FFT
% this saves us from having to use a for loop to assign the values
fstep = Fs/(NFFT);
f_start_bin = round(low/fstep) + 1;
f_end_bin = round(high/fstep) + 1;
f_bins = f_start_bin:f_end_bin;
fft_freqs = fstep*f_bins;
freqbins = length(fft_freqs);

% compute the phases
rand_phases = pi * limited_uniform(1, freqbins);
itd_phases = (usitd/1e6) * 2 * pi * fft_freqs;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Check is Smag and Sphase are specified
% if not, synthesize noise de novo, otherwise use the provided Smag and
% Sphase to synthesize the noise
% (added 16 Nov 2009 for frozen noise synthesis)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if ~(exist('Smag', 'var') && exist('Sphase', 'var'))
	% initialize and assign values to the FFT arrays
	Smag = zeros(2, fftbins);
	Sphase = Smag;

	% check is caldata is a structure.  if so, get the calibration data.  if
	% not, assume a flat calibration function
	if isstruct(caldata)
		% get the calibration magnitudes and phases
		[mags, phases] = figure_cal(fft_freqs, caldata);
		DAscale = caldata.DAscale;
	else
		mags = ones(2, freqbins);
		phases = 0*mags;
		DAscale = 1;
	end

	% Build the magnitude array for the fft of the signal (Smag) and
	% scale by 1/frequency_stepsize in order to preserve Parseval's theorem
	% first, build the full FFT array, S in Matlab format
	% Scale the FFT magnitude by 0.5 * (Length of Smag)
	% scale_f =  0.5 * fftbins * caldata.DAscale / fstep;
	% scale_f = 0.5*Fs/(fstep*NFFT); pre 25June
	% 24 Jun 09
	% scale_f = (0.5*NFFT)/(fstep);

	%*******
	% 23 Aug 2010 (SJS)
	%*******
	scale_f = DAscale * 0.5 * sqrt(NFFT) * (1/sqrt(2));
	Smag(1, f_start_bin:f_end_bin) = scale_f * mags(1, :);
	Smag(2, f_start_bin:f_end_bin) = scale_f * mags(2, :);

	% assign phases for left and right channels & apply the itd phase
	Sphase(1, f_start_bin:f_end_bin) = rand_phases(1, :) + phases(1, :);
	Sphase(2, f_start_bin:f_end_bin) = rand_phases(1, :) + phases(2, :) + itd_phases;
else
	% need to adjust Sphase(R, :) to generate proper ITD
	Sphase(2, f_start_bin:f_end_bin) = Sphase(2, f_start_bin:f_end_bin) + itd_phases;
end

% Sreduced is the complex form of the spectrum
Sreduced = complex(Smag.*cos(Sphase), Smag.*sin(Sphase));

% build the total FFT vector
Sfft(1, :) = buildfft(Sreduced(1, :));
Sfft(2, :) = buildfft(Sreduced(2, :));
	
% then, iFFT the signal
Sraw_L = real(ifft(Sfft(1, :)));
Sraw_R = real(ifft(Sfft(2, :)));

% keep only points we need
S = [Sraw_L(1:stimlen); Sraw_R(1:stimlen)];

% Compute Scale factor for setting the attenuators (rms of signal)
% since we have calibration data, dB output will be dbspl(VtoPa*Scale)
Scale = rms(S')';

% DEBUGGING
% save mp.mat
=======
function [S, Scale, Smag, Sphase] = syn_headphonenoise_fft(duration, Fs, low, high, usitd, caldata, Smag, Sphase)
%-------------------------------------------------------------------------
% [S, Scale, Smag, Sphase]  = syn_headphonenoise_fft(duration, Fs, low,
%												high, usitd, caldata, Smag, Sphase)
%-------------------------------------------------------------------------
%	Audio Toolbox: Synthesis
%-------------------------------------------------------------------------
%
% Using inverse FFT, Synthesize broadband noise for headphone presentation
% Normally, this function is not called directly, but is accessed through 
% syn_headphone_noise().  As such, it performs no checks on the input
% arguments or their values.  Use with caution!
%   
%-------------------------------------------------------------------------
% Input Arguments:
%	duration		signal duration (ms)
%	Fs				output sampling rate
%	low			low frequency cutoff
% 	high			high frequency cutoff
%	usitd			interaural time difference in us (ignored if mono signal)
%	caldata		caldata structure (caldata.mag, caldata.freq, caldata.phase)
%					*if no calibration is desired, replace caldata with value 0
% 
% 	Optional:
% 		Smag, Sphase	Magnitude and phase spectra for generating frozen or
% 							pre-specified noise
% 
% 	***Important***
% 
% 	For proper ITD with frozen/pre-specified noise, Sphase array must be 
% 	provided with ITD=0 usec
% 
% 	Example:
% 							
% 	- first synthesize noise with ITD = 0:
% 	
% 		[s, r, smag, sphase] = syn_headphonenoise_fft(100, 44100, 100, ...
% 																1000, 0, caldata)
% 
% 	- then synthesize with desired ITD, providing the smag and sphase arrays
% 							
% 		[s, r] = syn_headphonenoise_fft(100, 44100, 100, ...
% 													1000, -100, caldata, smag, sphase)
%  							
%-------------------------------------------------------------------------
% Output Arguments:
%	S			[2XN] array for stereo stimulus
%						L channel is row 1, R channel is row 2
%	Scale		rms scale factor in the form [lscale rscale]
%	Smag		FFT magnitudes
%	Sphase	FFT phases
%
%-------------------------------------------------------------------------
% See Also: syn_headphone_noise, syn_headphone_tone, figure_headphone_atten
%-------------------------------------------------------------------------
%	Audio Toolbox
%-------------------------------------------------------------------------

%-------------------------------------------------------------------------
% Sharad J. Shanbhag
% sshanbhag@neomed.edu
%
% 	Code adapted from synth library developed by
% 	Ben Arthur, Chris Malek & Jamie Mazer in the Konishi lab at Caltech
%-------------------------------------------------------------------------
% Revision History
%	19 September, 2002 (SJS):
%		-modified to include support for 2-channels of audio (i.e., stereo)
%		-Note that it is assumed that the bandwidth for both audio channels
%		 will be identical (fft_freqs passed get_cal for L and R channels is 
%		 identical
%	1 March, 2008 (SJS):
%		- created from syn_noise_fft.m.  syn_headphone_noise explicitly
%		expects stereo (2 channel) signal parameters for headphone
%		(dichotic) stimulus presentation.
%	24 March, 2008 (SJS):
%		- made some changes to scaling factors in attempt to resolve the
%		strange behavior in the output Scale values used to set the
%		attenuators - R channel is consistently louder than L channel
%	19 January, 2009 (SJS): still working on scaling...
%	23 January, 2009 (SJS):
%		- fixed scaling issues!  
%		- added computatation of Scale values by rms() function, removed old
%		  broken-down code that was incorrect (normalization)
%		- added division of mags by 1/freqstep in order to preserve
%		  Parseval's theorem
%	12 June, 2009 (SJS):
%		- fixed idiotic error that use the L output signal in both channels
%		  of the S array...
%	25 June 2009 (SJS): more scale factor silliness
%  30 October, 2009 (SJS): documentation updates
%	16 November, 2009 (SJS): added Smag and Sphase inputs to allow synthesis
%										of frozen or pre-specified noise
%	23 August, 2010 (SJS):
% 		-	another fix for scale_f computation.
% 		-	still need to fix some other components/functions, but this
% 			should take care of the scaling factor/stimulus length
% 			issues that have been resulting in clipping
%-----------------------------------------------------------------------------

% compute # of samples in stim
stimlen = ms2bin(duration, Fs);

% for speed's sake, get the nearest power of 2 to the desired output length
NFFT = 2.^(nextpow2(stimlen));
% length of real part of FFT
fftbins = 1+floor(NFFT/2);

% generate the frequency bounds for the FFT
% this saves us from having to use a for loop to assign the values
fstep = Fs/(NFFT);
f_start_bin = round(low/fstep) + 1;
f_end_bin = round(high/fstep) + 1;
f_bins = f_start_bin:f_end_bin;
fft_freqs = fstep*f_bins;
freqbins = length(fft_freqs);

% compute the phases
rand_phases = pi * limited_uniform(1, freqbins);
itd_phases = (usitd/1e6) * 2 * pi * fft_freqs;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Check is Smag and Sphase are specified
% if not, synthesize noise de novo, otherwise use the provided Smag and
% Sphase to synthesize the noise
% (added 16 Nov 2009 for frozen noise synthesis)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if ~(exist('Smag', 'var') && exist('Sphase', 'var'))
	% initialize and assign values to the FFT arrays
	Smag = zeros(2, fftbins);
	Sphase = Smag;

	% check is caldata is a structure.  if so, get the calibration data.  if
	% not, assume a flat calibration function
	if isstruct(caldata)
		% get the calibration magnitudes and phases
		[mags, phases] = figure_cal(fft_freqs, caldata);
	else
		mags = ones(2, freqbins);
		phases = 0*mags;
	end

	% Build the magnitude array for the fft of the signal (Smag) and
	% scale by 1/frequency_stepsize in order to preserve Parseval's theorem
	% first, build the full FFT array, S in Matlab format
	% Scale the FFT magnitude by 0.5 * (Length of Smag)
	% scale_f =  0.5 * fftbins * caldata.DAscale / fstep;
	% scale_f = 0.5*Fs/(fstep*NFFT); pre 25June
	% 24 Jun 09
	% scale_f = (0.5*NFFT)/(fstep);

	%*******
	% 23 Aug 2010 (SJS)
	%*******

	% most recent scale factor (20Feb2013)
	   scale_f = caldata.DAscale * 0.5 * sqrt(NFFT) * (1/sqrt(2));
	%%%%%%
	
	%%%
	% old (distributed Penalab?) version (added in caldata.DAscale)
	%%%%
% 	scale_f = caldata.DAscale * (0.5*NFFT)/(fstep);
	
	Smag(1, f_start_bin:f_end_bin) = scale_f * mags(1, :);
	Smag(2, f_start_bin:f_end_bin) = scale_f * mags(2, :);

	% assign phases for left and right channels & apply the itd phase
	Sphase(1, f_start_bin:f_end_bin) = rand_phases(1, :) + phases(1, :);
	Sphase(2, f_start_bin:f_end_bin) = rand_phases(1, :) + phases(2, :) + itd_phases;
else
	% need to adjust Sphase(R, :) to generate proper ITD
	Sphase(2, f_start_bin:f_end_bin) = Sphase(2, f_start_bin:f_end_bin) + itd_phases;
end

% Sreduced is the complex form of the spectrum
Sreduced = complex(Smag.*cos(Sphase), Smag.*sin(Sphase));

% build the total FFT vector
Sfft(1, :) = buildfft(Sreduced(1, :));
Sfft(2, :) = buildfft(Sreduced(2, :));
	
% then, iFFT the signal
Sraw_L = real(ifft(Sfft(1, :)));
Sraw_R = real(ifft(Sfft(2, :)));

% keep only points we need
S = [Sraw_L(1:stimlen); Sraw_R(1:stimlen)];

% Compute Scale factor for setting the attenuators (rms of signal)
% since we have calibration data, dB output will be dbspl(VtoPa*Scale)
Scale = rms(S')';

% DEBUGGING
% save mp.mat
>>>>>>> many changes, not sure if working.
% max(S')