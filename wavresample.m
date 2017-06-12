function [S_new, varargout] = wavresample(wavfilename, Fs_new, varargin)
%--------------------------------------------------------------------------
% [S_new, t_new, Fs_orig, t_orig, S_orig] = 
%									wavresample(wavfilename, Fs_new, varargin)
%--------------------------------------------------------------------------
% opto program
%--------------------------------------------------------------------------
% 
% Generates stimulus cache 
% 
%--------------------------------------------------------------------------
% Input Arguments:
% 	wavfilename		path and name of wav file
%	Fs_new			desired sample rate
%
% Optional:
% 	Interpolation method:
% 			'linear', 'pchip', or 'spline' (see interp1 for details)
% 		default is 'pchip'
% 
% Output Arguments:
%	S_new				resampled wav data
% 	t_new				time points for resampled wav data
% 	Fs_orig			original sample rate
% 	t_orig			time points for original wav data
% 	S_orig			original wav data
%--------------------------------------------------------------------------
% See Also: resample, interp1, audioread
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
% Sharad J. Shanbhag
% sshanbhag@neomed.edu
%--------------------------------------------------------------------------
% Revision History
%	6 September, 2016 (SJS): function created
%--------------------------------------------------------------------------


if ~exist(wavfilename, 'file')
	error('%s: wav file %s not found!', mfilename, wavfilename);
end
if nargin < 2
	error('%s: need 2 input args, wav file and new sample rate');
end
if ~isempty(varargin)
	method = varargin{1};
else
	method = 'pchip';
end

[S_orig, Fs_orig] = audioread(wavfilename);

% build time base for orig data
t_orig = (0:(length(S_orig) - 1)) * (1/Fs_orig);
% resample original data
[S_new, t_new] = resample(S_orig, t_orig, Fs_new, method);

if nargout >= 2
	varargout{1} = t_new;
end

if nargout >= 3
	varargout{2} = Fs_orig;
end

if nargout >= 4
	varargout{3} = t_orig;
end

if nargout == 5
	varargout{4} = S_orig;
end
	

