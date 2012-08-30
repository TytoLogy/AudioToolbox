function aout = buffer_filter(a, dur, fs, fcoeffb, fcoeffa)
%------------------------------------------------------------------------
% aout = buffer_filter(a, dur, fs, fcoeffb, fcoeffa)
%------------------------------------------------------------------------
% AudioToolbox:Filter
%------------------------------------------------------------------------
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

[tmpa, bindx] = bufferarray(a, dur, fs);

tmpout = filtfilt(fcoeffb, fcoeffa, tmpa);
aout = tmpout(bindx(1):bindx(2));
