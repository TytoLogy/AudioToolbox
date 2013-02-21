%% load calibration

% get a fake cal structure
caldata = fake_caldata;


%% Hardware settings

%------------------------------------------------------
% TDT - these are general processing settings
%------------------------------------------------------
% ISI
tdt.StimInterval = 500;
tdt.StimDuration = 1000;
tdt.AcqDuration = 300;
% sweep period is usually AcqDuration plus a small factor (10 msec)
tdt.SweepPeriod = tdt.AcqDuration + 10;
tdt.StimDelay = 20;
tdt.HeadstageGain = 1000;	% gain for headstage
tdt.MonitorChannel = 1;	% monitor channel on Rz5 (from medusa)
tdt.MonitorGain = 1000;	% monitor channel gain (for display and monitor channel only)
tdt.decifactor = 1;	% factor to reduce input data sample rate
tdt.HPEnable = 1;	% enable HP filter
tdt.HPFreq = 200;	% HP frequency
tdt.LPEnable = 1;	% enable LP filter
tdt.LPFreq = 10000;	% LP frequency
% # of input (spike) channels
tdt.nChannels = 1;
tdt.InputChannel = zeros(tdt.nChannels, 1);
tdt.OutputChannel = [1 2];
%TTL pulse duration (msec)
tdt.TTLPulseDur = 1;

%------------------------------------------------------
% outdev - these are settings for output device (RZ6)
%------------------------------------------------------
outdev.Fs = 50000;
% set this to wherever the RZ6 circuits are stored
outdev.Circuit_Path = 'C:\TytoLogy\Toolbox\TDTToolbox\Circuits\RZ6\';
outdev.Circuit_Name = 'RZ6_SpeakerOutput_zBus';
% Dnum = device number - this is for RZ6, device 1
outdev.Dnum=1;
outdev.C = [];
outdev.status = 0;


%% Stimulus settings

%------------------------------------------------------
% tAM settings
%------------------------------------------------------

% tAM carrier freq range
tAM.NoiseF = 4000; 
tAM.NoiseF = [200 19000];

% tAM ITD
tAM.ITD = 0;

% tAM ILD
tAM.ILD = 0;

% tAM binaural corr
tAM.BC = 100;

% rise/fall time for each period (ms)
tAM.RiseFall = 50;

% Modulation depth (percent)
tAM.tAMDepth = 100;

% tAM modulation freq (Hz)
tAM.tAMFreq = 5;

% on/off ramp time for entire signal (ms)
% NB: whether to do this is an issue that needs resolving
tAM.Ramp = 1;

% stim intensity (db SPL)
tAM.SPL = 50;

% Left output only
LRenable = [1 0];


%% synthesize stimuli

% %------------------------------------------------------
% % synthesize t.A.M. stimulus
% %------------------------------------------------------
% [tAM.S, tAM.rms_val, tAM.rms_mod, tAM.modPhi] = ...
% syn_headphone_tAM(tAM.RiseFall, tdt.StimDuration, outdev.Fs, tAM.NoiseF, ...
% tAM.ITD, tAM.BC, ...
% tAM.tAMDepth, tAM.tAMFreq, [], ...
% caldata);
% 
% 
% %% plot stimulus
% 
% figure;
% subplot(2,1,1); plot((0:(length(tAM.S(1,:)) - 1))/outdev.Fs, tAM.S(1,:),'b'); title('Normalized tAM')


%% TO-DO / ORGANIZATION

% FOR EITHER tAM emerging from silence 
%     OR tAM emerging from noise/tone of given level:

%  slopecurve - varying risefall time at 100% depth
%  moddepthcurve - varying moddepth at a given risefall
%  modfreqcurve - varying modfreq at a given depth and risefall


%% set parameters

c.nreps = 10; % number of repetitions
c.freezeStim = 1;  % 1 or 0 indicating FROZEN NOISE

% parameters to vary
tAM.RiseFall = [2 5 10 20 50];
tAM.tAMDepth;
tAM.tAMFreq;

% set number of trials, determined by range of varied parameter
if length(tAM.RiseFall) > 1
    curvetype = 'tAM_RISEFALL';
    c.nTrials = length(tAM.RiseFall);
    
elseif length(tAM.tAMDepth) > 1
    curvetype = 'tAM_MODDEPTH';
    c.nTrials = length(tAM.tAMDepth);
elseif length(tAM.tAMFreq) > 1
    curvetype = 'tAM_MODFREQ';
    c.nTrials = length(tAM.tAMFreq);
end


%% build curves

disp([mfilename ' is building stimuli for ' curvetype ' curve...'])
switch curvetype

    
%% tAM risefall modulation Curve (adapted from sAM depth curve code)

    case 'tAM_RISEFALL'
		% Stimulus parameter to vary (varName) and the range (stimvar)
		c.vname = upper(curvetype);  % was curve.curvetype
		c.vrange = tAM.RiseFall;     % was curve.sAMPCTrange
		
		% for tAM_RISEFALL curves, these parameters are fixed:
		ITD = tAM.ITD;
        ILD = tAM.ILD;
		BC = tAM.BC;
		SPL = tAM.SPL;  % this was ABI - see if you can substitute SPL below
		tAMFreq = tAM.tAMFreq;
        tAMDepth = tAM.tAMDepth; % added this
        CarrierFREQ = tAM.NoiseF;
        if tAM.NoiseF(end) >= caldata.freq(end) | tAM.NoiseF(1) <= caldata.freq(1)
            error('CAN''T DO THIS! Your carrier frequency is outside the range of frequencies in the calibration file.')
        end
        
		% If noise is frozen, generate zero ITD spectrum or tone, to be replicated later
		if c.freezeStim & length(CarrierFREQ)>1
			% get ITD = 0 Smag and Sphase
            [c.S0, c.rms_val0, c.rms_mod0, c.modPhi0, c.Smag0, c.Sphase0] = ...
                syn_headphone_tAM(5, tdt.StimDuration, outdev.Fs, CarrierFREQ, ...
                                  tAM.ITD, tAM.BC, ...
                                  tAMDepth, tAMFreq, [], ...
                                  caldata);
        end
        
        % Randomize trial presentations
        stimseq = HPCurve_randomSequence(c.nreps, c.nTrials);
        c.trialRandomSequence = stimseq;

		sindex = 0;
        plotsignals = figure(2);
		% now loop through the randomized trials
		for rep = 1:c.nreps  % was curve.nreps
			for trial = 1:c.nTrials % was curve.nTrials
				sindex = sindex + 1;

				% Get the randomized stimulus variable value from c.stimvar 
				% indices stored in c.trialRandomSequence
				tAMRiseFall = c.vrange(c.trialRandomSequence(rep, trial));

				% spl_val sets the L and R channel db levels, and the ILD
				spl_val = computeLRspl(ILD, SPL);  % substituted SPL for ABI

				% Synthesize noise or tone, frozed or unfrozed and get rms values for setting attenuator
                if ~c.freezeStim | length(CarrierFREQ)==1 % stimulus is unfrozen or tone
                    [Sn, rms_val, rms_mod, modPhi] = ...
                        syn_headphone_tAM(tAMRiseFall, tdt.StimDuration, outdev.Fs, CarrierFREQ, ...
                                          tAM.ITD, tAM.BC, ...
                                          tAMDepth, tAMFreq, [], ...
                                          caldata);

                else	% stimulus is frozen
                    [Sn, rms_val, rms_mod, modPhi] = ...
                        syn_headphone_tAM(tAMRiseFall, tdt.StimDuration, outdev.Fs, CarrierFREQ, ...
                                          tAM.ITD, tAM.BC, ...
                                          tAMDepth, tAMFreq, [], ...
                                          caldata, c.Smag0, c.Sphase0);
				end

                % ramp stimulus on and off
                Sn = sin2array(Sn, tAM.Ramp, outdev.Fs);


				% get the attenuator settings for the desired SPL
                atten = figure_headphone_atten(spl_val, rms_mod, caldata);

				% Store the parameters in the stimulus cache struct
				c.stimvar{sindex} = tAMRiseFall;
				c.Sn{sindex} = Sn;
				c.splval{sindex} = spl_val;
				c.rmsval{sindex} = rms_mod;
				c.atten{sindex} = atten;
				c.ITD(sindex) = ITD;
				c.ILD(sindex) = ILD;
				c.BC(sindex) = BC;
                c.tAMRiseFall = tAMRiseFall;
				c.CarrierFREQ{sindex} = CarrierFREQ;
				c.tAMDepth(sindex) = tAMDepth;
				c.tAMFreq(sindex) = tAMFreq;
                
                % plot each different type of signal
                if rep == 1
                    figure(plotsignals);  subplot(c.nTrials,1,trial);
                    plot(c.Sn{sindex}(1,:),'r-');  title(['RiseFall = ' num2str(tAMRiseFall)])
                    if trial ~= c.nTrials
                        set(gca,'xticklabel','')
                    end
                end
            end	%%% End of TRIAL LOOP
     
		end %%% End of REPS LOOP
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end




