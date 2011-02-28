function spl = dbspl2pa(dbspl)
% function spl = dbspl2pa(dbspl)
%
%	converts dB SPL to sound pressure (in Pa) 
%	
%	spl = 20e-6 * 10^(dbspl ./ 20);
%

% Sharad J. Shanbhag
% sharad@etho.caltech.edu
% Version 1.00



spl = 20e-6 * 10.^(dbspl ./ 20);
