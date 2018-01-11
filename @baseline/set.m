function model = set(model, param, value)

% function model = set(model, param, value)
%
%
% Christian Merkwirth 2002

switch(lower(param))
 	case 'trainparams'
   	model.trainparams = value;
   case 'eps'
      model.eps = value;
   otherwise
      warning(['Parameter ' param ' is not element of class baseline'])
end

