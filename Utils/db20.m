function dbval = db20(v)
% dbval = db20(v)
%
%	converts v (power) to db
%
%		dbval = 20 * log10(v)
%
% See Also: db, dbspl
%------------------------------------------------------------------------

%------------------------------------------------------------------------
% Sharad Shanbhag
% sshanbha@aecom.yu.edu
%------------------------------------------------------------------------
% Created:
%	12 Nov 08 (SJS): adapted from dbspl.m
%	
% Revisions:
%------------------------------------------------------------------------

if v <= 0
	warning('db20: v <= 0!');
	dbval = NaN;
	return
end

dbval = 20 .* log10(v);
