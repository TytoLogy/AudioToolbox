function [A, B] = golay_pair(N)
%------------------------------------------------------------------------
% [A, B] = golay_pair(N)
%------------------------------------------------------------------------
% Calibration Toolbox
%------------------------------------------------------------------------
% Generates Nth order Golay complementary sequence
% 
% Based on technique described in Zhou, et al., J Acoust Soc Am.  (1992) 
% 92(2 Pt 1):1169-71 "Characterization of external ear impulse 
% responses using Golay codes."
% 
%------------------------------------------------------------------------
% Input Arguments:
% 	N		Order of Golay sequence
%				sequence will be 4*(2^(N-1)) elements long
%
% Returns:
% 	A, B	complementary pairs
%
%------------------------------------------------------------------------
% See also:  golay_tfe, golay_impulse
%------------------------------------------------------------------------

%------------------------------------------------------------------------
% Sharad Shanbhag
% sharad.shanbhag@einstein.yu.edu
%------------------------------------------------------------------------
% Created:	20 July, 2001
% Revisions:
% 	18 March, 2010 (SJS):	updated comments
%------------------------------------------------------------------------

if nargin ~= 1
	error('must specify order!');
elseif N < 1
	error('Order must be greater than 0');
end

a0 = [1 1];
b0 = [1 -1];

for i=1:N
       A = [a0 b0];
       B = [a0 -1.*b0];
       a0 = A;
       b0 = B;
end

