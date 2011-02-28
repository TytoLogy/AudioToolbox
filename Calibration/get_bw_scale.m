function vrms_out = get_bw_scale(dbspl, caldata, bw)
%vrms_out = get_bw_scale(dbspl, caldata, bw)
% 
% given desired stimulus level in dB, returns Voltage rms scale
%  value to achieve output level
%
% Input Arguments:
%	dbspl		= desired signal level (dB SPL)
%	caldata = speaker calibration data structure
%	bw	= signal bandwidth vector, [low high] in Hz
% 			if signal is a tone, use single value for frequency
%			if not provided, no bw correction is done
% 
% Output arguments:
%	vrms_out	= Vrms scale factor
% 
% See Also: syn_headphone_noise, figure_atten (for headphones), get_pa, 
%				get_db
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
% Sharad Shanbhag
% sshanbha@aecom.yu.edu
%--------------------------------------------------------------------------
% Created: 5 June, 2009
% 
% Revisions:
%
%--------------------------------------------------------------------------

VMAX = 5;
VMIN = 0;

if nargin < 2
	error([mfilename ': incorrect input args'])
end

% compute the bandwidth - amplitude correction
% check if bw is defined
if nargin == 3
	% check if single freq (tone) or range
	if length(bw) == 2
		bandwidth = bw(2) - bw(1);
		if between(bandwidth, 2, 500)
			disp([mfilename ': SPL for bandwidth < 500 Hz is unpredictable!']);
		elseif bandwidth <= 0
			error([mfilename ': bandwidth range must be >= 0']);
		end
		bwdbfactor = interp1(caldata.bw.bwfreqs, caldata.bw.correction, bandwidth);
	else % tone
		if bw(1) <= 0
			error([mfilename ': bandwidth range must be >= 0']);
		else
% 			bwdbfactor = interp1(caldata.bw.bwfreqs, caldata.bw.correction, bw(1));
% 			bwdbfactor = caldata.bw.correction(1);
			bwdbfactor = 40;
		end
	end
else
	bwdbfactor = 0
end

dbval = dbspl+bwdbfactor;

pa = dbspl2pa(dbval);

if pa <= 0
	warning([mfilename ': pa is <= 0!'])
	vrms_out = 0;
	return

elseif ~between(pa, min(caldata.pa_rms), max(caldata.pa_rms))
	disp([mfilename ': desired dB outside of calibration range - extrapolating'])
	if ~isfield(caldata, 'dbcal')
		% compute regression fit to db calibration data
		b = regress(caldata.v_rms, [ones(size(caldata.pa_rms)) caldata.pa_rms]);
		caldata.dbcal.intercept = b(1);
		caldata.dbcal.slope = b(2);
	end
	vrms_out = caldata.dbcal.intercept + caldata.dbcal.slope * pa;
	% keep vrms_out within bounds of VMIN and VMAX
	if vrms_out < VMIN
		vrms_out = VMIN;
	elseif vrms_out > VMAX
		vrms_out = VMAX;
	end
	return

else
	vrms_out = interp1(caldata.pa_rms, caldata.v_rms, pa);
end

