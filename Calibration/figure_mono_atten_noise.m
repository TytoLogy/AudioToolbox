function [atten_val] = figure_mono_atten_noise(spl_val, rms_val, caldata)
%[atten_val] = figure_mono_atten_noise(spl_val, rms_val, caldata)
%---------------------------------------------------------------------
% TytoLogy AudioToolbox:Calibration Toolbox
%---------------------------------------------------------------------
% 
%	Given rms_value of sound and calibration data (caldata),	computes the 
% 	atten_val required to obtain desired spl_val output levels for noise
% 	
% 	Same as figure_headphone_atten.m, but with no checks on max/min atten
% 	levels
% 	
%	Input Arguments:
%		spl_val		desired output SPL values (dB)
% 		rms_val		rms values (from syn*.m functions)
% 		caldata		calibration data structure
% 		
%	Output Arguments:
%		atten_val	[1Xlength(spl_val)] array, attenuation settings (dB)
% 
%---------------------------------------------------------------------
%See alse: FIGURE_HEADPHONE_ATTEN, FIGURE_ATTEN
%---------------------------------------------------------------------

%---------------------------------------------------------------------
%	Sharad J Shanbhag
%	sshanbhag@neomed.edu
%
%--Revision History---------------------------------------------------
%	24 May, 2016 (SJS):	created
%	12 Apr, 2017: added checks for atten_val < 0, spl_val == 0
% 22 Oct 2017 (SJS): fixed issue with miscalc of atten. note that 
% this fix is really only valid for use when an attenuator is used
%---------------------------------------------------------------------
MAXATTEN = 120;

if length(spl_val) ~= length(rms_val)
	error('%s: mismatch in length of spl_val (%d) and rms_val (%d)', ...
					mfilename, length(spl_val), length(rms_val));
end

% # of atten values needed
nvals = length(spl_val);
% preallocate
atten_val = zeros(size(spl_val));
% assign values
for n = 1:nvals
% 	atten_val(n) = caldata.mindbspl(1) + db(rms_val(n)) - spl_val(n);
% 	atten_val(n) = caldata.mindbspl(1) + ...
% 					db(caldata.cal.VtoPa(1).*rms_val(n)) - spl_val(n);
% 	atten_val(n) = caldata.mindbspl(1) - spl_val(n);
% 	atten_val(n) = dbspl(caldata.cal.VtoPa(1).*rms_val(n)) - spl_val(n);
	atten_val(n) = dbspl(caldata.VtoPa(1).*rms_val(n)) - spl_val(n);

end
% set values < 0 to 0
atten_val(atten_val < 0) = 0;
% set values to max atten when spl_val == 0
atten_val(spl_val == 0) = MAXATTEN;


