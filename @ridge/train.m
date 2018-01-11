function [model, trainerr] = train(model, urbilder, bilder, sampleclass, trainparams, eps, varargin)

% function [model, trainerr] = train(model, urbilder, bilder, sampleclass, trainparams, eps, (sampleweights))
%
%
% Christian Merkwirth 2003

global entooldrawit

if isempty(trainparams)
    trainparams = get(model, 'trainparams');
end

nr_train = length(bilder);

if nargin > 6
    sampleweights = varargin{1};
end  

[indtrain, indtest] = dissemble(sampleclass, nr_train);

nr_train = length(indtrain);
nr_test = length(indtest);

coeff = [];

trainerr = [];
testerr = [];

if nargin > 6
    [model.coefficients, model.mx, sd, gcverrs, optimallambda, model.yloo] = svdridge(urbilder(indtrain,:), bilder(indtrain), ...
        model.lambda, model.svdcutoff, eps, sampleweights(indtrain));
else
    [model.coefficients, model.mx, sd, gcverrs, optimallambda, model.yloo] = svdridge(urbilder(indtrain,:), bilder(indtrain), ...
        model.lambda, model.svdcutoff, eps);
end

% Integrate mx into offset 
model.coefficients(end) = model.coefficients(end) - model.mx * model.coefficients(1:(end-1));
model.mx = [];

originallambda = model.lambda;
model.lambda = optimallambda;
model.trainparams = trainparams;
model.eps = eps;

if entooldrawit      
    z = calc(model, urbilder);
    
    subplot(1,2,1)
    plot(bilder(indtrain), z(indtrain), '.')
    hold on
    if nr_test
        plot(bilder(indtest), z(indtest), 'r.')
    end   
    hold off
    subplot(1,2,2)
    if eps < 0
        plot(originallambda, -gcverrs)
        ylabel('LOO-AUC')
    else
        plot(originallambda, gcverrs)
        ylabel('GCV Error')
    end
    xlabel('\lambda')
    title('Generalized LOO Cross Validation')
    
    drawnow       
end   
