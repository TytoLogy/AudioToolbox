function PlotFR(frdata)
%  PlotFR(frdata)
%
%   
% Input Arguments:
%
% Returned arguments:
%
% See Also: syn_headphone_noise, syn_headphone_tone, figure_headphone_atten
%
%-----------------------------------------------------------------------------

%-----------------------------------------------------------------------------
% Sharad J. Shanbhag
% sshanbha@aecom.yu.edu
%
%-----------------------------------------------------------------------------
% Revision History
%	28 April, 2008 (SJS): Created
%-----------------------------------------------------------------------------

if nargin ~=1
	error
end

if ~isstruct(frdata)
	error
end


figure

subplot(311)
plot(frdata.freq, frdata.mag(1, :), 'g.:', frdata.freq, frdata.mag(2, :), 'r.:')
title({'FR Data', frdata.time_str})
ylabel('L, R Mag');
set(gca, 'XGrid', 'on');
set(gca, 'YGrid', 'on');
set(gca, 'Color', .5*[1 1 1]);

subplot(312)
plot(frdata.freq, frdata.mag(3, :), 'b.:')
ylabel('REF Mag');
set(gca, 'XGrid', 'on');
set(gca, 'YGrid', 'on');
set(gca, 'Color', .5*[1 1 1]);


subplot(313)
plot(frdata.freq, frdata.mag(1, :)./frdata.mag(3, :), 'g.:');
hold on
	plot(frdata.freq, frdata.mag(2, :)./frdata.mag(3, :), 'r.:')
hold off
ylabel('Correction Factor');


xlabel('Frequency');
set(gca, 'XGrid', 'on');
set(gca, 'YGrid', 'on');
set(gca, 'Color', .5*[1 1 1]);
