function [f, varargout] = octaves(octn, fstart, fend, base)

if base == 2
	factor = power(2, 1 / octn);
elseif base == 10
	factor = power(10, 3 / (10*octn));
else
	error('octaves: base must be either 2 or 10');
end


f(1) = fstart;

index = 2;
while f(index-1) < fend
	if  (f(index - 1) * factor) > fend
		break
	else
		f(index) = f(index - 1) * factor;
		index = index + 1;
	end
end

if nargout > 1
	varargout{1} = factor;
end
