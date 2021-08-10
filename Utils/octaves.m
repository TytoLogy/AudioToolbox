function [f, varargout] = octaves(octn, fstart, fend, base)
%------------------------------------------------------------------------
% [f, f_factor] = octaves(octn, fstart, fend, base)
%------------------------------------------------------------------------
% TytoLogy:Toolboxes:AudioToolbox:Utils
%------------------------------------------------------------------------
% 
% Generates 1/nth octaves over a specified range
% 
%------------------------------------------------------------------------
% Input Arguments:
% 	octn     1/octn octave will be interval for each step
%  fstart   starting frequency (Hz)
%  fend     ending frequency (Hz)
%  base     log base, either 2 or 10
%
% Output Arguments:
% 	f  frequencies from fstart to fend in 1/octn steps
%  f_factor frequency multipler to get from step to step
%------------------------------------------------------------------------
% See also: 
%------------------------------------------------------------------------

%------------------------------------------------------------------------
% Sharad J. Shanbhag
% sshanbhag@neomed.edu
%------------------------------------------------------------------------
% Created: XX XXXX, 2021 (SJS)
%
% Revisions:
%------------------------------------------------------------------------
% TO DO:
%------------------------------------------------------------------------

% check base value
if base == 2
	f_factor = power(2, 1 / octn);
elseif base == 10
   % if base is 10, need to scale step size
	f_factor = power(10, 3 / (10*octn));
else
	error('octaves: base must be either 2 or 10');
end

% initial value
f(1) = fstart;
% loop through until fend is reached
index = 2;
while f(index-1) < fend
	if  (f(index - 1) * f_factor) > fend
		break
	else
		f(index) = f(index - 1) * f_factor; %#ok<AGROW>
		index = index + 1;
	end
end

if nargout > 1
	varargout{1} = f_factor;
end
