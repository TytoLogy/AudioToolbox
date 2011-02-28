function [ISI, cISI] = syn_SoloUniformISI(Nchan, Nisi, MinISI, MaxISI, Seed, MaxDuration)
%------------------------------------------------------------------------
% [ISI, cISI] = syn_SoloUniformISI(Nchan, Nisi, MinISI, MaxISI, Seed, MaxDuration)
%------------------------------------------------------------------------
% 
% Generates non-overlapping ISI values with uniformly-distributed interstimulus intervals 
% within range of MinISI, MaxISI.  Each channel will be activated in
% a random sequence to guarantee no overlap of stimuli.  but, it is up to
% the user to not do anything stupid, like have the stimulus pulse duration
% be longer than MinISI...
% 
%------------------------------------------------------------------------
% Input Arguments:
% 	Nchan				# of channels (i.e., speakers) used to play sounds
% 	Nisi				# of ISI values to generate per channel
% 	MinISI			min # of samples between points (default = 500)
% 	MaxISI			max # of samples between points (default = 500)
% 	Seed				seed value for rand (default = sum(100*clock))
% 							allows specification of seed value if random sequence
% 							needs to be regenerated
%	MaxDuration		maximum cumulatave duration (samples)
% 
% Output Arguments:
% 	ISI	[Nchan X Nisi] output array of ISI times
%	cISI	[Nchan X Nisi]	cumulative sum of ISI times
%------------------------------------------------------------------------
% See also: syn_mcUniformISI
%------------------------------------------------------------------------

%------------------------------------------------------------------------
%  Sharad J. Shanbhag
%	sharad.shanbhag@einstein.yu.edu
%------------------------------------------------------------------------
% Created: 19 March, 2010 from syn_mcUniformISI_Limited.m (SJS)
%
% Revisions:
%------------------------------------------------------------------------

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Check input arguments
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if ~nargin
	error([mfilename ': bad input args']);
	
elseif nargin < 2
	error([mfilename ': need Nchan and Nisi to generate noise']);

% check values of inputs, set default values
else

	% # of channels (Nchan)
	if isempty(Nchan) | Nchan < 1
		error([mfilename ': Nchan must be >= 1']);
	end

	% # of points (Npts)
	if isempty(Nisi) | Nisi < 1
		error([mfilename ': Nisi must be > 1']);
	end
	
	% min ISI
	if ~exist('MinISI', 'var')
		MinISI = 100;
	elseif isempty(MinISI)
		MinISI = 100;
	elseif MinISI < 1
		error([mfilename ': MinISI must be greater than or equal to 1'])
	end

	% max ISI
	if ~exist('MaxISI', 'var')
		MaxISI = 500;
	elseif isempty(MaxISI)
		MaxISI = 500;
	elseif MaxISI < 0
		error([mfilename ': MaxISI must be greater than or equal to 0'])
	end
	if MaxISI < MinISI
		error([mfilename ': MaxISI must be >= MinISI'])
	end
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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% generate uniform random ISI values in range a:b using 
% algorithm (b-a)*rand(N) + a
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% check if a fixed ISI is being called for (MinISI == MaxISI)
if MinISI == MaxISI
	% if so, create temporary ISI and cumulutive ISI (tmpISIc)
	% arrays.  need to create temp arrays because the invalid ISIs 
	% (cumsum greater than MaxDuration) will be set to zero in a later step
	isiList = MinISI * ones(1, Nisi)
else
	% generate random ISIs within the range specified
	isiList = ceil((MaxISI - MinISI).*rand(1, Nchan*Nisi))+MinISI;
end

% create a temporary matrix to hold the ISIc values
tmpISIc = zeros(Nchan, Nisi);

% initialize the currentISI variable to zero
currentISI = 0;
% loop through  Nisi
for n = 1:Nisi
	% get a random list of speakers
	randSpeakers = randperm(Nchan);	
	% loop through the channels
	for c = 1:Nchan
		% increment the current ISI time by  
		currentISI = currentISI + isiList(n);
		% assign the currentISI to one of the channels at random
		tmpISIc(randSpeakers(c), n) = currentISI;
	end
end

% build a matrix of temporary ISI values - need to include the 
% first row of tmpISIc in order to match behavior of the other 
% syn****ISI.m functions.
tmpISI = [tmpISIc(:, 1) diff(tmpISIc, 1, 2)];

% find the cumultive ISIs that are greater than MaxDuration
[r, c] = find(tmpISIc <= MaxDuration);

% trap bad MaxDuration case
if ~(length(c) + length(r))
	error('%s: MaxDuration not good', mfilename)
end

% create the output arrays
ISI = zeros(Nchan, max(c));
cISI = ISI;

% find the ISIs that are good
validISIindex = find(tmpISIc <= MaxDuration);

% transfer the valid ISIs from the tmp array to the output array
ISI(validISIindex) = tmpISI(validISIindex);

% transfer valid cumulative ISIs to output array (n.b., these are the 
% absolute pulse times)
cISI(validISIindex) = tmpISIc(validISIindex);

