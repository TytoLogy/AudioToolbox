function [f, mag, phi, maxf, maxmag] = daqdbfullfft(dataV, Fs, blocksize, plotFlag)
%------------------------------------------------------------------------
% [f, mag, phimaxf, maxmag] = daqdbfullfft(dataV, Fs, blocksize, plotFlag)
%------------------------------------------------------------------------
% TytoLogy Project
% AudioToolbox:FFT
%------------------------------------------------------------------------
%  [F,MAG] = daqdbfullfft(X,FS,BLOCKSIZE) calculates the FFT of X
%    using sampling frequency FS and the SamplesPerTrigger provided
%    in BLOCKSIZE.
% 
%------------------------------------------------------------------------
% See also: DAQ Toolbox 
%------------------------------------------------------------------------

%------------------------------------------------------------------------
% Sharad J. Shanbhag
% sshanbhag@neomed.edu
%------------------------------------------------------------------------
% Created: 1 October, 2012 (SJS) from daqdbfft()
%
% Revisions:
%------------------------------------------------------------------------


if ~exist('plotFlag', 'var');
	plotFlag = 0;
end

% take fft of data
dfft = fft(dataV);

%get magnitude, and normalize by blocksize
xfft = abs(dfft./blocksize);
% Avoid taking the log of 0.
xfft(xfft == 0) = 1e-17;

% compute dB SPL keep only 1:NFFT components (other 1/2 is repeat)
mag = db(xfft(1:floor(blocksize/2)));

if nargout > 2
	phi = unwrap(angle(dfft(1:floor(blocksize/2))));
end


% build frequency vector
f = (0:length(mag)-1)*Fs/blocksize;
f = f(:);
% find max point
[~, maxindx] = max(mag);
maxmag = mag(maxindx);
maxf = f(maxindx);

if plotFlag
	% plot
	plot(f, mag)
	grid on

	yrange = ylim;
	maxStr = sprintf('Peak: %f db SPL @ %f\n', maxmag, maxf);
	maxH = text(1, yrange(2)*0.92, maxStr);
	set(maxH, 'FontSize', 10);
	set(maxH, 'Color', 'r');
	hold on
	plot(maxf, maxmag, 'or');
	hold off
end


