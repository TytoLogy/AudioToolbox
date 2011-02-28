function C = correct_crc(bc)
% function C = correct_crc(bc)
%
%	Returns correction factor C for binaural correlation value bc
%		-1 <= bc <= 1
%
%
% Sharad J. Shanbhag
% sharad@etho.caltech.edu
% 	Code adapted from synth library developed by
% 	Jamie Mazer and Ben Arthur
%-----------------------------------------------------------------------------
% Revision History
%	24 February, 2003 (SJS): file created
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


