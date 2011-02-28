function S = synmonoclick(stimdur, Fs, delay, clickdur, scale)
%-------------------------------------------------------------------------
% S = synmonoclick(stimdur, Fs, delay, clickdur, scale)
%-------------------------------------------------------------------------
% Synthesis Toolbox
%-------------------------------------------------------------------------
% 
% 	synthesize a single-channel (mono) click, typically for use with 
% 	free-field array.
%   Note that click duration is in samples, not milliseconds!!!!
%-------------------------------------------------------------------------
%	stimdur		signal duration (ms)
%	Fs				output sampling rate
%	delay			click delay (milliseconds)
%	clickdur		click duration (samples)
%	scale			output scale factor  
%
% Output arguments:
%	S				[1XN] array, where N = 0.001*dur*Fs
%-------------------------------------------------------------------------
% See Also: synmonosine, synmononoise_fft
%-------------------------------------------------------------------------


%--------------------------------------------------------------------------
% Sharad J. Shanbhag
% sharad.shanbhag@einstein.yu.edu
%--------------------------------------------------------------------------
% Created: 11 March, 2010 (SJS) from synmononoise_fft
% Revision History:
%--------------------------------------------------------------------------

% do some basic checks on the input arguments
if nargin ~= 5
	help synmonoclick;
	error('%s: incorrect number of input arguments', mfilename);
end

if stimdur <=0
	error('%s: stimdur must be > 0', mfilename)
end
if delay < 0 
	error('%s: delay must be >= 0', mfilename);
end

stimdurBins = ms2bin(stimdur, Fs);
delayBins = ms2bin(delay, Fs);

if (delayBins + clickdur) > stimdurBins
	error('%s: delayBins + clickdur must be <= stimdurBins!', mfilename)
end

S = zeros(1, ms2bin(stimdur, Fs));
clickStim = ones(1, clickdur);

if delayBins
	S(delayBins:(delayBins+clickdur-1)) = clickStim;
else
	S(1:length(clickStim)) = clickStim;
end

S = scale * S;

