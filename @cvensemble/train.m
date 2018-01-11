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

if nargin > 6
    sampleweights = varargin{1};
else
    sampleweights = ones(nr_samples,1);
end  

% Compute reference error on all samples, but this does value is can not
% influence any further decisions

urbilder = urbilder(indtrain,:);
bilder = bilder(indtrain, :);

[nr_samples,nr_variables] = size(urbilder);

% Compute scale factors only on training data !
if trainparams.scaledata
    % Remember training data before we scale them
    model.urbilder = urbilder;
    model.bilder = bilder;
    [model.ensemble, urbilder, bilder] = compute_scalefactors(model.ensemble, urbilder, bilder);    
end


referr = epsinloss(bilder, ((bilder' * sampleweights(indtrain)) / sum(sampleweights(indtrain))) * ones(size(bilder)), eps, sampleweights(indtrain));


msampleclass = getsampleclass(bilder, trainparams.nr_cv_partitions*nr_model_classes, trainparams.frac_test, trainparams.correlated_testsamples);

counter = 1;

trainerrs = [];
testerrs = [];
fullerrs = [];
subspaces = {};


for i=1:trainparams.nr_cv_partitions  
    for j=1:nr_model_classes 
        [thismodeltrain,thismodeltest] = dissemble(msampleclass(:,counter), length(bilder));
        
        if entooldrawit
            disp(['Cross-validation training on train/test partition ' num2str(counter)])    
        end   
        
        modelclass = trainparams.modelclasses{j,1};
        mtrainparams = trainparams.modelclasses{j,2};
        minitparams = trainparams.modelclasses{j,3}; 
        
        m = feval(modelclass, minitparams{:});
        
        if isempty(mtrainparams)
            mtrainparams = get(m, 'trainparams');
        end
        
        try  
            if trainparams.use_subspaces 
                subspace = sort(randsel(1:nr_variables, ceil(sqrt(nr_variables))));
                m = train(m, full(urbilder(:,subspace)), bilder, msampleclass(:,counter), mtrainparams, eps, sampleweights(indtrain));
            else
                m = train(m, urbilder, bilder, msampleclass(:,counter), mtrainparams, eps, sampleweights(indtrain));
            end
        catch
            %keyboard
            disp(['An error occured while training ' modelclass ', model will be discarded']);
            disp(lasterr)
            m = [];
        end
        
        if ~isempty(m)
            if trainparams.use_subspaces     
                z = calc(m, urbilder(:,subspace));
            else
                z = calc(m, urbilder);
            end
            
            fullerr = epsinloss(bilder, z, eps, sampleweights(indtrain)) / referr;
            
            trainerr = epsinloss(bilder(thismodeltrain), z(thismodeltrain), eps, sampleweights(indtrain(thismodeltrain))) / referr;
            if length(thismodeltest)
                testerr = epsinloss(bilder(thismodeltest), z(thismodeltest), eps, sampleweights(indtrain(thismodeltest))) / referr;    
            else
                testerr = NaN;
            end
            
            if trainparams.use_subspaces 
                model.ensemble = addmodel(model.ensemble, m, 1.0, fullerr, subspace);
            else
                model.ensemble = addmodel(model.ensemble, m, 1.0, fullerr);
            end
            
            model.sampleclasses = [model.sampleclasses msampleclass(:,counter)];
            
            if entooldrawit
                disp(['Trained ' modelclass ' model  with train err/test err/total err ' ...
                        num2str([trainerr testerr fullerr])])  
            end
            
            trainerrs(end+1,1) = trainerr;
            testerrs(end+1,1) = testerr;
            fullerrs(end+1,1) = fullerr;               
        end
        
        counter = counter + 1;
    end
end

if entooldrawit
    disp(['Trained ' num2str(length(fullerrs)) ' models  with average train err/test err/total err ' ...
            num2str(mean([trainerrs testerrs fullerrs]))])  
end

if ~trainparams.scaledata
    % Now remember training data
    model.urbilder = urbilder;
    model.bilder = bilder;
    clear urbilder bilder
end    
    
model = set(model, 'eps', eps);
model = set(model, 'trainparams', trainparams);

