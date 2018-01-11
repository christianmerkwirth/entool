function ind = select_fit_prop(fitnesses)

% function ind = select_fit_prop(fitnesses)
%
% Select fitnessproportional, returning index into fitnesses
%
% Christian Merkwirth 2002

cs = cumsum([0; fitnesses(:)]);
r = cs(end) * rand;
ind = find((r > cs(1:(end-1))) & (r < cs(2:end)));

if isempty(ind)
    ind = 1;
end

