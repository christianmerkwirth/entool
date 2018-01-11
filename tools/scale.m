function [y, scalefactors] = scale(x, varargin)

% [y, scalefactors] = scale(x)
% y = scale(x, scalefactors)
% 
% Scales each column of input x to [-1 1].
% 
% If scalefactors are passed as second input argument,
% the result may not be within [-1 1].
%
% Anyway, the following will hold:
%
% [y, scalefactors] = scale(x);
% z = scale(x, scalefactors);
% all(all(z == y))
% 1
%
%
% If an optinal last argument mode is given and set to 1,
% the data set is centered is normalized to standard deviation 1.
%
% [y, scalefactors] = scale(x, [], 1)
%
% Christian Merkwirth 2002

mode = 0;   % == 0 scale to [-1 1], ==1 center and normalize columns

N = size(x, 1);

if nargin > 1
    scalefactors = varargin{1};
    
    if isempty(scalefactors) && (nargin > 2) && (varargin{2} == 1)
        scalefactors(1,:) = mean(x);
        scalefactors(2,:) = std(x); 
        scalefactors(2,find(scalefactors(2,:) == 0)) = inf;
    end
else
    scalefactors(2,:) = 0.5*(max(x) - min(x));
    scalefactors(1,:) = min(x) + scalefactors(2,:);
    scalefactors(2,find(scalefactors(2,:) == 0)) = inf;
end



y = x - repmat(scalefactors(1,:), N,1);
y = y ./ repmat(scalefactors(2,:), N,1);

y(:,find(scalefactors(2,:) == inf)) = 0;
