function value = get(model, param)

% function value = get(model, param)
%
% Assess properties of linear object.
%
% Christian Merkwirth 2002

value = [];

switch(lower(param))
 	case 'trainparams'
   	value = model.trainparams;
       
      if isempty(value)
        value.maxiter = 250;      % total number of training iterations (epochs)
        value.errormode = 0;       % ==0 : epsilon insensitive squared loss, == 1 : epsilon insensitive absolute loss
        
        value.weightdecay = 0.000001;    % weight decay paramter
        value.dont_scale_outputs = 0;       % when set to one, outputs won't be scaled prior to training
        
        % Parameters for iRPROP
        
        value.initweights = 0.3;
        value.initialstepsize = 0.001;        % when is stochastic gradient descent mode, this value is used for mu
        value.minstepsize = 1e-6;
        value.maxstepsize = 0.05;
        value.nplus = 1.2;
        value.nminus = 0.5;                 % when is stochastic gradient descent mode, this value is used for muminus
        value.weightlimit = 2.0;            % not used at all in the moment
        
        value.verbose = 0;          % set to one for verbose output of training mex function
      end
	case 'eps'
      value = model.eps;
   otherwise
      warning(['Parameter ' param ' is not element of class linear'])
end
