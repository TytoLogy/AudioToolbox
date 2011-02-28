function y = ramparray(a, dur, fs)
%	function y = ramparray(a, dur, fs)
%		ramps up and down signal a over duration
%		dur in ms.  fs = sample rate
%
%	Sharad J. Shanbhag

[m, n] = size(a);

rampbins = floor(fs * dur / 1000);

if 2*rampbins > length(a)
	error('ramparray: ramp duration > length of stimulus');
end

ramp1 = linspace(0, 1, rampbins);
ramp2 = linspace(1, 0, rampbins);

y = [(ramp1 .* a(1, 1:rampbins)) ...
		a(1, rampbins + 1:n - rampbins) ...
		(ramp2 .* a(1, n-rampbins+1:n))];

if m == 2
	y2 = [(ramp1 .* a(2, 1:rampbins)) ...
			a(2, rampbins + 1:n - rampbins) ...
			(ramp2 .* a(2, n-rampbins+1:n))];
	y = [y; y2];
end
