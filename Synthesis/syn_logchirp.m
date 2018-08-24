function S  = syn_logchirp(duration, fstart, fend, Fs)
%---------------------------------------------------------------------
% S = syn_logchirp(duration, delay, Fs)
%---------------------------------------------------------------------
% Tytology:AudioToolbox:Synthesis
%---------------------------------------------------------------------
%	Generates logarithmic frequency sweep
%---------------------------------------------------------------------
%	Input Arguments:
%		duration			time stimulus in ms
%		fstart			starting frequency (Hz)
%		fend				end frequency (Hz)
%		Fs					sampling rate (samples/s)
%	
%	Output Arguments:
%		S = 1 channel array of stimulus
%---------------------------------------------------------------------
%	Sharad J. Shanbhag
%	sshanbhag@neomed.edu
%--Revision History---------------------------------------------------
% 16 May, 2018
%	Program Created
% 13 Jun 2018 (SJS): superceded by syn_chirp
%---------------------------------------------------------------------

% check inputs
if nargin ~= 4
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

% create chirp
S = chirp(	(0:(1/Fs):(duration/1000)), ...
				fstart, duration/1000, fend, 'logarithmic');
