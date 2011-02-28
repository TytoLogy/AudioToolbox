function [RMSfactor, resp_eq] = rms_equalize(stim, resp)
%
%
%
%
%	Sharad J. Shanbhag
%	sharad@etho.caltech.edu
%	
%	Created 10/25/2001

if nargin ~= 2,
	error('rms_equalize: requires 2 input vectors');
end

stimRMS = rms(stim);
respRMS = rms(resp);

if respRMS == 0
	error('rms_equalize: rms(resp) == zero');
end

RMSfactor = stimRMS / respRMS;

if nargout == 2
	resp_eq = RMSfactor * resp;
end



