function value = get(model, param)

% function value = get(model, param)
%
% Assess properties of ridge object.
%
% Christian Merkwirth 2004

value = [];

switch(lower(param))
    case 'trainparams'
        value = model.trainparams;

        if isempty(value)
            value.singular_value_minimum = 0.01;   % cut off singular values below this threshold
        end
    case 'coefficients'
        value = model.coefficients;
    case 'mx'
        value = model.mx;
    case 'yloo'
        value = model.yloo;
    case 'lambda'
        value = model.lambda;
    case 'eps'
        value = model.eps;
    otherwise
        warning(['Parameter ' param ' is not element of class linear'])
end
