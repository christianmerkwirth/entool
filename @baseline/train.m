function [model, trainerr] = train(model, urbilder, bilder, sampleclass, trainparams, eps, varargin)

% function [model, trainerr] = train(model, urbilder, bilder, sampleclass, trainparams, eps, (sampleweights))
%
%
% Christian Merkwirth 2002

global entooldrawit

if isempty(trainparams)
   trainparams = get(model, 'trainparams');
end

nr_samples = length(bilder);

[indtrain, indtest] = dissemble(sampleclass, nr_samples);

if nargin > 6
    sampleweights = varargin{1};
else
    sampleweights = ones(nr_samples,1);
end

f = inline('mean(loss(bilder,alpha * ones(size(bilder)), eps, mode).*sampleweights)', 'alpha', 'bilder', 'eps', 'mode', 'sampleweights');

opt = optimset;
opt.maxiter = 1000;

[z, trainerr] = fminbnd(f, min(bilder), max(bilder), [], bilder(indtrain), eps, trainparams.errormode, sampleweights(indtrain));

model.a = z;
model.trainparams = trainparams;
model.eps = eps;
