function value = get(model, param)

% function value = get(model, param)
%
% Access properties of cvensemble object.
%
% Christian Merkwirth 2002

value = [];

switch(lower(param))
    case 'trainparams'
        value = get(model.ensemble, 'trainparams');
        
        if isempty(value)
            value.nr_cv_partitions = 10;
            value.frac_test = 0.20;
            value.use_subspaces = 0;
            value.modelclasses = {'vicinal2', [], {}; };
            value.scaledata = 1;        % set to zero to turn all intern scaling off!
            value.correlated_testsamples = 0;
        end
    case 'sampleclasses'
        value = model.sampleclasses;
    otherwise
        value = get(model.ensemble, param);
        %warning(['Parameter ' param ' is not element of class ' class(model)])
end

