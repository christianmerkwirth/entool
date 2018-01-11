function [z0, zperm, testflag] = variable_importance(model, varargin)

% [z0, zperm, testflag] = variable_importance(model, nr_repetitions)
%
% Estimate variable importance for ensemble model 'model' by method 1
% as proposed by L.Breiman in:
% WALD LECTURE II
% LOOKING INSIDE THE BLACK BOX
%
% For z0, the output of the ensemble for the input data set is calculated,
% but average is only taken over those samples that were in the left-out part of the input
% data while training one of the models for the ensemble.
%
% For the d-th column of zperm, the output is calculated as stated above,
% but with d-th input variable randomly permuted. To estimate the
% importance of d-th variable, one now could use error(zperm(:,d)) -
% error(z0).
%
% The second input argument nr_repetitions gives the number of repetions of
% this method. By default, it is set to one.
%
% To avoid that not all samples are actually test samples, check testflag
% for containing all ones. An entry of zero in testflag indicates that the
% output arguments z0 and zperm were partially taken from training samples and are therefore might not
% be a good estimator for the test error.

% Christian Merkwirth MPI 2002

global entooldrawit


if nargin>1
    nr_repetitions = varargin{1};
else
    nr_repetitions = 1;
end

s = sum(model.sampleclasses,2);
testflag = double(s > 0);

if ~all(testflag)
   disp('Warning: Not all samples of input data set are covered by at least one test set!') 
end

[N,D] = size(model.urbilder);

% Calculate out-of-train output on not-permuted data set
[dummy, zm] = calc(model, model.urbilder);

indno = find(s == 0);
s(indno) = 1;       % avoid division by zero
z0 = sum(zm.*model.sampleclasses, 2) ./ s;

% Now caculate ensemble output with d-th variable permuted

zperm = zeros(N, D);

for d=1:D
    z = [];
    for r=1:nr_repetitions
        u = model.urbilder;
        u(:,d) = u(randperm(size(u,1)), d);    
    
        [dummy, zm] = calc(model, u);
        z(:, r) = sum(zm.*model.sampleclasses, 2) ./ s;
    end    
        
    zperm(:,d) = mean(z, 2);
    if entooldrawit
        disp(d)
    end
end

    
    
    
    
