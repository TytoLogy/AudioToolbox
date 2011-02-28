function out = ABI2LRDB(ILD, ABI)
MAX_ATT = 120;

out = MAX_ATT * [1 1];

% compute the left and right levels
out(1) = out.ABI - out.IID / 2;
		out.RDB = out.ABI + out.IID / 2;
		
		if ~between(out.LDB, out.RDBmin, out.RDBmax)
			disp('ABI2LRDB: LDB out of bounds');
			out.LDB = 0;
		end
		if ~between(out.RDB, out.RDBmin, out.RDBmax)
			disp('ABI2LRDB: RDB out of bounds');
			out.RDB = 0;
		end
	end

