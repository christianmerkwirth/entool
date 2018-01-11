function [hd, ind1, ind2] = hausdorff_distance(x1, x2, metric)

% function [hd, ind1, ind2] = hausdorff_distance(x1, x2, metric)
%
% Compute hausdorff distance between two points sets x1 and x2 (must be of
% same dimension D, but not of same number of points). 
%
% Output arguments are:
%
% hd - value of the hausdorff distance
% ind1 - index of the point out of data set x1 which is closest to x2
% ind2 - index of the point out of data set x2 which is closest to x1
%
% Optional input argument metric may be chosen out of 'eucl' (L2), 'man' (L1), 'max' (Linf)
%
% Christian Merkwirth 2004

if nargin < 2
    error('At least two points sets must be given as input arguments');    
end

if nargin < 3
    metric = 'eucl';
end

[N1, D1] = size(x1);
[N2, D2] = size(x2);

if D1 ~= D2
    error('Dimension of point set 1 and point set 2 differ')    
end

atria = nn_prepare(x1, metric);
[nn,d] = nn_search(x1, atria, x2, 1); 
[hd, ind2] = min(d);
ind1 = nn(ind2);


