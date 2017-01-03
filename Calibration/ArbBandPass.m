function [ht, htrot, htwin] = ArbBandPass(N, freqs)
% from: http://stackoverflow.com/questions/3827346/any-rules-of-thumb-how-to-smooth-fft-spectrum-to-prevent-artifacts-when-hand-twe
%# N = desired filter length
%# freqs = array of frequencies, normalized by pi, to turn into passbands
%# returns raw, rotated, and rotated+windowed coeffs in time domain

if any(freqs >= 1) || any(freqs <= 0)
    error('0 < passband frequency < 1.0 required to fit within (DC,pi)')
end

hf = zeros(N,1); %# magnitude spectrum from DC to 2*pi is intialized to 0
%# In Matlabs FFT, idx 1 -> DC, idx 2 -> bin 1, idx N/2 -> Fs/2 - 1, idx N/2 + 1 -> Fs/2, idx N -> bin -1
idxs = round(freqs * N/2)+1; %# indeces of passband freqs between DC and pi
hf(idxs) = 1; %# set desired positive frequencies to 1
hf(N - (idxs-2)) = 1; %# make sure 2-sided spectrum is symmetric, guarantees real filter coeffs in time domain
ht = ifft(hf); %# this will have a small imaginary part due to numerical error
if any(abs(imag(ht)) > 2*eps(max(abs(real(ht)))))
    warning('Imaginary part of time domain signal surprisingly large - is the spectrum symmetric?')
end
ht = real(ht); %# discard tiny imag part from numerical error
htrot = [ht((N/2 + 1):end) ; ht(1:(N/2))]; %# circularly rotate time domain block by N/2 points
win = hann(N, 'periodic'); %# might want to use a window with a flatter mainlobe
htwin = htrot .* win;
htwin = htwin .* (N/sum(win)); %# normalize peak amplitude by compensating for width of window lineshape