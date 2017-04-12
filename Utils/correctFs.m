function Sout = correctFs(Sin, Fsin, Fsout)
%------------------------------------------------------------------------
% Sout = correctFs(Sin, Fsin, Fsout)
%------------------------------------------------------------------------
% TytoLogy
%------------------------------------------------------------------------
% function to match wav sample rate to output device sample rate by
% resampling wav data
%------------------------------------------------------------------------
%------------------------------------------------------------------------
% Input Arguments:
%
% Output Arguments:
%------------------------------------------------------------------------

%------------------------------------------------------------------------
% Sharad Shanbhag 
% sshanbhag@neomed.edu
%------------------------------------------------------------------------
% Created: 12 April, 2017 (SJS)
%	pulled out from correctWavFs.m file in opto program
%------------------------------------------------------------------------
% Revisions
%------------------------------------------------------------------------


%------------------------------------------------------------------------
% Check inputs
%------------------------------------------------------------------------
if nargin ~= 3
	error('%s: need signal and sample rates (orig, desired) as inputs', ...
					mfilename)
elseif isempty(Sin)
	error('%s: Sin is empty', mfilename)	
elseif isempty(Fsin) || (Fsin <= 0)
	error('%s: Fsin invalid', mfilename)	
elseif isempty(Fsout) || (Fsout <= 0)
	error('%s: Fsout invalid', mfilename)
elseif Fsin == Fsout
	warning('%s: Fsin == Fsout', mfilename);
	Sout = Sin;
	return;
end

% build time base for orig data
t_orig = (0:(length(Sin) - 1)) * (1/Fsin);
% resample original data
Sout = resample(Sin, t_orig, Fsout);
