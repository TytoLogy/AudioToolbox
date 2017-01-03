function smoothed = smooth_calibration_data(smoothmethod, caldata, varargin)
%------------------------------------------------------------------------
% smoothed = smooth_calibration_data()
%------------------------------------------------------------------------
% 
% 
% 
%------------------------------------------------------------------------
% Input Arguments:
% 	
% 
% 	Options:
% 
% Output Arguments:
%
%------------------------------------------------------------------------
% See also: compensate_signal
%------------------------------------------------------------------------

%------------------------------------------------------------------------
% Sharad J. Shanbhag
% sshanbhag@neomed.edu
%------------------------------------------------------------------------
% Created: 22 August, 2014 (SJS)
%
% Revisions:
%------------------------------------------------------------------------
% TO DO:
%------------------------------------------------------------------------

%------------------------------------------------------------------------
%------------------------------------------------------------------------
% define some constants
%------------------------------------------------------------------------
%------------------------------------------------------------------------

switch(smoothmethod)
	case 1
		% moving window average
		[nrows, ncols] = size(caldata.mag);
		smoothed = zeros(nrows, ncols);
		% smooth each row of mags using moving_average() function
		% (internal to FlatWav)
		for n = 1:nrows
			smoothed(n, :) = moving_average(	caldata.mag(n, :), ...
														varargin{1});
		end
	case 2
		% savitzky-golay filter
		[nrows, ncols] = size(caldata.mag);
		smoothed = zeros(nrows, ncols);
		for n = 1:nrows
			smoothed(n, :) = sgolayfilt(	caldata.mag(n, :), ...
													varargin{1}, ...
													varargin{2}	);
		end			

	otherwise
		% undefined method...
		error('%s: unknown smooth method %d', mfilename, smoothmethod);
end