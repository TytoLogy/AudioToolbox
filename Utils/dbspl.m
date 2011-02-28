function dbval = dbspl(spl)
% function dbval = dbspl(spl)
%
%	converts sound pressure (in Pa) to dB SPL, where
%
%		dBSPL = 20 * log10(spl / 20 uPa)
%

% Sharad J. Shanbhag
% sharad@etho.caltech.edu
% Version 1.00

if spl<=0
	warning('dbspl: spl <= 0!');
end

%dbval = 20 .* log10(spl./20e-6);

dbval = (20 .* log10(spl)) + 93.97940008672038 * ones(size(spl));
