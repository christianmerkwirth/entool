function [ym,y] = evalmulti(varargin)

% [ym,y] = evalmulti(models, urbilder)
% [ym,y] = evalmulti(models, urbilder, weights)
% [ym,y] = evalmulti(metamodels, models, urbilder)
% [ym,y] = evalmulti(metamodels, models, urbilder, weights)
%
% Evaluate several models on the same data set, average over the
% results. The models can be of heterogeneous type.
%
% ym - weighted mean of outputs
% y - matrix containing all outputs, size is #observations by #models
%
% Christian Merkwirth 2002 

if (isnumeric(varargin{end}) & isnumeric(varargin{end-1})) 
   weights = varargin{end}; 
   weights = weights(:)';
   urbilder = varargin{end-1};
   N = nargin-2;
else
   urbilder = varargin{end};
   weights = [];
	N = nargin-1;
end   

for j=N:(-1):1
   y = [];
   models = varargin{j};

	for i=1:length(models)
      y(:,end+1) = calc(models{i}, urbilder);
   end   
   
	urbilder = y;   
end

if isempty(weights)
   ym = mean(y,2);
else
   ym = sum(y .* repmat(weights, size(y,1), 1), 2) / sum(weights);
end


