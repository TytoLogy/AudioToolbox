function [f, mag, maxf, maxmag] = daqdbfft(dataV, Fs, blocksize, plotFlag, padFlag)
%------------------------------------------------------------------------
% [f, mag, maxf, maxmag] = daqdbfft(dataV, Fs, blocksize, plotFlag, padFlag)
%------------------------------------------------------------------------
% TytoLogy Project
% AudioToolbox:FFT
%------------------------------------------------------------------------
%  [F,MAG] = daqdbfft(X,FS,BLOCKSIZE) calculates the FFT of X
%    using sampling frequency FS and the SamplesPerTrigger provided
%    in BLOCKSIZE.
% if plotFlag is set to 1, plot of magnitude vs. frequency will be shown
% if padFlag is set, data will be zero padded to next power of length of
% dataV
%------------------------------------------------------------------------
% See also: DAQ Toolbox 
%------------------------------------------------------------------------

%------------------------------------------------------------------------
% Sharad J. Shanbhag
% sshanbhag@neomed.edu
%------------------------------------------------------------------------
% Created: August, 2012 (SJS) from daqfft() Matlab DAQ Toolbox function
%
% Revisions:
%------------------------------------------------------------------------


if ~exist('plotFlag', 'var');
	plotFlag = 0;
end
if ~exist('padFlag', 'var');
	padFlag = 0;
end

if padFlag
	blocksize = length(dataV);
	NFFT = 2^nextpow2(blocksize);
else
	NFFT = blocksize;
end

% take fft of data, get magnitude, and normalize by blocksize
xfft = abs(fft(dataV, NFFT))./blocksize;
% Avoid taking the log of 0.
xfft(xfft == 0) = 1e-17;
% compute dB SPL keep only 1:NFFT components (other 1/2 is repeat)
mag = db(xfft(1:floor(blocksize/2)));
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


