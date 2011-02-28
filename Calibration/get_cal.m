function [mag, phi] = get_cal(frequency, cal_freq, cal_mag, cal_phi)
%FUNCTION [mag, phi] = get_cal(freq, cal_freq, cal_mag, cal_phi)
%	Given calibration information in caldata, interpolates 
%	to return magnitude (mag) and phase (phi) correction 
%	factors at frequency.
%
%	frequency can be a vector; this approach can speed up the 
%	computation of the correction factors by eliminating a 
%	for loop in the calling function.
%
%	caldata structure format:
%		caldata.freq		array of sampled frequencies, size = 1:nfreq
%		caldata.mag			array of magnitudes (in db SPL)
%		caldata.phi			array of phases (in us)
%	*************** note that all arrays must be of equal length!!!!
%
% This function should work with any appropriate calibration data, e.g. 
% calibration data from xcalibur.
%
% Created 11/28/2001
% Sharad J. Shanbhag	sharad@etho.caltech.edu
% 

if isequal(size(cal_freq), size(cal_mag), size(cal_phi)) == 0
	error('get_cal: sizes of arrays in caldata must be equal!')
end

% mag = linterp(cal_freq, cal_mag, frequency);
% phi = linterp(cal_freq, cal_phi, frequency);

mag = interp1(cal_freq, cal_mag, frequency);
phi = interp1(cal_freq, cal_phi, frequency);
