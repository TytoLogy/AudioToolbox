function S  = syn_chirp(duration, fstart, fend, Fs, swtype)
%---------------------------------------------------------------------
% S = syn_chirp(duration, delay, Fs)
%---------------------------------------------------------------------
% Tytology:AudioToolbox:Synthesis
%---------------------------------------------------------------------
%	Input Arguments:
%		duration		length of stimulus in ms
%		fstart		starting frequency (Hz)
%		fend			end frequency (Hz)
%		Fs				sampling rate (samples/s)
%		swtype		'log' or 'linear'
%
%	Output Arguments:
%		S				1 channel array of stimulus
%---------------------------------------------------------------------
%	Generates log or linear frequency sweep
%---------------------------------------------------------------------
%	Sharad J. Shanbhag
%	sshanbhag@neomed.edu
%--Revision History---------------------------------------------------
% 16 May, 2018
%	Program Created
% 13 Jun 2018 (SJS) added code that actually does something.
%---------------------------------------------------------------------

% check inputs
if nargin ~= 5
	error('%s: incorrect number of input arguments', mfilename);
end
if duration <= 0
	error('%s: duration <= 0', mfilename)
end
if fstart < 0
	error('%s: fstart must be greater than 0', mfilename);
end
if Fs <= 0
	error('%s: Fs must be greater than 0', mfilename);
end
if fend > (Fs/2)
	error('%s: fend is greater than Nyquist frequency (%.4f)', mfilename, Fs/2);
end
if ~any(strcmpi(swtype, {'log', 'linear'}))
	error('%s: swtype %s is neither ''log'' nor ''linear''', mfilename, swtype);
end
% create chirp
if strcmpi(swtype(1:3), 'log')
	S = chirp(	(0:(1/Fs):(duration/1000)), ...
				fstart, duration/1000, fend, 'logarithmic');
else
	S = chirp(	(0:(1/Fs):(duration/1000)), ...
				fstart, duration/1000, fend, 'linear');	
end