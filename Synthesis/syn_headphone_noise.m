function [S, Scale, Smag, Sphase]  = syn_headphone_noise(duration, Fs, low, high, usitd, bc100, caldata, Smag, Sphase)
%-------------------------------------------------------------------------
% [S, Scale, Smag, Sphase] = syn_headphone_noise(duration, Fs, low, high, 
%													usitd, bc100, caldata, Smag, Sphase)
%-------------------------------------------------------------------------
%	Audio Toolbox: Synthesis
%-------------------------------------------------------------------------
%
% Synthesize pre-calibrated broadband noise for headphone presentation  
% using inverse FFT
%
%-------------------------------------------------------------------------
% Input Arguments:
%	duration		signal duration (ms)
%	Fs				output sampling rate
%	low			low frequency cutoff
% 	high			high frequency cutoff
%	usitd			interaural time difference in us (ignored if mono signal)
%	bc100			binaural correlation, range of -100% to 100%
%	caldata		caldata structure (caldata.mag, caldata.freq, caldata.phase)
%					if no calibration is desired, replace caldata with value 0
% 
% 	Optional:
% 		Smag, Sphase	Magnitude and phase spectra for generating frozen or
% 							pre-specified noise
%							***BC MUST BE 100% for this to work correctly!!!!!****
%								(hopefully, this will be fixed ASAP)
%-------------------------------------------------------------------------
% Output Arguments:
%	S			[2XN] array for stereo stimulus
%				L channel is row 1, R channel is row 2
% 
%	Scale		rms scale factor in the form [lscale rscale]
%	Smag		FFT magnitudes
%	Sphase	FFT phases
%-------------------------------------------------------------------------
% See Also: syn_headphonenoise_fft, syn_headphone_tone, 
%				figure_headphone_atten, synmononoise, load_headphone_cal
%-------------------------------------------------------------------------


%-------------------------------------------------------------------------
% Sharad J. Shanbhag
% sshanbhag@neoucom.edu
% 	Code adapted from synth library developed by
% 	Jamie Mazer and Ben Arthur
%-------------------------------------------------------------------------
% Revision History
%	19 September, 2002 (SJS):
%		-modified to include support for 2-channels of audio (i.e., stereo)
%		-Note that it is assumed that the bandwidth for both audio channels
%		 will be identical (fft_freqs passed get_cal for L and R 
%		 channels is identical.
%	24 February, 2003 (SJS):
%		-created syn_noise() from synnoise_fft(), added binaural 
%		 correlation capability to bring this in line with the 
%		 XDPHYS routine syn_noise.
%	14 February, 2008 (SJS):
%		-created syn_headphone_noise() from syn_noise()
% 		 major overhaul to actually implement accurate binaural
% 		 calibration (old version was not fully vetted).
% 		 stripped out checks for calibration and stereo signals, assuming
% 		 that calibration structure will be passed and stereo signals are
% 		 desired.  for mono signals, use syn_noise
% 	6 March, 2008 (SJS):
% 		- added scaling factor from caldata to multiply stimulus signal
%	23 January, 2009 (SJS):
% 		-	fixed scaling issues in syn_headphonenoise_fft, removed the
% 			scaling of the S array by caldata.DAscale here
%	2 February, 2009 (SJS):
% 		-	made changes to scale factor calculation for 0 < BC < 1 sounds
%	12 June, 2009 (SJS): some documentation updates
%	29-30 October, 2009 (SJS): updated documentation
%	16 November, 2009 (SJS): added Smag and Sphase inputs to allow synthesis
%										of frozen or pre-specified noise
% 									***Note that BC other than 1 will not be 
% 										"frozen" ******
%	28 Feb, 2011 (SJS): some comments added
%-------------------------------------------------------------------------
% TO DO:
%	- confirm BC ~= 0 or 1 functionality
%-------------------------------------------------------------------------

% do some basic checks on the input arguments
if nargin < 7
	error([mfilename ': incorrect number of input arguments']);
end
if duration <=0
	error([mfilename ': duration must be > 0'])
end
if low > high
	error([mfilename ': low freq must be < high freq limit']);
end
% check if Smag and Sphase were provided... if so, freeze the noise!
if (exist('Smag', 'var') && exist('Sphase', 'var'))
	FROZEN = 1;
else
	FROZEN = 0;
end

% convert bc100 (percentage) to value
BC = bc100 / 100.0;

% get an initial noise buffer
% 16 Nov: added frozen noise check
if ~FROZEN
	[outbuf, outscale, Smag, Sphase] = syn_headphonenoise_fft(duration, Fs, low, high, usitd, caldata);
else
	[outbuf, outscale, Smag, Sphase] = syn_headphonenoise_fft(duration, Fs, low, high, usitd, caldata, Smag, Sphase);
end

S = outbuf;
Scale = outscale;

%-------------
% DEBUGGING
%-------------
% disp(sprintf('ScaleL: %.2f  ScaleR: %.2f  Scaledelta: %.2f', Scale(1), Scale(2), diff(Scale)))
% disp(sprintf('RMSL: %.2f  RMSR: %.2f  RMSdelta: %.2f', outrms(1), outrms(2), diff(outrms)))
% disp(sprintf('db ScaleL: %.2f  ScaleR: %.2f  Scaledelta: %.2f\n', db(Scale(1)), db(Scale(2)), diff(db(Scale))))
%-------------

% if binaural correlation is 1, we're done
if BC == 1
	return;
end

% if binaural correlation is -1, invert channel 2 and return
if BC == -1
	S = outbuf;
	S(2, :) = -S(2, :);
	return;
end

% if the correlation is less than one, get another sound buffer to mix in
[buf2, buf2scale] = syn_headphonenoise_fft(duration, Fs, low, high, usitd, caldata);

% rescale and build output array
if BC == 0
	outbuf(2, :) = buf2(2, :);
	outscale(2) = buf2scale(2);
	S = outbuf;
	Scale = outscale;

elseif BC ~= 1		% get the correction factors for the requested BC
	crr_crc = correct_crc(BC);
	abs_crc = abs(crr_crc);
	S(1, :) = outbuf(1, :);
	Scale(1) = outscale(1);
	Scale(2) = buf2scale(2);
	
	S(2, :) = (crr_crc .* outbuf(2, :)) + ((1-abs_crc) .* buf2(2, :));
	%-------------
	% DEBUGGING
	%-------------
	%[S(2, :), normval] = normalize(S(2, :));
	%-------------
 	normval = max(abs(S(2, :)));
	Scale(2) = normval * (  sqrt( (abs_crc*Scale(2))^2 + ((1-abs_crc)*buf2scale(2))^2 )  );
end


