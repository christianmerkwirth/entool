function [z, testflag, zall] = outoftraincalc(model, varargin)

% [z, testflag, zall] = outoftraincalc(model, urbilder)
%
% Calculate the output of the ensemble for the input data set, but only
% average over those samples that were in the left-out part of the input
% data while training one of the models for the ensemble.
%
% To avoid that not all samples are actually test samples, check testflag
% for containing all ones. An entry of zero in testflag indicates that the
% output z was taken from training samples and therefore might result in 
% overly optimistic error rates when used for validation.
%
% Christian Merkwirth MPI 2002

if nargin < 2
    urbilder = model.urbilder;
else
    urbilder = varargin{1};    
end

s = sum(model.sampleclasses,2);
testflag = double(s > 0);

[z,zall] = calc(model, urbilder);

indno = find(s == 0);
s(indno) = 1;       % avoid division by zero
z = sum(zall.*model.sampleclasses, 2) ./ s;

% difficult : if there are no test samples for one row of z, use
% training samples to compute mean
z(indno) = mean(zall(indno,:), 2);

