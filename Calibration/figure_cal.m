function [rmsval, phi] = figure_cal(freqs, caldata)
%function [rmsval, phi] = figure_cal(freqs, caldata)
%	Input Arguments:
%		freqs		vector of frequencies for which to 
%					get calibration values
%
%		caldata		calibration data structure
%
%	Output Arguments:
%		rmsval		rms correction factors at each of freqs
%		phi			phase correction factors (in radians) at freqs
%
%	See Also:	LOAD_CALDATA, LOAD_HEADPHONE_CAL

%---------------------------------------------------------------------
%	Sharad Shanbhag
%	sshanbhag@aecom.yu.edu
%
%--Revision History---------------------------------------------------
%	12 Feb, 2008, SJS:	created
%	20 Mar, 2008, SJS:	added help comments
%	19 Jan, 2009, SJS:	- modified comments
%								- fixed error if n >= 3 in
%								  STEREO check code (from caldata that have
%									REF mic information)
%---------------------------------------------------------------------

% get size of vector
[n, m] = size(caldata.maginv);

% check if stereo
STEREO = 0;
if n >= 2
	STEREO = 1;
end

% get values for Left channel (1)
rmsval = interp1(caldata.freq, caldata.maginv(1, :), freqs);
phi = interp1(caldata.freq, caldata.phase_us(1, :), freqs);
phi = (phi ./ 1.0e6) .* freqs * 2 * pi;
if STEREO
	% get values for Right channel  (2)
	rmsval(2, :) = interp1(caldata.freq, caldata.maginv(2, :), freqs);
	phi(2, :) = interp1(caldata.freq, caldata.phase_us(2, :), freqs);
	phi(2, :) = (phi(2, :) ./ 1.0e6) .* freqs * 2 * pi;
end
