function [nn, d, querypoints] = calcnn(atria, urbilder, approximate)

% function [nn, d, querypoints] = calcnn(atria, urbilder, approximate)
%
% Christian Merkwirth 2002

if nargin < 3
    approximate = 0.0;
end

if isempty(urbilder)
   querypoints = atria.dataset;   
   [nn,d] = nn_search(atria.dataset, atria.searcher, (1:size(atria.dataset, 1))', atria.k, atria.trainparams.exclude, approximate, 'ref');
else
    querypoints = urbilder .* (ones(size(urbilder,1),1) * atria.metric);
	[nn,d] = nn_search(atria.dataset, atria.searcher, querypoints, atria.k, approximate, 'coordinates'); 
end
