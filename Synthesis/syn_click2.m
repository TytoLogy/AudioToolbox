function S  = syn_click2(duration, delaysamples, clicksamples, Fs)
%S = syn_click2(duration, delaysamples, clicksamples, Fs)
%	Input Arguments:
%		duration = time of total stimulus in ms
%		delaysamples = delay of click in samples
%		clicksamples = duration of click in samples
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

if nargin ~= 4
	error('syn_click2: incorrect number of input arguments');
end

if duration <= 0
	error('syn_click: duration <= 0')
end

dt = 1000 * 1/Fs;
stimbins = ms2bin(duration, Fs) ;
S = zeros(stimbins, 1);

startbin = delaysamples;
endbin = startbin+clicksamples;

if delaysamples <= 0
	S(1) = 1;
elseif delaysamples > stimbins
	S(stimbins-1) = 1;
else
	S(startbin:endbin) = ones(size(S(startbin:endbin)));
end


