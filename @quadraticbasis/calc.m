function [y, yall]  = calc(model, urbilder)

% [y, yall] = calc(model, urbilder)
%
% Christian Merkwirth 2002

uscalefacs = get(model.ensemble, 'uscalefacs');

if (~isempty(urbilder)) & (~isempty(uscalefacs))
    urbilder = scale(urbilder, uscalefacs);
end   

models = get(model.ensemble, 'models');

yall = zeros(size(urbilder,1), length(models));

% Calculate output for all models of the ensemble
for i=1:length(models)
    yall(:,i) = calc(models{i}, qbasisexpand(urbilder));
end 

bscalefac = get(model.ensemble, 'bscalefac');

% Bring output back to original scaling
if ~isempty(bscalefac)
    %yall = (yall+1)/2.0*model.bscalefac(2) + model.bscalefac(1);
    yall = yall*bscalefac(2) + bscalefac(1);
end

y = mean(yall,2);    
