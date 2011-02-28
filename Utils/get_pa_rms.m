function pa_rms_out = get_pa_rms(v_rms_in, parms, vrms)
%pa_rms_out = get_pa_rms(v_rms_in, parms, vrms)
%
% Input Arguments:
%	v_rms_in		= scale level (Volts, rms)
%	parms	= tested pa rms values (usu. from caldata.pa_rms)
%	vrms	= tested vrms values (usu. from caldata.v_rms)
%
% Output arguments:
%	pa_rms_out	= Pa level(Pascal, rms)
% 
% See Also: syn_headphone_noise, figure_atten (for headphones), get_scale, 
%				get_db
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
% Sharad Shanbhag
% sshanbha@aecom.yu.edu
%--------------------------------------------------------------------------
% Revisions:
%
% Created 3 June, 2009
%
%--------------------------------------------------------------------------

if ~isequal(size(vrms), size(parms))
	error([mfilename ': sizes of arrays must be equal!']);
end

if v_rms_in <= 0
	pa_rms_out = 0;
elseif v_rms_in > max(vrms)
	warning([mfilename ': v_rms_in is greater than maximum tested value']);
	pa_rms_out = max(parms);
else
	pa_rms_out = interp1(vrms, parms, v_rms_in);
end