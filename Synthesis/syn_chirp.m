function S  = syn_chirp(duration, fstart, fend, type, Fs)
%---------------------------------------------------------------------
% S = syn_logchirp(duration, delay, Fs)
%---------------------------------------------------------------------
% Tytology:AudioToolbox:Synthesis
%---------------------------------------------------------------------
%	Input Arguments:
%		duration = time of total stimulus in ms
%		delay = delay of click in ms
%		Fs = output sampling rate
%	
%	Output Arguments:
%		S = 1 channel array of stimuls
%---------------------------------------------------------------------
%	Generates log
%---------------------------------------------------------------------
%	Sharad J. Shanbhag
%	sshanbhag@neomed.edu
%--Revision History---------------------------------------------------
% 16 May, 2018
%	Program Created
%---------------------------------------------------------------------
S = [];