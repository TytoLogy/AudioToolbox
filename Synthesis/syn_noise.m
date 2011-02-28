function [S, Scale]  = syn_noise(duration, Fs, low, high, usitd, bc100, caldata)
%function S, Scale  = syn_noise(duration, Fs, low, high, usitd, bc100, caldata)
%
% Input Arguments:
%	dur		= signal duration (ms)
%	Fs 		= output sampling rate
%	low 	= low frequency cutoff
% 	high 	= high frequency cutoff
%	usitd 	= interaural time difference in us (ignored if mono signal)
%	bc100	= binaural correlation, range of -100% to 100%
%	caldata = caldata structure (caldata.mag, caldata.freq, caldata.phase)
%				if no calibration is desired, replace caldata with value 0
%
% Returned arguments:
%	S		= [1XN] array for mono signals, [2XN] for stereo
%				L channel is row 1, R channel is row 2
%	Scale	= rms scale factor.  if [1X2], a stereo signal is specified,
%				in the form [lscale rscale]


%--------------------------------------------------------------------------
% Sharad J. Shanbhag
% sharad@etho.caltech.edu
% 	Code adapted from synth library developed by
% 	Jamie Mazer and Ben Arthur
%--------------------------------------------------------------------------
% Revision History
%	19 September, 2002 (SJS):
%		-modified to include support for 2-channels of audio (i.e., stereo)
%		-Note that it is assumed that the bandwidth for both audio channels
%		 will be identical (fft_freqs passed get_cal for L and R 
%		 channels is identical.
%
%	24 February, 2003 (SJS):
%		-created syn_noise() from synnoise_fft(), added binaural 
%		 correlation capability to bring this in line with the 
%		 XDPHYS routine syn_noise.
%--------------------------------------------------------------------------

% do some basic checks on the input arguments
if nargin ~= 7
	error('syn_noise: incorrect number of input arguments');
end

if duration <=0
	error('syn_noise: duration must be > 0')
end
if low > high
	error('syn_noise: low freq must be < high freq limit');
end

CAL = 0;
if isstruct(caldata)
	% if calibration data is given, use it
	CAL = 1;
	% check if we're using stereophonic data
	[n, m] = size(caldata.mag);
	STEREO = 0;
	if n == 2
		STEREO = 1;
	end
else
	% otherwise, just check if stereo or not
	[n, m] = size(caldata);
	STEREO = 0;
	if n == 2
		STEREO = 1;
	end
end

% convert bc100 (percentage) to value
BC = bc100 / 100.0;

% get an initial noise buffer
[outbuf, outscale, outphi] = synnoise_fft(duration, Fs, low, high, usitd, [1 1], caldata);

S = outbuf;
Scale = outscale;

if BC == 1	| STEREO == 0	% if binaural correlation is 1, we're done
	return;
end

if BC == -1
	S = outbuf;
	S(2, :) = -S(2, :);
	Scale = outscale;
	return;
end

% if the correlation is less than one, get another one (buffer)
[buf2, buf2scale, buf2phi] = synnoise_fft(duration, Fs, low, high, usitd, [1 1], caldata);

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
	[S(2, :), normval] = normalize(S(2, :));
	Scale(2) = normval * (  sqrt( (abs_crc*Scale(2))^2 + ((1-abs_crc)*buf2scale(2))^2 )  );
end


