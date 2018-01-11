function m = mad(x, dim)

% function m = mad(x, dim)
%
% Median absolute deviation. 
% Robust alternative for standard deviation.
%
% Optional input argument dim defaults to one.
%
% Christian Merkwirth MPI 2002

if nargin < 2
    dim = 1;
end

med = median(x, dim);

s = ones(1, ndims(x));
s(dim) = size(x, dim);

x = x - repmat(med, s);

m = median(abs(x), dim);
