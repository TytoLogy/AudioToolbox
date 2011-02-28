function y = sin2array(a, dur, fs)
%------------------------------------------------------------------------
% y = sin2array(a, dur, fs)
%------------------------------------------------------------------------
% 	ramps up and down signal a over duration dur in ms;
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
% sshanbha@aecom.yu.edu
%------------------------------------------------------------------------
% Created: a long time ago...
%
% Revisions:
%	12 Nov 08 (SJS):	cleaned up comments & documentation 
%------------------------------------------------------------------------


[m, n] = size(a);

rampbins = floor(fs * dur / 1000);

if 2*rampbins > length(a)
	error('ramparray: ramp duration > length of stimulus');
end

ramp1x = linspace(0, pi/2, rampbins);
ramp2x = linspace(pi/2, 0, rampbins);

ramp1 = sin(ramp1x).^2;
ramp2 = sin(ramp2x).^2;

y = [(ramp1 .* a(1, 1:rampbins)) ...
		a(1, rampbins + 1:n - rampbins) ...
		(ramp2 .* a(1, n-rampbins+1:n))];

if m == 2
	y2 = [(ramp1 .* a(2, 1:rampbins)) ...
			a(2, rampbins + 1:n - rampbins) ...
			(ramp2 .* a(2, n-rampbins+1:n))];
	y = [y; y2];
end
