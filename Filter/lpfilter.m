function sout = lpfilter(sinput, fs, fc, varargin)
%-----------------------------------------------------------------------------
% sout = lpfilter(sinput, fs, fc)
%-----------------------------------------------------------------------------
% TytoLogy -> AudioToolbox -> Filter
%-----------------------------------------------------------------------------
%
% applies 3rd order (default) low pass filter with cutoff freq fc to
% signal sinput
% 
%-----------------------------------------------------------------------------
% Input Arguments:
% 	sinput		signal to be filtered
%	fs				sampling rate (samples/second)
%	fc				cutoff frequency (Hz)
%
%	Options:
% 		'DCremove'		'yes'/'no'		remove DC offset before filtering
% 												(reinstates offset afterwards)
%
%		'FilterOrder'	integer > 0		specify filter order
% 
% 		'MeanPad'		integer > 0		pads beginning and end of sinput
% 							samples			with # samples.  computes mean using
% 							 - or -			10 samples at beginning and end (unless
% 				[pad samples, mean samples]		specified as second element)
%		
% Output Arguments:
% 	sout			filtered signal
%
%-----------------------------------------------------------------------------
% See also: hpfilter, filtfilt, butter
%-----------------------------------------------------------------------------

%-----------------------------------------------------------------------------
% Sharad J. Shanbhag
% sshanbhag@neomed.edu
%-----------------------------------------------------------------------------
% Created: 1 May, 2012 (SJS)
%
% Revisions:
%	3 May 2017 (SJS): cleaned up a bit, added to AudioToolbox -> Filter
%-----------------------------------------------------------------------------
% TO DO:
%-----------------------------------------------------------------------------

%-----------------------------------------------------------------------------
%-----------------------------------------------------------------------------
% Defaults
%-----------------------------------------------------------------------------
%-----------------------------------------------------------------------------
DCREMOVE = 0;
MEANPAD = 0;
% default order of filter
Forder = 3;
% default # of points to compute mean
Meanpts = 10;
% default Window size
Winpts = 50;

%-----------------------------------------------------------------------------
%-----------------------------------------------------------------------------
% Parse inputs
%-----------------------------------------------------------------------------
%-----------------------------------------------------------------------------
optargin = size(varargin,2);
stdargin = nargin - optargin;

if stdargin == 0
	error('%s: improper input args', mfilename);
end

if optargin
	% parse varargin args
	n = 1;
	while n < optargin
		if ischar(varargin{n})
			if strcmpi(varargin{n}, 'DCremove')
				instruction = varargin{n+1};
				if strcmpi(instruction(1), 'y')
					DCREMOVE = 1;
				else
					DCREMOVE = 0;
				end
				n = n + 2;
				
			elseif strcmpi(varargin{n}, 'FilterOrder')
				Forder = varargin{n+1};
				n = n + 2;
				
			elseif strcmpi(varargin{n}, 'MeanPad')
				MEANPAD = 1;
				
				if isnumeric(varargin{n+1})
					% user provided mean pad values
					vals = varargin{n+1};
					
					if length(vals) == 2
						Winpts = vals(1);
						Meanpts = vals(2);
					else
						Winpts = vals(1);
					end
					n = n + 2;
				else
					n = n + 1;
				end

			else
				error('%s: unknown option %s', mfilename, varargin{n});
			end
		else
			n = n + 1;
		end
	end
end

%--------------------------------------------------------------
% define a low-pass filter  
%--------------------------------------------------------------
% Nyquist freq
Fnyq = fs / 2;
% generate coefficients for Butterworth filter
[B, A]  = butter(Forder, fc / Fnyq, 'low');

%--------------------------------------------------------------
% ensure sinput is a row vector
%--------------------------------------------------------------
if isrow(sinput)
	stmp = sinput;
else
	stmp = sinput';
end

%--------------------------------------------------------------
% remove DC or pad array if so instructed
%--------------------------------------------------------------
if DCREMOVE
	smean = mean(sinput);
	stmp = sinput - smean;
	
elseif MEANPAD
	append_start = mean(sinput(1:Meanpts)) .* ones(1, Winpts);
	append_end = mean(sinput(end-Meanpts:end)) .* ones(1, Winpts);
	stmp = [append_start stmp append_end];
end

%--------------------------------------------------------------
% filter data
%--------------------------------------------------------------
sout = filtfilt(B, A, stmp);

%--------------------------------------------------------------
% add back DC if it was removed 
%					or 
% remove pads if they were added
%--------------------------------------------------------------
if DCREMOVE
	sout = sout + smean;
elseif MEANPAD
	sout = sout((Winpts+1):(length(sout) - Winpts));
end


%-----------------------------------------------------------------------------
%--------------------------------------------------------------------------
function out = isrow(in)
%-----------------------------------------------------------------------------
% out = isrow(in)
%-----------------------------------------------------------------------------
% 
% if input vector is a row vector (i.e., size if [1 X N]), returns 1
% otherwise, returns 0
% 
%-----------------------------------------------------------------------------
% Input Arguments:
% 	in			vector
%
% Output Arguments:
%	out		1 if  input array IN is a vector
% 				0 otherwise
% 						
%-----------------------------------------------------------------------------
% See also: isrow (for more current Matlab versions)
%-----------------------------------------------------------------------------

[rows, ~] = size(in);

if rows == 1
	out = 1;
else
	out = 0;
end

%-----------------------------------------------------------------------------
%-----------------------------------------------------------------------------

