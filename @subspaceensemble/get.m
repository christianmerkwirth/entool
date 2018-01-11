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
            value.nr_models = 32;
            value.scaledata = 1;
            
            value.accept_thresh = 0.75;	% don't accept model if its relative error is more than that
            value.remove_worst = 0.50;		% fraction of models to be removed according to error on data set   
            
            % Which model type should be used for the single models 
            vtp = get(vicinal2, 'trainparams');
            value.modelclasses = {'vicinal2', vtp, {}};
        end
    otherwise
        value = get(model.ensemble, param);
        %warning(['Parameter ' param ' is not element of class ensemble'])
end

