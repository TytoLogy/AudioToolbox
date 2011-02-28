function [E, H] = extract_envelope(S)
% generate an AM signal:
% [E, H] = extract_envelope(S)
%
% Extract envelope E from signal S using hilbert transform H
%
% Input Arguments:
%	S		= real-valued signal signal vector
%
% Returned arguments:
%	E		= signal envelope
%	H		= hilbert transforms of S
%
% See Also: hilbert
%-------------------------------------------------------------------------

%-------------------------------------------------------------------------
% Sharad J. Shanbhag
% sshanbha@aecom.yu.edu
%-------------------------------------------------------------------------
% Revision History
%	11 August, 2009 (SJS):
%		- created
%-------------------------------------------------------------------------


% find the envelope
H = hilbert(S);
E = abs(H);

