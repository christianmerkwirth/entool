
global entooldrawit
entooldrawit = 1;


load K:\Projekte\ApplMPI\Roche\results\first_dataset_fhdt902_all\fhtd_gc.mat


topology = [2 8];

ctp = get(cvensemble, 'trainparams');
ptp = get(perceptron3, 'trainparams');

ptp.errormode = 2;
ptp.weightinit = 0.3;
ptp.stepinit = 0.1;
ptp.weightdecay =  1 / length(y);
ptp.weightlimit = 3.0;
ptp.verbose = 0;
ptp.dont_scale_outputs = 1;
ptp.maxiter = 800;

ctp.scaledata = 0;
ctp.nr_cv_partitions = 50;
ctp.modelclasses = {'perceptron3', ptp, {topology}; };  % 'ridge', [], {0:1:32}
ctp.frac_test  = 0.1
epsilon = 0.0;

ens = train(cvensemble, x, y, [], ctp, eps);

z = outoftraincalc(ens);

subplot(1,2,1)

plot(y+0.05*randn(size(y)), z, '.')
title('percetron_train')


subplot(1,2,2)
roc3(y,z)


binary_classification_error(y,z);




