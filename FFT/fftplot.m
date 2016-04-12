function varargout = fftplot(s, Fs, varargin)
%--------------------------------------------------------------------------
% [S, Smag, Sphase, Freq] = fftplot(s, Fs, varargin)
%--------------------------------------------------------------------------
%	Audio Toolbox: FFT
%-------------------------------------------------------------------------
%
%  plots the signal, FFT magnitude, and FFT phase
%
%-------------------------------------------------------------------------
%	Inputs:
%		s		signal vector
%		Fs		sampling rate
%		Optional:
%			<figure number> 
%					will generate new figure if not specified
% 			'RMS'			scale FFT magnitude data in RMS
% 			'LOGFREQ'	plot frequencies in log scale
% 			'dB'			plot FFT magnitude data logarithmically
%			'DEG'			plot phases as degrees (instead of radians)
%
%	Outputs:
%		S		  full FFT
%		Smag	  FFT magnitude
%		Sphase  FFT phase (in unwrapped radians)
%		Freq	  Freq vector (used for plot)
%-------------------------------------------------------------------------
%	See Also: fftdbplot
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
%  Sharad Shanbhag
%	sshanbhag@neomed.edu
%-------------------------------------------------------------------------
% Created: ?????
%
% Revisions:
% 	2 Jan 2009, SJS:
% 		- revised scaling of Smag
% 		- cleaned up some messy code
% 		- cleaned up comments
%	7 Sep 2012 (SJS):
%	 -	changed email address
% 	 -	fixed FFT length issue in freq and spectra
% 			length should be (NFFT/2) + 1, not NFFT/2
%	12 Apr 2016, SJS:
%	 Cleaning up, tidying, modifying
% 	 - reworked output arg assignment
% 	 - added 'RMS' option for output scaling
% 	 - added 'dB' option for output
% 	 - added 'logfreq' option for frequency scale
%	 - added 'deg' option for phase scale
%--------------------------------------------------------------------------

%------------------------------------------------------------------------
% Check Inputs
%------------------------------------------------------------------------
if nargin < 2
	error('%s: must specify Fs (sampling rate)!', mfilename);
end
if min(size(s)) > 1
	error('%s: s must be a vector, not an array', mfilename)
end

% define some switches
RMS_SCALE = 0;
DB = 0;
LOGFREQ = 0;
DEG = 0;

% loop through # variable input args
nvararg = length(varargin);
if nvararg
	% arg 1 this is figure handle
	f = varargin{1};
	figure(f);
	
	aindex = 2;
	while aindex <= nvararg
		switch(upper(varargin{aindex}))
			% set RMS scaling factor for magnitude plot
			case 'RMS'
				RMS_SCALE = 1;
				aindex = aindex + 1;
			% set DB scale for y axis (magnitude plot)
			case 'DB'
				DB = 1;
				aindex = aindex + 1;
			% set log scale for x frequency axis (mag, phase plots)
			case 'LOGFREQ'
				LOGFREQ = 1;
				aindex = aindex + 1;
			% set DEGree scale for phase y axies
			case 'DEG'
				DEG = 1;
				aindex = aindex + 1;
			% trap unknown input command
			otherwise
				error('%s: unknown argument %s', mfilename, varargin{aindex});
		end		% end of SWITCH
	end		% end of WHILE
else
	f = figure; %#ok<NASGU>
end

% get input variable name for plot title
varname = inputname(1);

%------------------------------------------------------------------------
% now compute the FFT with NFFT points
%------------------------------------------------------------------------
% length of signal
N = length(s);

% go to next power of 2 for speed's sake
NFFT = 2.^(nextpow2(N));
% run the FFT
S = fft(s, NFFT);

%non-redundant points are kept
% 7 sep 2012 (SJS): changed from nfft/2 into (nfft/2) + 1
Nunique = (NFFT/2) + 1;
Sunique = S(1:Nunique);

% get the magnitudes of the FFT, divide by N (length of input signal) &
% scale by 2 because we're taking only half of the points from the "full"
% FFT vector S;
Smag = abs(Sunique)/N;
if RMS_SCALE
	% convert mags to RMS by multiplying each magnitude by sqrt(2)/2
	% (factor of 2 in numerator cancels 2 in denominator)
	Smag(2:end) = sqrt(2) * Smag(2:end);
else
	Smag(2:end) = 2*Smag(2:end);
end	
% compute phase angle (radians)
Sphase = angle(Sunique);
Sphase = unwrap(Sphase);

%------------------------------------------------------------------------
% Plot!
%------------------------------------------------------------------------
% This is an evenly spaced frequency vector with Nunique points.
% scaled by the Nyquist frequency (Fn ==1/2 sample freq.)
Freq = (Fs/2)*linspace(0, 1, Nunique);
% generate time vector
time = ((1:N) - 1) / Fs;

% Signal
subplot(3, 1, 1), plot(time, s);
ylabel('Input Signal'); xlabel('time(s)')
title(varname);

% MAG
subplot(3, 1, 2)
if DB
	y = db(Smag);
else
	y = Smag;
end
if LOGFREQ
	semilogx(Freq, y);
else
	plot(Freq, y)
end
if DB
	if RMS_SCALE
		ylabel('FFT Magnitude (dB RMS)');
	else
		ylabel('FFT Magnitude (dB)');
	end
else
	if RMS_SCALE
		ylabel('FFT Magnitude (RMS)');
	else
		ylabel('FFT Magnitude');
	end
end

% PHASE
subplot(3, 1, 3)
if LOGFREQ
	if DEG
		semilogx(Freq, rad2deg(Sphase));
		ylabel('FFT Phase (deg)'); 
	else
		semilogx(Freq, Sphase);
		ylabel('FFT Phase'); 
	end
	xlabel('log(Frequency) Hz')
else
	if DEG
		plot(Freq, rad2deg(Sphase));
		ylabel('FFT Phase (deg)'); 
	else
		plot(Freq, Sphase);
		ylabel('FFT Phase'); 
	end
	xlabel('Frequency')
end


%% assign outputs
outargs = {'S', 'Smag', 'Sphase', 'Freq'};
if nargout
	varargout = cell(nargout);
	for n = 1:4
		if nargout >= n
			varargout{n} = eval(outargs{n});
		end
	end
else
	return
end
