function model=subspaceensemble(varargin)

% function model=subspaceensemble(varargin)
%
% Christian Merkwirth 2002

ens = ensemble(varargin{:});

model.dummy = [];
model = class(model, 'subspaceensemble', ens);


