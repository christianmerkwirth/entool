function h = hammings(x,y)

% function h = hammings(x,y)
% 
% Hamming distance for binary vectors of same length.
%
% Second argument can be sparse matrix containing several column vectors,
% in this case the first argument is compared with every column vector of
% the second argument.
%
% Christian Merkwirth 2002

h = sum(x) - (x')*y + ((~x)')*y;

