function ISIcell = limitISIDuration(ISIarr, Maxpts)
%------------------------------------------------------------------------
% ISInew = limitISIDuration(ISIarr, Maxpts)
%------------------------------------------------------------------------
% Audio Toolbox -> Synthesis
%------------------------------------------------------------------------
% 
% given an ISI (inter stimulus interval) array os size [Nchan, Nisi], 
% return only the ISIs that fall within a total stimulus 
% duration of Maxpts.
% 
% ISIcell is a cell vector of length Nchan.  A cell return type must
% used because the individual ISI channels will generally not have the 
% same total duration and hence have different lengths
% 
%------------------------------------------------------------------------
% Input Arguments:
% 	ISIarr		[Nchan X Nisi] matrix of ISI values
% 						ISI values should be in # of samples (instead of time)
% 	Maxpts		max # of points 
% 
% Output Arguments:
% 	ISIcell	[Nchan X variable] output cell of ISI times
%
%------------------------------------------------------------------------
% See also: syn_mcUniformISI, syn_mcGaussISI
%------------------------------------------------------------------------

%------------------------------------------------------------------------
% Sharad J. Shanbhag
% sshanbhag@neoucom.edu
%------------------------------------------------------------------------
% Created: 19 Feb, 2010 (SJS)
%
% Revisions:
%	28 Feb 2011 (SJS):	updated comments
%------------------------------------------------------------------------

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Check input arguments
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if ~nargin
	error([mfilename ': bad input args']);
end

if nargin < 2
	error([mfilename ': need ISIarr and Maxpts values']);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% find the absolute ISIs times that are 
% within the range 1:Npts
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[Nchan, M] = size(ISIarr);

% storage var for actual valid isis (vs. isisum)
ISIcell = cell(1, Nchan);

% build stimulus array S
for n = 1:Nchan
	% compute absolute ISI times
	isisum = cumsum(ISIarr(n, :));
	
	% find the absolute ISIs times that are within the range 1:Npts 
	validisis = find(isisum < Maxpts);
	ISIcell{n} = ISIarr(n, validisis);
end

