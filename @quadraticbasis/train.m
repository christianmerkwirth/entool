function [model, trainerr] = train(model, urbilder, bilder, sampleclass, trainparams, eps, varargin)

% function [model, trainerr] = train(model, urbilder, bilder, sampleclass, trainparams, eps, varargin)
%
%
% Christian Merkwirth 2002

global entooldrawit

tiny = 1e-10;

if isempty(trainparams)
    trainparams = get(model, 'trainparams');
end

[nr_samples,nr_variables] = size(urbilder);
[indtrain, indtest] = dissemble(sampleclass, nr_samples);

urbildertrain = urbilder(indtrain,:);
bildertrain = bilder(indtrain);
nr_train = length(bildertrain);

% Compute scale factors only on training data !
if trainparams.scaledata
    [model.ensemble, urbildertrain, bildertrain] = compute_scalefactors(model.ensemble, urbildertrain, bildertrain);    
end

nr_model_classes = size(trainparams.modelclasses,1);

models = {};
merrs = [];

counter = 1;

for j=1:size(trainparams.modelclasses,1)
    modelclass = trainparams.modelclasses{j,1};
    mtrainparams = trainparams.modelclasses{j,2};
    minitparams = trainparams.modelclasses{j,3}; 
    
    m = feval(modelclass, minitparams{:});
    
    if isempty(mtrainparams)
        mtrainparams = get(m, 'trainparams');
    end
    
    m = train(m, qbasisexpand(urbildertrain), bildertrain, [], mtrainparams, eps);
    
    if isa(m, 'vicinal') | isa(m, 'vicinalclass')
        y = calc(m, []);
    else
        y = calc(m, qbasisexpand(urbildertrain));
    end
    
    % Calculate error on full training set   
    err = relepsinloss(bildertrain, y, eps);
    
    if entooldrawit   
        disp(['Error of ' class(m) ' model  ' num2str(counter) ' on training set : ' num2str(err)]);     
    end   
    
    models{end+1} = m;
    merrs(1,end+1) = err;	
    
    counter = counter + 1;
    
end

for i=1:length(models)
    model.ensemble = addmodel(model.ensemble, models{i}, 1.0, merrs(i));	  	% -log(merrs(i)+tiny)
end

model = set(model, 'eps', eps);
model = set(model, 'trainparams', trainparams);

