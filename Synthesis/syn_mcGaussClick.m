function S = syn_mcGaussClick(Nchan, Npts, Offpts, Mu, Sigma, Seed)
%------------------------------------------------------------------------
% S = syn_mcGaussClick(Nchan, Npts, OffDelay, Mu, Sigma, Seed))
%------------------------------------------------------------------------
% 
% Generates gaussian-noise distributed clicks.  clicks are biphasic 
% 
%------------------------------------------------------------------------
% Input Arguments:
% 	Nchan				# of channels (i.e., speakers) used to play sounds
% 	Npts				# of points to generate 
%							(usually determined by SampRate * stimulus duration)
%	Offpts			# of points to hold signal at 0 after a click. 
% 	Mu					mean value of signal (default = 0)
% 	Sigma				std. deviation of signal (default = 1)
% 							default of 1 corresponds to approximately rms = 1
% 	Seed				seed value for randn (default = random)
% 
% Output Arguments:
% 	S	[Nchan X npoints] output array
%
%------------------------------------------------------------------------
% See also: 
%------------------------------------------------------------------------

%------------------------------------------------------------------------
%  Sharad J. Shanbhag
%	sharad.shanbhag@einstein.yu.edu
%------------------------------------------------------------------------
% Created: 21 January, 2010 (SJS)
%
% Revisions:
%	19 Feb, 2010 (SJS): fixed filename vs function name mismatch
%------------------------------------------------------------------------
% TO DO:
%------------------------------------------------------------------------

if ~nargin
	error([mfilename ': bad input args']);
elseif nargin < 2
	error([mfilename ': need Nchan and Npts to generate noise']);
else
	if ~exist('Offpts', 'var')
		Offpts = 1;
	elseif isempty(Offpts)
		Offpts = 1;
	end
	if ~exist('Mu', 'var')
		Mu = 0;
	elseif isempty(Mu)
		Mu = 0;
	end
	if ~exist('Sigma', 'var')
		Sigma = 1;
	elseif isempty(Sigma)
		Sigma = 1;
	end
	if ~exist('Seed', 'var')
		Seed = floor(100*rand);
	end
end

% seed the random number generator
randn('state', Seed);

% generate random number array
noisearr = normrnd(Mu, Sigma, Nchan, Npts);

noisearr = spikeschmitt(

