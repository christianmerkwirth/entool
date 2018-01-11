function value = get(model, param)

% function value = get(model, param)
%
% Access properties of object.
%
% Christian Merkwirth 2002

value = [];

switch(lower(param))
    case 'trainparams'
        value = get(model.ensemble, 'trainparams');
        
        if isempty(value)
            value.scaledata = 0;
            value.modelclasses = {'ridge', [], {0:0.5:20}};
        end
    otherwise
        value = get(model.ensemble, param);
        %warning(['Parameter ' param ' is not element of class ensemble'])
end

