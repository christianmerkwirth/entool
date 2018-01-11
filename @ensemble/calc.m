function [y, yall]  = calc(model, urbilder)

% [y, yall] = calc(model, urbilder)
%
% Christian Merkwirth 2002

if (~isempty(urbilder)) & (~isempty(model.uscalefacs))
    urbilder = scale(urbilder, model.uscalefacs);
end   

yall = zeros(size(urbilder,1), length(model.models));

% Calculate output for all models of the ensemble
for i=1:length(model.models)
    if isempty(model.subspaces)
        % Use all variables as input for model i
        yall(:,i) = calc(model.models{i}, urbilder);
    else
        % Use only a subset of the input variables for model i (subspace) 
        yall(:,i) = calc(model.models{i}, full(urbilder(:,model.subspaces{i})));
    end      
end 

% Bring output back to original scaling
if ~isempty(model.bscalefac)
    %yall = (yall+1)/2.0*model.bscalefac(2) + model.bscalefac(1);
    yall = yall*model.bscalefac(2) + model.bscalefac(1);
end

% Do the ensemble averaging or adding (in case of summing)

if isempty(model.weights)
    if model.summing
        y = sum(yall,2);   
    else
        if model.robust
            y = median(yall,2);
        else
            y = mean(yall,2);    
        end
    end
else
    if model.summing
        ws = 1.0;
    else
        ws = sum(model.weights);
    end
    
    if model.robust & ~model.summing
        y = weightedmedian(yall, model.weights(:)');
    else
        y = sum(yall .* repmat(model.weights, size(yall,1), 1), 2) / ws;
    end   
end

