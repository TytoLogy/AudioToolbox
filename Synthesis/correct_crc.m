function C = correct_crc(bc)
%-----------------------------------------------------------------------------
%C = correct_crc(bc)
%-----------------------------------------------------------------------------
% Audio Toolbox -> Synthesis
%-----------------------------------------------------------------------------
% Returns correction factor C for binaural correlation value bc
% -1 <= bc <= 1
%
% N.B. May or may not be working properly
%-----------------------------------------------------------------------------
% Input Arguments:
% 	bc		binaural correlation (-1 <= bc <= 1)
% 	
% Output Arguments:
% 	C		correction factor
%-----------------------------------------------------------------------------
% See also:
%-----------------------------------------------------------------------------

%-----------------------------------------------------------------------------
% Sharad J. Shanbhag
% sshanbhag@neoucom.edu
% 
% 	Code adapted from synth library developed by
% 	Jamie Mazer and Ben Arthur
%-----------------------------------------------------------------------------
% Created:	24 February, 2003 (SJS): file created
% Revision History:
%	28 Feb 2011 (SJS):	updated comments/information
%-----------------------------------------------------------------------------

if ((bc == 0) | (bc == 1) | (bc == -1))
	C = bc;
	return
end

C = abs(bc);

C = 1 / (1 + sqrt( 1 / C / C - 1));

if bc < 0
	C = -C;
end


