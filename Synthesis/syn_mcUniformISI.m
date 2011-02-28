function ISI = syn_mcUniformISI(Nchan, Nisi, MinISI, MaxISI, Seed)
%------------------------------------------------------------------------
% ISI = syn_mcUniformISI(Nchan, Nisi, MinISI, MaxISI, Seed)
%------------------------------------------------------------------------
% 
% Generates ISI values with uniformly-distributed interstimulus intervals 
% within range of MinISI, MaxISI.
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
% 
% Output Arguments:
% 	ISI	[Nchan X Nisi) output array of ISI times
%
%------------------------------------------------------------------------
% See also: multichanGaussNoise
%------------------------------------------------------------------------

%------------------------------------------------------------------------
%  Sharad J. Shanbhag
%	sharad.shanbhag@einstein.yu.edu
%------------------------------------------------------------------------
% Created: 19 Feb, 2010 (SJS)
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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% trap the trivial case of MinISI == MaxISI
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if MinISI == MaxISI
	ISI = MinISI * ones(Nchan, Nisi);
	return
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
ISI = ceil((MaxISI - MinISI).*rand(Nchan, Nisi))+MinISI;

