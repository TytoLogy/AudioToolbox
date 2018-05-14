function [Sout, varargout] = correctFs(Sin, Fsin, Fsout)
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
% 11 May 2018 (SJS): 
%	old algorithm did weird things to waveform when down sampling. 
%	implemented solution at 
%	https://www.mathworks.com/help/signal/ug/changing-signal-sample-rate.html
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

%{
%**** OLD METHOD***********************************
% build time base for orig data
t_orig = (0:(length(Sin) - 1)) * (1/Fsin);
% resample original data
Sout = resample(Sin, t_orig, Fsout);
%}

%**** NEW METHOD***********************************
% find rational number ratio of integers for resampling; this is from
% https://www.mathworks.com/help/signal/ug/changing-signal-sample-rate.html
[P,Q] = rat(Fsout/Fsin);
% resample original data
Sout = resample(Sin, P, Q);

if nargout > 1
	varargout{1} = [P, Q];
end

