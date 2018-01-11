%range_search
%
%   Fast range search based on the ATRIA algorithm as described in:
%   C. Merkwirth, U. Parlitz, Werner Lauterborn, Fast Nearest Neighbor Searching for Nonlinear Signal Processing, Phys. Rev. E 62(2), 2089-2097 (2000)
%
%
%   Syntax:
%
%     * [count, neighbors] = range_search(pointset, atria, query_points, r)
%     * [count, neighbors] = range_search(pointset, atria, query_indices, r, exclude)
%
%   Input arguments:
%
%     * pointset - a N by D double matrix containing the coordinates of
%       the point set, organized as N points of dimension D
%     * atria - output of (cf. Section )nn_prepare for pointset
%     * query_points - a R by D double matrix containing the coordinates
%       of the query points, organized as R points of dimension D
%     * query_indices - query points are taken out of the pointset,
%       query_indices is a vector of length R which contains the indices
%       of the query points
%     * r - range or search radius (r > 0). It is possible to give either a
%           single range which will then be used for all reference points
%           or a vector of range values with specific ranges for every reference point 
%     * exclude - in case the query points are taken out of the pointset,
%       exclude specifies a range of indices which are omitted from
%       search. For example if the index of the query point is 124 and
%       exclude is set to 3, points with indices 121 to 127 are omitted
%       from search. Using exclude = 0 means: exclude self-matches
%
%   Output arguments:
%
%     * count - a vector of length R contains the number of points within
%       distance r to the corresponding query point
%     * neighbors - a Matlab cell structure of size R by 2 which contains
%       vectors of indices and vectors of distances to the neighbors for
%       each given query point. This output argument can not be stored in
%       a standard Matlab matrix because the number of neighbors within
%       distance r will most probably not be the same for all query points. The vectors of
%       indices and distances for one query point have exactly the length
%       that is given in count. Neighbors are not sorted by distance!
%
% See also : nn_prepare nn_search
%
% Example:
%
%pointset = rand(10000, 3);     % create a 3-dimensional data set
%atria = nn_prepare(pointset, 'euclidian'); % do the ATRIA preprocessing using Euclidian norm, strore results in structure atria for later use
%[count, neighbors] = range_search(pointset, atria, [13 1692 1695 2101 2342]', 0.1, 0)       % search up to radius of 0.1
%[count, neighbors] = range_search(pointset, atria, [13 1692 1695 2101 2342]', [0.1:0.1:0.5], 0) % search with individual radius for each query point
%
% Copyright 1997-2001 DPI Goettingen, License http://www.physik3.gwdg.de/tstool/gpl.txt
% 2005 ZTI Krakow

