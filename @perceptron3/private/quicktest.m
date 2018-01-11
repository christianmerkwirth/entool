
x = randn(200, 5);
y = 3 * sin(0.1 * (x(:,2) + 0.2 * x(:,3))) + x(:,4);

x = scale(x);
y = 0.75 * scale(y);

sampleweights = ones(size(y));

topology = [8 8];

epsilon = 0.2;
nr_epochs = 150;
lossmode = 1;
weightinit = 0.3;
stepinit = 0.1;
weightdecay =  0.5 / length(y);
weightlimit = 3.0;
verbose = 1;


[net, offset, yh, trainerr] = perceptron_train(x, y, topology, [nr_epochs epsilon lossmode weightinit stepinit weightdecay weightlimit], ...
    sampleweights, verbose);

z = perceptron_calc(x, net, offset, 1);

subplot(1,3,1)
plot(y,yh, '.')
title('percetron_train')

subplot(1,3,2)
semilogy(trainerr)
title('training error')

subplot(1,3,3)
plot(yh, z, '.')
title('perceptron_calc vs. percetron_train')

relepsinloss(yh,z)

