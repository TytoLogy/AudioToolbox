% [calfile, calpath] = uigetfile('*_fr.mat','Open headphone mic calibration file...');
% if calfile ~= 0
% 	% save the sequence so we can match up with the RF data
% 	datafile = fullfile(calpath, calfile);
% 	
% 	micdata = load_headphone_cal(datafile);
% else
% 	return
% end

citfile = 'C:\Users\Matlab\Experiments\CalibrationData\cit_4Mar08_fr.mat';
newfile = 'C:\Users\Matlab\Experiments\CalibrationData\new_4Mar08_fr.mat';

citdata = load_headphone_cal(citfile);
newdata = load_headphone_cal(newfile);

figure(1)
subplot(211)
plot(citdata.freq, db(citdata.mag(1, :)), 'g.-');
hold on
plot(citdata.freq, db(citdata.mag(2, :)), 'r.-');
plot(citdata.freq, db(citdata.mag(3, :)), 'k.--');
hold off
ylabel('Response Mag (dB V)');
title('cit 4Mar08 fr.mat')
ylim([-110 0])
set(gca, 'XTick', (0:2500:15000))
set(gca, 'XTickLabel', []);

subplot(212)
plot(citdata.freq, (1.0e6 * unwrap(citdata.phase(1, :))) ./ (2 * pi * citdata.freq), 'g.-');
hold on
plot(citdata.freq, (1.0e6 * unwrap(citdata.phase(2, :))) ./ (2 * pi * citdata.freq), 'r.-');
plot(citdata.freq, (1.0e6 * unwrap(citdata.phase(3, :))) ./ (2 * pi * citdata.freq), 'k.--');
hold off
xlabel('Frequency');
ylabel('Phase (us)');
set(gca, 'XTick', (0:2500:15000))



figure(2)
subplot(211)
plot(newdata.freq, db(newdata.mag(1, :)), 'g.-');
hold on
plot(newdata.freq, db(newdata.mag(2, :)), 'r.-');
plot(newdata.freq, db(newdata.mag(3, :)), 'k.--');
hold off
ylabel('Response Mag (dB V)');
title('new 4Mar08 fr.mat')
ylim([-110 0])
set(gca, 'XTick', (0:2500:15000))
set(gca, 'XTickLabel', []);

subplot(212)
plot(newdata.freq, (1.0e6 * unwrap(newdata.phase(1, :))) ./ (2 * pi * newdata.freq), 'g.-');
hold on
plot(newdata.freq, (1.0e6 * unwrap(newdata.phase(2, :))) ./ (2 * pi * newdata.freq), 'r.-');
plot(newdata.freq, (1.0e6 * unwrap(newdata.phase(3, :))) ./ (2 * pi * newdata.freq), 'k.--');
hold off
xlabel('Frequency');
ylabel('Phase (us)');
set(gca, 'XTick', (0:2500:15000))

figure(3)
plot(citdata.freq, db(normalize(citdata.mag(1, :))), 'g.-');
hold on
plot(citdata.freq, db(normalize(citdata.mag(2, :))), 'r.-');
plot(citdata.freq, db(normalize(citdata.mag(3, :))), 'k.--');
hold off
ylabel('Normalized Mag (dB)');
title('cit 4Mar08 fr.mat')
ylim([-50 10])
set(gca, 'XTick', (0:2500:15000))
xlabel('Frequency');

figure(4)
plot(newdata.freq, db(normalize(newdata.mag(1, :))), 'g.-');
hold on
plot(newdata.freq, db(normalize(newdata.mag(2, :))), 'r.-');
plot(newdata.freq, db(normalize(newdata.mag(3, :))), 'k.--');
hold off
ylabel('Normalized Mag (dB)');
title('new 4Mar08 fr.mat')
ylim([-50 10])
set(gca, 'XTick', (0:2500:15000))
xlabel('Frequency');
