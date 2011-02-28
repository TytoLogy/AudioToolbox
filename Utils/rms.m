function rmsval = rms(v)
% function rmsval = rms(v)
%
%	computes RMS  (root mean square) of vector v

% Sharad Shanbhag
% sshanbha@aecom.yu.edu


rmsval = sqrt( mean( v.^2 ) );