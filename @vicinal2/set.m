function model = set(model, param, value)

% function model = set(model, param, value)
%
%
% Christian Merkwirth 2002

switch(lower(param))
	case 'k'
      model.k = value;
   case 'type'
      model.type = value;
   case 'metric'
      model.metric = value;
   case 'searcher'
      model.searcher = value;
   case 'dataset'
      model.dataset = value;
   case 'images'
      model.images = value;
 	case 'trainparams'
   	model.trainparams = value;
   case 'eps'
      model.eps = value;
   otherwise
      warning(['Parameter ' param ' is not element of class vicinal'])
end

