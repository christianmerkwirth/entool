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

nr_samples = length(bilder);
nr_model_classes = size(trainparams.modelclasses,1);
[indtrain, indtest] = dissemble(sampleclass, nr_samples);

urbilder = urbilder(indtrain,:);
bilder = bilder(indtrain);

% Compute scale factors only on training data !
if trainparams.scaledata
    [model.ensemble, urbilder, bilder] = compute_scalefactors(model.ensemble, urbilder, bilder);    
end

msampleclass = getsampleclass(bilder, trainparams.nr_cv_partitions, trainparams.frac_test, trainparams.correlated_testsamples);

referr = epsinloss(bilder, mean(bilder) * ones(size(bilder)), eps);

%imagesc(msampleclass); colorbar; pause

modelmatrix = {};
trainerrs = {};
testerrs = {};
fullerrs  = {};
outputmatrix = {};

models = {};
merrs = [];
output  = {};

for i=1:trainparams.nr_cv_partitions  
    [thismodeltrain,thismodeltest] = dissemble(msampleclass(:,i), length(bilder));
    
    thistrainerrs = [];
    thistesterrs = [];
    thisfullerrs = [];
    thisoutputs = [];
    thismodels = {};
    
    if entooldrawit
        disp(['Crosstraining on train/test partition ' num2str(i)])    
    end   
    
    for j=1:nr_model_classes 	   	
        modelclass = trainparams.modelclasses{j,1};
        mtrainparams = trainparams.modelclasses{j,2};
        minitparams = trainparams.modelclasses{j,3}; 
        
        m = feval(modelclass, minitparams{:});
        
        if isempty(mtrainparams)
            mtrainparams = get(m, 'trainparams');
        end
        
        try  
            m = train(m, urbilder, bilder, msampleclass(:,i), mtrainparams, eps);
        catch
            disp(['An error occured while training ' modelclass ', model will be discarded']);
            disp(lasterr)
            m = [];
        end
        
        if ~isempty(m)
            if trainparams.use_loo_for_vicinal & isa(m, 'vicinal')  
                % Treat vicinal models somewhat different than the other model types,
                % since it is possible to get from vicinal models the leave-one-out
                % crossvalidation error without the effort of retraining the model
                
                m = extend(m, urbilder, bilder);	% first we extend the model's data set to 
                % train and test set !
                y = calc(m, []);						% but here we derive the loo error on training and test!
                if same_model(y, output)
                    m = set(m, 'k', get(m, 'k')+1);	% Increase number of nearest neighbors 
                    y = calc(m, []);
                    if same_model(y, output)
                        m = [];	   
                    end   
                end   
            else
                y = calc(m, urbilder);		% calculate output of model on train+test set
            end   
        end
        
        
        if ~isempty(m)         
            trainerr = epsinloss(bilder(thismodeltrain), y(thismodeltrain), eps)/referr;
            
            % if there are not enough test samples, estimating the test error is to 
            % dangerous, we use instead the error on the full data set
            if length(thismodeltest) > trainparams.minimum_testsamples
                testerr = epsinloss(bilder(thismodeltest), y(thismodeltest), eps)/referr;
            else
                testerr = epsinloss(bilder, y, eps)/referr;
            end   
            
            fullerr = epsinloss(bilder, y, eps)/referr;
            
            if fullerr < trainparams.accept_thresh	% only accept models that are better than this
                thistrainerrs(end+1,1) = trainerr;
                thistesterrs(end+1,1) = testerr;
                thisfullerrs(end+1,1) = fullerr;
                
                thisoutputs(:,end+1) = y;
                thismodels{end+1} = m;
                
                if entooldrawit
                    disp(['Trained ' modelclass ' model with trainerr/testerr/total err ' ...
                            num2str([trainerr testerr fullerr])])   
                end
            end   
        end   
    end
    
    if isempty(thismodels)
        % if no model was succesfully trained, create naive predictor that output mean of data set
        m = baseline;
        m = train(m, urbilder, bilder, msampleclass(:,i), [], eps);
        y = calc(m, urbilder);		% calculate output of model on train+test set
        
        thistrainerrs = epsinloss(bilder(thismodeltrain), y(thismodeltrain), eps);
        thistesterrs = epsinloss(bilder(thismodeltest), y(thismodeltest), eps);
        thisfullerrs = relepsinloss(bilder, y, eps);
        
        thisoutputs = y;
        thismodels = {m};	
    end
    
    trainerrs{1,i} = thistrainerrs;
    testerrs{1,i} = thistesterrs;
    fullerrs{1,i} = thisfullerrs;
    
    outputmatrix{1,i} = thisoutputs;
    modelmatrix{1,i} = thismodels;   
end

model = set(model, 'eps', eps);
model = set(model, 'trainparams', trainparams);

% First stage of model selection: Select from models which were trained on the
% same train/test partition. Select by test error.

models = {};
merrs = [];
outputs = [];
modelweights = {};

for i=1:trainparams.nr_cv_partitions
    [thismodeltrain,thismodeltest] = dissemble(msampleclass(:,i), length(bilder));
    
    thistesterrs = testerrs{i};
    thismodels = modelmatrix{i};    
    thisoutputs = outputmatrix{i};
    
    % Remove worst models
    
    [dummy,ind] = sort(-thistesterrs);
    ind = ind(1:floor(length(thistesterrs)*trainparams.remove_worst));
    
    thistesterrs(ind) = [];
    thismodels(ind) = [];
    thisoutputs(:,ind) = [];	   
    
    [modeltrain,modeltest] = dissemble(msampleclass(:,i), length(bilder));
    
    if trainparams.weight_models
        %w = optimal_weights(bilder(modeltest), thisoutputs(modeltest,:), eps, 0.0, 0.8);
        w = optimal_weights(bilder, thisoutputs, eps, 0.0, 0.8);
        
        outputs(:,i) = thisoutputs*w;      
        merrs(1,i) = relepsinloss(bilder, outputs(:,i), eps);
        ind = find(w);
        modelweights{1,i} = w(ind);
        models{1,i} = thismodels(ind);
    else   
        [indselected, newfullerr] = select_by_testset(bilder, thistesterrs, modeltrain, modeltest, ... 
            thisoutputs, trainparams, eps);
        
        models{1,i} = thismodels(indselected);
        merrs(1,i) = newfullerr;	
        outputs(:,i) = mean(thisoutputs(:,indselected),2); 
    end
end   

% Second stage of model selection: Select from models or clusters of models which were trained 
% different train/test partitions

% Remove worst models
[dummy,ind] = sort(-merrs);
ind = ind(1:floor(length(merrs)*trainparams.remove_worst));

models(ind) = [];
if ~isempty(modelweights)
    modelweights(ind) = [];
end   
merrs(ind) = [];
outputs(:,ind) = [];

% Now select models for the final ensemble

nr_models_to_use = ceil(length(models)*trainparams.use_models);

if trainparams.weight_models
    w = optimal_weights(bilder, outputs, eps, 0.0, 0.8); 
    
    ind = find(w(:))'; 
    for i=ind
        thismodels = models{i};
        thisweights = modelweights{i};
        
        for j=1:length(thismodels)
            model.ensemble = addmodel(model.ensemble, thismodels{j}, w(i) * thisweights(j), merrs(i));
        end
    end
else
    counter = 0;
    
    try
        while((length(models) > 0) & (counter < nr_models_to_use))
            fitnesses = -log(merrs+tiny);
            ind = select_fit_prop(fitnesses);
            
            model.ensemble = addmodel(model.ensemble, models{ind}, 1.0,  merrs(ind));
            
            counter = counter + 1;
            
            models(ind) = [];
            merrs(ind) = [];
        end
    catch
        %keyboard
    end
end

return % end of main function



function flag = same_model(y, output)

flag = 0;

for l=1:length(output)
    if epsinloss(output{l}, y, 0.0) <= 0.0001    
        flag = 1;
        break;
    end   
end 


function [indselected, fullerr] = select_by_testset(bilder, testerrs, modeltrain, modeltest, ...
    outputs, trainparams, eps)

% Select models that were trained on the same train/test partition acording to test error,
% use a greedy heuristic to minimize the test error by combination of different models to
% a cluster

if length(modeltest) < trainparams.minimum_testsamples
    modeltest = unique([modeltrain(:); modeltest(:)]);   
end   

Nmodels = length(testerrs);
nr_max = ceil(Nmodels*trainparams.use_models);

err = inf;	
indavailable = 1:Nmodels;
indselected = [];

while((length(indavailable)>0) & (length(indselected) < nr_max))
    newerrs = [];
    
    for ind=indavailable
        newerrs(end+1) = relepsinloss(bilder(modeltest), mean(outputs(modeltest, [indselected ind]), 2), eps);   
    end
    
    [newerr,ind] = min(newerrs);
    
    if (newerr < (1-trainparams.minimum_improvement) * err) 
        err = newerr;
        indselected = [indselected indavailable(ind)];  
        indavailable(ind) = [];
    else
        break;
    end   
end   

fullerr = relepsinloss(bilder, mean(outputs(:,indselected),2), eps);




