function varargout = Tpad(ATTENdB, Z1, Z2)
%------------------------------------------------------------------
% [R1, R2, R3, K] = Tpad(ATTENdB, Z1, Z2)
%------------------------------------------------------------------
% 
% T-Pad attenuator calculator
% 
%------------------------------------------------------------------
%------------------------------------------------------------------
% T pad:
%                R1                R2
%       o-----/\/\/\/-----o-----/\/\/\/-----o
%                         |
%                         |
%                         \
%                         /
%                         \  R3						
%   Z1                    /                   Z2
%                         \
%                         |
%                         |
%       o-----------------o------------------o
%
%------------------------------------------------------------------
%------------------------------------------------------------------
%------------------------------------------------------------------
% Input Arguments:
%		ATTENdB		desired attenuation (in dB... use positive values!)
%		Z1				input impedance (ohms)
%		Z2				output impedance (ohms)
%
% Output Arguments:
% 		R1		resistor value
% 		R2		resistor value
% 		R3		resistor value
% 		K		attenuation ratio
%------------------------------------------------------------------
%------------------------------------------------------------------

%------------------------------------------------------------------------------
% Sharad J. Shanbhag
% sshanbhag@neomed.edu
%---------------------------------------------------------------------------
% Created: 18 December, 2014 (SJS)
%
% Revisions:
%---------------------------------------------------------------------------
% TO DO:
%------------------------------------------------------------------------------


if (nargin ~= 3) || any( [ischar(ATTENdB), ischar(Z1), ischar(Z2)] )
	help Tpad
	error('%s: need 3 numeric input values for Tpad calculation')
end

%------------------------------------------------------------------
%------------------------------------------------------------------
% calculate K ratio (convert db into a ratio)
%------------------------------------------------------------------
%------------------------------------------------------------------
if ATTENdB > 0
	K = power(10, ATTENdB / 20);
	% pre-calculate K^2 since it will be used in both cases
	Ksq = power(K, 2);
else
	error('%s: ATTENdB must be greater than or equal to 0!', mfilename);
end

%------------------------------------------------------------------
%------------------------------------------------------------------
% calculate for equal Z1 and Z2
%------------------------------------------------------------------
%------------------------------------------------------------------
if Z1 == Z2
	% when Z1 and Z2 are equal, R1 and R2 will be equal and the 
	% T-pad will be symmetric (reversible)
	R1 = Z1 * ( (K - 1) / (K + 1) );
	R2 = R1;
	R3 = 2 * Z1 * ( K / ( Ksq - 1) );
%------------------------------------------------------------------
%------------------------------------------------------------------
% calculate for unequal Z1 and Z2
%------------------------------------------------------------------
%------------------------------------------------------------------
elseif Z1 ~= Z2
	% calculate R3 first (calculations for R1 and R2 will use this value)
	R3 = 2 * sqrt(Z1 * Z2) * ( K / (Ksq - 1) );
	R1 = (Z1 * ( (Ksq + 1) / (Ksq -1) )) - R3;
	R2 = (Z2 * ( (Ksq + 1) / (Ksq -1) )) - R3;

%------------------------------------------------------------------
%------------------------------------------------------------------
% note that Z1 must be >= Z2! 
%------------------------------------------------------------------
%------------------------------------------------------------------
else
	fprintf('Although T pads are bidirectional, for calculations, \n');
	fprintf('impedance Z1 must be greater than or equal to impedance Z2!\n');
	error('%s: bad Z1 and Z2 values', mfilename);
end



fprintf('-----------------------------------------------------------------\n');
fprintf('-----------------------------------------------------------------\n');
fprintf('T pad:\n\n');
fprintf('                 R1                  R2\n');
fprintf('       o-----/\\/\\/\\/-----o-----/\\/\\/\\/-----o\n');
fprintf('                         | \n');
fprintf('                         | \n');
fprintf('                         \\ \n');
fprintf('                         / \n');
fprintf('                         \\  R3 \n');
fprintf('   Z1                    /                   Z2\n');
fprintf('                         \\ \n');
fprintf('                         | \n');
fprintf('                         | \n');
fprintf('       o-----------------o------------------o\n\n');
fprintf('-----------------------------------------------------\n');
fprintf('Calculated values for:\n')
fprintf('\tZ1 = %.2f\tOhms\n', Z1);
fprintf('\tZ2 = %.2f\tOhms\n', Z2);
fprintf('\tAtten = %.2f\tdB\t\t(ratio = %.2f)\n', ATTENdB, K);
fprintf('-----------------------------------------------------\n');
fprintf('\tR1 = %.2f\tOhms\n', R1);
fprintf('\tR2 = %.2f\tOhms\n', R2);
fprintf('\tR3 = %.2f\tOhms\n', R3);
fprintf('-----------------------------------------------------------------\n');
fprintf('-----------------------------------------------------------------\n');

%------------------------------------------------------------------
%------------------------------------------------------------------
% warning about negative values
%------------------------------------------------------------------
%------------------------------------------------------------------
if any( [R1 R2 R3] < 0 )
	fprintf('¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡ \n');
	fprintf('negative resistance values indicate Tpad specification\n');
	fprintf('that cannot be met using resistors alone\n');
	fprintf('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!\n');
	warning('%s: cannot meet specifications using resistors', mfilename);
end

if nargout
	varargout{1} = R1;	
end
if nargout > 1
	varargout{2} = R2;
end
if nargout > 2
	varargout{3} = R3;
end
if nargout == 4
	varargout = K;
end
