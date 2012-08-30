function [y, bindx, b1, b2] = bufferarray(a, dur, fs)
%------------------------------------------------------------------------
% y = bufferarray(a, dur, fs)
%------------------------------------------------------------------------
% AudioToolbox:Utils
%------------------------------------------------------------------------
% 	adds null data to array of duration dur;
% 
% 	ramp profile is a squared sinusoid
%------------------------------------------------------------------------
% Input Args:
% 	fs = sample rate
% 
% 	signal a is [1, N] or [2, N] array.
%
% 	dur cannot be longer than 1/2 of the total signal duration
%------------------------------------------------------------------------

%------------------------------------------------------------------------
% Sharad Shanbhag
% sshanbhag@neomed.edu
%------------------------------------------------------------------------
% Created: 30 August, 2012 (SJS) from sin2array
%
% Revisions:
%------------------------------------------------------------------------


[m, n] = size(a);

bufferbins = floor(fs * dur / 1000)

if 2*bufferbins > length(a)
	error('%s: bufferbins duration > length of stimulus', mfilename);
end

b1 = a(:, 1:bufferbins);
b2 = a(:, (n-bufferbins+1) : end);

y = [b1 a b2];

bindx = [bufferbins+1, n+bufferbins];
