function foct = freq_to_8ve(fHz, basefreqHz, varargin)
%------------------------------------------------------------------------
% foct = freq_to_8ve(fHz, basefreqHz, 'round', <true/false>, 
%                                     'roundN', <round digit value>)
%------------------------------------------------------------------------
% TytoLogy:AudioToolbox
%------------------------------------------------------------------------
% converts frequencies in Hz, fHz, to octaves of basefreqHz, in Hz.
% 'round' option allows octave values to be rounded to precision 
% specified by 'roundN' option
%
% default is 'round' = true, 'roundn' = 2 (round foct to 2 decimal places)
%------------------------------------------------------------------------

%------------------------------------------------------------------------
%  Sharad Shanbhag
%   sshanbhag@neomed.edu
%------------------------------------------------------------------------
% Revisions:
%  17 Jun 2022 (SJS): Created in APANALYZE 
%  14 Dec 2023: added to AudioToolbox:Utils
%------------------------------------------------------------------------

% some defaults
roundValues = true;
roundN = 2;
% process input args
nv = length(varargin);
if nv > 0
   n = 1;
   while n <= nv
      switch upper(varargin{n})
         case 'ROUND'
            if varargin{n+1} == 0
               roundValues = false;
            elseif varargin{n+1} == 1;
               roundValues = true;
            else
               error('%s: invalid roundValues argument', mfilename);
            end
            n = n + 2;
         case 'ROUNDN'
            roundN = varargin{n+1};
            n = n + 2;
         otherwise
            error('%s: invalid option %s', mfilename, varargin{n});
      end
   end
end
% convert to octaves
if roundValues
   foct = round(log2(fHz ./ basefreqHz), roundN);
else
   foct = log2(fHz ./ basefreqHz);
end
