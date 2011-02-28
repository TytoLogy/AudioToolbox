function vrms_out = get_scale_vector(pa, vrms, parms)
%--------------------------------------------------------------------------
%vrms_out = get_scale_vector(pa, vrms, parms)
%--------------------------------------------------------------------------
% Calibration Toolbox 
%--------------------------------------------------------------------------
% given desired stimulus level pa (in Pascals RMS), returns Voltage rms scale
% value to achieve output level.  uses interpolation  if necessary
%
% Same as get_scale(), but allows vector of input pa levels.
%--------------------------------------------------------------------------
% Input Arguments:
%	pa		= signal level (Pascal, rms) [N X 1 vector]
%	vrms	= tested vrms values (usu. from caldata.v_rms)
%	parms	= tested pa rms values (usu. from caldata.pa_rms)
%
% Output arguments:
%	vrms_out	= Vrms scale factor [N X 1] vector
% 
%--------------------------------------------------------------------------
% See Also: get_scale. synmononoise, syn_headphone_noise, 
%				figure_atten (for headphones), get_pa, get_db
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
% Sharad Shanbhag
% sharad.shanbhag@einstein.yu.edu
%--------------------------------------------------------------------------
% Created: 23 February, 2010 (SJS) from get_scale.m
%
% Revisions:
%--------------------------------------------------------------------------

% check to make sure the vrms and parms values are the same size
if ~isequal(size(vrms), size(parms))
	error('%s: sizes of arrays must be equal!', mfilename)
end

% some checks on inputs and if all is okay, interpolate to get the 
% vrms scale factor
% indices for Pa values equal to zero
zeroPa_indices = find(pa == 0);
% indices for Pa values less than min(parms)
lowPa_indices = find(pa < min(parms));
% indices for Pa values greater than max(parms)
highPa_indices = find(pa > max(parms));

% valid Pa values
validPa_indices = find( (pa>=min(parms)) & (pa<=max(parms)) );

% pre-allocate output vector with zeros
vrms_out = zeros(size(pa));

% now take some actions on the special, out of bounds cases
if lowPa_indices
	if min(vrms) == 0
		vrms_out(lowPa_indices) = 0.1*vrms(2)*ones(size(lowPa_indices));
	else
		vrms_out(lowPa_indices) = min(vrms)*ones(size(lowPa_indices));
	end
	warning('%s: some pa vals are less than min calibration level...', mfilename);
	disp(sprintf('...will use lowest possible level (%f)', vrms_out(1)) )
end

if zeroPa_indices	
	vrms_out(zeroPa_indices) = zeros(size(zeroPa_indices));
end


if highPa_indices
	warning('%s: some pa vals are greater than max calibration level...', mfilename);
	disp(sprintf('...will use highest possible level (%f)', max(vrms)) )
	vrms_out(highPa_indices) = max(vrms)*ones(size(highPa_indices));
end

vrms_out(validPa_indices) = interp1(parms, vrms, pa(validPa_indices));
