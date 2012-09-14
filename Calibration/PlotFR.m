function PlotFR(varargin)
%-----------------------------------------------------------------------------
% PlotFR(frdata)
%-----------------------------------------------------------------------------
% AudioToolbox:Calibration
%-----------------------------------------------------------------------------
% Plots microphone frequency response data (_fr.mat or .fr)
%-----------------------------------------------------------------------------
% Input Arguments:
%
% Output arguments:
%
%-----------------------------------------------------------------------------
% See Also: PlotCal, get_cal, MicrophoneCal, NICal
%-----------------------------------------------------------------------------

%-----------------------------------------------------------------------------
% Sharad J. Shanbhag
% sshanbhag@neomed.edu
%
%-----------------------------------------------------------------------------
% Created 28 April, 2008 (SJS)
%
% Revision History:
%	13 Sep 2012 (SJS):
% 	 -	updated comments/documentation
%	 -	changed input to varargin, added input checking
%	 -	added checks for # of data channels (2 or 3) and acts accordingly
%-----------------------------------------------------------------------------

%% constants
GRAYLEVEL = 0.6;

%% Check input args
if ~isempty(varargin)
	
	% act according to nature of input arg
	if isstruct(varargin{1})
		% if struct, assign to frdata
		frdata = varargin{1};
	elseif ischar(varargin{1})
		% if character, assume it's a full filename and load frdata from it
		% (use try in order to trap errors)
		try
			load(varargin{1}, '-MAT');
			if ~exist('frdata', 'var')
				error('%s: no frdata struct in file %s', mfilename, varargin{1});
			end
		catch err
			% something failed, let user know
			disp(err.identifier)
			error('%s: problem with filename %s', mfilename, varargin{1});
		end
	else
		% something's wrong
		error('%s: invalid input (must be frdata struct OR filename', mfilename);
	end
else
	% otherwise, read in fr data file pointed to by user
	[calfile, calpath] = uigetfile( {'*.fr'; '*_fr.mat'}, ...
												'Load microphone calibration data from file...');
	if calfile ~=0
		% read in data file
		datafile = fullfile(calpath, calfile);	
		load(datafile, '-MAT');
		if ~exist('frdata', 'var')
			error('%s: no frdata struct in file %s', mfilename, datafile);
		end
	else
		% return if user pressed CANCEL button on UI
		return
	end
end

% check the frdata struct
[Nchannels, Nfreqs] = size(frdata.mag);

% if # channels is 3, use channel 3 as ref, channels 1 and 2 as data
if Nchannels == 3
	L = 1;
	R = 2;
	REF = 3;
elseif Nchannels == 2
	L = 1;
	REF = 2;
else
	error('%s: bizarre Nchannels (%d)', mfilename, Nchannels);
end

%% Plot data

% create new figure
figure
set(gcf, 'Name', 'PlotFR');

subplot(311)
plot(frdata.freq, frdata.mag(L, :), 'g.:');
if Nchannels == 3
	hold on
		plot(frdata.freq, frdata.mag(R, :), 'r.:');
	hold off
	ylabel('L, R Mag');
else
	ylabel('Test Mag');
end
title({'FR Data', frdata.time_str})
set(gca, 'XGrid', 'on');
set(gca, 'YGrid', 'on');
set(gca, 'Color', GRAYLEVEL*[1 1 1]);

subplot(312)
plot(frdata.freq, frdata.mag(REF, :), 'b.:')
ylabel('REF Mag');
set(gca, 'XGrid', 'on');
set(gca, 'YGrid', 'on');
set(gca, 'Color', GRAYLEVEL*[1 1 1]);


subplot(313)
plot(frdata.freq, frdata.mag(L, :)./frdata.mag(REF, :), 'g.:');
if Nchannels == 3
	hold on
		plot(frdata.freq, frdata.mag(2, :)./frdata.mag(3, :), 'r.:')
	hold off
end
ylabel('Correction Factor');
xlabel('Frequency');
set(gca, 'XGrid', 'on');
set(gca, 'YGrid', 'on');
set(gca, 'Color', GRAYLEVEL*[1 1 1]);
