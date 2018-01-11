function x = descale(y,  scalefactors)

% x = descale(y, scalefactors)
% 
% Descales each column of y to original scaling.
%
% See scale
%
% Christian Merkwirth 2003

N = size(y, 1);
x = y .* repmat(scalefactors(2,:), N,1);
x = x  + repmat(scalefactors(1,:), N,1);
