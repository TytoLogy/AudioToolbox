function cout = calchancopy(cin, srcchan, tgtchan)

fnames = {	'mag', ...
				 'phase', ...
				 'dist', ...
				 'mag_stderr', ...
				 'phase_stderr', ...
				 'dist_stderr', ...
				 'leakmag', ...
				 'leakmag_stderr', ...
				 'leakphase', ...
				 'leakphase_stderr', ...
				 'leakdist', ...
				 'leakdist_stderr', ...
				 'leakdistphis', ...
				 'leakdistphis_stderr', ...
				 'phase_us', ...
				 'maginv'	};
			 
			 
nf = length(fnames);

% copy input cal struct to output
cout = cin;

% loop through fields
for f = 1:nf
	cout.(fnames{f})(tgtchan, :) = cin.(fnames{f})(srcchan, :);
end

cout.mindbspl(tgtchan) = cin.mindbspl(srcchan);
cout.maxdbspl(tgtchan) = cin.maxdbspl(srcchan);
