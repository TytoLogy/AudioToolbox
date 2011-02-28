function mergedfr = mergefrdata(Lfilename, Rfilename, mergedfilename)
%mergedfr = mergefrdata(Lfilename, Rfilename, mergedfilename)
%
%	Input Arguments:
%		Lfilename	= 	L filename 
%		Rfilename	=	R filename
% 		mergedfilename	=	merged filename
% 		
%	Output Arguments:
%		mergedfr	= 	Matlab structure containing merged fr data
% 				
%
%	See also: GET_CAL, FAKE_FLATCAL, READEARCAL, WRITEEARCAL;

%--------------------------------------------------------------------------
% Sharad Shanbhag
% sshanbha@aecom.yu.edu
%--------------------------------------------------------------------------
%
% Created:	28 May, 2009 (SJS)
%
% Revisions:
%
%--------------------------------------------------------------------------

L = 1;
R = 2;
REF = 3;
mergedfr = [];

if ~exist('Lfilename', 'var')
	disp('Selecting L fr file...')
	[Lfilename, Lfilepath] = uigetfile('*_fr.mat', 'Select L channel fr file');
	if ~Lfilename
		warning([mfilename ': Left source file not specified'])
		return
	else
		Lfilename = fullfile(Lfilepath, Lfilename);
	end
end

if ~exist('Rfilename', 'var')
	disp('Selecting R fr file...')
	[Rfilename, Rfilepath] = uigetfile('*_fr.mat', 'Select R channel fr file');
	if ~Rfilename
		warning([mfilename ': Right source file not specified'])
		return
	else
		Rfilename = fullfile(Rfilepath, Rfilename);
	end
end


Lfr = load(Lfilename, '-MAT');
Rfr = load(Rfilename, '-MAT');

Lcal = Lfr.cal;
Rcal = Rfr.cal;
Lfrdata = Lfr.frdata;
Rfrdata = Rfr.frdata;

cal = Lcal;
frdata = Lfrdata;

cal.CalChannel = 'B';
cal.CalChannelID = [1 2 3];

frdata.mag(R, :) = Rfrdata.mag(R, :);
frdata.phase(R, :) = Rfrdata.phase(R, :);
frdata.dist(R, :) = Rfrdata.dist(R, :);
frdata.mag_stderr(R, :) = Rfrdata.mag_stderr(R, :);
frdata.phase_stderr(R, :) = Rfrdata.phase_stderr(R, :);

frdata.background(R, :) = Rfrdata.background(R, :);

frdata.radjmag = Rfrdata.radjmag;
frdata.radjphi = Rfrdata.radjphi;



if ~exist('mergedfilename', 'var')
	disp('Selecting Merged fr file...')
	[mergedfilename, mergedfilepath] = uiputfile('*_fr.mat', 'Select merged output file')
	if ~mergedfilename
		mergedfilename = 'merged_fr.mat';		
	else
		mergedfilename = fullfile(mergedfilepath, mergedfilename);
	end
end

save(mergedfilename, 'cal', 'frdata', 'Lfr', 'Rfr', '-MAT')

mergedfr.cal = cal;
mergedfr.frdata = frdata;






