function paval = invdbspl(dbsplval)
% paval = invdbspl(dbsplval)
%
%	converts dB SPL (re 20 uPa) to Pa (rms)
%
%		val = 10^(dbval / 20)
%

%---------------------------------------------------------------------
%	Sharad Shanbhag
%	sshanbhag@aecom.yu.edu
%
%--Revision History---------------------------------------------------
%	28 April, 2009, SJS:	adapted from invdb
%---------------------------------------------------------------------


paval = 0.00002 * power(10, dbsplval ./ 20);