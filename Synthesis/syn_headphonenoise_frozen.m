function [S, Scale, Smag, Sphase]  = syn_headphonenoise_frozen(usitd, fftmag, fftphase, caldata)
% [S, Scale, Smag, Sphase]  = syn_headphonenoise_frozen(usitd, fftmag, fftphase, caldata)
%
% Synthesize frozen broadband noise for headphone presentation
%
% Input Arguments:
%	usitd 	= interaural time difference in us (ignored if mono signal)
%	caldata = caldata structure (caldata.mag, caldata.freq, caldata.phase)
%				if no calibration is desired, replace caldata with value 0
% 	fftmag, fftphase	fft mag and phase information for frozen sound or specific
% 					fft information
% 
% Returned arguments:
%	S		= [2XN] array for stereo stimulus
%			  L channel is row 1, R channel is row 2
%	Scale	= rms scale factor in the form [lscale rscale]
%	Smag
%	Sphase
%
% See Also: syn_headphonenoise_fft, syn_headphone_tone, 
%				figure_headphone_atten, synmononoise
%-------------------------------------------------------------------------


%-------------------------------------------------------------------------
% Sharad J. Shanbhag
% sharad@etho.caltech.edu
% 	Code adapted from synth library developed by
% 	Jamie Mazer and Ben Arthur
%-------------------------------------------------------------------------
% Revision History
%	3 August, 2009 (SJS):
% 		- created as fork from syn_headphone_noise
%-------------------------------------------------------------------------
% TO DO:
%-------------------------------------------------------------------------

Smag = fftmags;
Sphase(2, f_start_bin:f_end_bin) = rand_phases(1, :) + phases(2, :) + itd_phases;


if ~exist(fftdata, 'var')
	% get an initial noise buffer
	[outbuf, outscale, outrms] = syn_headphonenoise_fft(duration, Fs, low, high, usitd, caldata);
else
	% get an initial noise buffer
	[outbuf, outscale, outrms] = syn_headphonenoise_fft(duration, Fs, low, high, usitd, caldata);	
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


