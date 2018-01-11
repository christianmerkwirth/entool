function model=strip(model)

% function model=strip(model)
%
% Strip information about training dataset to 
% reduce memory consumption of model.
% 
% This affects the method outoftraincalc,
% which however can be still used with supplying
% the original training dataset as additional argument.
% 
% % Instead of :
% z = outoftraincalc(model);
% % one has to use now :
% z = outoftraincalc(model, urbilder);
% % urbilder must be exactly the same matrix as given for training "model"
%
% Christian Merkwirth MPI 2003

model.urbilder = [];
model.bilder = [];
