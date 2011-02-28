function cal = null_caldata(Fmin, Fmax, Fstep)
% cal = null_caldata
%
% returns a calibration structure with flat mag and phase, 70dB SPL
% Input Arguments:
%	Fmin	= min freq
% 	Fmax = max Freq
% 	Fstep = freq step
%
% Returned arguments:
%	cal =	caldata structure (caldata.mag, caldata.freq, caldata.phase)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%--------------------------------------------------------------------------
% Sharad J. Shanbhag
% sshanbha@aecom.yu.edu
% 	Code adapted from XDPHYS synth library developed by
% 	Jamie Mazer and Ben Arthur
%--------------------------------------------------------------------------
% Revision History
% 
%--------------------------------------------------------------------------

cal.range = sprintf('%d:%d:%d', Fmin, Fstep, Fmax);
cal.freq = eval(cal.range);
cal.nrasters = length(cal.freq);

cal.mag = ones(2, cal.nrasters);
cal.phase = zeros(2, cal.nrasters);
cal.mag = 120.0 * cal.mag;
cal.dist = cal.phase;
cal.leak_mag = cal.phase;
cal.leak_phase = cal.phase;
cal.leak_dist = cal.phase;
cal.mag_stderr = cal.phase;
cal.phase_stderr = cal.phase;
cal.phase_rad = cal.phase;
cal.mindbspl = [40.0 40.0];
cal.maxdbspl = [120.0 120.0];

cal.mono = 'b';
cal.calfilename = 'null_caldata.cal';

cal.phase_us = cal.phase;
% preconvert phases from angle (RADIANS) to microsecond
cal.phase_us(1, :) = (1.0e6 * unwrap(cal.phase(1, :))) ./ (2 * pi * cal.freq);
cal.phase_us(2, :) = (1.0e6 * unwrap(cal.phase(2, :))) ./ (2 * pi * cal.freq);

% % get the overall min and max dB SPL levels
% cal.mindbspl = min(cal.mag');
% cal.maxdbspl = max(cal.mag');

% precompute the inverse filter, and convert to RMS value.
cal.maginv = cal.mag;
cal.maginv(1, :) = power(10, (cal.mindbspl(1) - cal.mag(1, :)) ./ 20);
cal.maginv(2, :) = power(10, (cal.mindbspl(2) - cal.mag(2, :)) ./ 20);
