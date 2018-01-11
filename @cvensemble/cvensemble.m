function model=crosstrainensemble(varargin)

% function model=crosstrainensemble(varargin)
%
% Christian Merkwirth 2002

ens = ensemble(varargin{:});

model.urbilder = [];
model.bilder = [];
model.sampleclasses = [];

model = class(model, 'cvensemble', ens);


