function val = invdb(dbval)
% val = invdb(dbval)
%
%	converts dB (re 1 V or unit) to linear scale
%
%		val = 10^(dbval / 20)
%

% Sharad J. Shanbhag
% sshanbha@aecom.yu.edu
% Version 1.00

val = power(10, dbval ./ 20);