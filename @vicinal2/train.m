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

if nargin > 6
    sampleweights = varargin{1};
else
    sampleweights = ones(nr_samples,1);
end  

[indtrain, indtest] = dissemble(sampleclass, nr_samples);

nr_train = length(indtrain);
nr_test = length(indtest);

% Limits for the number of nearest neighbors

klimit = ceil(0.7*nr_train);

if length(model.kmax) == 1
    krange = (1:min(model.kmax, klimit))+1;
else
    krange = (min(model.kmax(1), klimit):min(model.kmax(2), klimit))+1;
end

model.kmax = [min(krange) max(krange)];

D = size(urbilder,2);       % dimension of inputs

tiny = 1e-10;

model.trainparams = trainparams;
model.eps = eps;

if D > 1
    model.metric = fastmutinfo(ranktransform(urbilder(indtrain,:)), ranktransform(bilder(indtrain)));
else
    model.metric = 1.0;
end
model.dataset = urbilder(indtrain,:) .*(ones(nr_train,1) * model.metric);
model.images = bilder(indtrain);
model.searcher = nn_prepare(model.dataset, model.metricclass);

% Determine optimal number of neighbors
model.k = max(krange);

errs = [];
yh = [];

[nn, d, querypoints] = calcnn(model, [], trainparams.approximate);

counterj = 1;
counteri = 1;

if model.linear
    lrange = [1e-2 * (exp(0:0.05:0.5)-0.99)];
else
    lrange = 0; % 
end
    
for l=lrange
    for k=krange
        y = calcoutput(model, nn(:,1:k), d(:,1:k), querypoints, l);
        errs(counteri, counterj) = relepsinloss(model.images, y, eps, sampleweights(indtrain));
        yh(:, counteri, counterj) = y; 
        
        counteri = counteri + 1;
    end   
    counteri = 1;
    counterj = counterj + 1;
end

[dummy, ind] = min(errs(:));
[i,j] = ind2sub(size(errs), ind);

k = krange(i);
l = lrange(j);

model.lambda = l;
model.k = k;

if entooldrawit
    subplot(1,2,1)
    plot(model.images, yh(:,i,j), '.');
    subplot(1,2,2)
    if length(lrange) == 1
        plot(krange, errs)
    else
        imagesc(errs); colorbar; 
    end
    drawnow
end
