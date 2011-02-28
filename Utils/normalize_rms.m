function [Anorm, Fnorm] = normalize_rms(A)
% [Anorm, Fnorm] = normalize_rms(A)
%	Normalize the input array A to rms = 1.  
%	Returns normalized array in Anorm, normalization factor in Fnorm
%
%	See Also: rms, normalize

% Sharad J. Shanbhag
% sharad@etho.caltech.edu

Anorm = A ./ rms(A);

if nargout == 2
	Fnorm = rms(A);
end
