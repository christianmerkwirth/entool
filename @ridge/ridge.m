function model=ridge(varargin)

% function model=ridge(lambda, svdcutoff)
%
% Constructor for a ridge regression linear model.
%
% No topological parameters necessary. 
%
% Christian Merkwirth 2003

model.lambda = 0.0;
model.svdcutoff = 1e-9;

if nargin >= 1
    model.lambda = varargin{1};    
end
if nargin >= 2
    model.svdcutoff = varargin{2}; 
end

model.mx = [];
model.coefficients = [];
model.trainparams = {};		
model.eps = 0.0;
model.yloo = [];    % Remember Leave-One-Out output for the training data set


model = class(model, 'ridge');


