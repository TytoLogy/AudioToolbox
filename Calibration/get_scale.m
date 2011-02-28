function vrms_out = get_scale(pa, vrms, parms)
%--------------------------------------------------------------------------
% vrms_out = get_scale(pa, vrms, parms)
%--------------------------------------------------------------------------
% Calibration Toolbox 
%--------------------------------------------------------------------------
% given desired stimulus level pa (in Pascals RMS), returns Voltage rms scale
% value to achieve output level
%--------------------------------------------------------------------------
% Input Arguments:
%	pa			desired signal level (Pascal RMS)
%	vrms		tested vrms values (usu. from caldata.v_rms)
%	parms		tested pa rms values (usu. from caldata.pa_rms)
%
% Output arguments:
%	vrms_out	 Vrms scale factor
% 
%--------------------------------------------------------------------------
% See Also: syn_headphone_noise, figure_atten (for headphones), get_scale_db, 
%				synmononoise_rmscale
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
% Sharad Shanbhag
% sshanbhag@neoucom.edu
%--------------------------------------------------------------------------
% Created 1/4/2008
%
% Revisions:
%	20 Feb 2010 (SJS): updated comments/documentation
%	11 Feb 2011 (SJS): more comments updates, email address update
%--------------------------------------------------------------------------
% To Do:
%	- vectorize!
%--------------------------------------------------------------------------

% check to make sure the vrms and parms values are the same size
if ~isequal(size(vrms), size(parms))
	error('%s: sizes of arrays must be equal!', mfilename)
end

% some checks on inputs and if all is okay, interpolate to get the 
% vrms scale factor
if pa == 0
	vrms_out = 0;
	
elseif pa < min(parms)
	if min(vrms) == 0
		vrms_out = 0.1*vrms(2);
	else
		vrms_out = min(vrms);
	end
	warning(['get_scale: requested pa is less than min calibration level - will use lowest possible level: ' num2str(vrms_out)])
	
elseif pa > max(parms)
	warning('get_scale: requested pa is greater than max calibration level - will use highest possible level')
	vrms_out = max(vrms);
else
	vrms_out = interp1(parms, vrms, pa);
end