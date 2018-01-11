function value = get(model, param)

% function value = get(model, param)
%
% Assess properties of baseline object.
%
% Christian Merkwirth 2002

value = [];

switch(lower(param))
 	case 'trainparams'
   	value = model.trainparams;
       
      if isempty(value)
         value.optional = {};	
         value.errormode = 0;   % 0 : eps-ins square loss, 1: eps-ins quad loss 2: binary classification loss
      end
	case 'eps'
      value = model.eps;
   otherwise
      warning(['Parameter ' param ' is not element of class linear'])
end
