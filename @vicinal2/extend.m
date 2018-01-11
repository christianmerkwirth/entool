function model = extend(model, urbilder, bilder)

% function model = extend(model, urbilder, bilder)
% Extend the training set of the k-nearest-neigbor regressor
%
% The number of nearest-neighbors and the metric will not be adjusted!
% 
% Christian Merkwirth 2003

for i=1:length(model)
	metricclass = model(i).searcher.optional;
	x = urbilder .* repmat(model(i).metric, size(urbilder, 1), 1);
	atria = nn_prepare(x, metricclass);

	model(i).searcher = atria;
	model(i).dataset = x;
	model(i).images = bilder;
end