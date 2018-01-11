function traits = create_traits

% function traits = create_traits
%
% Create default traits structure. 
%
% Each statistical learning model type has its own characteristics or
% traits. This structure tries to describe the traits of a model type by
% several fields :
%
% 
%
%
%
%
%
% Christian Merkwirth 2004


traits.can_return_cv_error = 0;     % if set to 1, a model type can return a validated error on the training data set by issuing
                                    % yvalidated = calc(model, []);
                                    
traits.deterministic_training = 1;  % if set to 1, a model type will always produce the same model when trained repeatedly on exactly
                                    % the same data set. Neural networks  models with random weight initialization don't have this feature,
                                    % while SVMs usually have this.
                                    
traits.nonlinear = 0;
trait.time_complexity = 'log(N)*N*D*D'; % time-complexity of training with respect to number of samples N and dimension of samples D

