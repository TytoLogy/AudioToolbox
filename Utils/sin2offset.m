function y = sin2offset(a, dur, fs)
%------------------------------------------------------------------------
% y = sin2offset(a, dur, fs)
%------------------------------------------------------------------------
% TytoLogy->AudioToolbox:Utils
%------------------------------------------------------------------------
% 	ramps down signal a over duration dur in ms;
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
% Created: 15 Aug 2019 from sin2array which was created a long time ago...
%
% Revisions:
%------------------------------------------------------------------------


% get size
[m, n] = size(a);
% # of bins for ramp
rampbins = floor(fs * dur / 1000);
% check length
if rampbins > length(a)
	error('%s: onset ramp duration (%d) > length of stimulus (%d)', ...
				mfilename, rampbins, length(a));
end
% offset ramp time values
ramp2x = linspace(pi/2, 0, rampbins);
% compute ramp
ramp2 = sin(ramp2x).^2;
% apply ramp
y = [ a(1, 1:rampbins) ...
		a(1, rampbins + 1:n - rampbins) ...
		(ramp2 .* a(1, n-rampbins+1:n))];

if m == 2
	y2 = [(ramp1 .* a(2, 1:rampbins)) ...
			a(2, rampbins + 1:n - rampbins) ...
			(ramp2 .* a(2, n-rampbins+1:n))];
	y = [y; y2];
end
