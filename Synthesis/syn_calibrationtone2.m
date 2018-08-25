function [S, Smag, Sphi] = syn_calibrationtone2(duration, Fs, freq, rad_vary, channel)
%---------------------------------------------------------------------
%[S, Smag, Sphi] = syn_calibrationtone2(duration, Fs, freq, rad_vary, channel)
%---------------------------------------------------------------------
% Tytology:AudioToolbox:Synthesis
%---------------------------------------------------------------------
%	Input Arguments:
%		duration = time of stimulus in ms
%		Fs = output sampling rate
%		freq = tone frequency
%		rad_vary = parameter to vary starting phase (0 = no, 1 = yes)
%		channel = 'L' = left (R=0), 'R' = right (L channel = zeros)
%	
%	Output Arguments:
%		S = L or R sine data (2XN array)
%		Smag = calibration magnitude
%		Sphi = phase
%
%	Sharad Shanbhag
%	sharad@etho.caltech.edu
%
%--Revision History---------------------------------------------------
% 7 Feb, 2008, SJS
%	created from syn_tone
%

if nargin ~= 5
	error('syn_calibrationtone2: incorrect number of input arguments');
end

tbins = ms2bin(duration, Fs);
tvec = (1/Fs)*(0:(tbins-1));
omega = 2 * pi * freq;

if rad_vary
	phi = 2 * pi * rand(1, 1);
else
	phi = 0;
end


S = zeros(2, tbins);
switch channel
	case 'L'
		S(1, :) = sin(omega * tvec + phi);
		Smag = [rms(S(1, :)) 0];
		Sphi = [phi 0];
	case 'R'
		S(2, :) = sin(omega * tvec + phi);
		Smag = [0 rms(S(2, :))];
		Sphi = [0 phi];
	otherwise
		warning('syn_calibrationtone2: bad channel input, zero array output')
		Smag = [0 0];
		Sphi = Smag;
end



