function bkwdata = readBKW(filename)
% bkwdata = readBKW(filename)
% 
% reads in Bruel and Kjaer calibration data from a .bkw file
% 
% Input Arguments:
% 	filename		name of .bkw file
% 
% Output Arguments:
%	bkwdata		structure of B&K microphone data
% 
% 					   ID: 	file ID string
% 					 Name:	name of microphone
% 				Contents:	contents of data file
% 					 Type:	mic type
% 			  SerialNum:	Serial Number
% 					 Date:	date of calibration
% 				Operator:	operator ID
% 			Temperature:	temperature at calibration time
% 		StaticPressure:	pressure (kPa) at calibration time
% 	 RelativeHumidity:	relative humidity (%) at calibration time
% 			 DataHeader:	Header line for data
% 				Response:	[NX2] array of response data
% 									col 1 == frequency (Hz)
% 									col 2 == response (dB)
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

if nargin == 0 | ~exist(filename, 'file')
	error([mfilename ': file not found']);
end

fp = fopen(filename, 'r');

bkwdata.ID = fgetl(fp);
bkwdata.Name = fgetl(fp);
bkwdata.Contents = fgetl(fp);
bkwdata.Type = fgetl(fp);
bkwdata.SerialNum = fgetl(fp);
bkwdata.Date = fgetl(fp);
bkwdata.Operator = fgetl(fp);
bkwdata.Temperature = fgetl(fp);
bkwdata.StaticPressure = fgetl(fp);
bkwdata.RelativeHumidity = fgetl(fp);

bkwdata.DataHeader = fgetl(fp);

n = 1;

while ~feof(fp)
	lineIn = fgetl(fp);
	
	bkwdata.Response(n, :) = sscanf(lineIn, '%f,%f');
	
	n = n+1;
end

fclose(fp);

