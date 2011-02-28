function [S, ISI] = syn_mcUniformISIClick(Nchan, Npts, MinISI, MaxISI, Seed, ClickType)
%------------------------------------------------------------------------
% [S, ISI] = syn_mcUniformISIClick(Nchan, Npts, MinISI, MaxISI, Seed, ClickType)
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
% 	Npts				# of points to generate 
%							(usually determined by SampRate * stimulus duration)
% 	MinISI			min # of samples between points (default = 500)
% 	MaxISI			max # of samples between points (default = 500)
% 	Seed				seed value for rand (default = sum(100*clock))
% 							allows specification of seed value if random sequence
% 							needs to be regenerated
%	ClickType		Type of click
% 							Options:
% 								'pos'		positive (upward) click (default)
% 								'neg'		negative (downward)
% 								'posbi'	positive-leading biphasic
% 								'negbi'	negative-leading biphasic
% 
% Output Arguments:
% 	S	[Nchan X npoints] output array
% 	ISI	[Nchan X variable) output array of ISI times
%
%------------------------------------------------------------------------
% See also: multichanGaussNoise
%------------------------------------------------------------------------

%------------------------------------------------------------------------
%  Sharad J. Shanbhag
%	sharad.shanbhag@einstein.yu.edu
%------------------------------------------------------------------------
% Created: 25 January, 2010 (SJS)
%
% Revisions:
%	29 January, 2010 (SJS): completed
%	19 Feb, 2010 (SJS): fixed filename vs function name mismatch
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
	if isempty(Npts) | Npts < 1
		error([mfilename ': Npts must be > 1']);
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
	if MaxISI <= MinISI
		error([mfilename ': MaxISI must be greater than MinISI'])
	end
	
	% clicktype
	if ~exist('ClickType', 'var')
		ClickType = 'pos';
	elseif isempty(ClickType)
		ClickType = 'pos';
	else
		ClickType = lower(ClickType);
	end
	switch ClickType
		case 'pos'
			click = [1 zeros(1, MinISI)];
		case 'neg'
			click = [-1 zeros(1, MinISI)];
		case 'posbi'
			click = [1 -1 zeros(1, MinISI)];
		case 'negbi'
			click = [-1 1 zeros(1, MinISI)];
		otherwise
			error([mfilename ': unknown ClickType ' ClickType])
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


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% allocate S array
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
S = zeros(Nchan, Npts);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% generate potential ISI values
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% assume we don't neet as many ISI values as there are in the 
% signal (which can be long).  dividing by 2 SHOULD be very generous.
Nisipts = Npts/2;

% generate uniform random ISI values in range a:b using 
% algorithm (b-a)*rand(N) + a
isiarr = ceil((MaxISI - MinISI).*rand(Nchan, Npts))+MinISI;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Then, find the absolute ISIs times that are 
% within the range 1:Npts
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% storage var for actual valid isis (vs. isisum)
isi = cell(1, Nchan);

% build stimulus array S
for n = 1:Nchan
	% compute absolute ISI times
	isisum = cumsum(isiarr(n, :));
	
	% find the absolute ISIs times that are within the range 1:Npts 
	validisis = find(isisum < Npts);
	isi{n} = isiarr(n, validisis);
	
	% create a temp vector, assign 1s to the valid ISI bins
	tmp1 = zeros(1, Npts);
	tmp1(isisum(validisis)) = 1 + 0*validisis;
	
	% convolve temp vector with click pattern
	tmp2 = conv(tmp1, click);
	
	% assign to output array
	S(n, :) = tmp2(1:Npts);
end

% initialize ISI vector
if nargout == 2
	ISI = isi;
end

