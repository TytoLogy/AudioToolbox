function [S, Smag, Sphi] = syn_calibrationtone(duration, Fs, freq, rad_vary, channels)
%[S, Smag, Sphi] = syn_calibrationtone(duration, Fs, freq, rad_vary, channels)
%
%	Input Arguments:
%		duration = time of stimulus in ms
%		Fs = output sampling rate
%		freq = tone frequency
%		rad_vary = parameter to vary starting phase (0 = no, 1 = yes)
%		channels = 'L' = left only, 'B' = both, 'R' = right only
%	
%	Output Arguments:
%		S = L & R sine data
%		Smag = L & R calibration magnitude
%		Sphi = L & R phase
%
% See Alse: syn_tone, syn_noise, syn_click
%-------------------------------------------------------------------------

%-------------------------------------------------------------------------
%	Sharad Shanbhag
%	sshanbha@aecom.yu.edu
%
%--Revision History-------------------------------------------------------
% 7 Feb, 2008, SJS
%		created from syn_tone
% 9 Jan, 2009, SJS
%		Updated Help and comments
%-------------------------------------------------------------------------

if nargin ~= 5
	help syn_calibrationtone
	error('syn_calibrationtone: incorrect number of input arguments');
end

tbins = ms2bin(duration, Fs);
tvec = (1/Fs)*[0:(tbins-1)];
omega = 2 * pi * freq;

if rad_vary
	Sphi = 2 * pi * rand(1, 1);
else
	Sphi = 0;
end

svec = sin( omega * tvec + Sphi );
Smag = rms(svec);

switch channels
	case 'L'
		S(1, :) = svec;
		S(2, :) = zeros(size(svec));
	case 'R'
		S(2, :) = svec;
		S(1, :) = zeros(size(svec));
	case 'B'
		S(1, :) = svec;
		S(2, :) = svec;
	otherwise
		S = svec;
end


	


