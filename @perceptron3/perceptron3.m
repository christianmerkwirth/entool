function model=mgnmulti3(varargin)

% Neural network class trained by iRPROP+ backpropagation.
%
% model = perceptron3;
% model = perceptron3(topology)
%
% Christian Merkwirth MPI 2004

model.nr_hidden_neurons = [8 4];
model.uscalefacs = [];
model.bscalefac = [];
model.net = {};
model.offset = 0;

if nargin>0
    model.nr_hidden_neurons = varargin{1};
end

model.trainparams = {};		
model.eps = 0.0;

model = class(model, 'perceptron3');


