function y = insert_delay(a, delay, fs)
% y = insert_delay(a, delay, fs)
%	inserts delay time delay (msec) into signal a 
%	fs = sample rate
%
%	Sharad J. Shanbhag

y = [zeros(1, ceil(fs * delay / 1000)) a];

