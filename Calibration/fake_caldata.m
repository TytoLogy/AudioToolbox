function caldata  = fake_caldata(varargin)
% caldata  = fake_caldata(varargin)
%
% Creates a fake caldata structure with flat response
% 
% Input Arguments:
%
% Returned arguments:
%
% See Also: load_headphone_cal
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
% Sharad J. Shanbhag
% sshanbha@aecom.yu.edu
%--------------------------------------------------------------------------
% Created: 12 June, 2009
% 
% Revision History:
%--------------------------------------------------------------------------

minfreq = 20;
maxfreq = 20000;
freqstep = 100;

freqs = (minfreq:freqstep:maxfreq);
nfreqs = length(freqs);

onearray = ones(2, nfreqs);
zeroarray = zeros(2, nfreqs);

caldata.time_str = [date ' ' time];
caldata.timestamp = now;
caldata.adFc =  4.8828e+004;
caldata.daFc =  4.8828e+004;
caldata.nrasters = nfreqs;
caldata.range = [minfreq freqstep maxfreq];
caldata.reps = 2;
caldata.settings = [];
caldata.frdata = [];
caldata.atten = [];
caldata.max_spl = 50;
caldata.min_spl = 40;
caldata.frfile = [];
caldata.freq = freqs;
caldata.mag =  onearray;
caldata.phase =  zeroarray;
caldata.dist =  zeroarray;
caldata.mag_stderr =  zeroarray;
caldata.phase_stderr =  zeroarray;
caldata.DAscale = 5;
caldata.dist_stderr =  zeroarray;
caldata.leakmag =  zeroarray;
caldata.leakmag_stderr =  zeroarray;
caldata.leakphase =  zeroarray;
caldata.leakphase_stderr =  zeroarray;
caldata.leakdist =  zeroarray;
caldata.leakdist_stderr =  zeroarray;
caldata.leakdistphis =  zeroarray;
caldata.leakdistphis_stderr =  zeroarray;
caldata.magsraw = [];
caldata.magsdbug = [];
caldata.phisdbug = [];
caldata.maginv = onearray;
caldata.phase_us = caldata.phase;
% preconvert phases from angle (RADIANS) to microsecond
caldata.phase_us(1, :) = (1.0e6 * unwrap(caldata.phase(1, :))) ./ (2 * pi * caldata.freq);
caldata.phase_us(2, :) = (1.0e6 * unwrap(caldata.phase(2, :))) ./ (2 * pi * caldata.freq);

caldata.mindbspl = [80 80];
caldata.maxdbspl = [100 100];

