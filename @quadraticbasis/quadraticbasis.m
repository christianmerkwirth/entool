function model=quadraticbasis(varargin)

% function model=quadraticbasis(varargin)
%
% Simple quadratic basis expansion class,
% allows to try any kind of model on the expanded
% input variables.
%
% Christian Merkwirth 2004

ens = ensemble(varargin{:});

model.dummy = [];
model = class(model, 'quadraticbasis', ens);


