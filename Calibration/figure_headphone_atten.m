function [atten_val, spl_val] = figure_headphone_atten(spl_val, rms_val, caldata, varargin)
%---------------------------------------------------------------------
%[atten_val, spl_val] = figure_headphone_atten(spl_val, rms_val, caldata, varargin)
%---------------------------------------------------------------------
%	Calibration Toolbox 
%---------------------------------------------------------------------
% 
%	Given rms_value of sound and calibration data (caldata),	computes the 
% 	atten_val required to obtain desired spl_val output levels.
% 	
% 	Same as figure_atten, but performs more checks on input and output levels
% 	
%---------------------------------------------------------------------
%	Input Arguments:
%		spl_val		[1X2] array of desired L and R output SPL values (dB)
% 		rms_val	[1X2] array of L and R rms values (from syn*.m functions)
% 		caldata		calibration data structure
% 
% 		Optional:
% 			varargin{1}	[1X2] array of L and R enable values
% 							e.g., [0 0]	sets attenuation to MAXATTEN for both 
% 											channels
% 									[0 1] sets atten to MAXATTEN for L channel,
% 											R channel computed as normal
% 											
%	Output Arguments:
%		atten_val	[1X2] array, L and R attenuation settings (dB)
% 
%---------------------------------------------------------------------

%---------------------------------------------------------------------
%	Sharad Shanbhag
%	sshanbhag@neomed.edu
%
%--Revision History---------------------------------------------------
%	12 Feb, 2008, SJS:	created
% 	29 May, 2009:	added documentation (SJS)
%						changed scale_val variable to rms_val to more accurately
% 						reflect data type
%	9 Dec, 2009 (SJS):	added varargin to allow input of L/R Enable
%	2 Jan, 2013 (SJS):
%	 -	fixed stupid error in spl_val calculation when varargin is 
% 		provided (l/r headphone enable)
% 	 -	updated documentation email
%---------------------------------------------------------------------

MAXATTEN = 120;
MINATTEN = 0;

% check and see if L/R enable was provided, if so, modify spl_cal
% accordingly
if ~isempty(varargin)
	spl_val = spl_val .* varargin{1};
end

if spl_val(1) == 0
	atten_val(1) = MAXATTEN;
else
	atten_val(1) = caldata.mindbspl(1) + db(rms_val(1)) - spl_val(1);
end

if (atten_val(1) > MAXATTEN) && (spl_val(1) ~= 0)
	disp([mfilename ' warning: requested lspl too low']);
	atten_val(1) = MAXATTEN;
elseif atten_val(1) < MINATTEN
	disp([mfilename ' warning: requested lspl too high']);
	atten_val(1) = MINATTEN;
elseif isnan(atten_val(1))
	disp([mfilename ' warning: NaN returned for lspl']);
	fprintf('lrms = %.4f, spl_val = %.4f\n', rms_val(1), spl_val(1));
	atten_val(1) = MAXATTEN;
end

if spl_val(2) == 0
	atten_val(2) = MAXATTEN;
else
	atten_val(2) = caldata.mindbspl(2) + db(rms_val(2)) - spl_val(2);
end

if (atten_val(2) > MAXATTEN) && (spl_val(2) ~= 0)
	disp([mfilename ' warning: requested rspl too low']);
	atten_val(2) = MAXATTEN;
elseif atten_val(2) < MINATTEN
	disp([mfilename ' warning: requested rspl too high']);
	atten_val(2) = MINATTEN;
elseif isnan(atten_val(2))
	disp([mfilename ' warning: NaN returned for rspl']);
	fprintf('rrms = %.4f, spl_val = %.4f\n', rms_val(2), spl_val(2));
	atten_val(1) = MAXATTEN;
end


