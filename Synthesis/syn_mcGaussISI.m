function ISI = syn_mcGaussISI(Nchan, Nisi, Offpts, Mu, Sigma, Seed)
%------------------------------------------------------------------------
% ISI = syn_mcGaussISI(Nchan, Nisi, Offpts, Mu, Sigma, Seed)
%------------------------------------------------------------------------
% 
% Generates clicks with Gaussian-distributed interstimulus intervals 
% with mean Mu and standard deviation Sigma.
% 
%------------------------------------------------------------------------
% Input Arguments:
% 	Nchan				# of channels (i.e., speakers) used to play sounds
% 	Nisi				# of isi values to generate per channel
%	Offpts			# of points to hold signal at 0 after a click.
% 							(default = 10)
% 	Mu					mean # of samples between points (default = 500)
% 	Sigma				std. deviation of signal (default = Mu / 2)
% 	Seed				seed value for randn (default = random value)
% 							allows specification of seed value if random sequence
% 							needs to be regenerated
% 
% Output Arguments:
% 	ISI	[Nchan X Nisi) output array of ISI times
%
%------------------------------------------------------------------------
% See also: syn_mcUniformISI
%------------------------------------------------------------------------

%------------------------------------------------------------------------
%  Sharad J. Shanbhag
%	sharad.shanbhag@einstein.yu.edu
%------------------------------------------------------------------------
% Created: 19 February, 2010 (SJS)
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
	if isempty(Nchan) || Nchan < 1
		error([mfilename ': Nchan must be >= 1']);
	end

	% # of points (Npts)
	if isempty(Nisi) || Nisi < 1
		error([mfilename ': Nisi must be > 1']);
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
% generate gaussian distributed random ISI values 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ISI = round(abs(normrnd(Mu, Sigma, Nchan, Nisi)));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% make sure ISI values are above the Offset points
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for n = 1:Nchan
	shortisis = find(ISI(n, :) <= Offpts);
	if length(shortisis)
		for m = 1:length(shortisis)
			loopFlag = 1;
			while loopFlag
				isitest = round(abs(normrnd(Mu, Sigma, 1, 1)));
				if isitest > Offpts
					loopFlag = 0;
				end
			end
			ISI(n, shortisis(m)) = isitest;
		end
	end
end
				
