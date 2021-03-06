function value = get(model, param)

% function value = get(model, param)
%
% Access properties of crosstrainensemble object.
%
% Christian Merkwirth 2002

value = [];

switch(lower(param))
    case 'trainparams'
        value = get(model.ensemble, 'trainparams');
        
        if isempty(value)
            value.nr_cv_partitions = 8;
            value.frac_test = 0.20;
            value.minimum_testsamples = 5;	% if there are less test samples than this number, use error on full data set 
            value.remove_worst = 0.33;		% remove this fraction of the models according to their error		
            value.use_models = 0.8;		% select models for final enesemble until this fraction is reached		
            value.weight_models = 0;		% 0 => don't weight models of final ensemble 
            value.use_loo_for_vicinal = 1;	% =1 => vicinal models are treated in a special way, using leave-one-out error
            value.minimum_improvement = 0.02;	% when selection models on the test set, at least this improvement should be achieved
            value.accept_thresh = 1.2;          % don't accept models with test error higher than this
            
            value.modelclasses = {  'perceptron3', [], {}; ... 
                                    'vicinal2', [], {};  ...
                                    'ridge', [], {0:20}; ...
                                    };	       
            
            value.scaledata = 1;        % set to zero to turn all intern scaling off!
            value.correlated_testsamples = 0;       % if this flag is set to one, test samples will not be randomly distributed
                                                    % in the data set,  instead they will be coherent blocks
                                        
            %value.modelclasses = [value.modelclasses; value.modelclasses];
        end
    otherwise
        value = get(model.ensemble, param);
        %warning(['Parameter ' param ' is not element of class ensemble'])
end

