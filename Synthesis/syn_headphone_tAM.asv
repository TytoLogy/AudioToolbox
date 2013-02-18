function [S, Srms, SrmsMod, SmodPhi, Smag, Sphase] = syn_headphone_tAMnoise(RiseFall, Dur, Fs, NoiseF, ITDus, BC, ModDepth, ModF, ModPhi, caldata, Smag, Sphase)
%-------------------------------------------------------------------------
% [S, Srms, SrmsMod, SmodPhi, Smag, Sphase] = syn_headphone_amnoise(RiseFall, Dur, Fs, NoiseF, ITDus, BC, 
%																	ModDepth, ModF, ModPhi,
%																	caldata, Smag, Sphase)
%-------------------------------------------------------------------------
% Synthesis Toolbox
%-------------------------------------------------------------------------
% 
% Synthesize trapezoidally amplitude-modulated tone or broadband noise for 
% headphone presentation, and normalize for overall energy (normalize RMS)
%
%-------------------------------------------------------------------------
% Input Arguments:
%   RiseFall    duration of rise/fall time (ms)
%	Dur		    signal duration (ms)
%	Fs			output sampling rate (samples/s)
%	NoiseF  either [1X2] Noise frequency bandwidth [lowFreq highFreq] (Hz)
%           or     [1x1] Tone frequency (Hz)
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
%	SrmsMod     RMS scale factor of modulated signal
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
%   23 January, 2013 (MjR):
%       - changed this program to create trapezoidal rather than sinuoidal AM
%-------------------------------------------------------------------------
% TO DO:
%	- confirm BC ~= 0 or 1 functionality
%
%   - Play with ramps at begin/end of whole signal. Options: 
%     1) 1st and last ramps are sin2 for very short duration (0.5ms) - 
%     need to test this empirically, and at low carrier frequencies.
%     2) 1st and last ramps are sin2 for the entire ramp
%
%-------------------------------------------------------------------------

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% some checks on the input arguments, and Synthesize Carrier
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if Dur <=0
	error([mfilename ': duration must be > 0'])
end

% Create either TONE or NOISE carrier
if length(NoiseF) ~= 1  % if user specified hi and lo freq cutoffs, to create a noise
    
    if NoiseF(1) >= NoiseF(2)
        error([mfilename ': low freq must be < high freq limit']);
    end

    % check if Smag and Sphase were provided... if so, freeze the noise!
    % Synthesize Calibrated Noise
    if (exist('Smag', 'var') && exist('Sphase', 'var'))
        [Scarrier, Srms, Smag, Sphase]  = syn_headphone_noise(Dur, Fs, NoiseF(1), NoiseF(2), ITDus, BC, caldata, Smag, Sphase);
    else
        [Scarrier, Srms, Smag, Sphase]  = syn_headphone_noise(Dur, Fs, NoiseF(1), NoiseF(2), ITDus, BC, caldata);
    end

else % if user specified a single frequency, to create a tone
    
    [Scarrier, Srms] = syn_headphone_tone(Dur, Fs, NoiseF, ITDus, 0, caldata); % The 0 sets vary onset phase of tone to NO.
    
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


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Modulation 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Modulator trapezoid
modTrap = trapelope(RiseFall, ModF, ModDepth, Dur, Fs);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% make sure length of Scarrier matches time vector
% (usually off by 1 or 2 samples due to round-off error)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if length(Scarrier) ~= length(modTrap)
	if length(Scarrier) < length(modTrap)
		Scarrier = [Scarrier zeros(2, length(modTrap) - length(Scarrier))];
	else
		Scarrier = Scarrier(:, 1:length(modTrap));
	end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% modulate the carrier with the trapezoid
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

SUnnorm = zeros(size(Scarrier));
SUnnorm = modTrap .* Scarrier(1,:);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% normalize modulated signal
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[Snorm, Fnorm] = normalize_rms(SUnnorm);
S(1,:) = Snorm;
S(2,:) = Snorm;
% disp(['ModDepth=',num2str(ModDepth),', Rise=',num2str(RiseFall),...
%     ', RMSpre=',num2str(rms(SUnnorm')),', RMSpost=',num2str(rms(Snorm))])


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% compute rms of normalized modulated signal
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

SrmsMod = rms(S');

SmodPhi = ModPhi; % phase isn't implemented here, but I kept this anyway


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% plot
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% figure; 
% subplot(2,1,1); plot((0:(length(S) - 1))/Fs, SUnnorm,'r'); title('Unnormalized tAM')
% subplot(2,1,2); plot((0:(length(Snorm) - 1))/Fs, Snorm,'b'); title('Normalized tAM')



