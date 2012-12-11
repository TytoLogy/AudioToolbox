function [Anorm, Fnorm] = normalize(A)
%--------------------------------------------------------------------------
% [Anorm, Fnorm] = normalize(A)
%--------------------------------------------------------------------------
% AudioToolbox->Utils
% TytoLogy Project
%--------------------------------------------------------------------------
%	Normalize the input array A to unitary maximum.  
%	Returns normalized array in Anorm, normalization factor in Fnorm
%------------------------------------------------------------------------
% Input Arguments:
% 	A			vector of numbers
% 
% Output Arguments:
% 	Anorm		normalized vector A
%	Fnorm		normalization factor (max(abs(A))
%------------------------------------------------------------------------
% See also: abs, max
%------------------------------------------------------------------------

%--------------------------------------------------------------------------
% Sharad J Shanbhag
% sshanbhag@neomed.edu
%--------------------------------------------------------------------------
% Created: ??? (SJS)
% 
% Revisions:
%	5 Dec, 2012 (SJS): updated documentation
%--------------------------------------------------------------------------

% obtain normalization factor: maximum absolute value
Fnorm = max(abs(A));
% apply normalization
Anorm = A ./ Fnorm;
