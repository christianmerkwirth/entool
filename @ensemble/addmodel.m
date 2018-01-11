function model = addmodel(model, m, varargin)

% function model = addmodel(model, newmodel, (newmodelweight), (newmodelerror), (subspace))
% 
% Add model m to ensemble
%
% Christian Merkwirth 2002

if iscell(m)
   % If m is a cell array, it should just contain several models inside this
   % so called "cluster"
   
   for i=1:length(m)
      model.models{end+1} = m{i};
      
   	if nargin > 2
			model.weights(end+1) = varargin{1};
		end
		if nargin > 3
			model.errors(end+1) = varargin{2};
      end
      if nargin > 4
			model.subspaces{end+1} = varargin{3};
		end
   end   
else
   model.models{end+1} = m;
      
   if nargin > 2
		model.weights(end+1) = varargin{1};
	end

	if nargin > 3
		model.errors(end+1) = varargin{2};
   end
   if nargin > 4
		model.subspaces{end+1} = varargin{3};
	end
end   
   

