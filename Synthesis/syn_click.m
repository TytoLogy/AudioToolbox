function S  = syn_click(duration, delay, Fs, varargin)
%---------------------------------------------------------------------
% S = syn_click(duration, delay, Fs)
%---------------------------------------------------------------------
% Tytology:AudioToolbox:Synthesis
%---------------------------------------------------------------------
%	Input Arguments:
%		duration			total stimulus time (ms)
%		delay				delay of click (ms)
%		Fs					sampling rate (samples/sec)
%	Optional Input Arguments
%		'ClickDurMS', <value>		specify click duration in ms
%		     -or-
%		'ClickDurSamples', <value>	specify click duration in samples
%	
%	Output Arguments:
%		S = 1 channel array of stimlus
% %-------------------------------------------------------------
%	Default click duration is 1 sample. Use 'ClickDurMS' or
%	'ClickDurSamples' to change this.
%
%	Click is by default a positive value of 1.
%
%	Examples:
%		1 ms long click with total signal duration of 1000 ms 
%		and delay of 100 ms; sample rate of 10000 samples/s
% 		
% 			S = syn_click(1000, 100, 10000, 'ClickDurMS', 1);
% 
%		20 samples long click with total signal duration of 500 ms 
%		and delay of 5 ms; sample rate of 44100 samples/s
% 		
% 			S = syn_click(500, 5, 44100, 'ClickDurSamples', 20);
%---------------------------------------------------------------------

%---------------------------------------------------------------------
%	Sharad Shanbhag
%	sshanbhag@neomed.edu
%--Revision History---------------------------------------------------
% 21 December, 2007
%	Program Created
% 24 Aug 2018 (SJS):
%	- updated email, forced to row vector form
% 25 Aug 2018 (SJS):
%	- added input arg to change click duration (either in ms or samples)
%---------------------------------------------------------------------
% default click length
click = 1;

%------------------------------------------------------
% Check inputs
%------------------------------------------------------
if nargin < 3
	error('syn_click: incorrect number of input arguments');
end
if duration <= 0
	error('syn_click: duration <= 0')
end
if delay > duration
	error('syn_click: delay (%d) > stimulus duration (%s)', ...
				mfilename, delay, duration);
end
% var args
if ~isempty(varargin)
	nv = length(varargin);
	if nv ~= 2
		error('syn_click: incorrect optional input args');
	end
	n = 1;
	while n <= nv
		switch(upper(varargin{n}))
			case 'CLICKDURMS'
				clickdur = varargin{n+1};
				click = ones(ms2bin(clickdur, Fs), 1);
				n = n + 2;
			case 'CLICKDURSAMPLES'
				clickdur = varargin{n+1};
				click = ones(clickdur, 1);
				n = n + 2;
			otherwise
				error('%s: unknown argument %s', mfilename, varargin{n});
		end
	end
end

%------------------------------------------------------
% create stimulus
%------------------------------------------------------
% force into row vector form
S(1, :) = zeros(ms2bin(duration, Fs), 1);

% length of click in samples?
clickbins = length(click);

% assign click into stimulus
if delay == 0
	S(1:clickbins) = click;
else
	S(ms2bin(delay, Fs) + (0:(clickbins-1))) = click;
end

