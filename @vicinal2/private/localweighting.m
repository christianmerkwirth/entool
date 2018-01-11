function [z,w] = localweighting(y, nn, d, degree)

% function [z,w] = localweighting(y, nn, d, degree)
%
% Christian Merkwirth 2002

if nargin < 4
	degree = 2;   
end

tiny = 1e-12;

N = size(nn,1);
k = size(nn,2)-1;

D = d(:,1:k) ./ ((d(:,end)+tiny)*ones(1,k)) ;    % avoid dividing by zero
D = 1-D.^degree;
w = D.^degree + tiny;
w = w ./ (sum(w,2)* ones(1, k));

if size(nn,1) == 1
   y = y';
end

z = sum(y(nn(:,1:k)) .* w, 2);
