%nn_prepare
%
%   Preprocessing for the fast nearest neighbor search based on the ATRIA algorithm as described in:
%   C. Merkwirth, U. Parlitz, Werner Lauterborn, Fast Nearest Neighbor Searching for Nonlinear Signal Processing, Phys. Rev. E 62(2), 2089-2097 (2000)
%
%
%
%   The intention of this mex-file was to reduce the computational
%   overhead of preprocessing for nearest neighbor or range searching.
%   With nn_prepare it is possible to do the preprocessing for a given
%   point set only once and save the created tree structure into a Matlab
%   variable. This Matlab variable, usually called atria, can then be used
%   for repeated neighbor searches on the same point set. Most mex-files
%   that rely on nearest neighbor or range search offer the possibility to
%   use this variable atria as optional input argument. However, if the
%   underlying point set is altered in any way, the proprocessing has to
%   be repeated for the new point set. If the preprocessing output does
%   not belong to the given point set, wrong results or program
%   termination may occur.
%
%   Syntax:
%
%     * atria = nn_prepare(pointset)
%     * atria = nn_prepare(pointset, metric)
%     * atria = nn_prepare(pointset, metric, clustersize)
%
%   Input arguments:
%
%     * pointset - a N by D double matrix containing the coordinates of
%       the point set, organized as N points of dimension D
%     * metric - (optional) either 'manhattan' (L_1), 'euclidian' (L_2), 'maximum' (L_infinity) or
%                'hamming', (default is 'euclidian')
%     * clustersize - (optional) threshold for clustering algorithm,
%       defaults to 64
%
% See also : nn_search range_search
%
% Example:
%
%pointset = rand(40000, 3);     % create a 3-dimensional data set with random coordinates
%atria = nn_prepare(pointset, 'max');   % do the ATRIA preprocessing using maximum norm, store result in structure atria for futher use
%[nn, distance] = nn_search(pointset, atria, (1:10)', 8, 0);  % perform an exact k-NN search for eight neighbors to each of the first 10 points of the data set 
%
% Copyright 1997-2001 DPI Goettingen, License http://www.physik3.gwdg.de/tstool/gpl.txt


