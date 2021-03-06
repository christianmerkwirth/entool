%boxcount
%   boxcount is a fast algorithm that partitions a data set of points into
%   equally spaced and sized boxes. The algorithm is based on Robert
%   Sedgewick's Ternary Search Trees which offer a fast and efficient way
%   to create and search a multidimensional histogram. Empty boxes require
%   no storage space, therefore the maximum number of boxes (and memory)
%   used can not exceed the number of points in the data set, regardless
%   of the data set's dimension and the number of partitions per axis.
%
%   During processing, data values are scaled to be within the range
%   [0,1]. All columns of the input matrix are scaled by the same factor,
%   so no skewing is introduced into the point set.
%
%   Syntax:
%
%     * [a,b,c] = boxcount(point_set, partitions)
%
%   Input arguments:
%
%     * pointset - a N by D double matrix containing the coordinates of
%       the point set, organized as N points of dimension D. D is limited
%       to 128.
%     * partitions - number of partitions per axis, limited to 16384. For
%       convenience, if partitions is a vector of length P, boxcount will iterate over all
%       entries of this vector.
%
%   Output arguments:
%
%     * a - matrix of size P by D with: -log2(sum(Number of nonempty boxes))
%       From the scaling behaviour of a D_0 can be
%       estimated
%     * b - matrix of size P by D with: sum_i(p_i * log2(p_i)) , where p_i is the
%       relative frequency of points falling into a box i
%       From the scaling behaviour of b D_1 can be estimated
%     * c - matrix of size P by D with: log2(sum_i(p_i*p_i)), where p_i is the relative
%       frequency of points falling into a box i
%       From the scaling behaviour of c D_2 can be
%       estimated
% 
% Outputs are computed as follows : The first column of the outputs a,b,c
% is computed for the first column of the input data set pointset. The
% second column of the outputs a,b,c is computed for the first and second
% columns (i.e. a two-dimensional) of the input data set pointset. The last
% column of the outputs a,b,c is computed for the all columns of pointset. 
% This allows to investigate the effect of increasing number of dimensions.
%
%   Example:
%
% p = rand(50000, 4);
% nr_partitions = unique(ceil(2.^(1:0.2:5)));
%
% [a,b,c] = boxcount(p, nr_partitions);
% semilogx(nr_partitions, a(:,end))
%
% Copyright 1997-2001 DPI Goettingen, License http://www.physik3.gwdg.de/tstool/gpl.txt
% Christian Merkwirth 2005

