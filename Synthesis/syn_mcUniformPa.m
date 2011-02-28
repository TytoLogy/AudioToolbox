function PA = syn_mcUniformPa(Nchan, Nlevels, MinPa, MaxPa, Seed)
%------------------------------------------------------------------------
%  PA = syn_mcUniformPa(Nchan, Nlevels, MinPa, MaxPa, Seed)
%------------------------------------------------------------------------
% Synthesis Toolbox
%------------------------------------------------------------------------
% Generates stimulus Pa (Pascal) values with uniform distribution
% within range of [MinPa, MaxPa]
%------------------------------------------------------------------------
% Input Arguments:
% 	Nchan				# of channels (i.e., speakers) used to play sounds
% 	Nlevels			# of Pa values to generate per channel
% 	MinPa				min level of sounds (in Pascal)
% 	MaxPa				max level of sounds (in Pascal)
% 	Seed				seed value for rand (default = sum(100*clock))
% 							allows specification of seed value if random sequence
% 							needs to be regenerated
% 
% Output Arguments:
% 	PA					[Nchan X Nlevels) output array of stimulus amplitudes
%------------------------------------------------------------------------
% See also: syn_mcUniformISI
%------------------------------------------------------------------------

%------------------------------------------------------------------------
%  Sharad J. Shanbhag
%	sharad.shanbhag@einstein.yu.edu
%------------------------------------------------------------------------
% Created: 19 Feb, 2010 (SJS)
%
% Revisions:
% 	20 Feb 2010 (SJS): added trap for minPa == maxPA, fixed up help
%------------------------------------------------------------------------

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Check input arguments
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if ~nargin
	error([mfilename ': bad input args']);
	
elseif nargin < 2
	error([mfilename ': need Nchan and Nlevels to generate noise']);

% check values of inputs, set default values
else

	% # of channels (Nchan)
	if isempty(Nchan) | Nchan < 1
		error([mfilename ': Nchan must be >= 1']);
	end

	% # of points (Npts)
	if isempty(Nlevels) | Nlevels < 1
		error([mfilename ': Nlevels must be > 1']);
	end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% trap the trivial case of MinPa == MaxPa
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if MinPa == MaxPa
	PA = MinPa * ones(Nchan, Nlevels);
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
PA = (MaxPa - MinPa).*rand(Nchan, Nlevels)+MinPa;

