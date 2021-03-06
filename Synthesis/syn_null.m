function S = syn_null(duration, Fs, STEREO)
%-------------------------------------------------------------------------
% S = syn_null(duration, Fs, stereo)
%-------------------------------------------------------------------------
% TytoLogy:AudioToolbox:Synthesis Toolbox
%-------------------------------------------------------------------------
%	Input Arguments:
%		duration = time of stimulus in ms
%		Fs = output sampling rate
%		stereo = 1 for 2 channels, 0 for 1 channel
%	
%	Output Arguments:
%		S = L & R null data
%-------------------------------------------------------------------------

%-------------------------------------------------------------------------
%	Sharad Shanbhag
%	sshanbhag@neomed.edu
%
%--Revision History---------------------------------------------------
% 3 August, 2003, SJS
%	created from syn_tone
% 22 Oct,2017 (SJS): updated notes
%-------------------------------------------------------------------------

if nargin ~= 3
	error('syn_null: incorrect number of input arguments');
end

duration = 0.001 * duration;
dt = 1/Fs;
tvec = dt*(0:(Fs * duration)-1);

S(1, :) = 0 * tvec;
if STEREO
	S(2, :) = S(1, :);
end

