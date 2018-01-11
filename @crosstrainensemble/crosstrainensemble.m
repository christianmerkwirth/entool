function model=crosstrainensemble(varargin)

% function model=crosstrainensemble(varargin)
%
% Christian Merkwirth 2002

ens = ensemble(varargin{:});

model.dummy = [];
model = class(model, 'crosstrainensemble', ens);


