function [X, L] = xcorrplot(S1, S2, titlestr)
%------------------------------------------------------------------------
% [X, L] = xcorrplot(S1, S2, titlestr)
%------------------------------------------------------------------------
% 
% plots cross-correlation function for signals S1 & S2
% 
%------------------------------------------------------------------------
% Input Arguments:
% 	S1, S2	vectors of same length N
%	titlestr	plot title (optional)
% 
% Output Arguments:
%	X		cross-correlation function, length 2N+1
% 	L		lags
%------------------------------------------------------------------------
% See also: 
%------------------------------------------------------------------------

%------------------------------------------------------------------------
%  Sharad J. Shanbhag
%	sharad.shanbhag@einstein.yu.edu
%------------------------------------------------------------------------
% Created: 21 January, 2010 (SJS)
%
% Revisions:
%------------------------------------------------------------------------
% TO DO:
%------------------------------------------------------------------------

% checks
if nargin < 2
	error([mfilename ': need 2 input vectors!']);
else
	if size(S1) ~= size(S2)
		error([mfilename ': vector sizes do not match']);
	end
end

% compute x correlation and get lag vector
[X, L] = xcorr(S1, S2);

% check to make sure the input vars have valid names - if the inputs
% are passed as indexed arrays (i.e., S(:, N)), they won't have names
s1name = inputname(1);
s2name = inputname(2);
if isempty(s1name)
	s1name = 'S1';
end
if isempty(s2name)
	s2name = 'S2';
end

% plot
subplot(311), plot(S1), ylabel(s1name);
if exist('titlestr', 'var')
	title(titlestr);
end

subplot(312), plot(S2), ylabel(s2name), xlabel('n');
subplot(313), plot(L, X);
ylabel(['xcorr(' s1name ', ' s2name ')']);
xlabel('lag');
