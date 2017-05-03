function sout = hpfilter(sinput, fs, fc, varargin)
%-----------------------------------------------------------------------------
% sout = hpfilter(sinput, fs, fc)
%-----------------------------------------------------------------------------
% TytoLogy -> AudioToolbox -> Filter
%-----------------------------------------------------------------------------
% 
% applies 3rd order (default) high pass filter with cutoff freq fc to
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
%		'FilterOrder'	integer > 0		specify filter order
%		
% Output Arguments:
% 	sout			filtered signal
%
%-----------------------------------------------------------------------------
% See also: lpfilter, filtfilt, butter
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
% order of filter
Forder = 3;

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

			else
				error('%s: unknown option %s', mfilename, varargin{n});
			end
		else
			n = n + 1;
		end
	end
end

%--------------------------------------------------------------
% define a high-pass filter  
%--------------------------------------------------------------
% Nyquist freq
Fnyq = fs / 2;
% generate coefficients for Butterworth filter
[B, A]  = butter(Forder, fc / Fnyq, 'high');

%--------------------------------------------------------------
% remove DC
%--------------------------------------------------------------

if DCREMOVE
	smean = mean(sinput);
	sinput = sinput - smean;
end

%--------------------------------------------------------------
% filter data
%--------------------------------------------------------------
sout = filtfilt(B, A, sinput);

%--------------------------------------------------------------
% add back DC if it was removed
%--------------------------------------------------------------
if DCREMOVE
	sout = sout + smean;
end
