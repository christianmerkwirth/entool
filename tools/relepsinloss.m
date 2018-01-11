function e = relepsinloss(des, is, eps, varargin)

% function relepsinloss(des, is, eps, weights)
%
% Relative eps-insensitive squared loss compared to eps-insensitve variance
% of the desired (first input argument).
%
% Christian Merkwirth

if nargin < 3
    eps = 0.0;
end

N = length(des);

if nargin < 4
    desmean = sum(des)/N;
else
    weights = varargin{1};
    weights = weights(:)/sum(weights);
    desmean = weights' * des(:);
end

rel = epsinloss(des, ones(N,1) * desmean, eps, varargin{:});
err = epsinloss(des, is, eps, varargin{:});

if rel > 0
    e = err/rel;
else
    if N > 1
        warning('Desired values show zero variance, cannot compute relative loss');
    end
    e = err;
end


