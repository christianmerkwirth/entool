


load K:\Projekte\ApplMPI\Roche\results\first_dataset_fhdt902_all\fhtd_gc.mat


sampleweights = ones(size(y));

topology = [2 8];

epsilon = 0.0;
nr_epochs = 150;
lossmode = 2;
weightinit = 0.3;
stepinit = 0.1;
weightdecay =  0.5 / length(y);
weightlimit = 3.0;
verbose = 1;

[net, offset, yh, trainerr] = perceptron_train(x, y, topology, [nr_epochs epsilon lossmode weightinit stepinit weightdecay weightlimit], ...
    sampleweights, verbose);

z = perceptron_calc(x, net, offset, 1);

subplot(1,3,1)

plot(y+0.05*randn(size(y)), yh, '.')
title('percetron_train')

subplot(1,3,2)
semilogy(trainerr)
title('training error')

subplot(1,3,3)
roc3(y,z)


binary_classification_error(y,z);




