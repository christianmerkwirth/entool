%nn_search
%
%   Fast nearest neighbor search based on the ATRIA algorithm as described in:
%   C. Merkwirth, U. Parlitz, Werner Lauterborn, Fast Nearest Neighbor Searching for Nonlinear Signal Processing, Phys. Rev. E 62(2), 2089-2097 (2000)
%
%   Syntax:
%
%     * [index, distance] = nn_search(pointset, atria, query_points, k)
%     * [index, distance] = nn_search(pointset, atria, query_points, k,
%       epsilon)
%     * [index, distance] = nn_search(pointset, atria, query_points, k,
%       epsilon, 'coordinates')
%     * [index, distance] = nn_search(pointset, atria, query_indices, k,
%       exclude)
%     * [index, distance] = nn_search(pointset, atria, query_indices, k,
%       exclude, epsilon)
%     * [index, distance] = nn_search(pointset, atria, query_indices, k,
%       exclude, epsilon, , 'coordinates')
%
%
%   Input arguments:
%
%     * pointset - a N by D double matrix containing the coordinates of
%       the point set, organized as N points of dimension D
%     * atria - output of (cf. Section ) nn_prepare for pointset
%     * query_points - a R by D double matrix containing the coordinates
%       of the query points, organized as R points of dimension D
%     * query_indices - query points are taken out of the pointset,
%       query_indices is a vector of length R which contains the indices
%       of the query points (indices may vary from 1 to N)
%     * k - number of nearest neighbors to be determined
%     * epsilon - (optional) relative error for approximate nearest
%       neighbors queries, defaults to 0 (= exact search)
%     * exclude - in case the query points are taken out of the pointset,
%       exclude specifies a range of indices which are omitted from
%       search. For example if the index of the query point is 124 and
%       exclude is set to 3, points with indices 121 to 127 are omitted
%       from search. Using exclude = 0 means: exclude self-matches
%       If exclude is a array of size R by 2, it will be interpreted as individual
%        exclude ranges for each reference point
%
%    If 'coordinates' is given as additional argument, the third input argument
%    is interpreted to be the coordinates of the query points. This option was added
%    in order to manually override the automatic interpretation of this
%    argument which can lead in rare cases to unexpected behaviour.
%
%   Output arguments:
%
%     * index - a matrix of size R by k which contains the indices of the
%       nearest neighbors. Each row of index contains k indices of the
%       nearest neighbors to the corresponding query point.
%     * distance - a matrix of size R by k which contains the distances of
%       the nearest neighbors to the corresponding query points, sorted in
%       increasing order.
%
% See also : nn_prepare range_search
%
% Example:
%pointset = rand(10000, 3);
%atria = nn_prepare(pointset, 'max');
%[nn, distance] = nn_search(pointset, atria, (1:10)', 8, 0, 0.0);   % exact search for the first ten points of the point set 
%
% Copyright 1997-2001 DPI Goettingen, License http://www.physik3.gwdg.de/tstool/gpl.txt


