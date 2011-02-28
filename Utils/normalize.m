function [Anorm, Fnorm] = normalize(A)
% [Anorm, Fnorm] = normalize(A)
%	Normalize the input array A to unitary maximum.  
%	Returns normalized array in Anorm, normalization factor in Fnorm
%
% Sharad J. Shanbhag
% sharad@etho.caltech.edu

Fnorm = max(abs(A));

Anorm = A ./ Fnorm;
