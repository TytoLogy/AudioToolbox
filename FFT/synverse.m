function [s, Sfull, sraw] = synverse(Smag, Sphase, varargin)
%-------------------------------------------------------------------------
% [s, Sfull, indx] = synverse(Smag, Sphase, varargin)
%-------------------------------------------------------------------------
% AudioToolbox:FFT
%-------------------------------------------------------------------------
%
% Given the magnitude (Smag) and phase (Sphase) FFT spectra, synverse
% constructs the full conjugate complex array Sfull and then takes the 
% ifft of Sfull to give s	
% 
% 	It is assumed that the magnitudes (Smag) have been properly scaled - if 
%  not, the 'auto' setting for the 'Scale' option can be used
%
%	If the imaginary portion of the the ifft is significantly large
%	(default is 1e-6, can be specified using the 'MaxImag' option), 
%	a warning message will be displayed.
%
%-------------------------------------------------------------------------
% Input Arguments:
% 	Smag		magnitude of signal spectrum
%	Sphase	phase of signal spectrum
%	
% 	Options: given as 'tag', <value> pair
%
% 	 'Scale'		<scale value -=OR- 'auto'>
% 		Default is to use the Smag values *as given* in order to build the
% 		full FFT vector.  
% 		If a different scale value is desired (e.g., # pts in stimulus 
% 		is not the same as 2 * length(Smag without DC component) ), give
%		it here.  
% 		'auto' will generate scaling based on length of Smag
% 		
%	 'DC', <'yes', 'no'>
%		By default, it is assumed that the Smag and Sphase arrays DO NOT
%		have the DC component at Smag(1) and Sphase(1).
%			This can be toggled using the 'DC' option:
%				..., 'DC', 'yes'			will indicate that DC component is included
%				..., 'DC', 'no'			(default) indicates no DC component
% 	
%	 'MaxImag', <max value for imaginary part of s>, default = 1e-6
%		
%-------------------------------------------------------------------------
% Output Arguments:
%	s			real output stimulus
% 	Sfull		complex, 2-sided (MATLAB) format spectrum, used for ifft
%
%-------------------------------------------------------------------------
% See Also: buildfft, fft, ifft, syn_headphonenoise, syn_headphonenoise_fft
%-------------------------------------------------------------------------

%---------------------------------------------------------------------
%	Sharad Shanbhag
%	sshanbhag@neomed.edu
%
%--Revision History---------------------------------------------------
%	7 Sep 2012 (SJS):	created
%	10 Sep 2012 (SJS):
% 	 -	added Scale option and associated code
% 	 - fixed issue with scaling
% 	 - added check for excessive imaginary parts of s output vector
%	12 Sep 2012 (SJS):
%	 - added check for peak imaginary part, changed s output to abs(s)
% 	 - added 'MaxImag' option to allow user to specify max imag value
%---------------------------------------------------------------------


%% set defaults
HAS_DC = 0;
SCALE_F = 1;
AUTOSCALE = 0;
MAX_IMAG = 1e-6;

%% check inputs

% length of Smag and Sphase the same?
if length(Smag) ~= length(Sphase)
	error('%s: lengthh mismatch of input vectors Smag, Sphase', mfilename);
end

% loop through # variable input args
nvararg = length(varargin);
if nvararg
	aindex = 1;
<<<<<<< HEAD
	while aindex < nvararg
=======
	while aindex <= nvararg
>>>>>>> origin/sjs_working
		switch(upper(varargin{aindex}))
			
			% set scaling factor SCALE_F
			case 'SCALE'
				if isnumeric(varargin{aindex+1})
					SCALE_F = varargin{aindex+1};
					aindex = aindex + 2;
				elseif strcmpi(varargin{aindex+1}, 'auto')
					AUTOSCALE = 1;
					aindex = aindex + 2;
				else
					error('%s: unknown setting %s for Scale value', ...
					mfilename, varargin{aindex+1});
				end
		
			% set HAS_DC option based on user input
			case 'DC'
				if strcmpi(varargin{aindex+1}, 'no')
					HAS_DC = 0;
				elseif strcmp(varargin{aindex+1}, 'yes')
					HAS_DC = 1;
				else
					error('%s: unknown setting %s for DC option', ...
									mfilename, varargin{aindex+1});
				end
				aindex = aindex + 2;
				
			% set max imag test value
			case 'MAXIMAG'
				if isnumeric(varargin{aindex+1})
					MAX_IMAG = abs(varargin{aindex+1});
					aindex = aindex + 2;
				else
					error('%s: unknown setting %s for MAX_IMAG value', ...
									mfilename, varargin{aindex+1});
				end
				
			% trap unknown input command
			otherwise
				error('%s: unknown argument %s', mfilename, varargin{aindex});
		end		% end of SWITCH
	end		% end of WHILE
end		% end of IF


%% deal with DC component

% if HAS_DC is set, the Smag vector has the DC value of the 
% signal at Smag(1), Sphase(1). 
if ~HAS_DC
	 % If not, prepend a 0 to start of Smag and Sphase	
	Smag = [0 Smag];
	Sphase = [0 Sphase];
end

% Nunique is # of unique (non-conjugate) points in the full spectrum, 
% including the DC component!
Nunique = length(Smag);
% NFFT is length of full spectrum (2 * size of spectrum w/o DC)
NFFT = 2*(Nunique - 1);

%% scale the magnitudes for conversion to full length spectrum

% if AUTOSCALE is set, use the length of Smag (minus 1) as scale factor
if AUTOSCALE
	SCALE_F = length(Smag) - 1;
end
% apply scaling by scale factor, divide non-DC components by two
Smag = SCALE_F * [Smag(1) Smag(2:end)./2];

%% build full FFT

% build complex spectrum
Scomplex = complex(Smag.*cos(Sphase), Smag.*sin(Sphase));

% assign indices into Sfull for the two "sections"
indx{1} = 1:Nunique;
% second portion
indx{2} = (Nunique+1):NFFT;

% assign to Sfull
Sfull = zeros(1, NFFT);
Sfull(indx{1}) = Scomplex;
% second section is computed as:
%	(1) take fftred(1:(end-1)), since final point (fftred(end)) 
% 		 is common to both sections
% 	(2) flip the fftred section around using fliplr (reverse order)
% 	(3) take complex conjugate of flipped fftred
Sfull(indx{2}) = conj(fliplr(Scomplex(2:(end-1))));

%% take ifft
s = ifft(Sfull);

%% check imaginary part
if max(abs(imag(s))) > MAX_IMAG
	warning('%s: Imaginary part of ifft (%f) is greater than limit (%f)', ...
				mfilename, max(abs(imag(s))), MAX_IMAG);
end

if nargout == 3
	sraw = s;
end

s = real(s);

		
