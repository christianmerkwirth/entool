% Demo script for learning a simple two-dimensional function,
% the user can choose between Matlab's peaks function and the
% ramp-hill function.
%
% Christian Merkwirth

% Turn on visualization of learning progress
global entooldrawit
entooldrawit = 1;

close all

f1 = figure;
set(gcf, 'Position', [ 461   421   562   285]);
f2 = figure;
set(gcf, 'Position', [ 461    37   560   308 ]);

%problem = 'peaks';
problem = 'ramp';

noise = randn(20000,1);
noise2 = randn(20000, 5);

add_noisy_dimensions = 0;

Nbegin = 26;		% Start with this number of randomly placed observations
Nlimit = 200;		% Do active learning until this number of observations is reached

urbilder = 2*rand(Nbegin,2)-1;

if add_noisy_dimensions
    urbilder = [urbilder noise2(1:size(urbilder,1),:)];
end

while 1
    switch(lower(problem))
        case 'peaks'
            X = urbilder(:,1)*3;
            Y = urbilder(:,2)*3;

            Z = peaks(X,Y);

            [bilder, imagescalefactors] = scale(Z(:));
        case 'ramp'
            [dummy, bilder] = ramp_hill(urbilder(:,1), urbilder(:,2));
    end

    % Add noise to the observations
    sb = std(bilder);
    no =  0.4 * noise(1:length(bilder));
    sn = std(no);
    %disp(sb/sn)
    bilder = bilder + no;

    if entooldrawit
        figure(f1);
    end

    ens = crosstrainensemble;
    enstrainparams = get(ens, 'trainparams');

    if size(urbilder, 1) < Nlimit
        enstrainparams.use_models = 0.85;		% While learning, generate big ensemble to include many model types
    end

    enstrainparams.modelclasses = {  'perceptron', [], {} ; };
    ens = train(ens, urbilder, bilder, [], enstrainparams, 0.05);

    switch(lower(problem))
        case 'peaks'
            [x0, y0, z0] = peaks;

            urcomp = [x0(:) y0(:)]/3;
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
        urcomp = [urcomp noise2(1:size(urcomp,1),:)];
    end

    [zm, z] = calc(ens, urcomp);

    figure(f2)

    subplot(1,2,1)
    %surf(x0, y0, reshape(zm, size(x0)))
    mesh(x0, y0, reshape(zm, size(x0)))
    hold on
    plot3(urbilder(:,1), urbilder(:,2), bilder, 'k*')
    hold off
    axis tight
    rotate3d on


    subplot(1,2,2)
    mesh(x0, y0, reshape(zm-zcomp, size(x0)))
    axis equal
    %plot(zcomp(:), zm(:), '.');

    generrs = [];

    for i=1:size(z,2)
        generrs(i) = relepsinloss(zcomp(:), z(:,i),0.0);
    end

    generrensemble = relepsinloss(zcomp(:), zm,0.0);

    disp(' ')
    disp(['Size of data set                         : ' num2str(length(bilder))])
    disp(['Mean of individual generalization errors : ' num2str(mean(generrs))])
    disp(['Best individual generalization error     : ' num2str(min(generrs))])
    disp(['Ensemble generalization error            : ' num2str(generrensemble)])

    set(gcf, 'Name', ['Sample size ' num2str(length(bilder))])
    drawnow

    urnew = [];

    if length(bilder) < Nlimit
        for outer=1:3
            x = 2*rand(100,size(urbilder,2))-1;

            [zm, z] = calc(ens, x);

            % Select new points according to variance of models

            s = std(z,0,2);

            [dummy,ind] = sort(-s);
            urnew = [urnew ; x(ind(1:2),:)];

        end
        urbilder = [urbilder; urnew];
    else
        break
    end
end

subplot(1,2,2)
surf(x0, y0, reshape(zcomp(:), size(x0)))
axis tight


