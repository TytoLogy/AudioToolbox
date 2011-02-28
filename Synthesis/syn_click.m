function S  = syn_click(duration, delay, Fs)
%S = syn_click(duration, delay, Fs)
%	Input Arguments:
%		duration = time of total stimulus in ms
%		delay = delay of click in ms
%		Fs = output sampling rate
%	
%	Output Arguments:
%		S = 1 channel array of stimuls

%---------------------------------------------------------------------
%	Sharad Shanbhag
%	sharad@etho.caltech.edu
%
%--Revision History---------------------------------------------------
% 21 December, 2007
%	Program Created
%---------------------------------------------------------------------

if nargin ~= 3
	error('syn_click: incorrect number of input arguments');
end

if duration <= 0
	error('syn_click: duration <= 0')
end

dt = 1000 * 1/Fs;
S = zeros(ms2bin(duration, Fs), 1);


if delay == 0
	S(1) = 1;
elseif delay > duration
	S(ms2bin(duration, Fs)-1) = 1;
else
	S(ms2bin(delay, Fs)) = 1;
end