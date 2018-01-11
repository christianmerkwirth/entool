function value = get(model, param)

% function value = get(model, param)
%
% Assess properties of ensemble object.
%
% Christian Merkwirth 2002

value = [];

switch(lower(param))
    case 'robust'
        value = model.robust;
    case 'models'
        value = model.models;
    case 'weights'
        value = model.weights;
    case 'errors'
        value = model.errors;
    case 'optional'
        value = model.optional;
    case 'uscalefacs'
        value = model.uscalefacs;
    case 'bscalefac'
        value = model.bscalefac;
    case 'trainparams'
        value = model.trainparams;
    case 'eps'
        value = model.eps;
    case 'summing'
        value = model.summing;
    case 'subspaces'
        value = model.subspaces;
    otherwise
        warning(['Parameter ' param ' is not element of class ensemble'])
end
