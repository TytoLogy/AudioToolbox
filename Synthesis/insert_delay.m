function y = insert_delay(a, delay, fs)
%-----------------------------------------------------------------------------
% y = insert_delay(a, delay, fs)
%-----------------------------------------------------------------------------
% Audio Toolbox -> Synthesis
%-----------------------------------------------------------------------------
%
%	inserts delay time delay (msec) into signal a 
%
%-----------------------------------------------------------------------------
% Input Arguments:
% 	a			[NXM] vector where N = # of channels, M = # of samples
% 	delay		delay in milliseconds
%	fs			sample rate (samples/sec)
%
% Output Arguments:
% 	y	vector a with delay inserted
%-----------------------------------------------------------------------------
% See Also:
%-----------------------------------------------------------------------------

%-----------------------------------------------------------------------------
% Sharad J. Shanbhag
% sshanbhag@neoucom.edu
%-----------------------------------------------------------------------------
% Created: ?? ?????, ???? (SJS)
%
% Revisions:
%	28 Feb 2011 (SJS): added comments in header
%	12 Jul 2012 (SJS): modified to work with N-channel data
%-----------------------------------------------------------------------------
% TO DO:
%-----------------------------------------------------------------------------


% old  
% y = [zeros(1, ceil(fs * delay / 1000)) a];

delaypts = ceil(fs * delay / 1000);
[n, ~] = size(a);
y = [zeros(n, delaypts) a];
