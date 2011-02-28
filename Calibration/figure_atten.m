function [atten_val] = figure_atten(spl_val, rms_val, caldata)
%[atten_val] = figure_atten(spl_val, rms_val, caldata)
% 
%	Given rms_value of sound and calibration data (caldata),	computes the 
% 	atten_val required to obtain desired spl_val output levels.
% 	
% 	Same as figure_headphone_atten.m, but with no checks on max/min atten
% 	levels
% 	
%	Input Arguments:
%		spl_val		[1X2] array of desired L and R output SPL values (dB)
% 		rms_val	[1X2] array of L and R rms values (from syn*.m functions)
% 		caldata		calibration data structure
% 		
%	Output Arguments:
%		atten_val	[1X2] array, L and R attenuation settings (dB)
% 
%See alse: FIGURE_HEADPHONE_ATTEN
%---------------------------------------------------------------------

%---------------------------------------------------------------------
%	Sharad Shanbhag
%	sharad@etho.caltech.edu
%
%--Revision History---------------------------------------------------
%	12 Feb, 2008, SJS:	created
% 	29 May, 2009:	added documentation (SJS)
%						changed scale_val variable to rms_val to more accurately
% 						reflect data type
%---------------------------------------------------------------------

[n, m] = size(caldata.mag);

atten_val(1) = caldata.mindbspl(1) + db(rms_val(1)) - spl_val(1);
if n == 2
	atten_val(2) = caldata.mindbspl(2) + db(rms_val(2)) - spl_val(2);
end


