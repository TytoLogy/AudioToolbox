function S = synSpeakerID(speakerazel, Fs, scale, caldata)
%-------------------------------------------------------------------------
%S = synSpeakerID(speakerazel, Fs, scale, caldata)
%-------------------------------------------------------------------------
% Synthesis Toolbox
%-------------------------------------------------------------------------
% 
% given speaker location [az el], returns an output signal (sample rate of
% 48000 samples/sec) of synthesized speech that says the location of the
% the speaker.
% 
%-------------------------------------------------------------------------
% Input Arguments:
%	speakerazel		[azimuth elevation] of speaker
%	Fs					output sampling rate - not used
%	scale				rms scaling factor
%	caldata			caldata structure (caldata.mag, caldata.freq, caldata.phase)
%							if no calibration is desired, replace caldata with value 0
%
% Output arguments:
%	S				[1XN] 
%-------------------------------------------------------------------------
% See Also: synmonosine, synmononoise_fft
%-------------------------------------------------------------------------


%--------------------------------------------------------------------------
% Sharad J. Shanbhag
% sharad.shanbhag@einstein.yu.edu
%--------------------------------------------------------------------------
% Created: 15 March, 2010 (SJS) from synmononoise
% Revision History:
%--------------------------------------------------------------------------

% do some basic checks on the input arguments
if nargin ~= 4
	help synSpeakerID;
	error('%s: incorrect number of input arguments', mfilename);
end

CAL = 0;
if isstruct(caldata)
	CAL = 1;
end

speakerazel

az = speakerazel(1);
el = speakerazel(2);

% check if center speaker
if (az == 0) && (el == 0)
	S = scale*normalize_rms(wavread('center.wav'))';
	return
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% build the azimuth sound signal
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% determine if positive or negative
if az > 0
	az_sign = wavread('positive.wav')';
elseif az < 0	
	az_sign = wavread('negative.wav')';
else
	az_sign = [];
end

% get the azimuth
switch(abs(az))
	case 0
		az_val = wavread('zero.wav')';
	case 10
		az_val = wavread('ten.wav')';
	case 20
		az_val = wavread('twenty.wav')';
	case 30
		az_val = wavread('thirty.wav')';
	case 40
		az_val = wavread('forty.wav')';
	case 50
		az_val = wavread('fifty.wav')';
	case 60
		az_val = wavread('sixty.wav')';
	case 70
		az_val = wavread('seventy.wav')';
	case 80
		az_val = wavread('eighty.wav')';
	case 90
		az_val = wavread('ninety.wav')';
	case 100
		az_val = wavread('onehundred.wav')';
	case 110
		az_val = wavread('onehundredten.wav')';
	otherwise	
		az_val = zeros(1, 1000);
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% build the elevation sound signal
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% determine if positive or negative
if el > 0
	el_sign = wavread('positive.wav')';
elseif el < 0	
	el_sign = wavread('negative.wav')';
else
	el_sign = [];
end

% get the elevation sound
switch(abs(el))
	case 0
		el_val = wavread('zero.wav')';
	case 10
		el_val = wavread('ten.wav')';
	case 20
		el_val = wavread('twenty.wav')';
	case 30
		el_val = wavread('thirty.wav')';
	case 40
		el_val = wavread('forty.wav')';
	case 50
		el_val = wavread('fifty.wav')';
	case 60
		el_val = wavread('sixty.wav')';
	case 70
		el_val = wavread('seventy.wav')';
	case 80
		el_val = wavread('eighty.wav')';
	case 90
		el_val = wavread('ninety.wav')';
	case 100
		el_val = wavread('onehundred.wav')';
	case 110
		el_val = wavread('onehundredten.wav')';
	otherwise	
		el_val = zeros(1, 1000);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% build the stimulus
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
S = scale*normalize_rms([az_sign az_val zeros(1, 10000) el_sign el_val]);

