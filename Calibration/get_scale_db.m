function vrms_out = get_scale_db(desired_db, vrms, dbspl)
%--------------------------------------------------------------------------
% vrms_out = get_scale_db(desired_db, vrms, dbspl)
%--------------------------------------------------------------------------
% Calibration Toolbox 
%--------------------------------------------------------------------------
% given desired stimulus level desired_db (in dB SPL), returns voltage rms 
% scale value to achieve desired output level
%--------------------------------------------------------------------------
% Input Arguments:
%	desired_db		desired signal level (dB SPL)
%	vrms				tested vrms value vector (usu. from caldata.v_rms)
%	dbspl				measured dB SPL vector (usu. from caldata.dbspl)
%
% Output arguments:
%	vrms_out	= Vrms scale factor
% 
%--------------------------------------------------------------------------
% See Also: syn_headphone_noise, figure_atten (for headphones), get_scale, 
%				synmononoise_rmscale
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
% Sharad Shanbhag
% sshanbhag@neoucom.edu
%--------------------------------------------------------------------------
% Created 1/4/2008 (SJS)
%
% Revisions:
%	20 Feb 2010 (SJS): updated comments/documentation
%	11 Feb 2011 (SJS):
% 		-	reworked code so that interpolation works on linear
% 			scale (pascals!)
% 		-	updated comments
% 		-	updated email address
%--------------------------------------------------------------------------
% To Do:
%	- vectorize!
%--------------------------------------------------------------------------

if ~isequal(size(vrms), size(dbspl))
	error('%s: sizes of arrays must be equal!', mfilename)
end

% convert desired db SPL value to Pascals (RMS)
pa = invdbspl(desired_db);
% convert db SPL vector to Pascals (RMS)
parms = invdbspl(dbspl);

% some checks on inputs
if pa == 0
	vrms_out = 0;
	
elseif pa < min(parms)
	warning('%s: requested db SPL is less than min calibration level - will use lowest possible level', mfilename)
	vrms_out = min(vrms);

elseif pa > max(parms)
	warning('%s: requested pa is greater than max calibration level - will use highest possible level', mfilename)
	vrms_out = max(vrms);

else
	vrms_out = interp1(parms, vrms, pa);
end
