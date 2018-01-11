function atria=vicinal2(varargin)

% model=vicinal2(kmax, metricclass, kerneltype, linearflag)
%
% Input arguments:
% kmax - Maximal number of nearest neighbors (
% metricclass - 'man' (L_1 norm), 'eucl' (L_2 norm), 'max' (L_infinity norm)
% kerneltype = [0...3] : 0 results in weights that are independend of distance to neighbors,
% 1 means a weighting linear to the neighbor distance is applied, 2 results
% in a biquadratic weighting 
% 
%
% vicinal2 class of entool toolbox
%
% Provides a k-nearest neighbor model that 
% 
%
% Christian Merkwirth

switch(randsel(1:3))
   case 1
      atria.metricclass = 'eucl';		
   case 2
      atria.metricclass = 'max';
   case 3
      atria.metricclass = 'man';
end
   
atria.searcher = {};
atria.dataset = [];
atria.images = [];
atria.metric = [];
atria.kmax = randsel(5:20);
atria.k = [];
atria.trainparams = {};
atria.type = randsel([(0:3) 0.5]);		
atria.eps = 0.0;
atria.lambda = 0.001;   % ridge penalty parameter
atria.linear = 0;       % if set to one we will train a local linear model

if nargin >= 1
   atria.kmax = varargin{1};
end
if nargin >= 2
   atria.metricclass = varargin{2};
end
if nargin >= 3
   atria.type = varargin{3};
end
if nargin >= 4
   atria.linear = varargin{4};
end

atria = class(atria, 'vicinal2');


