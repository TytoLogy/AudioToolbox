function [rmsval, phi] = figure_cal(freqs, caldata)
%function [rmsval, phi] = figure_cal(freqs, caldata)
%	Input Arguments:
%		freqs		vector of frequencies for which to 
%					get calibration values
%
%		caldata		calibration data structure
%
%	Output Arguments:
%		rmsval		rms correction factors at each of freqs
%		phi			phase correction factors (in radians) at freqs
%
%	See Also:	LOAD_CALDATA, LOAD_HEADPHONE_CAL

%---------------------------------------------------------------------
%	Sharad Shanbhag
%	sshanbhag@aecom.yu.edu
%
%--Revision History---------------------------------------------------
%	12 Feb, 2008, SJS:	created
%	20 Mar, 2008, SJS:	added help comments
%	19 Jan, 2009, SJS:	- modified comments
%								- fixed error if n >= 3 in
%								  STEREO check code (from caldata that have
%									REF mic information)
%   20 Feb, 2013, MjR: Now using only the frequency range contained within
%                       the noise to determine the rmsval. Avoids having
%                       the signal generated to account for the lowest
%                       amplitude frequencies in caldata when those 
%                       frequencies are not part of the signal.
%---------------------------------------------------------------------

% get size of vector
[n, m] = size(caldata.maginv);

% check if stereo
STEREO = 0;
if n >= 2
	STEREO = 1;
end

% For NOISE
if length(freqs) > 1
    % find indices of freqs that have calibration data which are closest to the lowest and highest freqs in the stimulus
    [a,loweridx]=min(abs(round(caldata.freq-freqs(1))));
    [a,upperidx]=min(abs(round(caldata.freq-freqs(end))));
    freqrangeidx = [loweridx-1:upperidx+1]; % -1 and +1 to make sure values entirely encompass range of freqs in the stimulus

    % get values for Left channel (1)
    localminL = min(caldata.mag(1,freqrangeidx));
    maginv(1,:) = invdb(localminL - caldata.mag(1,freqrangeidx));
    rmsval = interp1(caldata.freq(freqrangeidx), maginv(1, :), freqs);
    phi = interp1(caldata.freq(freqrangeidx), caldata.phase_us(1, freqrangeidx), freqs);
    phi = (phi ./ 1.0e6) .* freqs * 2 * pi;

    if STEREO
        % get values for Right channel  (2)
        localminR = min(caldata.mag(2,freqrangeidx));
        maginv(2,:) = invdb(localminR - caldata.mag(2,freqrangeidx));
        rmsval(2,:) = interp1(caldata.freq(freqrangeidx), maginv(2, :), freqs);
        phi(2, :) = interp1(caldata.freq(freqrangeidx), caldata.phase_us(2, freqrangeidx), freqs);
        phi(2, :) = (phi(2, :) ./ 1.0e6) .* freqs * 2 * pi;
    end
% For TONE
elseif length(freqs) == 1
    % pasted from original figure_cal.m
    % get values for Left channel (1)
    rmsval = interp1(caldata.freq, caldata.maginv(1, :), freqs);
    phi = interp1(caldata.freq, caldata.phase_us(1, :), freqs);
    phi = (phi ./ 1.0e6) .* freqs * 2 * pi;
    if STEREO
        % get values for Right channel  (2)
        rmsval(2, :) = interp1(caldata.freq, caldata.maginv(2, :), freqs);
        phi(2, :) = interp1(caldata.freq, caldata.phase_us(2, :), freqs);
        phi(2, :) = (phi(2, :) ./ 1.0e6) .* freqs * 2 * pi;
    end
end

