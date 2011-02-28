function [S, ISI] = syn_mcGaussISIClick(Nchan, Npts, Offpts, Mu, Sigma, Seed, ClickType)
%------------------------------------------------------------------------
% [S, ISI] = syn_mcGaussISIClick(Nchan, Npts, Offpts, Mu, Sigma, Seed, ClickType)
%------------------------------------------------------------------------
% 
% Generates clicks with Gaussian-distributed interstimulus intervals 
% with mean Mu and standard deviation Sigma.  clicks are either positive, negative,
% positive-leading biphasic, or negative-leading biphasic. Take your pick.
% Positive is default.
% 
%------------------------------------------------------------------------
% Input Arguments:
% 	Nchan				# of channels (i.e., speakers) used to play sounds
% 	Npts				# of points to generate 
%							(usually determined by SampRate * stimulus duration)
%	Offpts			# of points to hold signal at 0 after a click.
% 							(default = 10)
% 	Mu					mean # of samples between points (default = 500)
% 	Sigma				std. deviation of signal (default = Mu / 2)
% 	Seed				seed value for randn (default = random value)
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
% See also: syn_mcGaussNoise
%------------------------------------------------------------------------

%------------------------------------------------------------------------
%  Sharad J. Shanbhag
%	sharad.shanbhag@einstein.yu.edu
%------------------------------------------------------------------------
% Created: 23 January, 2010 (SJS)
%
% Revisions:
%	29 January, 2010 (SJS):
% 		-	changed ISI to cell array so that actual ISI values are returned
% 			instead of cumulative ISI
%	19 Feb, 2010 (SJS):	fixed filename/function name mismatch
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
	
	% off points
	if ~exist('Offpts', 'var')
		Offpts = 10;
	elseif isempty(Offpts)
		Offpts = 10;
	elseif Offpts < 1
		error([mfilename ': Offpts must be greater than or equal to 1'])
	end

	% mean ISI
	if ~exist('Mu', 'var')
		Mu = 500;
	elseif isempty(Mu)
		Mu = 500;
	elseif Mu < 0
		error([mfilename ': Mu must be greater than or equal to 0'])
	end
	if Mu <= Offpts
		warning([mfilename ': Offpts is greater than mean ISI (Mu)!'])
	end
	
	% ISI std dev
	if ~exist('Sigma', 'var')
		Sigma = Mu / 2;
	elseif isempty(Sigma)
		Sigma = Mu / 2;
	elseif Sigma <= 0
		error([mfilename ': Sigma must be greater than 0'])
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
			click = [1 zeros(1, Offpts)];
		case 'neg'
			click = [-1 zeros(1, Offpts)];
		case 'posbi'
			click = [1 -1 zeros(1, Offpts)];
		case 'negbi'
			click = [-1 1 zeros(1, Offpts)];
		otherwise
			error([mfilename ': unknown ClickType ' ClickType])
	end

	
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% seed the random number generator
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if exist('Seed', 'var')
	if ~isempty(Seed)
		randn('state', Seed);
	else
		randn('state', sum(100*clock));
	end
else
	randn('state', sum(100*clock));
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% allocate S array
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
S = zeros(Nchan, Npts);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% generate ISI values
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% assume we don't neet as many ISI values as there are in the 
% signal (which can be long).  dividing by 2 SHOULD be very generous.
Nisipts = ceil(Npts/2);
isiarr = round(abs(normrnd(Mu, Sigma, Nchan, Nisipts)));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% first make sure ISI values are above the Offset points
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for n = 1:Nchan
	shortisis = find(isiarr(n, :) <= Offpts);
	% set invalid ISI values to zero
	isiarr(n, shortisis) = 0*shortisis;
	if isiarr(n, 1) == 0
		isiarr(n, 1) = 1;
	end
end

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


