function model = normweights(model)

% function model = normweights(model)
%
% Normalize weights to one.
%
% Christian Merkwirth 2002

if ~isempty(model.weights)
   weights = weights / sum(weights);
end