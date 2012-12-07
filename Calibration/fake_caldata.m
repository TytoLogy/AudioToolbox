function caldata  = fake_caldata(varargin)
%------------------------------------------------------------------------
% caldata  = fake_caldata(varargin)
%------------------------------------------------------------------------
%
% Creates a fake caldata structure with flat response
% 
%------------------------------------------------------------------------
% Input Arguments:
% 
% Output Arguments:
% 	caldata		caldata struct
%
%------------------------------------------------------------------------
%
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
%--------------------------------------------------------------------------


% some defaults
MINFREQ = 20;
MAXFREQ = 20000;
FREQSTEP = 100;
freqs = (MINFREQ:FREQSTEP:MAXFREQ);
FS =  4.8828e+004;
DASCALE = 5;

% loop through # variable input args
nvararg = length(varargin);
if nvararg
	aindex = 1;
	while aindex < nvararg
		switch(upper(varargin{aindex}))
			
			% set freqs 
			case 'FREQS'
				if isnumeric(varargin{aindex+1})
					freqs = varargin{aindex+1};
					aindex = aindex + 2;
				else
					error('%s: bad freqs vector', mfilename);
				end
				
			% set DASCALE
			case 'DASCALE'
				if isnumeric(varargin{aindex+1})
					DASCALE = varargin{aindex+1};
					aindex = aindex + 2;
				else
					error('%s: bad DASCALE (%s)', mfilename, varargin{aindex+1});
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
caldata.adFc =  FS;
caldata.daFc =  FS;
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
caldata.mag =  onearray;
caldata.phase =  zeroarray;
caldata.dist =  zeroarray;
caldata.mag_stderr =  zeroarray;
caldata.phase_stderr =  zeroarray;
caldata.DAscale = DASCALE;
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
caldata.phase_us(1, :) = (1.0e6 * unwrap(caldata.phase(1, :))) ./ (2 * pi * caldata.freq);
caldata.phase_us(2, :) = (1.0e6 * unwrap(caldata.phase(2, :))) ./ (2 * pi * caldata.freq);

caldata.mindbspl = [80 80];
caldata.maxdbspl = [100 100];

