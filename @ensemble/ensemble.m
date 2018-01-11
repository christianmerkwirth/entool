function model=ensemble(varargin)

% function model=ensemble(varargin)
%
% Christian Merkwirth 2002
%
% Joerg Wichard 2004-2005

if nargin == 0
    model.models = {};
    model.errors = [];
    model.weights = [];
    model.summing = 0;		%	0 => average models, sum(weights) == 1; 1 => add model output !
    model.subspaces = {};
    model.trainparams = [];
    model.eps = 0.0;
    model.uscalefacs = [];
    model.bscalefac = [];
    model.optional = {};
    model.robust = 0;           % use weighted median instread of weighted average

    model = class(model, 'ensemble');
elseif isa(varargin{1},'ensemble')
    %% return the ensemle object

    model = varargin{1};
end
