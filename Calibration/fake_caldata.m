function caldata  = fake_caldata(varargin)
%------------------------------------------------------------------------
% caldata  = fake_caldata(varargin)
%------------------------------------------------------------------------
%
% Creates a fake caldata structure with flat response
% 
%------------------------------------------------------------------------
% Input Arguments:
% 	<none>		use defaults
% 					20 to 20000 Hz in 100 Hz steps
% 					Fs = 44100;
% 					DAscale = 1;
% 					calshape = 'flat'
% 	
% 	'Fs', <value>			Sample rate (samples/sec)
% 	
% 	'calshape',	<name>	profile of calibration curve
% 					'flat'		flat profile
% 					'peak'		peak in middle of frequency range
% 					'notch'		notch in middle of frequency range		
% 					'rolloff'	rolls off as function of frequency
% 
% 	'freqs', <array>		List of frequencies for data
% 
%	'DAscale', <value>	scaling factor for output
%
% Output Arguments:
% 	caldata		caldata struct
%
%------------------------------------------------------------------------
% See Also: load_headphone_cal
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
% Sharad J. Shanbhag
% sshanbhag@neomed.edu
%--------------------------------------------------------------------------
% Created: 12 June, 2009
% 
% Revision History:
%	1 Oct 2012 (SJS):
%	 -	updated comments format
%	 - implemented varargin for user control of caldata parameters
%	8 Apr 2016 (SJS):
%	 - added features to generate testing caldata values
%--------------------------------------------------------------------------


%--------------------------------------------------------------------------
% some defaults
%--------------------------------------------------------------------------
minfreq = 20;
maxfreq = 20000;
freqstep = 100;
freqs = (minfreq:freqstep:maxfreq);
Fs =  44100;
DAscale = 1;
calshape = 'flat';

%--------------------------------------------------------------------------
% Parse Input Arguments
%--------------------------------------------------------------------------

% loop through # variable input args
nvararg = length(varargin);
if nvararg
	aindex = 1;
	while aindex < nvararg
		switch(upper(varargin{aindex}))
			
			% set Fs
			case 'Fs'
				if isnumeric(varargin{aindex+1})
					Fs = varargin{aindex+1};
					aindex = aindex + 2;
				else
					error('%s: bad Fs value', mfilename);
				end
				
			% set calshape (shape of calibration data)
			case 'CALSHAPE'
				calshape = varargin{aindex+1};
				aindex = aindex + 2;				

			% set freqs 
			case 'FREQS'
				if isnumeric(varargin{aindex+1})
					freqs = varargin{aindex+1};
					aindex = aindex + 2;
				else
					error('%s: bad freqs vector', mfilename);
				end
				
			% set DAscale
			case 'DASCALE'
				if isnumeric(varargin{aindex+1})
					DAscale = varargin{aindex+1};
					aindex = aindex + 2;
				else
					error('%s: bad DAscale (%s)', mfilename, varargin{aindex+1});
				end
				
			% trap unknown input command
			otherwise
				error('%s: unknown argument %s', mfilename, varargin{aindex});
		end		% end of SWITCH
	end		% end of WHILE
end		% end of IF

% determine length of freqs vector and build zero arrays
nfreqs = length(freqs);
onearray = ones(2, nfreqs);
zeroarray = zeros(2, nfreqs);

caldata.time_str = [date ' ' time];
caldata.timestamp = now;
caldata.adFc =  Fs;
caldata.daFc =  Fs;
caldata.nrasters = nfreqs;
caldata.range = [min(freqs) (freqs(2) - freqs(1)) max(freqs)];
caldata.reps = 2;
caldata.settings = [];
caldata.frdata = [];
caldata.atten = zeroarray;
caldata.max_spl = 50;
caldata.min_spl = 40;
caldata.frfile = [];
caldata.freq = freqs;
caldata.phase =  zeroarray;
caldata.dist =  zeroarray;
caldata.mag_stderr =  zeroarray;
caldata.phase_stderr =  zeroarray;
caldata.DAscale = DAscale;
caldata.dist_stderr =  zeroarray;
caldata.leakmag =  zeroarray;
caldata.leakmag_stderr =  zeroarray;
caldata.leakphase =  zeroarray;
caldata.leakphase_stderr =  zeroarray;
caldata.leakdist =  zeroarray;
caldata.leakdist_stderr =  zeroarray;
caldata.leakdistphis =  zeroarray;
caldata.leakdistphis_stderr =  zeroarray;
caldata.magsraw = [];
caldata.magsdbug = [];
caldata.phisdbug = [];
caldata.maginv = onearray;
caldata.phase_us = caldata.phase;
% preconvert phases from angle (RADIANS) to microsecond
caldata.phase_us(1, :) = (1.0e6 * unwrap(caldata.phase(1, :))) ...
										./ (2 * pi * caldata.freq);
caldata.phase_us(2, :) = (1.0e6 * unwrap(caldata.phase(2, :))) ...
										./ (2 * pi * caldata.freq);
caldata.mindbspl = [80 80];
caldata.maxdbspl = [100 100];

switch upper(calshape)
	
	case 'FLAT'
		% flat
		caldata.mag =  onearray;
		
	case 'PEAK'
		% modulate mags by a gaussian peak
		if mod(length(freqs), 2)
			nfreqs = length(freqs) + 1;
		else
			nfreqs = length(freqs);
		end
		xmin = -1;
		xmax = 1;
		x = xmin:( (xmax-xmin)/nfreqs):xmax;
		y = 0.9 * exp(-(x.^2)*10);
		caldata.mag(1, :) = onearray(1, :) + y(1:length(freqs));
		caldata.mag(2, :) = caldata.mag(1, :);
		
	case 'NOTCH'
		% modulate mags by gaussian notch
		if mod(length(freqs), 2)
			nfreqs = length(freqs) + 1;
		else
			nfreqs = length(freqs);
		end
		xmin = -1;
		xmax = 1;
		x = xmin:( (xmax-xmin)/nfreqs):xmax;
		y = -0.9 * exp(-(x.^2)*10);
		caldata.mag(1, :) = onearray(1, :) + y(1:length(freqs));
		caldata.mag(2, :) = caldata.mag(1, :);
		
	case 'ROLLOFF'
		if mod(length(freqs), 2)
			nfreqs = length(freqs) + 1;
		else
			nfreqs = length(freqs);
		end
		xmin = -1;
		xmax = 1;
		x = xmin:( (xmax-xmin)/nfreqs):xmax;
		y = -0.9 * (0.5 * (1 + erf(x*3)));
		caldata.mag(1, :) = onearray(1, :) + y(1:length(freqs));
		caldata.mag(2, :) = caldata.mag(1, :);		
		
	otherwise
		fprintf('%s: unknown fake cal profile %s\n', mfilename, calshape);
		fprintf('\tUsing FLAT profile (default)\n');
		caldata.mag =  onearray;
end

% mags need to be in dB SPL
caldata.mag = dbspl(caldata.mag);

% get the overall min and max dB SPL levels
caldata.mindbspl = min(caldata.mag'); %#ok<*UDIM>
caldata.maxdbspl = max(caldata.mag');

% subtract SPL mags (at each freq) from the min dB recorded for each
% channel and convert back to Pa (rms)
caldata.maginv(1, :) = invdb(caldata.mindbspl(1) - caldata.mag(1, :));
caldata.maginv(2, :) = invdb(caldata.mindbspl(2) - caldata.mag(2, :));




