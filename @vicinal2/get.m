function value = get(model, param)

% function value = get(model, param)
%
% Assess properties of ensemble object.
%
% Christian Merkwirth 2002

value = [];

switch(lower(param))
    case 'k'
        value = model.k;
    case 'type'
        value = model.type;
    case 'metric'
        value = model.metric;
    case 'searcher'
        value = model.searcher;
    case 'dataset'
        value = model.dataset;
    case 'images'
        value = model.images;
    case 'trainparams'
        value = model.trainparams;
        
        if isempty(value)
            value.exclude = 0; 
            value.approximate = 0.0;    % value for approximate nearest-neighbor search to accelerate compuation
        end
    case 'eps'
        value = model.eps;
    otherwise
        warning(['Parameter ' param ' is not element of class vicinal'])
end
