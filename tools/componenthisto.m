function [components, count] = componenthisto(x)

% function [components, count] = componenthisto(x)
%
% Find all unique entries in input matrix x (should be integer)
% and count absolute frequencies for all entries (components).
%
% The unique components and the corresponding absolute frequencies 
% are returned as column vectors. 
%
%
% Christian Merkwirth MPI 2002

x = x(:);
N = length(x);


components = unique(x);
count = sparse(ones(N,1), x, ones(N,1));
count = full(count(components));
count = count(:);

