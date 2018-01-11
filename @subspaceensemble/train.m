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


if nargin > 6
   sampleweights = varargin{1};
else
   sampleweights = ones(nr_samples,1);
end  

urbildertrain = urbilder(indtrain,:);
bildertrain = bilder(indtrain);
nr_train = length(bildertrain);

if trainparams.scaledata
    [model.ensemble, urbildertrain, bildertrain] = compute_scalefactors(model.ensemble, urbildertrain, bildertrain);    
end

nr_model_classes = size(trainparams.modelclasses,1);

models = {};
merrs = [];
subspaces = {};

round = 1;

while(length(models) < trainparams.nr_models)
    subspace = sort(randsel(1:nr_variables, ceil(sqrt(nr_variables))));
    
    % Randomly select modelclass
    j = randsel(1:size(trainparams.modelclasses,1));
    modelclass = trainparams.modelclasses{j,1};
    mtrainparams = trainparams.modelclasses{j,2};
    minitparams = trainparams.modelclasses{j,3}; 
    
    m = feval(modelclass, minitparams{:});
    
    if isempty(mtrainparams)
        mtrainparams = get(m, 'trainparams');
    end
    
    m = train(m, full(urbildertrain(:,subspace)), bildertrain, [], mtrainparams, eps, sampleweights(indtrain));
    
    if isa(m, 'vicinal') | isa(m, 'vicinalclass')  | isa(m, 'vicinal2') | isa(m, 'ridge')
        y = calc(m, []);
    else
        y = calc(m, full(urbildertrain(:,subspace)));
    end
    
    % Calculate error on full training set   
    err = relepsinloss(bildertrain, y, eps);
    
    if entooldrawit   
        disp(['Error of subspace model ' num2str(round) ' on training set : ' num2str(err)]); 
        %disp(subspace)
    end   
    
    if err < trainparams.accept_thresh
        models{end+1} = m;
        merrs(1,end+1) = err;	
        subspaces{end+1} = subspace;
    end   
    
    round = round + 1;
end

% Remove worst models
[dummy, indselected] = sort(merrs);
indselected = indselected(1:(end-floor(length(models)*trainparams.remove_worst))); 

for i=indselected
    model.ensemble = addmodel(model.ensemble, models{i}, 1.0, merrs(i), subspaces{i});	  	% -log(merrs(i)+tiny)
end

model = set(model, 'eps', eps);
model = set(model, 'trainparams', trainparams);
