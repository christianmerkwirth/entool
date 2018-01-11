function r = triangle_rand(n,m)

% function r = triangle_rand(n,m)
%
% Generate random numbers with triangle shaped distribution within 
% range [-1 1].
%
% Example:
%
% hist(triangle_rand(25000,1), 49)
%
% Christian Merkwirth 2002

r = rand(n,m) + rand(n, m) - 1;
