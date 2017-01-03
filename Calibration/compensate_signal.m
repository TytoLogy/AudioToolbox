function [sadj, Sfull, Magnorm, f] = ...
							compensate_signal(s, calfreq, calmag, ...
													Fs, corr_frange, varargin)
%------------------------------------------------------------------------
% [sadj, Sfull, Magnorm, f] = compensate_signal(s, calfreq, calmag, Fs, corr_frange)
%------------------------------------------------------------------------
% 
% Function that takes an input signal, s, sampled at Fs, and applies calibration 
% (magnitude only!) information in calfreq, calmag over range corr_frange.
% 
%------------------------------------------------------------------------
% Input Arguments:
% 	
% 	s					signal to be calibrated (NX1 or 1XN only!)
% 	calfreq			1XN vector of frequencies for calibration data
% 	calmag			1XN vector of calibration values at frequencies 
% 						given by calfreq
% 	Fs					sample rate, samples/second
% 	corr_frange		1X2 vector specifying range of frequencies (in Hz)
% 						to calibrate [fmin fmax] 
% 
% 	Options:
%
% 		Method		'atten' | 'boost' | 'compress'
% 		
% 		Normalize	'on' | 'off', <value>
% 		
% 		Lowcut		'off' | <value>
% 		
% 		Level			<value> greater than 0
%						**only applicable for COMPRESS method!
%
%		Prefilter	'on' | [minf maxf]
%						'on' will use corr_frange
%
%		Postfilter	'on' | [minf maxf]
%						'on' will use corr_frange
%
%		Rangelimit	'on'  (default) | 'off'
% 						limits range for finding peak or min for compensation
% 						to corr_frange window
%
%		Corrlimit	'on' | <value> | 'off' (default)
%
%		SmoothEdges	'on' | <[freq_pct window_size]> | 'off' (default)
%
% 
% Output Arguments:
% 	sadj				compensated verion of vector s
% 	Sfull				full discrete Fourier transform of sadj
% 	Magnorm			correction factors for sadj, in dB
% 	f					frequencies for calibration
%
%------------------------------------------------------------------------
% See also: NICal, FlatWav
%------------------------------------------------------------------------

%------------------------------------------------------------------------
% Sharad J. Shanbhag
% sshanbhag@neomed.edu
%------------------------------------------------------------------------
% Created: XX XXXX, 2011 (SJS)
%
% Revisions:
%	1 Oct 2012 (SJS): working on method # 2
%	8 Oct 2012 (SJS): implemented COMPRESS method
%	9 Oct 2012 (SJS): added LEVEL option to specify target level
%	23 Oct 2012 (SJS): updated docs
%	22 Aug 2014 (SJS): some tweaks to improve performance.  This function
% 		should ideally be moved into the general TytoLogy library
%		- added Prefilter option
%------------------------------------------------------------------------
% TO DO:
%	*Implement phase correction in algorithm and switch/tag for input 
%------------------------------------------------------------------------

%------------------------------------------------------------------------
%------------------------------------------------------------------------
% define some constants
%------------------------------------------------------------------------
%------------------------------------------------------------------------
% arbitrary minimum dB value
MIN_DB = -200;
% need to have a small, but non-zero value when taking log, so set that here
ZERO_VAL = 1e-17;

%------------------------------------------------------------------------
%------------------------------------------------------------------------
% define defaults for settings
%------------------------------------------------------------------------
%------------------------------------------------------------------------
% default method
COMPMETHOD = 'BOOST';
% default low frequency cutoff.  4 kHz is used to protect speakers!
LOWCUT = 4000;
% normalize
NORMALIZE = 0;
% level sets target flattening level; if 0 (default), will set from cal data 
% depending on method
LEVEL = 0;
% sets option to pre-filter the waveform before compensating
PREFILTER = 0;
% sets option to post-filter the waveform before compensating
POSTFILTER = 0;
% Limit calculation of max/min values to corr_frange
RANGELIMIT = 1;
% limit correction amount
CORRLIMIT = 0;
% Smooth freq. transitions at corr_frange limits
SMOOTHEDGES = 0;

%------------------------------------------------------------------------
%------------------------------------------------------------------------
% check input arguments
%------------------------------------------------------------------------
%------------------------------------------------------------------------
nvararg = length(varargin);
if nvararg
	aindex = 1;
	while aindex <= nvararg
		switch(upper(varargin{aindex}))
			
			% select method
			case 'METHOD'
				mtype = upper(varargin{aindex + 1});
				switch mtype
					case 'BOOST'
						COMPMETHOD = 'BOOST';
					case 'ATTEN'
						COMPMETHOD = 'ATTEN';
					case 'COMPRESS'
						COMPMETHOD = 'COMPRESS';
					otherwise
						fprintf('%s: unknown compensation method %s\n', ...
																				mfilename, mtype);
						fprintf('\tUsing default, BOOST method\n');
						COMPMETHOD = 'BOOST';
				end
				aindex = aindex + 2;
				clear mtype;
			
			% set LOWCUT (low frequency cutoff) option & frequency
			case 'LOWCUT'
				lval = varargin{aindex + 1};
				if strcmpi(lval, 'OFF')
					LOWCUT = 0;
				elseif isnumeric(lval)
					LOWCUT = lval;
				end
				aindex = aindex + 2;
				clear lval;
				
			% set normalization of output signal
			case 'NORMALIZE'
				nval = varargin{aindex + 1};
				if strcmpi(nval, 'ON')
					NORMALIZE = 1;
				elseif strcmpi(nval, 'OFF')
					NORMALIZE = -1;
				elseif isnumeric(nval)
					NORMALIZE = nval;
				else
					NORMALIZE = -1;
				end
				aindex = aindex + 2;
				clear nval;
				
			% set level
			case 'LEVEL'
				lval = varargin{aindex + 1};
				if strcmpi(lval, 'OFF')
					LEVEL = 0;
				elseif isnumeric(lval)
					if lval <= 0
						error('%s: LEVEL value must be greater than zero!', ...
																						mfilename);
					else
						LEVEL = lval;
					end
				else
					error('%s: invalid LEVEL value (%s)', mfilename, lval);
				end
				aindex = aindex + 2;
				clear lval;
				
			% set PREFILTER option
			case 'PREFILTER'
				lval = varargin{aindex + 1};
				if strcmpi(lval, 'ON')
					PREFILTER = 1;
				elseif isnumeric(lval)
					PREFILTER = lval;
				else
					PREFILTER = 0;
				end
				aindex = aindex + 2;
				clear lval;
				
			% set POSTFILTER option
			case 'POSTFILTER'
				lval = varargin{aindex + 1};
				if strcmpi(lval, 'ON')
					POSTFILTER = 1;
				elseif isnumeric(lval)
					POSTFILTER = lval;
				else
					POSTFILTER = 0;
				end
				aindex = aindex + 2;
				clear lval;
				
			% set RANGELIMIT option
			case 'RANGELIMIT'
				lval = varargin{aindex + 1};
				if strcmpi(lval, 'ON')
					RANGELIMIT = 1;
				else
					RANGELIMIT = 0;
				end
				aindex = aindex + 2;
				clear lval;

			% set CORRLIMIT option
			case 'CORRLIMIT'
				lval = varargin{aindex + 1};
				if strcmpi(lval, 'ON')
					CORRLIMIT = 1;
				elseif isnumeric(lval)
					CORRLIMIT = lval;
				else
					CORRLIMIT = 0;
				end
				aindex = aindex + 2;
				clear lval;
				
			% set SMOOTHEDGES option
			case 'SMOOTHEDGES'
				lval = varargin{aindex + 1};
				if strcmpi(lval, 'ON')
					SMOOTHEDGES = [0.01 3];
				elseif isnumeric(lval)
					SMOOTHEDGES = [0.01*lval(1) lval(2)];
				else
					SMOOTHEDGES = 0;
				end
				aindex = aindex + 2;
				clear lval;				
				
			otherwise
				error('%s: Unknown option %s', mfilename, varargin{aindex});
		end		% END SWITCH
	end		% END WHILE aindex
end		% END IF nvararg


%------------------------------------------------------------------------
%------------------------------------------------------------------------
% check the correction frequency range, adjust values if out of bounds
%------------------------------------------------------------------------
%------------------------------------------------------------------------
if corr_frange(1) < min(calfreq)
	corr_frange(1) = min(calfreq);
end
if corr_frange(2) > max(calfreq)
	corr_frange(2) = max(calfreq);
end


%------------------------------------------------------------------------
%------------------------------------------------------------------------
% prefilter raw signal
%------------------------------------------------------------------------
%------------------------------------------------------------------------
if PREFILTER
	if length(PREFILTER) == 2
		pre_frange = PREFILTER;
	else
		pre_frange = corr_frange;
	end
	
	% build bandpass filter
	% passband definition
	fband = pre_frange ./ (Fs / 2);
	% filter coefficients using a butterworth bandpass filter
	[pref_b, pref_a] = butter(6, fband, 'bandpass');
	% filter data using input filter settings
	s = filtfilt(pref_b, pref_a, s);
end

%------------------------------------------------------------------------
%------------------------------------------------------------------------
% get spectrum of raw signal
%------------------------------------------------------------------------
%------------------------------------------------------------------------
% length of signal
Nsignal = length(s);
% for speed's sake, get the nearest power of 2 to the desired output length
NFFT = 2.^(nextpow2(Nsignal));
% fft
S = fft(s, NFFT);
%non-redundant points are kept
Nunique = NFFT/2;
Sunique = S(1:Nunique);
% get the magnitudes of the FFT  and scale by 2 because we're taking only
% half of the points from the "full" FFT vector S;
Smag = abs(Sunique)/Nsignal;
Smag(2:end) = 2*Smag(2:end);
% get phase
Sphase = angle(Sunique);
% convert to db - need to avoid log(0)
tmp = Smag;
tmp(tmp==0) = ZERO_VAL; 
SdBmag = db(tmp);
clear tmp;

%------------------------------------------------------------------------
%------------------------------------------------------------------------
% determine frequency vector for calibration of signal
%------------------------------------------------------------------------
%------------------------------------------------------------------------
% build frequency vector
% This is an evenly spaced frequency vector with Nunique points.
% scaled by the Nyquist frequency (Fn ==1/2 sample freq.)
f = (Fs/2)*linspace(0, 1, NFFT/2);
% need to find max, min of calibration range
valid_indices = find(between(f, corr_frange(1), corr_frange(2))==1);
% check to make sure there is overlap in ranges
if isempty(valid_indices)
	% if not, throw an error
	error('%s: mismatch between FFT frequencies and calibration range', ...
																						mfilename);
end
% then, get the frequencies for correcting that range
corr_f = f(valid_indices);
% set lowcutindices
if LOWCUT
	lowcutindices = find(f < LOWCUT);
end

%------------------------------------------------------------------------
%------------------------------------------------------------------------
% set edges for smoothing SdBadj transitions
%------------------------------------------------------------------------
%------------------------------------------------------------------------
if SMOOTHEDGES
	smoothedges_win = SMOOTHEDGES(1) * corr_frange;
	
	% get midpoints for smooth windows
	midpoints = floor(smoothedges_win ./ 2);

	% indices for center of smoothing will be given by valid_indices.
	% use this to determine indices of Sadj to be smoothed
% 	% check if lowcut?
% 	if LOWCUT
% 		lcindx = max(lowcutindices);
% 		sindx{1} = (lcindx - midpoints(1)):(lcindx + midpoints(1));
% 		sindx{2} = (valid_indices(1) - midpoints(1)):(valid_indices(1) + midpoints(1));
% 		sindx{3} = (valid_indices(end) - midpoints(2)):(valid_indices(end) + midpoints(2));
% 	else
% 		sindx{1} = (valid_indices(1) - midpoints(1)):(valid_indices(1) + midpoints(1));
% 		sindx{2} = (valid_indices(end) - midpoints(2)):(valid_indices(end) + midpoints(2));
% 	end
	sindx{1} = (valid_indices(1) - midpoints(1)):(valid_indices(1) + midpoints(1));
	sindx{2} = (valid_indices(end) - midpoints(2)):(valid_indices(end) + midpoints(2));
end

%****************************************************************************
%****************************************************************************
%****************************************************************************
%									APPLY CORRECTION
%****************************************************************************
%****************************************************************************
%****************************************************************************

%------------------------------------------------------------------------
%------------------------------------------------------------------------
% apply correction using BOOST method
%------------------------------------------------------------------------
%------------------------------------------------------------------------
% procedure:	find additive compensation values for frequency range 
%					for which there are calibration data and apply to FFT, 
%					then iFFT to get corrected version
%------------------------------------------------------------------------
%------------------------------------------------------------------------
if strcmpi(COMPMETHOD, 'BOOST')
	% normalize to peak of xfer function
	
	if RANGELIMIT
		% need to find max, min of calibration range
		range_indx = find(between(calfreq, corr_frange(1), corr_frange(2))==1);
		peakmag = max(calmag(range_indx));
	else
		% find peak magnitude
		peakmag = max(calmag);
	end
	% normalize by finding deviation from peak
	Magnorm = peakmag - calmag;
	
	% if CORRLIMIT is set, limit correction to specified value
	if CORRLIMIT
		Magnorm(Magnorm > CORRLIMIT) = CORRLIMIT;
	end

	% interpolate to get the correction values (in dB!)
	corr_vals = interp1(calfreq, Magnorm, corr_f);

	% create adjusted magnitude vector from Smag (in dB)
	SdBadj = SdBmag;
	% apply correction
	SdBadj(valid_indices) = SdBadj(valid_indices) + corr_vals;

	% smooth transitions at edges
	if SMOOTHEDGES
		spiece = cell(3, 1);
		for n = 1:length(sindx)
			spiece{n} = moving_average(SdBadj(sindx{n}), SMOOTHEDGES(2));
			SdBadj(sindx{n}) = spiece{n};
		end
	end
	
	% convert back to linear scale...
	Sadj = invdb(SdBadj);

	% scale for length of signal and divide by 2 to scale for conversion to 
	% full FFT before inverse FFT
	Sadj = Nsignal * Sadj ./ 2;

	% create compensated time domain signal from spectrum
	[sadj, Sfull] = synverse(Sadj, Sphase, 'DC', 'no');
	% return only 1:Nsignal points
	sadj = sadj(1:Nsignal);
end

%------------------------------------------------------------------------
%------------------------------------------------------------------------
% apply correction using ATTEN method
%------------------------------------------------------------------------
%------------------------------------------------------------------------
% procedure:	find subtractive compensation values for frequency range 
%					for which there are calibration data and apply to FFT, 
%					then iFFT to get corrected version
%------------------------------------------------------------------------
%------------------------------------------------------------------------
if strcmpi(COMPMETHOD, 'ATTEN')
	% normalize to minimum of xfer function
	
	if RANGELIMIT
		% need to find max, min of calibration range
		range_indx = find(between(calfreq, corr_frange(1), corr_frange(2))==1);
		minmag = min(calmag(range_indx));
	else
		% find lowest magnitude
		minmag = min(calmag);
	end
	% normalize by finding deviation from peak
	Magnorm = minmag - calmag;
	
	% if CORRLIMIT is set, limit correction to specified value
	if CORRLIMIT
		Magnorm(abs(Magnorm) > CORRLIMIT) = -1 * CORRLIMIT;
	end	
	
	% interpolate to get the correction values (in dB!)
	corr_vals = interp1(calfreq, Magnorm, corr_f);

	% create adjusted magnitude vector from Smag (in dB)
	SdBadj = SdBmag;
	% apply correction
	SdBadj(valid_indices) = SdBadj(valid_indices) + corr_vals;

% 	% set freqs below LOWCUT to MINDB
% 	if (LOWCUT > 0) && ~isempty(lowcutindices)
% 		SdBadj(lowcutindices) = MIN_DB;
% 	end
% 
	% smooth transitions at edges
	if SMOOTHEDGES
		spiece = cell(3, 1);
		for n = 1:length(sindx)
			spiece{n} = moving_average(SdBadj(sindx{n}), SMOOTHEDGES(2));
			SdBadj(sindx{n}) = spiece{n};
		end
	end
	
	% convert back to linear scale...
	Sadj = invdb(SdBadj);

	% scale for length of signal and divide by 2 to scale for conversion to 
	% full FFT before inverse FFT
	Sadj = Nsignal * Sadj ./ 2;

	% create compensated time domain signal from spectrum
	[sadj, Sfull] = synverse(Sadj, Sphase, 'DC', 'no');
	% return only 1:Nsignal points
	sadj = sadj(1:Nsignal);
end

%------------------------------------------------------------------------
%------------------------------------------------------------------------
% apply correction using COMPRESS method
%------------------------------------------------------------------------
%------------------------------------------------------------------------
% procedure:	find subtractive compensation values for frequency range 
%					for which there are calibration data and apply to FFT, 
%					then iFFT to get corrected version
%------------------------------------------------------------------------
%------------------------------------------------------------------------
% some assumptions:
% 					magnitude values are in ACTUAL, dB SPL range.  
% 						¡this algorithm blows up for negative magnitudes!
%------------------------------------------------------------------------
%------------------------------------------------------------------------
if strcmpi(COMPMETHOD, 'COMPRESS')
	
	% check if LEVEL was specified
	if LEVEL
		% normalize by finding deviation from the specified dB level
		Magnorm = LEVEL - calmag;
		
	else
		% find midpoint of max and min dB level in calibration data
		% and "compress" around that value
		
		% check if rangelimit was specified
		if RANGELIMIT
			% need to find max, min of calibration range
			range_indx = find(between(calfreq, corr_frange(1), corr_frange(2))==1);
			% find max and min in magnitude spectrum (within range_indx)
			maxmag = max(calmag(range_indx));
			minmag = min(calmag(range_indx));
			% compute middle value
			midmag = ((maxmag - minmag) / 2) + minmag;			
			% normalize by finding deviation from middle level
			Magnorm = midmag - calmag(range_indx);
		else
			% find max and min in magnitude spectrum
			maxmag = max(calmag);
			minmag = min(calmag);
			% compute middle value
			midmag = ((maxmag - minmag) / 2) + minmag;
			% normalize by finding deviation from middle level
			Magnorm = midmag - calmag;
		end
	end
	
	% if CORRLIMIT is set, limit correction to specified value
	if CORRLIMIT
		if all(Magnorm < CORRLIMIT)
			warning('CompensateSignal:CORRLIMIT', 'CORRLIMIT > all values');
			fprintf('\tConsider raising the Target SPL level\n');
			fprintf('\tin order to balance correction amount!\n\n');
		elseif all(Magnorm > CORRLIMIT)
			warning('CompensateSignal:CORRLIMIT', 'CORRLIMIT < all values');
			fprintf('\tConsider lowering the Target SPL level\n');
			fprintf('\tin order to balance correction amount!\n\n');
		end
		Magnorm(Magnorm > CORRLIMIT) = CORRLIMIT;
		Magnorm(Magnorm < -CORRLIMIT) = -CORRLIMIT;
	end
	
	% interpolate to get the correction values (in dB!)
	corr_vals = interp1(calfreq, Magnorm, corr_f);
	
	% create adjusted magnitude vector from Smag (in dB)
	SdBadj = SdBmag;
	% apply correction
	SdBadj(valid_indices) = SdBadj(valid_indices) + corr_vals;

% 	% set freqs below LOWCUT to MINDB
% 	if (LOWCUT > 0) && ~isempty(lowcutindices)
% 		SdBadj(lowcutindices) = MIN_DB;
% 	end
	
	% smooth transitions at edges
	if SMOOTHEDGES
		spiece = cell(3, 1);
		for n = 1:length(sindx)
			spiece{n} = moving_average(SdBadj(sindx{n}), SMOOTHEDGES(2));
			SdBadj(sindx{n}) = spiece{n};
		end
	end
	
	% convert back to linear scale...
	Sadj = invdb(SdBadj);

	% scale for length of signal and divide by 2 to scale for conversion to 
	% full FFT before inverse FFT
	Sadj = Nsignal * Sadj ./ 2;

	% create compensated time domain signal from spectrum
	[sadj, Sfull] = synverse(Sadj, Sphase, 'DC', 'no');
	% return only 1:Nsignal points
	sadj = sadj(1:Nsignal);
end

%------------------------------------------------------------------------
%------------------------------------------------------------------------
% lowcut? define filter
%------------------------------------------------------------------------
%------------------------------------------------------------------------
if LOWCUT
	% build highpass filter
	% passband definition
	lcfc = LOWCUT ./ (Fs / 2);
	% filter coefficients using a butterworth highpass filter
	[lcf_b, lcf_a] = butter(7, lcfc, 'high');
	% filter data using input filter settings
	sadj = filtfilt(lcf_b, lcf_a, sadj);
end

%------------------------------------------------------------------------
%------------------------------------------------------------------------
% postfilter signal
%------------------------------------------------------------------------
%------------------------------------------------------------------------
if POSTFILTER
	if length(POSTFILTER) == 2
		post_frange = POSTFILTER;
	else
		post_frange = corr_frange;
	end
	
	% build bandpass filter
	% passband definition
	fband = post_frange ./ (Fs / 2);
	% filter coefficients using a butterworth bandpass filter
	[postf_b, postf_a] = butter(5, fband, 'bandpass');
	% filter data using input filter settings
	sadj = filtfilt(postf_b, postf_a, sadj);
end

%------------------------------------------------------------------------
%------------------------------------------------------------------------
% normalize output if desired
%------------------------------------------------------------------------
%------------------------------------------------------------------------
if NORMALIZE >= 0
	sadj = NORMALIZE * normalize(sadj);
end