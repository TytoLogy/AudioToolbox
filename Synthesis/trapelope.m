%% Created for Tytology setup in RosenLab 1/23/13 by Merri J. Rosen

function trapwave = trapelope(...
    risefall,...    % msec
    modfreq,...     % Hz
    moddepth,...    % percent
    len,...         % msec
    Fs)             % samples/sec
    
% clear all; close all;
% 
% risefall = 20;   % msec
% modfreq = 10;	% Hz
% moddepth = 50;	% percent
% len = 400;     % msec
% Fs = 1000;      % samples/sec

% compute maximum allowable rise/fall time
maxrise = (1000/modfreq)/2;
if risefall > maxrise
    risefall = maxrise;
    warndlg(['Rise-fall time was reduced to the max allowable value for chosen modfreq: ', num2str(maxrise)'])
%     warning(['WARNING! Rise-fall time was reduced to max allowable value for chosen modfreq: ', num2str(maxrise)])
end

% Create properly-shaped tAM, then compute RMS and scale from there to keep energy constant across stimuli
% ( (Vmax-Vdepth)/risetime ) *t  +Vdepth    <-- (y=mx+b)

trapwave=0;                         % initialize trapwave with a zero so signal has no click at onset
period = (1/modfreq)*Fs;            % compute period (in samples)
Vdepth=(100-moddepth)/100;          % convert depth from percent depth
riset =  0 : 1/Fs : risefall*0.001; % create time vector for upward ramp
riset = riset(1:end-1);             % shorten time vector by one sample
slope = (1-Vdepth)/(risefall*0.001);% compute slope using depth and rise/fall time (converted to seconds)
rise = (slope .* riset) + Vdepth;   % calculate rising phase
holdlev = ones(1,(period-(2*size(riset,2)))+1); % calculate holdlev vector at max amplitude
if isempty(holdlev)                    % if risefall is at max allowable duration
    holdlev = 1;                       % make sure there is 1 point at the max amplitude
end
trap = [rise holdlev fliplr(rise)];    % create single trapezoidal envelope period

temp = len/1000*Fs/(size(trap,2)-1);% number of periods
numper = fix(temp);                 % integer number of periods
extra = (temp-numper)*size(trap,2); % any leftover time
for i=1:numper                      % create trapwave but truncate last point of non-final periods
    trapwave = [trapwave trap(1:end-1)];
end
% trapwave = [trapwave trap];         % append final non-truncated period
trapwave = [trapwave zeros(1,extra)]; % pad with zeros if not enough time for a full period


%% plot

% figure(1);
% subplot 311
% plot(riset,rise,'g.-')
% xlabel('Time (seconds)')
% subplot 312
% plot((0:(length(trap) - 1))/Fs, trap, 'k.-')
% xlabel('Time (seconds)')
% subplot 313
% hold on; plot((0:(length(trapwave) - 1))/Fs, trapwave, 'r.-')
% xlabel('Time (seconds)')


%% extra

% period = 1/modfreq*Fs;
% riset = [0 : 1/(risefall/1000*Fs) : 1];
% riset = riset(1:end-1); % shorten by one sample
% trap = [riset ones( 1, period-(2*size(riset,2)) ) fliplr(riset)];
% temp = len/1000*Fs/size(trap,2);
% numper = fix(temp);  % integer number of periods
% extra = (temp-numper)*size(trap,2); % any leftover if user is an idiot
% 
% trapwave=[];
% for i=1:numper
%     trapwave = [trapwave trap];
% end
% trapwave = [trapwave zeros(1,extra)]; % pad with zeros if not enough time for a full period

% plot(trapwave)




% trap = [rise ones( 1, (period-(2*size(rise,2)))-1 ) fliplr(rise)]; % create full trapezoidal envelope
