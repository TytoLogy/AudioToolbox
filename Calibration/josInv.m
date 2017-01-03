function [B, A, varargout] = josInv(fe, Gdbe, NZ, NP, Nfft, fs, varargin)
%------------------------------------------------------------------------
% [B, A, Finv] = josInv(fe, Gdbe, NZ, NP, Nfft, fs, <<optional>>)
%------------------------------------------------------------------------
% 
% implements a fast (FFT-based) equation-error method for recursive filter
% design given samples of the desired frequency response.
%
% Given "experimentally measured" response magnitudes, Gdbe, and
% frequencies , fe, (need not be sampled at regular frequency intervals),
% generates filter coefficients, B and A. 
% 
% NZ and NP define number of zeros and poles in the filter while Nfft and
% fs used to define the length of the filter and sampling rate for the
% impulse response
%
% Optional input showPlot tells josInv to show some plots of filter 
%
% This method implements minimum-phase response and generates a filter 
% that modifies magnitude response and does not correct the phase response
% 
%------------------------------------------------------------------------
% Input Arguments:
% 	fe		frequencies for gain measurements [0:fs/2]
%	Gdbe	Gain measurements (dB) at frequencies in fe (can be non-uniform)
%	NZ		# of zeros in filter to be designed
%	NP		# of poles in filter to be designed
%	Nfft	fft length for calculations
%	fs		sample rate for calculation of impulse response
%			technically, this is not needed for calculation of filter, but
%			it is used to compute the impulse response for check of 
% 			accuracy of the calculation
%	Optional Inputs:
% 		'ShowPlot'			'y' tells josInv to show some plots of filter
%								default is 'n' (do not show plots)
%								if figure handle is passed in, plots will be
%								sent to that figure handle
%
%		'InterpMethod'		Method used for fitting adjustment curve to 
%								the uniform fft values required for ifft
% 
% 								default is 'spline'
% 								other options use methods from intep1() function:
% 								'linear'
% 								'nearest'
% 								'next'
% 								'previous'
% 								'pchip'
% 								'cubic'
% 								'v5cubic'
% 								'spline'
%
% Output Arguments:
% 	B, A		filter coefficients
%				B = numerator coefficients, A = denominator coefficients
%	Finv		Inverse Filter struct
% 		Fields:		
% 			Wh, Hh	Filter frequency response
% 						Hh = weights, Wh = frequencies
% 			Fk, Gdbk	Desired response
% 						Fk = Frequencies, Gdbk = gain
% 			s			Impulse response at sample rate s
%------------------------------------------------------------------------
% See also: invfreqz, freqz
%------------------------------------------------------------------------

%------------------------------------------------------------------------
% Original code developed by Julius Orion Smith III
% Functionalized, tidied up by Sharad J. Shanbhag (sshanbhag@neomed.edu)
%------------------------------------------------------------------------
% Created: 16 November, 2016 (SJS)
%
% Revisions:
%------------------------------------------------------------------------
% TO DO:
%------------------------------------------------------------------------

%------------------------------------------------------------------------
% defaults and check inputs
%------------------------------------------------------------------------
% default values
PLOTS = 'y';
INTERP_METHOD = 'default';
% check inputs
if ~isempty(varargin)
	n = 1;
	while n <= length(varargin)
		switch(upper(varargin{n}))
			case 'SHOWPLOT'
				if ishandle(varargin{n+1})
					PLOTS = varargin{n+1};
				elseif strcmpi(varargin{n+1}(1), 'y')
					PLOTS = 'y';
				elseif strcmpi(varargin{n+1}(1), 'n')
					PLOTS = 'n';
				else
					error('%s: invalid option %s for ''ShowPlot''', mfilename);
				end
				n = n + 2;
			case 'INTERPMETHOD'
				if strcmpi(varargin{n+1}, 'default')
					INTERP_METHOD = 'default';
				elseif strcmpi(varargin{n+1}, 'linear')
					INTERP_METHOD = 'linear';
				elseif strcmpi(varargin{n+1}, 'nearest')
					INTERP_METHOD = 'nearest';
				elseif strcmpi(varargin{n+1}, 'next')
					INTERP_METHOD = 'next';
				elseif strcmpi(varargin{n+1}, 'previous')
					INTERP_METHOD = 'previous';
				elseif strcmpi(varargin{n+1}, 'pchip')
					INTERP_METHOD = 'pchip';
				elseif strcmpi(varargin{n+1}, 'cubic')
					INTERP_METHOD = 'cubic';
				elseif strcmpi(varargin{n+1}, 'v5cubic')
					INTERP_METHOD = 'v5cubic';
				elseif strcmpi(varargin{n+1}, 'spline')
					INTERP_METHOD = 'spline';
				else
					error( ['%s: %s ' ...
								'is invalid argument for ''InterpMethod'' ' ...
								'option'], mfilename, varargin{n+1});
				end
				n = n+2;
			otherwise
				error('%s: invalid option %s', mfilename, varargin{n});
		end
	end
end
%------------------------------------------------------------------------
% Build spectrum 
%------------------------------------------------------------------------
% Resample to a uniform frequency grid, as required by ifft.
% Define fft frequency grid (nonneg freqs)
fk = fs*(0:Nfft/2)/Nfft;

switch(INTERP_METHOD)
	case 'default'
		% Default: we do this by fitting cubic splines 
		% evaluated on the fft grid:
		Gdbei = spline(fe,Gdbe);
		% Uniformly resampled amp-resp, passing spline polynomial to ppval
		Gdbfk = ppval(Gdbei,fk);
	case 'linear'
		Gdbfk = interp1(fe, Gdbe, fk, 'linear');
	case 'nearest'
		Gdbfk = interp1(fe, Gdbe, fk, 'nearest');
	case 'next'
		Gdbfk = interp1(fe, Gdbe, fk, 'next');
	case 'previous'
		Gdbfk = interp1(fe, Gdbe, fk, 'previous');
	case 'pchip'
		Gdbfk = interp1(fe, Gdbe, fk, 'pchip');
	case 'cubic'
		Gdbfk = interp1(fe, Gdbe, fk, 'cubic');
	case 'v5cubic'
		Gdbfk = interp1(fe, Gdbe, fk, 'v5cubic');
	case 'spline'
		Gdbfk = interp1(fe, Gdbe, fk, 'spline');
	otherwise
		error('%s: %s is not yet implemented')
end

% figure
% tmplin = interp1(fe, Gdbe, fk, 'linear');
% tmpnear = interp1(fe, Gdbe, fk, 'nearest');
% tmpnext = interp1(fe, Gdbe, fk, 'next');
% tmpprev = interp1(fe, Gdbe, fk, 'previous');
% tmppchip = interp1(fe, Gdbe, fk, 'pchip');
% tmpcubic = interp1(fe, Gdbe, fk, 'cubic');
% tmpv5 = interp1(fe, Gdbe, fk, 'v5cubic');
% tmpspline = interp1(fe, Gdbe, fk, 'spline');
% plot(	fk, Gdbfk, '.', ...
% 		fk, tmplin, '.', ...
% 		fk, tmpnear, '.', ...
% 		fk, tmpnext, '.', ...
% 		fk, tmpprev, '.', ...
% 		fk, tmppchip, '.', ...
% 		fk, tmpcubic, '.', ...
% 		fk, tmpv5, '.', ...
% 		fk, tmpspline, '.');
% grid
% legend({ 'defaultspline', ...
% 			'linear', ...
% 			'nearest', ...
% 			'next', ...
% 			'previous', ...
% 			'pchip', ...
% 			'cubic', ...
% 			'v5cubic', ...
% 			'spline'});
% pause

% check length of Gsbfk re: Nfft
Ns = length(Gdbfk);
if Ns ~= Nfft/2+1
	error('%s: Ns ~= Nfft/2 + 1, %d ~= %d', ...
				mfilename, Ns, Nfft/2+1);
end
% install negative-frequencies
Sdb = [Gdbfk,Gdbfk(Ns-1:-1:2)]; 
% convert to linear magnitude
S = 10 .^ (Sdb/20);
% desired impulse response
s = ifft(S);
% any imaginary part is quantization noise
s = real(s);
% compute time limit error
tlerr = 100*norm(s(round(0.9*Ns:1.1*Ns)))/norm(s);
if tlerr > 1.0
	% arbitrarily set 1% as the upper limit allowed
	fprintf(['Time-limitedness check: Outer 20%% of impulse ' ...
              'response is %0.2f %% of total rms\n'], tlerr);
	error('Increase Nfft and/or smooth Sdb');
end

%------------------------------------------------------------------------
% cepstrum to compute mimimum phase spectrum
%------------------------------------------------------------------------
% compute real cepstrum from log magnitude spectrum
c = ifft(Sdb);
% Check aliasing of cepstrum (in theory there is always some):
caliaserr = 100*norm(c(round(Ns*0.9:Ns*1.1)))/norm(c);
% = 0.09 percent
if caliaserr > 1.0
	% arbitrary limit
	fprintf(['Cepstral time-aliasing check: Outer 20%% of ' ...
				'cepstrum holds %0.2f %% of total rms\n'], caliaserr);
	error('Increase Nfft and/or smooth Sdb to shorten cepstrum');
end
% Fold cepstrum to reflect non-min-phase zeros inside unit circle:
% If complex:
% cf = [c(1), c(2:Ns-1)+conj(c(Nfft:-1:Ns+1)), c(Ns), zeros(1,Nfft-Ns)];
cf = [c(1), c(2:Ns-1)+c(Nfft:-1:Ns+1), c(Ns), zeros(1,Nfft-Ns)];
% = dB_magnitude + j * minimum_phase
Cf = fft(cf);
% minimum-phase spectrum
Smp = 10 .^ (Cf/20);
% nonnegative-frequency portion
Smpp = Smp(1:Ns);

%------------------------------------------------------------------------
% generate inverse
%------------------------------------------------------------------------
% typical weight fn for audio
wt = 1 ./ (fk+1);
wk = 2*pi*fk/fs;
[B,A] = invfreqz(Smpp, wk, NZ, NP, wt);
[Hh, Wh] = freqz(B,A,Ns);

%------------------------------------------------------------------------
% assign optional output
%------------------------------------------------------------------------
if nargout == 3
	varargout{1} = struct('Wh', Wh, 'Hh', Hh, ...
									'Fk', fk, 'Gdbk', Gdbfk, 's', s);	
end

%------------------------------------------------------------------------
% Plotting if requested
%------------------------------------------------------------------------
if ~ishandle(PLOTS)
	% if PLOTS is not a figure handle, it still might be 'y' which
	% instructs us to create a new plot
	if PLOTS == 'y'
		PLOTS = figure;
	else
		PLOTS = 'n';
	end
end
if ishandle(PLOTS)
	figure(PLOTS);

	% frequency max, min
	fmin = min(fe);
	fmax = max(fe);

	% plot measured and fit magnitude response
	subplot(411)
	semilogx(fk(2:end-1),Gdbfk(2:end-1),'-k'); 
	grid('on'); 
	axis([fmin/2 fmax*2 min(Gdbfk) 1.1*max(Gdbfk)]);
	hold('on'); 
		semilogx(fe,Gdbe,'o');
	hold('off');
	xlabel('Frequency (Hz)');
	ylabel('Magnitude (dB)');
	title(['Measured and Extrapolated/Interpolated/Resampled ',...
			 'Amplitude Response']);

	% plot desired and created compensation curve
	subplot(412);
	plot(fk,db([Smpp(:),Hh(:)])); grid('on');
	xlabel('Frequency (Hz)');
	ylabel('Correction Magnitude (dB)');
	title('Correction Frequency Response');
	legend('Desired','Filter');

	subplot(413);
	plot(s, '-k');
	grid('on');
	title('Impulse Response');
	xlabel('Samples');
	ylabel('Amplitude');
	xlim([0 Nfft+1]);

	subplot(414)
	zplane(B, A);
 	axis square
	xlim([-1.1 1.1]);
	ylim([-1.1 1.1]);
	drawnow
end

%{
Fitting Filters to Measured Amplitude Response Data Using invfreqz in
Matlab

Julius Orion Smith III November 8, 2010

In the 1980s I wrote the matlab function invfreqz that implements a fast
(FFT-based) equation-error method for recursive filter design given samples
of the desired frequency response. This method designs causal filters,
fitting both the phase and magnitude of the desired (complex) frequency
response. As a result, one must be careful about the specified phase
response, especially when it doesn't matter!  This article gives some
pointers on this topic. The case I see most often is where there are no
phase data at all. For example, a filter response may be specified simply
as a desired (real) gain at various frequencies, i.e., only the amplitude
response is specified. The easiest choice of phase response in this case is
zero, but that would correspond to an impulse response that is symmetric
about time zero, and causal filters cannot produce any response before time
zero. In this case, phase-sensitive filter-design methods such as invfreqz
will generally give their best results for minimum phase in place of zero
phase. In other words, we need to convert our desired amplitude response to
the corresponding minimum-phase frequency response (whose magnitude equals
the original desired amplitude response). A commonly used method for
computing the minimum-phase frequency response from its magnitude is the
cepstral method.  The steps are as follows:


1.	Interpolate the amplitude response samples from 0 to half the sampling
rate, if necessary, and resample to a uniform "FFT frequency axis", if
necessary.  Denote the real, sampled amplitude response by S(k).

2. Perform an inverse FFT of log(S) to obtain the real cepstrum of
s, denoted by c(n).

3.	Fold the noncausal portion of c(n) onto its causal portion.

4. Perform a forward FFT, followed by exponentiation to obtain the minimum
phase frequency response Sm(k), where now sm(n) is causal, and
|Sm(k)|=S(k).
%}
