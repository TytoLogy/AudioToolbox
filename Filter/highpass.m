function f3db = highpass(R, C)
% function f3db = highpass(R, C)
%	
%	given R (ohms) and C (microfarads),
% 	returns 1/(2 pi R C)
%

if nargin ~= 2
	error('highpass requires values for R and C')
end
if R==0 | C == 0
	error('R or C cannot be zero')
end

f3db = 1 / (2 * pi * R * C * 0.000001);