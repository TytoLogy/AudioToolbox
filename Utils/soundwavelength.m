% sound wavelength plot based on speed of sound = 347.87 meters/second

% define speed of sound
SOUNDSPEED = 347.87;

% set up list of frequencies
exponents = 0:5;
fscales = 1:9;
nfreqs = length(exponents)*length(fscales);
f = zeros(1, nfreqs);

% initialize frequency index var
findx = 1;
% loop through exponents
for m = exponents
	% loop through frequency scale factors
	for n = fscales
		% compute frequency, store in f vector and increment index
		f(findx) = n * (10^m);
		findx = findx + 1;
	end
end

% compute wavelengths
w = SOUNDSPEED ./ f;

% plot in log log format
f1 = figure(1)
p1 = loglog(f, w, '.-');
a1 = gca;
% turn on grid
grid on
% axis labels
xlabel('Frequency (Hz)')
ylabel('Wavelength (meters)')
% title
title( {'Sound Wavelength (meters) vs. Sound Frequency (Hz)', ...
			'Vsound = 347.87 m/s'})

		
f2 = figure(2)
p2 = loglog(f, 1000*w, '.-');
a2 = gca;
% turn on grid
grid on
% axis labels
xlabel('Frequency (Hz)')
ylabel('Wavelength (mm)')
% title
title( {'Sound Wavelength (mm) vs. Sound Frequency (Hz)', ...
			'Vsound = 347.87 m/s'})

ticklab = get(a2, 'XTickLabel')
tickval = get(a2, 'XTick')
set(a2, 'XTickLabel', tickval);
ticklab = get(a2, 'YTickLabel')
tickval = get(a2, 'YTick')
set(a2, 'YTickLabel', tickval);








% print out list
fprintf('Hz\t\tm\n');
for n = 1:nfreqs
	fprintf('%d\t\t%f\n', f(n), w(n))
end
fprintf('\n\n');