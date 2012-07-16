function dbval = dbspl(spl)
%--------------------------------------------------------------------------
% dbval = dbspl(spl)
%--------------------------------------------------------------------------
% AudioToolbox: Utils
%--------------------------------------------------------------------------
%	converts sound pressure (in Pa) to dB SPL, where
%
%		dBSPL = 20 * log10(spl / 20 uPa)
%
% note that spl value should be the rms Pascal value
%------------------------------------------------------------------------
% Input Arguments:
%	spl		sound pressure level in Pascal (rms)
%
% Output Arguments:
%	dbval		dB SPL value (re 20e-6 Pa)
%------------------------------------------------------------------------
% See also: log10, rms
%------------------------------------------------------------------------

%--------------------------------------------------------------------------
% Sharad J. Shanbhag
% sshanbhag@neomed.edu
%------------------------------------------------------------------------
% Created: ?, SJS
% 
% Revisions:
%	12 Jul 2012 (SJS):
% 	 -	added comments
% 	 - added code to eliminate issue with taking dbspl(0)
%--------------------------------------------------------------------------

% Avoid taking the log of 0.
spl(spl <= 0) = 1e-17;

%dbval = 20 .* log10(spl./20e-6);

dbval = (20 .* log10(spl)) + 93.97940008672038 * ones(size(spl));
