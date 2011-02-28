function mergedfrdata = mergeFRfiles(file1name, file2name, channelmap, mergedfilename)
% mergedfrdata = mergeFRfiles(file1name, file2name, channelmap, mergedfilename)
% 
% Combines data from 2 frequency response (_fr.mat) files into one.
%
% If the REF data for the different runs come from different files, we
% need a different way to store those data, since the REF data is not
% common to both channels
% 
% 
% 	channelmap	[4 X 2]		determines source and destination of data
% 
%                    source	source
%                     file		channel
%		left_data       (1|2)		 (L|R)
% 		right_data      (1|2)		 (L|R)
% 		left_ref        (1|2)		 ignored
% 		right_ref       (1|2)		 ignored
% 	
% 	Some definitions for channels:
% 	L == 1
% 	R == 2
% 	REF == 3
% 	REFL == 3
% 	REFR == 4
% 
% Example 1: 
% 
% 		file1 has left earphone data recorded on left channel,
% 		file2 has right earphone data recorded on right channel
% 		
% 		so, channelmap is:
%                  source    source
%                   file     channel
%     left_data       1         1			(file1, L ch has left mic data)
%     right_data      2         2			(file2, R ch has right mic data)
%     left_ref        1         0			(file1 has left reference data)
%     right_ref       2         0			(file2 has right reference data)
%
% Example 2: 
% 
% 		file1 has right earphone data recorded on left channel,
% 		file2 has left earphone data recorded on left channel
% 		
% 		so, channelmap is:
%                  source    source
%                   file     channel
%     left_data      2			1			(file2, L ch has left mic data)
%     right_data     1			1			(file1, L ch has right mic data)
%     left_ref       2			3			(file2 has left reference data)
%     right_ref      1			3			(file1 has right reference data)
%
%
%  
% See also: 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%------------------------------------------------------------------------
%  Sharad Shanbhag
%	sshanbha@aecom.yu.edu
%------------------------------------------------------------------------
% Created: 7 April, 2009
%
% Revisions:
%------------------------------------------------------------------------

L = 1;
R = 2;
REF = 3;
REFL = 3;
REFR = 4;

if ~exist('channelmap', 'var')
	disp(' ');
	disp([mfilename ': no channelmap specified'])
	disp(['... assuming '])
	disp(['      ' file1name ' has L channel, stored in L channel'])
	disp(['      ' file2name ' has R channel, stored in R channel'])
	disp(' ')
	channelmap = [	1	L;...
						2	R;...
						1	3;...
						2	3    ];
end

if ~exist('mergedfilename', 'var')
	disp([mfilename ': no merged file will be written.']);
	WRITE_MERGED_FILE = 0;
else
	WRITE_MERGED_FILE = 1;
end

if ~exist('file1name', 'var') | ~ exist('file2name', 'var')
	error([mfilename ': need to provide filenames for 2 input _fr.mat files!'])
end

% read in frdata from file 1
load(file1name, 'frdata');
frdata1 = frdata;
clear frdata;
% read in frdata from file 2
load(file2name, 'frdata');
frdata2 = frdata;
clear frdata;

% some checks
if frdata1.freq ~= frdata2.freq
	error([mfilename ': data files do not have equivalent frequency sampling!'])
end

% for no particular reason, use frdata1 as template
mergedfrdata = frdata1;

mergedfrdata.mergeinfo.channelmap = channelmap;
mergedfrdata.mergeinfo.files = {file1name, file2name};

% assign frdata structs to sourcedata cell so we can index using 
% number - will cut down on number of if/else statements
sourcedata{1} = frdata1;
sourcedata{2} = frdata2; 

mergedfrdata.mag(L, :) = sourcedata{channelmap(1, 1)}.mag(channelmap(1, 2), :);
mergedfrdata.mag(R, :) = sourcedata{channelmap(2, 1)}.mag(channelmap(2, 2), :);
mergedfrdata.mag(REFL, :) = sourcedata{channelmap(3, 1)}.mag(REF, :);
mergedfrdata.mag(REFR, :) = sourcedata{channelmap(4, 1)}.mag(REF, :);

mergedfrdata.phase(L, :) = sourcedata{channelmap(1, 1)}.phase(channelmap(1, 2), :);
mergedfrdata.phase(R, :) = sourcedata{channelmap(2, 1)}.phase(channelmap(2, 2), :);
mergedfrdata.phase(REFL, :) = sourcedata{channelmap(3, 1)}.phase(REF, :);
mergedfrdata.phase(REFR, :) = sourcedata{channelmap(4, 1)}.phase(REF, :);

mergedfrdata.dist(L, :) = sourcedata{channelmap(1, 1)}.dist(channelmap(1, 2), :);
mergedfrdata.dist(R, :) = sourcedata{channelmap(2, 1)}.dist(channelmap(2, 2), :);
mergedfrdata.dist(REFL, :) = sourcedata{channelmap(3, 1)}.dist(REF, :);
mergedfrdata.dist(REFR, :) = sourcedata{channelmap(4, 1)}.dist(REF, :);

mergedfrdata.mag_stderr(L, :) = sourcedata{channelmap(1, 1)}.mag_stderr(channelmap(1, 2), :);
mergedfrdata.mag_stderr(R, :) = sourcedata{channelmap(2, 1)}.mag_stderr(channelmap(2, 2), :);
mergedfrdata.mag_stderr(REFL, :) = sourcedata{channelmap(3, 1)}.mag_stderr(REF, :);
mergedfrdata.mag_stderr(REFR, :) = sourcedata{channelmap(4, 1)}.mag_stderr(REF, :);

mergedfrdata.phase_stderr(L, :) = sourcedata{channelmap(1, 1)}.phase_stderr(channelmap(1, 2), :);
mergedfrdata.phase_stderr(R, :) = sourcedata{channelmap(2, 1)}.phase_stderr(channelmap(2, 2), :);
mergedfrdata.phase_stderr(REFL, :) = sourcedata{channelmap(3, 1)}.phase_stderr(REF, :);
mergedfrdata.phase_stderr(REFR, :) = sourcedata{channelmap(4, 1)}.phase_stderr(REF, :);

mergedfrdata.background(L, :) = sourcedata{channelmap(1, 1)}.background(channelmap(1, 2), :);
mergedfrdata.background(R, :) = sourcedata{channelmap(2, 1)}.background(channelmap(2, 2), :);
mergedfrdata.background(REFL, :) = sourcedata{channelmap(3, 1)}.background(REF, :);
mergedfrdata.background(REFR, :) = sourcedata{channelmap(4, 1)}.background(REF, :);

if channelmap(1, 2) == L
	mergedfrdata.ladjmag = sourcedata{channelmap(1, 1)}.ladjmag;
	mergedfrdata.ladjphi = sourcedata{channelmap(1, 1)}.ladjphi;
elseif channelmap(1, 2) == R
	mergedfrdata.ladjmag = sourcedata{channelmap(1, 1)}.radjmag;
	mergedfrdata.ladjphi = sourcedata{channelmap(1, 1)}.radjphi;
else
	error([mfilename ': channelmap(1, 2) error']);
end

if channelmap(2, 2) == L
	mergedfrdata.radjmag = sourcedata{channelmap(2, 1)}.ladjmag;
	mergedfrdata.radjphi = sourcedata{channelmap(2, 1)}.ladjphi;
elseif channelmap(2, 2) == R
	mergedfrdata.radjmag = sourcedata{channelmap(2, 1)}.radjmag;
	mergedfrdata.radjphi = sourcedata{channelmap(2, 1)}.radjphi;
else
	error([mfilename ': channelmap(2, 2) error']);
end

if WRITE_MERGED_FILE
	frdata = mergedfrdata;
	save(mergedfilename, 'frdata');
end

