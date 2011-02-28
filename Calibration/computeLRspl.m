function out = computeLRspl(ILD, ABI)
MAX_ATT = 120;

out = MAX_ATT * ones(2, length(ILD));

% compute the left and right levels
ILD = ILD ./ 2;

out(1, :) = ABI - ILD;
out(2, :) = ABI + ILD;
