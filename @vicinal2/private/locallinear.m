function [z,w] = locallinear(y, x, nn, d, degree, xnew, lambda)


% function [z,w] = locallinear(y, x, nn, d, degree, xnew, lambda)
%
% Christian Merkwirth 2002

if nargin < 4
	degree = 2;   
end

[N,p] = size(x);

X = [x ones(N,1)];

tiny = 1e-12;

N = size(nn,1);
k = size(nn,2)-1;

D = d(:,1:k) ./ ((d(:,end)+tiny)*ones(1,k)) ;    % avoid dividing by zero
D = 1-D.^degree;
w = D.^degree + tiny;
w = w ./ (sum(w,2)* ones(1, k));

z = zeros(size(nn,1),1);

lambda = lambda * diag([ones(1,p) 0]);

for i=1:size(nn,1)
%     X(nn(i,1:k),:)
%     y(nn(i,1:k))
%     w(i,1:k)
%     xnew(i,:)
    
    beta = localridge(X(nn(i,1:k),:), y(nn(i,1:k)), w(i,1:k), lambda);
    z(i) = [xnew(i,:) 1] * beta;
end

function beta = localridge(X,y, w, lambda)

beta = inv(X' * diag(w) * X + lambda) * X' * diag(w)  * y(:);
