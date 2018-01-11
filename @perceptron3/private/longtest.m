% Demo script for learning a simple two-dimensional function,
% the user can choose between Matlab's peaks function and the
% ramp-hill function.
% 
% Christian Merkwirth 2002

% Turn on visualization of learning progress
global entooldrawit 
entooldrawit = 1;

N = 200;			% number of observations available for training

noiselevel = 0.2;

problem = 'peaks';
%problem = 'ramp';

add_noisy_dimensions = 1;

switch(lower(problem))
    case 'peaks' 
        X = 6 * rand(N,1) - 3;
        Y = 6 * rand(N,1) - 3;
        
        Z = peaks(X,Y);
        
        [urbilder, preimagescalefactors] = scale([X(:) Y(:)]);
        [bilder, imagescalefactors] = scale(Z(:));
    case 'ramp'
        [urbilder, bilder] = ramp_hill(N);
end   

if add_noisy_dimensions
    urbilder = [urbilder triangle_rand(size(urbilder,1),5)];
end

% Add noise to the observations
bilder = bilder + noiselevel * std(bilder) * randn(size(bilder));

eps = 0.05;

ens = crosstrainensemble;    %  cvensemble;   % 
enstrainparams = get(ens, 'trainparams');
enstrainparams.weight_models = 0;
enstrainparams.nr_cv_partitions = 20;

ptp = get(perceptron3, 'trainparams');
ptp.maxiter = 300;
ptp.weightdecay = 0.005 / length(bilder);
ptp.weightlimit = 4.0;
ptp.errormode = 0;

enstrainparams.modelclasses = { 'perceptron3',  ptp,  {[12 12 12]} ;   };       

ens = train(ens, urbilder, bilder, [], enstrainparams, eps); 

clf

switch(lower(problem))
    case 'peaks'
        [x0, y0, z0] = peaks;
        
        urcomp = scale([x0(:) y0(:)], preimagescalefactors);
        zcomp = scale(z0(:), imagescalefactors);
        
        M = size(urcomp,1);
        x0 = reshape(urcomp(:,1), sqrt(M),sqrt(M));
        y0 = reshape(urcomp(:,2), sqrt(M),sqrt(M));
        
        
    case 'ramp'
        [urcomp, zcomp] = ramp_hill;
        
        M = size(urcomp,1);
        x0 = reshape(urcomp(:,1), sqrt(M),sqrt(M));
        y0 = reshape(urcomp(:,2), sqrt(M),sqrt(M));
end

if add_noisy_dimensions
    urcomp = [urcomp triangle_rand(size(urcomp,1),5)];
end

[zm, z] = calc(ens, urcomp);

subplot(2,2,1)
%surf(x0, y0, reshape(zm, size(x0)))
mesh(x0, y0, reshape(zm, size(x0)))
hold on
plot3(urbilder(:,1), urbilder(:,2), bilder, 'k*')
hold off
axis tight
rotate3d on

generrs = [];

for i=1:size(z,2)
    generrs(i) = relepsinloss(zcomp(:), z(:,i),0.0);
end

generrensemble = relepsinloss(zcomp(:), zm,0.0);

disp(['Mean of individual generalization errors ' num2str(mean(generrs))])
disp(['Best individual generalization error ' num2str(min(generrs))])
disp(['Ensemble generalization error ' num2str(generrensemble)])


subplot(2,2,2)
surf(x0, y0, reshape(zcomp(:), size(x0)))
axis tight
rotate3d on


improvement = [];

for i=1:size(z,2)
    improvement(i) = relepsinloss(zcomp(:), mean(z(:,1:i),2),0.0);
end


subplot(2,2,3)
plot(improvement)
hold on
plot([1 size(z,2)], [mean(generrs) mean(generrs)], 'k');
plot([1 size(z,2)], [min(generrs) min(generrs)], 'm');
legend('Ensemble', 'Mean individual', 'Best individual')
title('Improvement with increasing number of ensemble members')
ylabel('Generalization error');
hold off
