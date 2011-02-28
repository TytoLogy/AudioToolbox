function [S, ISI] = syn_mcUniformISINoisePulse(Nchan, Durms, Fs, MinISIms, MaxISIms, NoiseParam, Seed)
%------------------------------------------------------------------------
% [S, ISI] = syn_mcUniformISINoisePulse(Nchan, Durms, Fs, MinISIms, MaxISIms, NoiseParam, Seed)
%------------------------------------------------------------------------
% 
% Generates clicks with uniformly-distributed interstimulus intervals 
% within range of MinISI, MaxISI.  clicks are either positive, negative,
% positive-leading biphasic, or negative-leading biphasic. Take your pick.
% Positive is default.
% 
%------------------------------------------------------------------------
% Input Arguments:
% 	Nchan				# of channels (i.e., speakers) used to play sounds
% 	Durms			Total stimulus duration (milliseconds)
% 	Fs					output sample rate (samples/second)
% 	MinISIms			time between points (default = 500)
% 	MaxISIms			max # of samples between points (default = 500)
%	NoiseParam		noise parameters struct:
% 							NoiseParam.duration = duration of noise (milliseconds)
% 							NoiseParam.low = low frequency limit
% 							NoiseParam.high = high frequency limit
% 							NoiseParam.rampms = ramp time for turning sound
% 														on and off in milliseconds, 
% 														must be less than duration/2
% 							NoiseParam.scale = rms scale factor, 1XNchan length
% 													 vector of scaling factors for 
% 													 setting each channels dB output
% 													 levels. if empty, scale of 1 will
% 													 be used
% 							NoiseParam.caldata = calibration data
% 														1XNchan cell array containing 
% 														frequency and phase calibration 
% 														data.  if empty, sound will be
% 														uncalibrated.
% 	Seed				seed value for rand (default = sum(100*clock))
% 							allows specification of seed value if random sequence
% 							needs to be regenerated
% 
% Output Arguments:
% 	S	[Nchan X npoints] output array
% 	ISI	[Nchan X variable) output array of ISI times
%
%------------------------------------------------------------------------
% See also: syn_mcGaussNoise
%------------------------------------------------------------------------

%------------------------------------------------------------------------
%  Sharad J. Shanbhag
%	sharad.shanbhag@einstein.yu.edu
%------------------------------------------------------------------------
% Created: 25 January, 2010 (SJS)
%
% Revisions:
%	29 January, 2010 (SJS): completed
%------------------------------------------------------------------------
% To Do:
%------------------------------------------------------------------------

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Check input arguments
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if ~nargin
	error([mfilename ': bad input args']);
	
elseif nargin < 2
	error([mfilename ': need Nchan and Npts to generate noise']);

% check values of inputs, set default values
else

	% # of channels (Nchan)
	if isempty(Nchan) | Nchan < 1
		error([mfilename ': Nchan must be >= 1']);
	end

	% # of points (Npts)
	if isempty(Durms) | Durms < 1
		error([mfilename ': Durms must be > 1']);
	end
	
	% min ISI
	if ~exist('MinISIms', 'var')
		MinISIms = 10;
	elseif isempty(MinISIms)
		MinISIms = 10;
	elseif MinISIms < 1
		error([mfilename ': MinISIms must be greater than or equal to 1'])
	end

	% max ISI
	if ~exist('MaxISIms', 'var')
		MaxISIms = 500;
	elseif isempty(MaxISIms)
		MaxISIms = 500;
	elseif MaxISIms < 0
		error([mfilename ': MaxISIms must be greater than or equal to 0'])
	end
	if MaxISIms <= MinISIms
		error([mfilename ': MaxISIms must be greater than MinISIms'])
	end
	
end

% Need to convert times in milliseconds to samples, since most 
% of the further calculations are done in samples, not millisec.
Npts = ms2samples(Durms, Fs);
MinISI = ms2samples(MinISIms, Fs);
MaxISI = ms2samples(MaxISIms, Fs);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Check the stimulus parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	% get number of samples for each stim pulse
	NoiseParam.stimlen = ms2samples(NoiseParam.duration, Fs);
	
	if MinISI < ceil(NoiseParam.stimlen/2)
		error('%s: MinISI is too short (or NoiseParam.duration is too long...)', mfilename);
	end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% seed the random number generator
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if exist('Seed', 'var')
	if ~isempty(Seed)
		rand('state', Seed);
	else
		rand('state', sum(100*clock));
	end
else
	rand('state', sum(100*clock));
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% allocate S array
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
S = zeros(Nchan, Npts);
stimoccur = S;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% generate potential ISI values
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% assume we don't neet as many ISI values as there are in the 
% signal (which can be long).  dividing by 2 SHOULD be very generous.
Nisipts = Npts/2;

% generate uniform random ISI values in range a:b using 
% algorithm (b-a)*rand(N) + a
isiarr = ceil((MaxISI - MinISI).*rand(Nchan, Npts))+MinISI;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Then, find the absolute ISIs times that are 
% within the range NoiseParam.stimlen/2:Npts - NoiseParam.stimlen/2
% NOTE:
% 	Don't need explicit check to make sure 1st ISI is within the 
% 	NoiseParam.stimlen/2 boundary, because the MinISI *should* have
% 	taken care of this already.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% storage var for actual valid isis (vs. isisum)
isi = cell(1, Nchan);
isisum = isi;

maxpts = Npts - ceil(NoiseParam.stimlen / 2);

% build stimulus array S
for n = 1:Nchan
	% compute absolute ISI times
	isicumsum = cumsum(isiarr(n, :));
	
	% find the absolute ISIs times that are less than Npts - NoiseParam.stimlen/2 
	% (length of noise stimulus length
	validisis = find(isicumsum < maxpts );
	isi{n} = isiarr(n, validisis);
	isisum{n} = isicumsum(validisis);
	
	% assign 1s to the valid ISI bins in stimoccur
	stimoccur(n, isisum{n}(validisis)) = 1 + 0*validisis;
	
end

% initialize ISI vector
if nargout == 2
	ISI = isi;
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Generate noise pulses for all channels
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

halfstimlen = round(NoiseParam.stimlen / 2);

for c = 1:Nchan
	% # of stims for this channel is length of isi vector stored in 
	% isi{c} (isi cell array)
	nstims = length(isisum{c});
	stims = cell(1, nstims);
	
	% get the locations for the stimuli
	stimstartlocs = isisum{c} - halfstimlen;
	
	for n = 1:nstims
		stims{n} = synmononoise_fft(NoiseParam.duration, Fs, ...
										NoiseParam.low, NoiseParam.high, ...
										NoiseParam.scale(c), NoiseParam.caldata{c});

		% ramp the stimulus on and off for smoothness' sake...
		stims{n} = sin2array(stims{n}, NoiseParam.rampms, Fs);
				
		S(c, stimstartlocs(n):stimstartlocs(n)+length(stims{n})-1) = stims{n};
	end

end
	


