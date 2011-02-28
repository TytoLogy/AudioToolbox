function [amp, phi] = fitsinvec(data, skip, fs, f)
% [amp, phi] = fitsinvec(data, skip, fs, f)
%
%	Given data vector, sampling rate fs and frequency f
%	returns amplitude amp and phase phi (in radians)
%

nsamps = length(data);
period = floor(fs/f);
term = floor(nsamps/period) * period;

n = 1:term;
idx = n*skip;

rvec = sin(f * (n-1) * 2.0 * pi / fs) .* data(idx);
ivec = cos(f * (n-1) * 2.0 * pi / fs) .* data(idx);
re = sum(rvec);
im = sum(ivec);

% % un-vectorized code here
% re = 0;
% im = 0;
% for n = 1:term
% 	idx = n*skip;
% 	re = re + (sin(f * (n-1) * 2.0 * pi / fs) * data(idx));
% 	im = im + (cos(f * (n-1) * 2.0 * pi / fs) * data(idx));
% end

re = re / term;
im = im / term;

amp = 2 * abs(complex(re, im));
phi = angle(complex(re, im));

	
	