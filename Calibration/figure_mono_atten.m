function [atten_val] = figure_mono_atten(spl_val, rms_val, caldata)
%[atten_val] = figure_mono_atten(spl_val, rms_val, caldata)
%---------------------------------------------------------------------
% TytoLogy AudioToolbox:Calibration Toolbox
%---------------------------------------------------------------------
% 
%	Given rms_value of sound and calibration data (caldata),	computes the 
% 	atten_val required to obtain desired spl_val output levels.
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
%See alse: FIGURE_HEADPHONE_ATTEN
%---------------------------------------------------------------------

%---------------------------------------------------------------------
%	Sharad JShanbhag
%	sshanbhag@neomed.edu
%
%--Revision History---------------------------------------------------
%	24 May, 2016 (SJS):	created
%---------------------------------------------------------------------

nvals = length(spl_val);

atten_val = zeros(size(spl_val));

for n = 1:nvals
	atten_val(n) = caldata.mindbspl(n) + db(rms_val(n)) - spl_val(n);
end


