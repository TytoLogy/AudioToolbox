function [S, Srms, SrmsMod, SmodPhi, Smag, Sphase] = syn_headphone_amnoise(Dur, Fs, NoiseF, ITDus, BC, ModDepth, ModF, ModPhi, caldata, Smag, Sphase)
%-------------------------------------------------------------------------
% [S, Srms, SrmsMod, SmodPhi, Smag, Sphase] = syn_headphone_amnoise(Dur, Fs, NoiseF, ITDus, BC, 
%																	ModDepth, ModF, ModPhi,
%																	caldata)
%-------------------------------------------------------------------------
% Synthesis Toolbox
%-------------------------------------------------------------------------
% 
% Synthesize sinusoidally amplitude-modulated broadband noise for 
% headphone presentation
%
%-------------------------------------------------------------------------
% Input Arguments:
%	Dur		signal duration (ms)
%	Fs			output sampling rate (samples/s)
%	NoiseF	[1X2] Noise frequency bandwidth [lowFreq highFreq] (Hz)
%	ITDus		interaural time difference (usec) 
% 				*ignored if mono signal*
%	BC			binaural correlation, range of -100% to 100% (pct)
%	ModDepth	% depth of signal modulation (pct)
%	ModF		Modulation frequency (Hz)
%	ModPhi	Modulation Phase (radians)
% 				enter empty vector ( [] ) if automatic config is desired
%	caldata	sound calibration structure (caldata.mag, caldata.freq, caldata.phase)
%				if no calibration is desired, enter empty vector []
%-------------------------------------------------------------------------
% Output Arguments:
%	S			[2XN] array for stereo stimulus
%					L channel is row 1, R channel is row 2
%	Srms		rms scale factor in the form [lscale rscale] of carrier noise
%	SrmsMod	RMS scale factor of modulated signal
% 
% 	Optional:
%		SmodPhi
% 		Smag, Sphase	Magnitude and phase spectra for generating frozen or
% 							pre-specified noise
%							***BC MUST BE 100% for this to work correctly!!!!!*****
%-------------------------------------------------------------------------
% See Also: syn_headphonenoise_fft, syn_headphone_tone, 
%				figure_headphone_atten, synmononoise, load_headphone_cal
%-------------------------------------------------------------------------

%-------------------------------------------------------------------------
% Sharad J. Shanbhag
% sharad.shanbhag@aecom.yu.edu
% 	Code adapted from synth library developed by
% 	Jamie Mazer and Ben Arthur.
%	AM signal modulation code from Merri Rosen and Dan Sanes of NYU
%-------------------------------------------------------------------------
% Created: 
% 	30 October, 2009 (SJS): adapted from syn_headphone_noise.m and
%		sAM_noise.m
% 
% Revision History:
%	21 November, 2009 (SJS):
% 		- added check for ModDepth == 0
% 		- added to sound synth toolbox
%-------------------------------------------------------------------------
% TO DO:
%	- confirm BC ~= 0 or 1 functionality
%-------------------------------------------------------------------------

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% some checks on the input arguments
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if Dur <=0
	error([mfilename ': duration must be > 0'])
end
if NoiseF(1) >= NoiseF(2)
	error([mfilename ': low freq must be < high freq limit']);
end

% check if Smag and Sphase were provided... if so, freeze the noise!
if (exist('Smag', 'var') && exist('Sphase', 'var'))
	FROZEN = 1;
else
	FROZEN = 0;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% setup
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Sample interval
dt = 1/Fs;
% buffer size
buffer_size = ms2samples(Dur, Fs);
% time vector
t = (0:buffer_size-1)*dt;
% Convert modulation depth from pct to range from 0 to 1
ModDepth = ModDepth / 100;
			
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Modulation 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% modulation depth factor
DMfactor = sqrt(0.3750*ModDepth^2 - ModDepth + 1);

% Modulator Phase
if isempty(ModPhi) && (ModDepth > 0)
	ModPhi = acos( (2/ModDepth) * (DMfactor - 1) + 1 );
else
	ModPhi = 0;
end

% Normalization Factor
NormF = 1 / DMfactor;

% Modulator sinusoid
modSin = 0.5 * ModDepth * cos(2*pi*ModF*t + ModPhi) - 0.5*ModDepth + 1;

% Normalized Modulator
modSin_norm = NormF * modSin;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Calibrated Noise
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% synthesize noise
if ~FROZEN
	[Snoise, Srms, Smag, Sphase]  = syn_headphone_noise(Dur, Fs, NoiseF(1), NoiseF(2), ITDus, BC, caldata);
else
	[Snoise, Srms, Smag, Sphase]  = syn_headphone_noise(Dur, Fs, NoiseF(1), NoiseF(2), ITDus, BC, caldata, Smag, Sphase);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% make sure length of Snoise matches time vector
% (usually off by 1 or 2 samples due to round-off error)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if length(Snoise) ~= length(t)
	if length(Snoise) < length(t)
		Snoise = [Snoise zeros(2, length(t) - length(Snoise))];
	else
		Snoise = Snoise(:, 1:length(t));
	end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% modulate the noise with the sinusoid
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
S = zeros(size(Snoise));
S(1, :) = modSin_norm .* Snoise(1, :);	
S(2, :) = modSin_norm .* Snoise(2, :);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% compute rms of modulated signal
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
SrmsMod = rms(S');

SmodPhi = ModPhi;

