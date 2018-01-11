function [model, trainerr] = train(model, urbilder, bilder, sampleclass, trainparams, eps, varargin)

global entooldrawit

if isempty(trainparams)
    trainparams = get(model, 'trainparams');
end

nr_samples = size(urbilder,1);

[indtrain, indtest] = dissemble(sampleclass, nr_samples);

nr_train = length(indtrain);
nr_test = length(indtest);

if nargin > 6
    sampleweights = varargin{1};
    sampleweights = sampleweights(:);
else
    sampleweights = ones(nr_samples,1);
end

sw_train = sampleweights(indtrain); % sample weights for training samples

% Only use training samples to derive scaling factors
[x, model.uscalefacs] = scale(urbilder(indtrain,:)); x = x * 0.75;

if ~trainparams.dont_scale_outputs
    [y, model.bscalefac] = scale(bilder(indtrain)); y = y * 0.75;

    % Scale epsilon accordingly
    eps = 0.75 * eps / model.bscalefac(2);
else
    y = bilder(indtrain);
    model.bscalefac = [];
end

%disp(trainparams);

% Give training parameters as long vector
params = [trainparams.maxiter eps trainparams.errormode ...
        trainparams.initweights trainparams.initialstepsize trainparams.weightdecay  ...
         trainparams.weightlimit];

[model.net, model.offset, yh, trainerr] = perceptron_train(x, y, model.nr_hidden_neurons, ...
    params, sw_train, trainparams.verbose); 
 
% Fill in standard model fields
model.trainparams = trainparams;
model.eps = eps;

if entooldrawit      
    yh = calc(model, urbilder);
    subplot(1,2,1)
    plot(bilder(indtrain), yh(indtrain), '.') 
    hold on
    if nr_test
        plot(bilder(indtest), yh(indtest), 'r.') 
    end 
    hold off   
    subplot(1,2,2)
    semilogy(trainerr)
    drawnow
end  
